require 'erb'

module Elzar
  module Template
    class << self; attr_accessor :source_directory; end
    self.source_directory = File.dirname(__FILE__) + '/templates'

    def self.generate(file, dest, ivars={})
      str = generate_string(file, ivars)
      File.open("#{dest}/#{file}", 'w+') {|f| f.write str }
    end

    def self.generate_string(file, ivars={})
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
