#
# Cookbook Name:: passenger
# Recipe:: default
#
# Copyright 2012, Relevance
#
# All rights reserved - Do Not Redistribute
#
include_recipe "ruby"
include_recipe "nginx::source"

gem_package "passenger" do
  version node[:passenger][:version]
end

configure_flags = node[:nginx][:configure_flags].join(" ")
nginx_install = node[:nginx][:install_path]
nginx_version = node[:nginx][:version]
nginx_dir = node[:nginx][:dir]

execute "passenger_nginx_module" do
  command %Q{
    #{node[:ruby][:install_path]}/bin/passenger-install-nginx-module \
      --auto --prefix=#{nginx_install} \
      --nginx-source-dir=#{Chef::Config[:file_cache_path]}/nginx-#{nginx_version} \
      --extra-configure-flags='#{configure_flags}'
  }
  not_if "#{nginx_install}/sbin/nginx -V 2>&1 | grep '#{node[:ruby][:gems_dir]}/gems/passenger-#{node[:passenger][:version]}/ext/nginx'"
  notifies :restart, resources(:service => "nginx")
end

template "#{nginx_dir}/conf.d/passenger.conf" do
  source "passenger_nginx.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, resources(:service => "nginx")
end
