require 'elzar/fog'
require 'slushy'
require 'yaml'

module Elzar
  module Compute
    def self.provision_and_bootstrap!(instance_name)
      instance_id, instance_ip = provision(instance_name)
      bootstrap(instance_id)

      [instance_id, instance_ip]
    end

    def self.provision(name)
      conf = config['server']['creation_config']
      conf['tags'] = {'Name' => name}

      slushy = Slushy::Instance.launch(fog_connection, conf)
      [slushy.instance_id, slushy.server.public_ip_address]
    end

    def self.bootstrap(instance_id)
      slushy = Slushy::Instance.new(fog_connection, instance_id)
      slushy.server.private_key = private_key
      slushy.bootstrap
    end

    def self.converge!(instance_id)
      tmpdir = Elzar.merge_and_create_temp_directory File.expand_path('provision/')
      slushy = Slushy::Instance.new(fog_connection, instance_id)
      slushy.converge tmpdir

      [slushy.instance_id, slushy.server.public_ip_address]
    end

    private

    def self.config
      # TODO Allow users of this API to specify the location of the config file
      @config ||= YAML.load File.read('provision/aws_config.yml')
    end

    def self.fog_connection
      @fog_connection ||= Fog::Compute.new(config['aws_credentials'].merge(:provider => 'AWS'))
    end

    def self.private_key
      config['server']['private_key']
    end
  end
end
