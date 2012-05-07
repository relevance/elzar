## Description
Use this directory to define your app's Chef cookbooks. If you're using relevance\_rails,
your app automatically bundles (Elzar's recipes)[http://github.com/relevance/elzar].

## Usage

First, setup this directory: `cd provision && bundle install`.

To create new cookbooks or install [existing ones](https://github.com/cookbooks):

```sh
# Create a new cookbook
$ script/new_cookbook my_cookbook

# Install any cookbook on github by user/name
$ script/install_cookbook cookbooks/mysql
```

Once you've added a cookbook you need to add the recipe name to the "run_list" key of dna.json.

## Elzar Cookbooks
Although Elzar's cookbooks and roles are automatically bundled, you can override them in cookbooks or
site_cookbooks.

## Vagrant
To provision using Vagrant [see these detailed instructions](https://github.com/relevance/elzar#using-vagrant).
