require 'elzar'
require 'elzar/ssh_key_locator'

module Elzar
  module Cli
    class Runner
      def self.run(*args)
        runner = new(*args)
        runner.run
      end

      private

      def notify(msg)
        # TODO chop off only initial indentation level
        puts msg.gsub(/^\s+/,'')
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
        # TODO Enhance to use ssh agent keys if no local keys are found
        Elzar::SshKeyLocator.find_local_keys
      end
    end

    class Preheat < Runner
      attr_reader :instance_name

      def initialize(instance_name, options = {})
        @instance_name = instance_name
        @aws_config_file = options[:aws_config_file]
      end

      def run
        notify "Provisioning an instance..."
        instance_id, instance_ip = Elzar::Compute.provision_and_bootstrap!(instance_name)
        notify <<-MSG
          Finished Provisioning Server
            Instance ID: #{instance_id}
            Instance IP: #{instance_ip}
        MSG
      end
    end

    class Cook < Runner
      attr_reader :instance_id

      def initialize(instance_id, options = {})
        @instance_id = instance_id
        puts @instance_id
      end

      def run
        notify "Cooking..."
        inst_id, inst_ip = Elzar::Compute.converge!(instance_id)
        notify <<-MSG
          Finished Provisioning Server
            Instance ID: #{inst_id}
            Instance IP: #{inst_ip}
        MSG
      end
    end
  end
end
