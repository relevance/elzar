#
# Cookbook Name:: ruby
# Recipe:: default
#
# Copyright 2012, Relevance
#
# All rights reserved - Do Not Redistribute

include_recipe "build-essential"

packages = value_for_platform(
    ["centos","redhat","fedora"] => {'default' => ['readline-devel', 'openssl-devel', 'patch']},
    "default" => ['libssl-dev', 'libreadline5-dev', 'libyaml']
  )

packages.each do |pkg|
  package pkg
end

remote_file "/tmp/ruby-#{node[:ruby][:version]}.tar.gz" do
  source "#{node[:ruby][:url]}.tar.gz"
  not_if { ::File.exists?("/tmp/ruby-#{node[:ruby][:version]}.tar.gz") }
end

directory '/opt/ruby' do
  recursive true
  user 'root'
  group 'root'
  mode '0644'
end

bash "Install Ruby" do
  cwd "/tmp"
  code <<-EOH
  tar zxf ruby-#{node[:ruby][:version]}.tar.gz
  cd ruby-#{node[:ruby][:version]}
  ./configure --prefix=/opt/ruby
  ./make
  ./make install
  EOH
  not_if do
    ::File.exists?("#{node[:ruby][:install_path]}/bin/ruby") &&
    %x("#{node[:ruby][:install_path]}/bin/ruby -e "puts \"#{RUBY_VERSION}-p#{RUBY_PATCHLEVEL}\"") == node[:ruby][:version]
  end
end
