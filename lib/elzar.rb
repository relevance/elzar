require 'elzar/version'
require 'elzar/template'
require 'elzar/assistant'
require 'multi_json'

module Elzar
  ROOT_DIR = File.expand_path File.dirname(__FILE__) + '/../'
  # order matters
  COOKBOOK_DIRS = ['site-cookbooks', 'cookbooks']

  def self.templates_dir
    @templates_dir ||= "#{ROOT_DIR}/lib/elzar/templates"
  end

  def self.create_provision_directory(destination, options={})
    Assistant.create_user_provision_dir destination.to_s
    Assistant.generate_files destination.to_s, options
  end

  def self.merge_and_create_temp_directory(user_dir)
    Assistant.merge_and_create_temp_directory user_dir
  end

  def self.vagrant_cookbooks_path
    COOKBOOK_DIRS.map {|dir| "#{ROOT_DIR}/#{dir}" }
  end

  def self.vagrant_roles_path
    "#{ROOT_DIR}/roles"
  end
end
