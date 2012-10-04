require 'bundler/capistrano'
require 'capistrano/relevance/all'

set :application, "elzar_nightly_app"
set :repository, "/tmp/elzar_nightly_app" # TODO Find a way not to duplicate this path here and inside the spec. Pass as env arg?

set(:server_ip) { ENV['SERVER_IP'] || raise("You must supply SERVER_IP") }

role :web, server_ip
role :app, server_ip
role :db,  server_ip, :primary => true
