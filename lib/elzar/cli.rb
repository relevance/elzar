require 'elzar'

module Elzar
  module Cli

    class << self
      def install(options, args)
        options = options.merge(:authorized_keys => find_ssh_keys)
        Elzar.create_provision_directory 'provision', options
        notify <<-MSG
          Created provision/ directory.
          !!! You must go edit provision/dna.json to meet your app's needs !!!
        MSG
      end

      private

      def find_ssh_keys
        # TODO Replace with (tested) logic from ProvisionConfigGenerator
        ['ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAvmJFEIEqQh/hOertDav1G44Sd24gBjyvi/u/idrrPO9uhZj4e+2Hcpkw5Z4Gmco36oD/ycX6r/fur9WJjpYTlQKzqTFMzYE55qN93sQirzNQ59kSa02Qj6DIMIKuK7QZ8h6Au+XcQpRr51ebXe2Qch3CFjb5bh08S8EaStuNM0iTUBMVrRHO/nlmbP7QDqCWy66iTDP0QU2YGYpriVwwg/bOI3RjQF9l0NpKSihYRpECo6qC3QTPIY0U+Vle+pREEjbHaZs9d6txCJWGJqprqW6FWfpr81yETHmI1TSIfZwnjh3bHGWgAEb8XNUfvOIcfgzroVOLcQYqpIdr+gaMdw== jason@jmac']
      end

      def notify(msg)
        puts msg.gsub(/^\s+/,'')
      end
    end

  end
end
