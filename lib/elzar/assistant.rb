require 'fileutils'
require 'tmpdir'

module Elzar
  module Assistant
    ELZAR_DIR = 'elzar'
    CHEF_SOLO_DIR = '/tmp/chef-solo'

    class InvalidDnaError < StandardError
      def initialize(line, line_number)
        super "Invalid configuration in dna.json:#{line_number} - #{line.strip}"
      end
    end

    class << self
      def generate_files(dest, options={})
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

      def create_user_provision_dir(dest, options={})
        dna = options[:dna] || 'rails' # TODO be better than this

        FileUtils.mkdir_p dest
        cp "#{Elzar.templates_dir}/gitignore", "#{dest}/.gitignore"
        cp "#{Elzar.templates_dir}/.rvmrc", dest
        cp "#{Elzar.templates_dir}/aws_config.yml", dest
        cp "#{Elzar.templates_dir}/aws_config.private.yml", dest
        cp "#{Elzar.templates_dir}/dna/#{dna}.json", "#{dest}/dna.json"
        cp "#{Elzar.templates_dir}/Gemfile", dest
        cp "#{Elzar.templates_dir}/README.md", dest
        cp "#{Elzar.templates_dir}/upgrade-chef.sh", dest
        cp_r "#{Elzar.templates_dir}/data_bags", dest
        cp_r "#{Elzar.templates_dir}/script", dest
        cp_r "#{Elzar.templates_dir}/.chef", dest
      end

      def merge_and_create_temp_directory(user_dir)
        validate_dna! "#{user_dir}/dna.json"

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

      def validate_dna!(dna_file_path)
        lines = File.readlines(dna_file_path)
        lines.each_with_index do |line, line_number|
          raise InvalidDnaError.new(line, line_number + 1) if line.match(/TODO/)
        end
      end

      private

      def generate_local_files(dest)
        generate_solo_rb dest
        cp_r Elzar::ROLES_DIR, dest
        cp_r "#{Elzar::CHEF_DIR}/cookbooks", dest
        cp_r "#{Elzar::CHEF_DIR}/site-cookbooks", dest
      end

      def generate_user_files(dest, options={})
        if options[:authorized_keys]
          create_authorized_key_data_bag(options[:authorized_keys], dest)
        end
      end

      def generate_solo_rb(dest, additional=[])
        dirs = Elzar::COOKBOOK_DIRS.map {|dir| "#{CHEF_SOLO_DIR}/#{dir}" }
        Template.generate "solo.rb", dest, :cookbook_path => dirs + additional,
          :chef_solo_dir => CHEF_SOLO_DIR
      end

      def cp(*args)
        FileUtils.cp(*args)
      end

      def cp_r(*args)
        FileUtils.cp_r(*args)
      end

      def create_authorized_key_data_bag(authorized_keys, dest)
        data_bag_dir = "#{dest}/data_bags/deploy"
        FileUtils.mkdir_p data_bag_dir
        File.open("#{data_bag_dir}/authorized_keys.json", 'w+') do |f|
          f.write MultiJson.dump("id" => "authorized_keys", "keys" => authorized_keys)
        end
      end
    end

  end
end
