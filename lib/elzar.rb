require 'elzar/version'
require 'elzar/template'
require 'elzar/assistant'

module Elzar
  ROOT_DIR = File.expand_path File.dirname(__FILE__) + '/../'
  CHEF_DIR = "#{ROOT_DIR}/chef"

  def self.templates_dir
    @templates_dir ||= "#{ROOT_DIR}/lib/elzar/templates"
  end

  def self.create_provision_directory(destination, options={})
    Assistant.create_user_provision_dir destination.to_s, options[:local]
    Assistant.generate_files destination.to_s, options
  end

  def self.merge_and_create_temp_directory(user_dir)
    Assistant.merge_and_create_temp_directory user_dir
  end

  def self.vagrant_cookbook_paths
    # order matters
    [
     "#{CHEF_DIR}/cookbooks",
     "#{CHEF_DIR}/site-cookbooks",
    ]
  end

  def self.vagrant_roles_path
    "#{CHEF_DIR}/roles"
  end
end
