#!/bin/bash
gem list -d chef | grep "0.10.2"
OLD_CHEF_INSTALLED=$?
if [ $OLD_CHEF_INSTALLED -eq 0 ]
then
    gem install chef -v '=0.10.8' --no-ri --no-rdoc
    gem uninstall chef -v '<0.10.8'
fi
