require 'spec_helper'
require 'fileutils'

describe Elzar::AwsConfig do
  let(:aws_config) do
    <<-YAML
      server:
        creation_config:
          :flavor_id: 'm1.large'
          :image_id: "ami-fd589594"
          :groups: default
          :key_name: relevance_aws
    YAML
  end

  let(:private_aws_config) do
    <<-YAML
      aws_credentials:
        :aws_access_key_id: AKIAIQZWXGD2S56W2MMQ
        :aws_secret_access_key: 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

      server:
        private_key: |
          -----BEGIN RSA PRIVATE KEY-----
          SecretsSecretsSecretsSecretsSecretsSecretsSecretsSecretsSecretsSecrets
          SecretsSecretsSecretsSecretsSecretsSecretsSecretsSecretsSecretsSecrets
          SecretsSecretsSecretsSecretsSecretsSecretsSecretsSecretsSecretsSecrets
          -----END RSA PRIVATE KEY-----
    YAML
  end

  context '.load_configs' do
    def create_configs_at(path)
      FileUtils.mkdir_p path
      File.open(File.join(path, 'aws_config.yml'), 'w') { |f| f << aws_config }
      File.open(File.join(path, 'aws_config.private.yml'), 'w') { |f| f << private_aws_config }
    end

    def cleanup_configs(path)
      %w(aws_config.yml aws_config.private.yml).each do |base|
        full_path = File.join(path, base)
        FileUtils.rm(full_path) if File.exist?(full_path)
      end
    end

    after do
      cleanup_configs '/tmp/elzar'
      cleanup_configs '/tmp/elzar-specified'
    end

    it 'trys to load config files in the DEFAULT_CONFIG_DIR if no config_directory specified' do
      stub_const 'Elzar::AwsConfig::DEFAULT_CONFIG_DIR', '/tmp/elzar'
      create_configs_at '/tmp/elzar'

      config = Elzar::AwsConfig.load_configs
      config['aws_credentials'].should_not be_nil
    end

    it 'trys to load config files in config_directory if specified' do
      create_configs_at '/tmp/elzar-specified'

      config = Elzar::AwsConfig.load_configs '/tmp/elzar-specified'
      config['aws_credentials'].should_not be_nil
    end

    it 'does a deep merge of the configuration files' do
      create_configs_at '/tmp/elzar'
      config = Elzar::AwsConfig.load_configs '/tmp/elzar'

      config['server']['creation_config'][:flavor_id].should == 'm1.large'
      config['server']['private_key'].should match(/Secrets/)
    end

    it 'raises an error if it was unable to find the configuration files' do
      expect do
        Elzar::AwsConfig.load_configs '/tmp/nothing-to-see-here'
      end.to raise_error(Elzar::AwsConfig::ConfigFileNotFound)
    end
  end


end
