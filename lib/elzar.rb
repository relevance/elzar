require 'elzar/version'
require 'elzar/template'
require 'fileutils'
require 'tmpdir'
require 'multi_json'

module Elzar
  ELZAR_COOKBOOKS_DIR = 'elzar'
  # order matters
  COOKBOOK_DIRS = ['site-cookbooks', 'cookbooks']

  def self.root_dir
    @root_dir ||= File.expand_path File.dirname(__FILE__) + '/../'
  end

  def self.templates_dir
    @templates_dir ||= "#{root_dir}/lib/elzar/templates"
  end

  def self.create_provision_directory(destination, options={})
    create_user_provision_dir destination.to_s
    generate_files destination.to_s, options
  end

  def self.merge_and_create_temp_directory(user_dir)
    dest = Dir.mktmpdir
    elzar_dir = "#{dest}/#{ELZAR_COOKBOOKS_DIR}"
    FileUtils.mkdir_p elzar_dir

    cp "#{templates_dir}/solo.rb", dest
    cp_r "#{root_dir}/roles", dest
    cp_r "#{root_dir}/cookbooks", elzar_dir
    cp_r "#{root_dir}/site-cookbooks", elzar_dir
    # merges user provision with elzar's provision
    cp_r "#{user_dir}/.", dest
    dest
  end

  private

  def self.create_user_provision_dir(dest)
    FileUtils.mkdir_p dest
    cp "#{templates_dir}/dna.json", dest
    cp "#{templates_dir}/Gemfile", dest
    cp "#{root_dir}/.rvmrc", dest
    cp_r "#{root_dir}/data_bags", dest
    cp_r "#{root_dir}/script", dest
  end

  def self.generate_files(dest, options={})
    vm_host_name = options[:app_name] ?
      "#{options[:app_name].gsub('_','-')}.local" : "elzar.thinkrelevance.com"
    cookbooks_path = COOKBOOK_DIRS + COOKBOOK_DIRS.map {|dir| "#{root_dir}/#{dir}" }
    generate 'Vagrantfile', dest, :vm_host_name => vm_host_name,
      :cookbooks_path => cookbooks_path
    if options[:authorized_keys]
      create_authorized_key_data_bag(options[:authorized_keys], dest)
    end
    # TODO
    # :ruby, :database, :gem_version
    # generate_dna_json(options)
  end

  def self.create_authorized_key_data_bag(authorized_keys, dest)
    data_bag_dir = "#{dest}/data_bags/deploy"
    FileUtils.mkdir_p data_bag_dir
    File.open("#{data_bag_dir}/authorized_keys.json", 'w+') do |f|
      f.write MultiJson.dump("id" => "authorized_keys", "keys" => authorized_keys)
    end
  end

  def self.cp(*args)
    FileUtils.cp(*args)
  end

  def self.cp_r(*args)
    FileUtils.cp_r(*args)
  end

  def self.generate(*args)
    Template.generate(*args)
  end
end
