require 'elzar'
require 'bahia'

Dir['spec/support/**/*.rb'].each do |support_file|
  require File.expand_path(support_file)
end

Bahia.project_directory = File.expand_path('../..', __FILE__)

RSpec.configure do |config|
  config.filter_run_excluding :disabled => true
  config.filter_run_excluding :ci => true
  config.run_all_when_everything_filtered = true

  config.alias_example_to :fit, :focused => true
  config.alias_example_to :xit, :disabled => true
  config.alias_example_to :they

  config.include Bahia, :ci => true
  config.include ShellInteractionHelpers, :ci => true
end
