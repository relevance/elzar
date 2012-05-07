require 'fileutils'
require 'tmpdir'
require 'elzar/chef_dna'

module Elzar
  module Assistant
    ELZAR_DIR = 'elzar'
    CHEF_SOLO_DIR = '/tmp/chef-solo'

    def self.generate_files(dest, options={})
      vm_host_name = options[:app_name] ?
        "#{options[:app_name].gsub('_','-')}.local" : "elzar.thinkrelevance.com"
      Template.generate 'Vagrantfile', dest, :vm_host_name => vm_host_name,
        :cookbooks_path => Elzar::COOKBOOK_DIRS, :local => options[:local]
      if options[:local]
        generate_local_files dest
      else
        require 'multi_json'
        generate_user_files dest, options
      end
    end

    def self.create_user_provision_dir(dest, local=false)
      FileUtils.mkdir_p dest
      cp "#{Elzar.templates_dir}/dna.json", dest
      cp "#{Elzar.templates_dir}/Gemfile", dest
      cp "#{Elzar.templates_dir}/upgrade-chef.sh", dest
      cp "#{Elzar.templates_dir}/.rvmrc", dest
      cp "#{Elzar.templates_dir}/README.md", dest
      cp_r "#{Elzar.templates_dir}/data_bags", dest
      cp_r "#{Elzar.templates_dir}/script", dest
      cp_r "#{Elzar.templates_dir}/.chef", dest
    end

    def self.merge_and_create_temp_directory(user_dir)
      dest = Dir.mktmpdir
      elzar_dir = "#{dest}/#{ELZAR_DIR}"
      FileUtils.mkdir_p elzar_dir

      generate_solo_rb dest, Elzar::COOKBOOK_DIRS.map {|dir| "#{CHEF_SOLO_DIR}/#{ELZAR_DIR}/#{dir}" }
      cp_r Elzar::ROLES_DIR, dest
      cp_r "#{Elzar::CHEF_DIR}/cookbooks", elzar_dir
      cp_r "#{Elzar::CHEF_DIR}/site-cookbooks", elzar_dir
      # merges user provision with elzar's provision
      cp_r "#{user_dir}/.", dest
      dest
    end

    private

    def self.generate_local_files(dest)
      generate_solo_rb dest
      cp_r Elzar::ROLES_DIR, dest
      cp_r "#{Elzar::CHEF_DIR}/cookbooks", dest
      cp_r "#{Elzar::CHEF_DIR}/site-cookbooks", dest
    end

    def self.generate_user_files(dest, options={})
      if options[:authorized_keys]
        create_authorized_key_data_bag(options[:authorized_keys], dest)
      end
      if options[:app_name] && options[:database] && options[:ruby_version]
        create_dna_json(dest, *options.values_at(:app_name, :database, :ruby_version))
      end
    end

    def self.generate_solo_rb(dest, additional=[])
      dirs = Elzar::COOKBOOK_DIRS.map {|dir| "#{CHEF_SOLO_DIR}/#{dir}" }
      Template.generate "solo.rb", dest, :cookbook_path => dirs + additional,
        :chef_solo_dir => CHEF_SOLO_DIR
    end

    def self.cp(*args)
      FileUtils.cp(*args)
    end

    def self.cp_r(*args)
      FileUtils.cp_r(*args)
    end

    def self.create_dna_json(dest, app_name, database, ruby_version)
      content = MultiJson.load(File.read("#{Elzar.templates_dir}/dna.json"))
      content['rails_app']['name'] = app_name
      ChefDNA.gene_splice(content, database, ruby_version)
      File.open("#{dest}/dna.json", 'w+') {|f| f.write MultiJson.dump(content) }
    end

    def self.create_authorized_key_data_bag(authorized_keys, dest)
      data_bag_dir = "#{dest}/data_bags/deploy"
      FileUtils.mkdir_p data_bag_dir
      File.open("#{data_bag_dir}/authorized_keys.json", 'w+') do |f|
        f.write MultiJson.dump("id" => "authorized_keys", "keys" => authorized_keys)
      end
    end
  end
end
