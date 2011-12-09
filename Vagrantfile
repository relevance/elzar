Vagrant::Config.run do |config|
  config.vm.box       = "lucid64"
  config.vm.box_url   = "http://files.vagrantup.com/lucid64.box"
  config.vm.host_name = "elzar.thinkrelevance.com"
  config.vm.network     "172.25.5.5"
  config.vm.provision :chef_solo do |chef|
    chef.cookbooks_path = ["site-cookbooks", "cookbooks"]
    chef.roles_path = "roles"
    chef.add_role("rails")
  end
end
