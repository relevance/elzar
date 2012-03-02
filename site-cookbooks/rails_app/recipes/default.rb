#
# Cookbook Name:: rails_app
# Recipe:: default
#
# Copyright 2011, Relevance
#
# All rights reserved - Do Not Redistribute
#

group 'deploy' do
  append true
end

user "deploy" do
  shell "/bin/bash"
  action :create
  group 'deploy'
end

group 'admin' do
  append true
  members ['deploy']
end

directory "/home/deploy" do
  owner 'deploy'
  group 'deploy'
  mode '0755'
end

directory "/home/deploy/.ssh" do
  owner 'deploy'
  group 'deploy'
  mode '0755'
end

file "/home/deploy/.ssh/authorized_keys" do
  all_authorized_keys = Dir[File.expand_path("../../files/default/public_keys/*.pub",__FILE__)]
  content all_authorized_keys.map {|path| File.read(path)}.join
  owner 'deploy'
  group 'deploy'
  mode '0600'
end

directory "/var/www/apps/" do
  recursive true
  owner 'deploy'
  group 'deploy'
  mode '2775'
end

file "/home/deploy/.bashrc" do
  content "export PATH=#{node[:ruby_enterprise][:install_path]}/bin:$PATH"
  owner 'deploy'
  group 'deploy'
  mode '0700'
end

file "/home/deploy/.bash_profile" do
  content 'source "$HOME/.bashrc"'
  owner 'deploy'
  group 'deploy'
  mode '0700'
end

template "#{node[:nginx][:dir]}/sites-enabled/#{node[:rails_app][:name]}" do
  source "rails_app_nginx.erb"
  mode "0440"
  owner "root"
  group "root"
end
