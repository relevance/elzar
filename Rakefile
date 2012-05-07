require "bundler/gem_tasks"

desc "Creates provision/ for local vagrant use"
task :bam do
  $:.unshift 'lib'
  require 'elzar'
  Elzar.create_provision_directory File.dirname(__FILE__) + '/provision', :local => true
end

desc "Run Rspec tests"
task :spec do
  sh 'rspec spec'
end

task :default => :spec
