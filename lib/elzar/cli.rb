require 'elzar'

module Elzar
  module Cli
    def self.install(options, args)
      Elzar.create_provision_directory 'provision', options
    end
  end
end
