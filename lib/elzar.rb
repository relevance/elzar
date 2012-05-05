require 'elzar/version'
require 'elzar/template'
require 'fileutils'

module Elzar
  def self.root_dir
    @root_dir ||= File.expand_path File.dirname(__FILE__) + '/../'
  end

  def self.templates_dir
    @templates_dir ||= "#{root_dir}/lib/elzar/templates"
  end

  def self.provision_dir
    "#{root_dir}/provision"
  end

  def self.bam!(options={})
    options = {:destination => 'provision'}.update options
    # Template.destination_directory = options[:destination]
    create_local_provision_dir provision_dir
    create_remote_provision_dir options[:destination]
  end

  private

  def self.create_local_provision_dir(dest)
    FileUtils.rm_rf dest
    FileUtils.mkdir_p "#{dest}/elzar"

    cp "#{templates_dir}/solo.rb", dest
    cp_r "#{root_dir}/data_bags", dest
    cp_r "#{root_dir}/roles", dest
    cp_r "#{root_dir}/cookbooks", "#{dest}/elzar"
    cp_r "#{root_dir}/site-cookbooks", "#{dest}/elzar"
  end

  def self.create_remote_provision_dir(dest)
    FileUtils.mkdir_p dest
    cp "#{templates_dir}/dna.json", dest
    cp "#{templates_dir}/Gemfile", dest
    cp "#{templates_dir}/Vagrantfile", dest
    cp "#{root_dir}/.rvmrc", dest
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
