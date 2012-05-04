require 'erb'

module Elzar
  module Template
    class << self; attr_accessor :source_directory, :destination_directory; end
    self.source_directory = File.dirname(__FILE__) + '/templates'
    self.destination_directory = '.'

    def self.generate_to_file(file, ivars={})
      str = generate(file, ivars)
      File.open(destination_directory + "/#{file}", 'w+') {|f| f.write str }
    end

    def self.generate(file, ivars={})
      file = source_directory + "/#{file}.erb"
      ERB.new(File.read(file)).result(create_template_binding(ivars))
    end

    def self.create_template_binding(ivars)
      obj = Object.new
      ivars.each {|name, val| obj.instance_variable_set("@#{name}", val) }
      obj.instance_eval { binding }
    end
  end
end
