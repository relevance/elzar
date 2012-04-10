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
  run_list = node.run_list.map(&:name)
  ruby_path = if run_list.include?('ruby_appstack')
    node[:ruby][:install_path]
  elsif run_list.include?('enterprise_appstack')
    node[:ruby_enterprise][:install_path]
  else
    '/usr/local'
  end
  content "export PATH=#{ruby_path}/bin:$PATH"
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

if node.run_list.include? 'mysql::server'
  gem_package "mysql"
  mysql_database "#{node[:rails_app][:name]}_#{node[:rails_app][:rails_env]}" do
    connection({:host => 'localhost', :username => 'root', :password => node['mysql']['server_root_password']})
    action :create
  end
elsif node.run_list.include? 'role[postgres_database]'
  gem_package 'pg'

  postgres_connection_info = {:host => 'localhost', :username => 'postgres', :password => node['postgresql']['password']['postgres']}

  postgresql_database_user 'deploy' do
    connection postgres_connection_info
    password 'd3pl0y-p0stgr3s'
    action :create
  end

  postgresql_database "#{node[:rails_app][:name]}_#{node[:rails_app][:rails_env]}" do
    connection postgres_connection_info
    action :create
    owner 'deploy'
  end

  template "#{node[:postgresql][:dir]}/pg_hba.conf" do
    mode "0600"
    owner 'postgres'
    group 'postgres'
    notifies :reload, resources(:service => 'postgresql')
  end
end
