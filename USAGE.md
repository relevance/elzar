Elzar Usage
===========

## Rails Tutorial

This example assumes that you have a working Rails application that is
compatible with the default [Rails DNA](/relevance/elzar/tree/master/lib/elzar/templates/dna/rails.json)
included in Elzar.


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
  "run_list":["role[plumbing]", "mysql::server", "role[enterprise_appstack]", "rails_app"],
  "mysql": {"server_root_password": ""},
  "passenger":  {
    "version":  "3.0.11",
    "root_path":  "/opt/relevance-ruby/lib/ruby/gems/1.9.1/gems/passenger-3.0.11",
    "module_path":  "/opt/relevance-ruby/lib/ruby/gems/1.9.1/gems/passenger-3.0.11/ext/apache2/mod_passenger.so"
  },
  "ruby":  {
    "version":  "1.9.3-p125",
    "url":  "http://ftp.ruby-lang.org/pub/ruby/1.9/ruby-1.9.3-p125.tar.gz"
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
    :flavor_id: <instance type, e.g. 'm1.large'>
    :image_id: <ami to bootstrap with. Must be some UBUNTU image. e.g. "ami-fd589594">
    :groups: <security group to place the new deployment in, e.g. "default">
    :key_name: <name of the public/private keypair to start instance with>

# aws_config.private.yml
aws_credentials:
  :aws_access_key_id: <your aws access key id>
  :aws_secret_access_key: <your aws secret access key>

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

```sh
elzar preheat "ElzarRailsExample Staging"
```

In this case, Elzar will provision a new instance and tag it with a name
of "ElzarRailsExample Staging". This is the name that you will see when browsing
instances in the AWS console. Name your instance accordingly.

If this step completes successfully, it will display the ID of the
instance as well as its public IP address. For example:

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
elzar cook i-abcdef01
```

When running this command be sure to use the instance ID returned to you
from the `preheat` command.


### Step 6: Configure Capistrano

At this point in time, we have a server that is ready to run our app.
Now, we just need to get our app up there.

First off, we need to add Capistrano to your Rails app.

```sh
gem install capistrano
capify .
```

Unfortunately, the default Capistrano configs won't get us very far at
all. We'll need to pull in some pretty generic configuration that we use
on most of our applications. See [this commit](https://github.com/relevance/elzar_rails_example/commit/d9e205f80991f07222b86705c4598b01660ebcb9)
for an example of the boilerplate configuration we'll need to get up and
running.
    
Next, we need to specify the IP address of the server we just set up in
`config/deploy.rb`. By default the config looks something like this:

```ruby
role :web, "your web-server here"                          # Your HTTP server, Apache/etc
role :app, "your app-server here"                          # This may be the same as your `Web` server
role :db,  "your primary db-server here", :primary => true # This is where Rails migrations will run
role :db,  "your slave db-server here"
```

Using the IP address that we got from running `elzar preheat` earlier,
our config would look like this:

```ruby
role :web, "42.42.000.42"                   # Your HTTP server, Apache/etc
role :app, "42.42.000.42"                   # This may be the same as your `Web` server
role :db,  "42.42.000.42", :primary => true # This is where Rails migrations will run
```

Notice that we deleted the configuration for the slave DB server since we do
not have one at this time.

### Step 7: Prepare to Serve

Now that we have a working Capistrano configuration we just need to make
a couple of other small tweaks to make the box deployable. Specifically,
we need to create the directory structure that Capistrano expects and
place our database configuration on the box.

It is considered a best practice to not check in any actual database
credential into your Git repo. Alternatively, you check in a
`database.example.yml` file and then manually manage a `database.yml`
file on your target server. See [this example](https://github.com/relevance/elzar_rails_example/commit/3763bba70fd50e2bb04f28cf35412ed208b25852)
for a sample diff.

```sh
cap deploy:setup
ssh deploy@42.42.000.42
mkdir /var/www/apps/elzar_rails_example/shared/config
vim /var/www/apps/elzar_rails_example/shared/config/database.yml
```

Your `database.yml` file should look similar to this one, obviously
edited to meet your applications needs. Be sure you configure `database`
to match the one created by Chef (i.e. `#{rails_app[name]}_production`).

```yaml
production:
  adapter: mysql2
  encoding: utf8
  reconnect: false
  database: elzar_rails_example_production
  pool: 5
  username: root
  password:
```

### Step 8: Serve It Up

Here comes the exiting part. It's time to deploy our Rails app to the
box. Since this is the first time we've ever deployed to the box we'll
need to run a special Capistrano command that does slightly more work
than a bare deploy.

```sh
cap deploy:cold
```

Congratulations! You should be able to visit the IP address using your
favorite browser and see the application up and running.

For subsequent deploys you should just be able to simply run:

```sh
cap deploy
```
