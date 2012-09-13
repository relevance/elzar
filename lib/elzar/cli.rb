require 'elzar'
require 'elzar/ssh_key_locator'

module Elzar
  module Cli
    class MissingArgumentsError < StandardError
      def initialize(cmd, arguments)
        super "Required arguments missing (#{arguments.join(', ')})." \
          " Run `elzar help #{cmd}` for more information."
      end
    end

    class Runner
      def self.run(*args)
        runner = new(*args)
        runner.require_arguments!
        runner.run
      end

      def self.required_argument(*arg_names)
        @required_arguments ||= []
        @required_arguments += arg_names
      end

      def self.required_arguments
        @required_arguments || []
      end

      def require_arguments!
        missing_arguments = self.class.required_arguments.select do |arg|
          arg_value = self.instance_variable_get(:"@#{arg}")
          arg_value.to_s.strip.empty?
        end

        raise MissingArgumentsError.new(cmd, missing_arguments) unless missing_arguments.empty?
      end

      private

      def notify(msg)
        # TODO chop off only initial indentation level
        puts msg.gsub(/^\s+/,'')
      end

      def aws_config
        Elzar::AwsConfig.load_configs @aws_config_dir
      end

      def cmd
        self.class.name.split('::').last.downcase
      end


    end

    class Init < Runner
      attr_reader :authorized_keys, :dna

      def initialize(options = {})
        @dna = options[:dna]
      end

      def run
        Elzar.create_provision_directory 'provision', provisioning_options
        notify <<-MSG
          Created provision/ directory.
          !!! You must go edit provision/dna.json to meet your app's needs !!!
        MSG
      end

      private

      def provisioning_options
        {
          :authorized_keys => find_ssh_keys,
          :dna => dna
        }
      end

      def find_ssh_keys
        Elzar::SshKeyLocator.find_local_keys
      end
    end

    class Preheat < Runner
      attr_reader :instance_name

      required_argument :instance_name

      def initialize(instance_name, options = {})
        @instance_name = instance_name
        @aws_config_dir = options[:aws_config_dir]
      end

      def run
        notify "Provisioning an instance..."
        instance_id, instance_ip = Elzar::Compute.provision_and_bootstrap!(instance_name, aws_config)
        notify <<-MSG
          Finished Provisioning Server
            Instance ID: #{instance_id}
            Instance IP: #{instance_ip}
        MSG
      end
    end

    class Cook < Runner
      attr_reader :instance_id

      required_argument :instance_id

      def initialize(instance_id, options = {})
        @instance_id = instance_id
        @aws_config_dir = options[:aws_config_dir]
      end

      def run
        notify "Cooking..."
        inst_id, inst_ip = Elzar::Compute.converge!(instance_id, aws_config)
        notify <<-MSG
          Finished Provisioning Server
            Instance ID: #{inst_id}
            Instance IP: #{inst_ip}
        MSG
      end
    end
  end
end
