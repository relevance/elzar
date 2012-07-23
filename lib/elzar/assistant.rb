require 'fileutils'
require 'tmpdir'
require 'elzar/chef_dna'

module Elzar
  module Assistant
    CHEF_SOLO_DIR = '/tmp/chef-solo'

    def self.generate_files(dest, options={})
      vm_host_name = options[:app_name] ?
        "#{options[:app_name].gsub('_','-')}.local" : "elzar.thinkrelevance.com"
      Template.generate 'Vagrantfile', dest, :vm_host_name => vm_host_name,
        :cookbook_paths => cookbook_paths(dest), :local => options[:local]
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

    def self.merge_and_create_temp_directory(application_chef_assets_dir)
      chef_staging_area = Dir.mktmpdir
      stage_elzar_chef_assets(chef_staging_area)
      merge_chef_assets(application_chef_assets_dir, chef_staging_area)
      generate_solo_rb(chef_staging_area)
      chef_staging_area
    end

    private

    def self.cookbook_paths(chef_staging_area)
      %w[elzar-cookbooks elzar-site-cookbooks cookbooks site-cookbooks].select do |path|
        File.exist?("#{chef_staging_area}/#{path}")
      end
    end

    def self.generate_local_files(dest)
      stage_elzar_chef_assets(dest)
      generate_solo_rb(dest)
    end

    def self.stage_elzar_chef_assets(dest)
      cp_r "#{Elzar::CHEF_DIR}/roles",          "#{dest}/roles"
      cp_r "#{Elzar::CHEF_DIR}/cookbooks",      "#{dest}/elzar-cookbooks"
      cp_r "#{Elzar::CHEF_DIR}/site-cookbooks", "#{dest}/elzar-site-cookbooks"
    end

    def self.merge_chef_assets(src, dest)
      cp_r "#{src}/.", dest
    end

    def self.generate_user_files(dest, options={})
      if options[:authorized_keys]
        create_authorized_key_data_bag(options[:authorized_keys], dest)
      end
      if options[:app_name] && options[:database] && options[:ruby_version]
        create_dna_json(dest, *options.values_at(:app_name, :database, :ruby_version))
      end
    end

    def self.generate_solo_rb(dest)
      Template.generate "solo.rb", dest, :cookbook_paths => cookbook_paths(dest), :chef_solo_dir => CHEF_SOLO_DIR
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
