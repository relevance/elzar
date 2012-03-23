#!/bin/bash

if `gem list -d chef | grep "10.2"`
then
    gem install chef -v '=0.10.8' --no-ri --no-rdoc && gem uninstall chef -v '<0.10.8'
fi
