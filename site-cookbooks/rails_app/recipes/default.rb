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

cookbook_file "/etc/sudoers" do
  source 'sudoers'
  owner 'root'
  group 'root'
  mode '0440'
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
  content data_bag_item('deploy','authorized_keys')['keys'].join("\n")
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
  notifies :reload, resources(:service => "nginx"), :immediately
end

gem_package "mysql"
mysql_database "#{node[:rails_app][:name]}_#{node[:rails_app][:rails_env]}" do
  connection({:host => 'localhost', :username => 'root', :password => node['mysql']['server_root_password']})
  action :create
end
