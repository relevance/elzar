#
# Cookbook Name:: ruby
# Recipe:: default
#
# Copyright 2012, Relevance
#
# All rights reserved - Do Not Redistribute

include_recipe "build-essential"
ruby_tarball = "/tmp/ruby-#{node[:ruby][:version]}.tar.gz"
packages = value_for_platform(
    ["centos","redhat","fedora"] => {'default' => ['readline-devel', 'openssl-devel', 'patch']},
    "default" => ['libssl-dev', 'libreadline6-dev', 'libyaml-dev']
  )

packages.each do |pkg|
  package pkg
end

remote_file ruby_tarball do
  source node[:ruby][:url]
  action :create_if_missing
end

directory '/opt/ruby' do
  recursive true
  owner 'root'
  group 'root'
  mode '0755'
end

bash "Compiling and Installing Ruby" do
  cwd "/tmp"
  code <<-EOH
  tar zxf ruby-#{node[:ruby][:version]}.tar.gz
  cd ruby-#{node[:ruby][:version]}
  ./configure --prefix=#{node[:ruby][:install_path]}
  make
  make install
  EOH
  not_if do
    ::File.exists?("#{node[:ruby][:install_path]}/bin/ruby") &&
    `#{node[:ruby][:install_path]}/bin/ruby -e "puts \\"\#{RUBY_VERSION}-p\#{RUBY_PATCHLEVEL}\\""`.chomp == node[:ruby][:version]
  end
end

execute "Installing bundler" do
  command "#{node[:ruby][:install_path]}/bin/gem install bundler"
  not_if "#{node[:ruby][:install_path]}/bin/gem list -l bundler$ | grep -q bundler"
end

execute "Updating rubygems" do
  command "#{node[:ruby][:install_path]}/bin/gem update --system && #{node[:ruby][:install_path]}/bin/gem update --system #{node[:ruby][:gems_version]}"
end
