require 'spec_helper'
require 'fileutils'
require 'json'

describe "Rails integration", :ci => true do
  let(:rails_app)         { 'elzar_nightly_app' }
  let(:path_to_rails_app) { File.join '/tmp', rails_app }
  let(:server_name)       { "Elzar Nightly (rails) - #{Time.now.strftime("%Y-%m-%d %H:%M:%S")}" }
  let(:aws_config_dir)    { ENV['AWS_CONFIG_DIR'] || raise('You must set AWS_CONFIG_DIR to run the integration tests') }
  let(:instance_info)     { { :id => nil, :ip => nil } }

  ######################################################################
  # Command line helpers
  ######################################################################

  # wrapper around system
  def shell(cmd)
    puts "Executing #{cmd}..."
    Bundler.clean_system(cmd)
    abort "Command '#{cmd}' failed" unless $?.success?
  end

  def elzar(args)
    puts "Running `elzar #{args}`"

    super

    raise "Error running `elzar #{args}`. Failed with: #{stderr}" unless process.exitstatus == 0
  end

  def rake(cmd)
    sh "bundle exec rake #{cmd}"
  end

  def in_rails_app(&block)
    pwd = FileUtils.pwd
    FileUtils.cd path_to_rails_app
    yield
  ensure
    FileUtils.cd pwd
  end

  ######################################################################
  # Rails app helpers
  ######################################################################

  def create_new_rails_app
    shell "gem install rails"
    FileUtils.rm_rf(path_to_rails_app)
    rails_template = File.expand_path('../../fixtures/rails_integration_template/template.rb', __FILE__)
    shell %Q{rails new "#{path_to_rails_app}" -d postgresql -m "#{rails_template}"}
  end

  def configure_elzar
    in_rails_app do
      rewrite_json('provision/dna.json') do |dna|
        dna['rails_app']['name'] = rails_app
      end
    end
  end

  def rewrite_json(path_to_json, &block)
    json = JSON.parse File.read(path_to_json)
    yield json
    File.open(path_to_json, 'w') { |f| f << JSON.generate(json) }
  end

  ######################################################################
  # AWS helpers
  ######################################################################

  def aws_config
    @aws_config ||= Elzar::AwsConfig.load_configs(aws_config_dir)
  end

  def fog
    @fog ||= Fog::Compute.new(aws_config['aws_credentials'].merge(:provider => 'AWS'))
  end

  def server(instance_id)
    fog.servers.get(instance_id).tap do |s|
      s.private_key = aws_config['server']['private_key']
    end
  end

  def ssh(server, cmd)
    job = nil
    capture_stdout { job = server.ssh(cmd).first }
    job
  end

  def put_database_config_on_server(server)
    shared_path = "/var/www/apps/#{rails_app}/shared/config"
    path_to_db_config = File.expand_path('../../fixtures/rails_integration_template/database.yml', __FILE__)
    server.scp path_to_db_config, "/home/ubuntu/database.yml"

    ssh server, "sudo mkdir -p #{shared_path}"
    ssh server, "sudo mv ~/database.yml #{shared_path}/database.yml"
    ssh server, "sudo chown -R deploy:deploy #{shared_path}"
  end

  def destroy_instance(instance_id)
    in_rails_app do
      elzar "destroy \"#{instance_id}\" --aws_config_dir=#{aws_config_dir}"
    end
  end

  def capture_instance_details(output)
    id = output.match(/Instance ID: (.+)$/i)[1]
    ip = output.match(/Instance IP: (.+)$/i)[1]
    [id, ip]
  end

  ######################################################################
  # Assertion helpers
  ######################################################################

  # Returns true if the command gives zero exit status, false for non zero exit status.
  def execute_local_command(cmd)
    Bundler.clean_system(cmd)
  end

  # Returns true if the command gives zero exit status, false for non zero exit status.
  def execute_remote_command(server, cmd)
    ssh(server, cmd).status == 0
  end

  def assert_state_after_init
    in_rails_app do
      execute_local_command('ls provision > /dev/null').should == true
      execute_local_command('grep -q rails provision/dna.json').should == true
    end
  end

  def assert_state_after_preheat(server)
    execute_remote_command(server, 'gem list | grep chef').should == true
  end

  def assert_state_after_cook(server)
    execute_remote_command(server, '/opt/relevance-ruby/bin/ruby -v | grep 1\.9\.3').should == true
    execute_remote_command(server, 'sudo service postgresql status').should == true
    execute_remote_command(server, 'sudo service nginx status').should == true
    execute_remote_command(server, 'ls /home/deploy').should == true
  end

  def assert_state_after_deploy(server_ip)
    execute_local_command(%Q{curl -sL -w '%{http_code}' #{server_ip} -o /dev/null | grep 200}).should == true
    execute_local_command(%Q{curl -s #{server_ip}/users.json | grep '"username":"root"'}).should == true
  end

  it 'works' do
    create_new_rails_app

    in_rails_app do
      elzar "init --dna=rails"
    end

    assert_state_after_init

    in_rails_app do
      configure_elzar
      elzar %Q{preheat "#{server_name}" --aws_config_dir=#{aws_config_dir}}
      instance_info[:id], instance_info[:ip] = capture_instance_details(stdout)
    end

    instance_info[:id].should_not == nil
    instance_info[:ip].should_not == nil
    server = server(instance_info[:id])

    assert_state_after_preheat(server)

    in_rails_app do
      elzar "cook \"#{instance_info[:id]}\" --aws_config_dir=#{aws_config_dir}"
    end

    assert_state_after_cook(server)

    in_rails_app do
      shell %Q{SERVER_IP="#{instance_info[:ip]}" cap deploy:setup}
      put_database_config_on_server(server)
      shell %Q{SERVER_IP="#{instance_info[:ip]}" cap deploy}
    end

    assert_state_after_deploy(instance_info[:ip])
  end

  after(:each) do
    destroy_instance(instance_info[:id]) if instance_info[:id]
  end
end
