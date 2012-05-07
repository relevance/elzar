## Description
This gem enables a Rails app to define custom Chef recipes while still using an awesome default set
of Chef recipes. Best used in conjunction with relevance\_rails and slushy. Includes recipes for
ruby 1.9, ree, mysql, postgresql and nginx/passenger.

## Usage

To use Elzar with your Rails app, just use (relevance_rails)[https://github.com/relevance/relevance_rails].

But if you'd like to manually do it:

```ruby
# Creates a provision/ directory to define app-specific cookbooks
Elzar.create_provision_directory 'provision'

# To combine Elzar's cookbooks with your app's cookbooks
dir = Elzar.merge_and_create_temp_directory 'provision'
# You now have a directory you can put on a chef node
```

## Local Development

If you'd like to try these Chef cookbooks with Vagrant:

```sh
$ git clone git@github.com:relevance/elzar.git
$ cd elzar
$ gem install bundler
# creates provision/ for local vagrant use
$ rake bam
$ cd provision
$ bundle install

## Using Vagrant

Download and install VirtualBox (as instructed in the Vagrant
[Getting Started guide](http://vagrantup.com/docs/getting-started/index.html)). Then set up
your bundle and grab the Ubuntu Lucid VM image.

    vagrant box add lucid64 http://files.vagrantup.com/lucid64.box

```sh
## Spin up a new VM
$ vagrant up

## SSH into the VM
$ vagrant ssh

## Destroy the VM
$ vagrant destroy

## Re-run Chef recipes on the VM
$ vagrant provision

## Stop/Start the VM
$ vagrant suspend
$ vagrant resume
```

## Issues

Please file issues [on github](https://github.com/relevance/elzar/issues).
