require 'yaml'
require 'pathname'

module Elzar
  module AwsConfig

    DEFAULT_CONFIG_DIR = 'provision/'
    CONFIG_FILE = 'aws_config.yml'
    PRIVATE_CONFIG_FILE = 'aws_config.private.yml'

    class ConfigFileNotFound < StandardError
      def initialize(file)
        super "Unable to locate config file: #{file.to_path}"
      end
    end

    class << self
      def load_configs(config_directory = nil)
        config_directory ||= DEFAULT_CONFIG_DIR

        config_file, private_config_file = find_config_files(config_directory)
        read_and_merge_config_files(config_file, private_config_file)
      end

      private

      def find_config_files(config_directory)
        dir = Pathname.new config_directory
        config, private_config = dir.join(CONFIG_FILE), dir.join(PRIVATE_CONFIG_FILE)
        raise_error_unless_files_exist! config, private_config

        [config, private_config]
      end

      def read_and_merge_config_files(base_file, other_file)
        base, other = YAML.load(base_file.read), YAML.load(other_file.read)
        base.deep_merge(other)
      end

      def raise_error_unless_files_exist!(*files)
        files.each { |f| raise ConfigFileNotFound.new(f) unless f.exist? }
      end
    end

  end
end
