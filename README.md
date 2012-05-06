# Getting Started

Download and install VirtualBox (as instructed in the Vagrant
[Getting Started guide](http://vagrantup.com/docs/getting-started/index.html)). Then set up
your bundle and grab the Ubuntu Lucid VM image.

    gem install bundler
    # creates provision/ for local vagrant use
    rake bam
    cd provision
    bundle install
    vagrant box add lucid64 http://files.vagrantup.com/lucid64.box

## Spin up a new VM

    vagrant up

## SSH into the VM

    vagrant ssh

## Destroy the VM

    vagrant destroy

## Re-run Chef recipes on the VM

    vagrant provision

## Stop/Start the VM

    vagrant suspend
    vagrant resume

# Install additional cookbooks

This script (and the knife extension it invokes) automatically creates a
vendor branch for tracking upstream git sources, merges the cookbook into the
cookbooks/ directory, and makes it easy to update these cookbook as needed in
the future.

To use this script, the cookbook must be in its own git repository, like those
at https://github.com/cookbooks/.

    ./script/install_cookbook cookbooks/mysql
