file_cache_path "/tmp/chef-solo"
data_bag_path   "/tmp/chef-solo/data_bags"
cookbook_path   [ "/tmp/chef-solo/site-cookbooks",
                  "/tmp/chef-solo/cookbooks",
                  "/tmp/chef-solo/elzar/site-cookbooks",
                  "/tmp/chef-solo/elzar/cookbooks"]
role_path       "/tmp/chef-solo/roles"
log_level       :debug
log_location    STDOUT
