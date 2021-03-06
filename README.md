## Description

This gem enables a Rails app to define custom Chef recipes while still using an awesome default set
of Chef recipes. Includes recipes for Ruby 1.9, postgresql, and nginx/passenger.

## Usage

To use Elzar with your Rails app, see [USAGE.md](https://github.com/relevance/elzar/blob/master/USAGE.md).

## Local Development

If you'd like to try these Chef cookbooks with Vagrant:

```sh
$ git clone git@github.com:relevance/elzar.git
$ cd elzar
$ gem install bundler

# creates a `provision` directory for local vagrant use
$ rake bam

$ cd provision
$ vim dna.json # edit DNA file to give a name to your Rails app with no whitespace (e.g., "my_sample_app")
$ bundle install

## Using Vagrant

Download and install VirtualBox (as instructed in the Vagrant
[Getting Started guide](http://vagrantup.com/docs/getting-started/index.html)). Then set up
your bundle and grab the Ubuntu Lucid VM image.

    vagrant box add lucid64 http://files.vagrantup.com/lucid64.box

```sh
## Spin up a new VM and run the Chef recipes on it
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

### CLI Development

The CLI tool (bin/elzar) is built on top of [GLI](https://github.com/davetron5000/gli)
which is a command line parser modelled after Git. Normally any
exception that occurs while running a command results in only the error
message being displayed, not the backtrace. If you would like to view
the backtrace you must set the env variable `GLI_DEBUG=true`.

    GLI_DEBUG=true bundle exec bin/elzar foo

## Issues

Please file issues [on GitHub](https://github.com/relevance/elzar/issues).
