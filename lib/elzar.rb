require 'elzar/version'
require 'elzar/template'
require 'fileutils'

module Elzar
  def self.bam!(options={})
    options = {:destination => 'provision', :authorized_keys => []}.update options
    FileUtils.mkdir_p options[:destination]
    Template.destination_directory = options[:destination]
    root_dir = File.expand_path File.dirname(__FILE__) + '/../'
    templates_dir = "#{root_dir}/lib/elzar/templates"

    cp "#{templates_dir}/solo.rb", options[:destination]
    cp "#{templates_dir}/dna.json", options[:destination]
    cp "#{templates_dir}/Gemfile", options[:destination]
    cp "#{templates_dir}/Vagrantfile", options[:destination]
    cp_r "#{root_dir}/data_bags", options[:destination]
    cp_r "#{root_dir}/cookbooks", options[:destination]
    cp_r "#{root_dir}/site-cookbooks", options[:destination]
    cp "#{root_dir}/.rvmrc", options[:destination]

    # TODO
    # generate_vagrantfile(options[:app_name])
    # :ruby, :database, :gem_version
    # generate_dna_json(options)
    # generate_data_bags
  end

  private

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
