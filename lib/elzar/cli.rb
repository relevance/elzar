require 'elzar'

module Elzar
  module Cli
    def self.install(options, args)
      Elzar.create_provision_directory 'provision', options
      puts 'Created /provision directory'
    end
  end
end
