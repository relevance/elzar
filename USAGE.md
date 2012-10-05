Elzar Usage
===========

## Rails Tutorial

This example assumes that you have a working Rails application that is
compatible with the default [Rails DNA](/relevance/elzar/tree/master/lib/elzar/templates/dna/rails.json)
included in Elzar.

All commands assume your `RAILS_ROOT` is your current working directory.

### Step 0: Install Elzar

```sh
gem install elzar
```


### Step 1: Initialize Elzar's Provision Directory

This creates a `provision/` directory inside of your project. This
folder will be used to hold configuration data, custom Chef recipes,
and the `dna.json` file which specifies how configuration data to
the Chef recipes themselves.

```sh
elzar init --dna=rails
```


### Step 2: Configure dna.json

The previous command created a `dna.json` template at
`provision/dna.json`. It will look roughly like so:

```javascript
{
  "run_list":["role[plumbing]", "role[postgres_database]", "ruby", "passenger", "rails_app"],
  "passenger":  {
    "version":  "3.0.11",
    "root_path":  "/opt/relevance-ruby/lib/ruby/gems/1.9.1/gems/passenger-3.0.11",
    "module_path":  "/opt/relevance-ruby/lib/ruby/gems/1.9.1/gems/passenger-3.0.11/ext/apache2/mod_passenger.so"
  },
  "ruby":  {
    "version":  "1.9.3-p194",
    "url":  "http://ftp.ruby-lang.org/pub/ruby/1.9/ruby-1.9.3-p194.tar.gz"
  },
  "rails_app":  {
    "name":  "TODO: Replace with the name of your Rails app"
  }
}
```

This file specifies which recipes Chef will run and how they will be
ran. For example, you can edit the `run_list` to run a custom
recipe that you have created or swap out one of the default recipes for
another (e.g. mysql for postgresql).

At the very least you will need to specify `rails_app[name]`. For
example:

```javascript
"rails_app":  {
  "name": "elzar_rails_example"
}
```

The `rails_app[name]` in `dna.json` has several implicit effects:

* It determines where your app lives on the file system (e.g.,
  `/var/www/apps/elzar_rails_example/`)
* It determines the name of your database (e.g.,
  `elzar_rails_example_production`)
* It determines the path of your nginx configuration file (e.g.,
  `/etc/nginx/sites-enabled/elzar_rails_example`)

You'll want to consider how your choice of `rails_app` name will operate
in these contexts (e.g.,  whether your database engine allows
dashes in its database names).


### Step 3: Configure AWS Settings

The `init` command also created 2 separate AWS configuration files:

* `provision/aws_config.yml` - holds non-sensitive settings, which
  you're comfortable checking into Git
* `provision/aws_config.private.yml` - holds (wait for it) private
  settings, which you should **not** check into Git

These files look like so:

```yaml
# aws_config.yml
server:
  creation_config:
    flavor_id: <instance type, e.g. 'm1.large'>
    image_id: <AMI to bootstrap with; must be some Ubuntu server image; e.g., "ami-fd589594" for Ubuntu 11.04>
    groups: <security group to place the new deployment in, e.g. "default">
    key_name: <name of the public/private keypair to start instance with>
```

```yaml
# aws_config.private.yml
aws_credentials:
  aws_access_key_id: <your aws access key id>
  aws_secret_access_key: <your aws secret access key>

server:
  private_key: |
    -----BEGIN RSA PRIVATE KEY-----
    Include the RSA private key here. This should correspond to the keypair indicated
    by server[:creation_config][:key_name] in aws_config.yml.
    -----END RSA PRIVATE KEY-----
```

Elzar will load both of these files and perform a deep merge on them.
Any settings in `aws_config.private.yml` will override settings found in
`aws_config.yml`.

Edit these files as appropriate for your project.


### Step 4: Preheat Your Server

This step will provision a new server from AWS using your specified
credentials and will bootstrap Chef Solo on the box.

Note: **A *new* EC2 instance is provisioned each time this script is
executed**; you'll probably want to clean up those instances if you need
to re-start for any reason.

```sh
elzar preheat "ElzarRailsExample Staging"
```

In this case, Elzar will provision a new instance and tag it with a name
of "ElzarRailsExample Staging". This is the name that you will see when browsing
instances in the AWS console. Name your instance accordingly.

If this step completes successfully, it will display the ID of the
instance, which you'll use in the next step, as well as its public IP address. For example:

```
Finished Provisioning Server
Instance ID: i-abcdef01
Instance IP: 42.42.000.42
````


### Step 5: Cook the Recipes

This step is responsible for combining your custom recipes (if any) and
configuration with the default recipes that ship with Elzar. The
combined payload will be uploaded to the server and placed in
`/tmp/chef-solo` where they will run.


```sh
elzar cook [YOUR-INSTANCE-ID]
```


### Step 6: Configure Capistrano

At this point in time, we have a server that is ready to run our app.
Now, we just need to get our app up there.

First off, we need to add Capistrano and [capistrano-relevance](https://github.com/relevance/capistrano-relevance) to our Rails app.
To do so, add these lines to the `Gemfile` in the Rails application:

```ruby
group :deployment do
  gem 'capistrano', :git => 'git://github.com/capistrano/capistrano', :ref => 'b31e2f5'
  gem 'capistrano-relevance'
end
```

And then execute:

```sh
bundle
bundle exec capify .
```

Next, we need to customize `config/deploy.rb` for our app.
(For the purposes of this tutorial, we'll assume that we want the default capistrano-relevance configuration. For alternative setups, and for more information on capistrano-relevance, check out its [README](https://github.com/relevance/capistrano-relevance/blob/master/README.md).)

*Replace* the existing contents of `config/deploy.rb` with a structure like so:

```ruby
require 'bundler/capistrano'
require 'capistrano/relevance/all'

set :application, "elzar_rails_example"                      # TODO Replace with *your* app name
set :repository,  "git://github.com/you/elzar_rails_example" # TODO Replace with *your* repo

role :web, "42.42.000.42"                                    # TODO Replace with the IP address for *your* EC2 instance
role :app, "42.42.000.42"                                    # TODO Replace with the IP address for *your* EC2 instance
role :db,  "42.42.000.42", :primary => true                  # TODO Replace with the IP address for *your* EC2 instance
```


### Step 7: Prepare to Serve

Now that we have a working Capistrano configuration we just need to make a couple of other small tweaks to make the box deployable.
Specifically, we need to create the directory structure that Capistrano expects and place our database configuration on the box.

Best practices (TM) discourage us from checking in any database credentials into our Git repo.
Instead, we can create a `database.yml` file on the server.

```sh
bundle exec cap deploy:setup

ssh deploy@42.42.000.42

# Create the the directory where you will store your shared configuration.
mkdir /var/www/apps/[YOUR-APP-NAME]/shared/config

# Add production settings for the database
vim /var/www/apps/[YOUR-APP-NAME]/shared/config/database.yml

# We're done messing around on the server; let's get outta here
exit
```

Your `database.yml` file should look similar to this one, obviously edited to meet your application's needs.

```yaml
production:
  adapter: postgresql
  encoding: unicode
  database: [YOUR-APP-NAME]_production
  pool: 5
  username: deploy
  password: d3pl0y-p0stgr3s
```


### Step 8: Serve It Up

Here comes the exciting part.
It's time to deploy our Rails app to the box.
Since this is the first time we've ever deployed to the box we'll need to run a special Capistrano command that does slightly more work than a bare deploy.

```sh
# execute from RAILS_ROOT on your localhost
bundle exec cap deploy:cold
```

Congratulations! You should be able to visit the IP address using your favorite browser and see the application up and running.

For subsequent deploys, you can simply run:

```sh
bundle exec cap deploy
```
