require 'elzar/version'
require 'elzar/template'
require 'fileutils'
require 'tmpdir'

module Elzar
  ELZAR_COOKBOOKS_DIR = 'elzar'

  def self.root_dir
    @root_dir ||= File.expand_path File.dirname(__FILE__) + '/../'
  end

  def self.templates_dir
    @templates_dir ||= "#{root_dir}/lib/elzar/templates"
  end

  def self.create_provision_directory(destination, options={})
    # Template.destination_directory = destination
    create_user_provision_dir destination.to_s
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
    cp "#{templates_dir}/Vagrantfile", dest
    cp "#{root_dir}/.rvmrc", dest
    cp_r "#{root_dir}/data_bags", dest
    cp_r "#{root_dir}/script", dest
  end

  def self.generate_files
    # TODO
    # generate_vagrantfile(options[:app_name])
    # :ruby, :database, :gem_version
    # generate_dna_json(options)
    # generate_data_bags
  end

  def self.cp(*args)
    FileUtils.cp(*args)
  end

  def self.cp_r(*args)
    FileUtils.cp_r(*args)
  end

  def self.generate(*args)
    Template.generate_to_file(*args)
  end
end
