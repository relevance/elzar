require 'elzar'

module Elzar
  module Cli
    class Runner
      def self.run(*args)
        runner = new(*args)
        runner.run
      end

      private

      def notify(msg)
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
        # TODO Replace with (tested) logic from ProvisionConfigGenerator
        ['ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAvmJFEIEqQh/hOertDav1G44Sd24gBjyvi/u/idrrPO9uhZj4e+2Hcpkw5Z4Gmco36oD/ycX6r/fur9WJjpYTlQKzqTFMzYE55qN93sQirzNQ59kSa02Qj6DIMIKuK7QZ8h6Au+XcQpRr51ebXe2Qch3CFjb5bh08S8EaStuNM0iTUBMVrRHO/nlmbP7QDqCWy66iTDP0QU2YGYpriVwwg/bOI3RjQF9l0NpKSihYRpECo6qC3QTPIY0U+Vle+pREEjbHaZs9d6txCJWGJqprqW6FWfpr81yETHmI1TSIfZwnjh3bHGWgAEb8XNUfvOIcfgzroVOLcQYqpIdr+gaMdw== jason@jmac']
      end
    end

    class Preheat < Runner

      attr_reader :instance_name

      def initialize(instance_name, options)
        @instance_name = instance_name
        @aws_config_file = options[:aws_config_file]
      end

      def run
        notify "Provisioning an instance..."
        instance_id = Elzar::Compute.provision_and_bootstrap!(instance_name)
        notify "Finished Provisioning Server - Instance ID #{instance_id}"
      end
    end
  end
end
