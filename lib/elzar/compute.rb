require 'elzar/fog'
require 'slushy'
require 'yaml'

module Elzar
  module Compute
    def self.provision_and_bootstrap!(instance_name, aws_config)
      instance_id, instance_ip = provision(instance_name, aws_config)
      bootstrap(instance_id, aws_config)

      [instance_id, instance_ip]
    end

    def self.provision(name, aws_config)
      config = aws_config['server']['creation_config']
      config['tags'] = {'Name' => name}

      slushy_instance = Slushy::Instance.launch(fog_connection(aws_config), config)
      [slushy_instance.instance_id, slushy_instance.server.public_ip_address]
    end

    def self.bootstrap(instance_id, aws_config)
      slushy_instance = slushy_instance_for(instance_id, aws_config)
      slushy_instance.bootstrap
    end

    def self.converge!(instance_id, aws_config)
      tmpdir = Elzar.merge_and_create_temp_directory File.expand_path('provision/')
      slushy_instance = slushy_instance_for(instance_id, aws_config)
      slushy_instance.converge tmpdir

      [slushy_instance.instance_id, slushy_instance.server.public_ip_address]
    end

    private

    def self.fog_connection(aws_config)
      @fog_connection ||= Fog::Compute.new(aws_config['aws_credentials'].merge(:provider => 'AWS'))
    end

    def self.slushy_instance_for(instance_id, aws_config)
      Slushy::Instance.new(fog_connection(aws_config), instance_id).tap do |s|
        s.server.private_key = aws_config['server']['private_key']
      end
    end
  end
end
