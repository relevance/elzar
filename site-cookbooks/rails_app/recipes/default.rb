#
# Cookbook Name:: rails_app
# Recipe:: default
#
# Copyright 2011, Relevance
#
# All rights reserved - Do Not Redistribute
#

user "deploy" do
  shell "/bin/bash"
  action :create
end

directory "/home/deploy/.ssh" do
  mode 0600
  recursive true
end

file "/home/deploy/.ssh/authorized_keys" do
  all_authorized_keys = Dir[File.expand_path("../../files/default/public_keys/*.pub",__FILE__)]
  content all_authorized_keys.map {|path| File.read(path)}.join
  mode 0600
end
