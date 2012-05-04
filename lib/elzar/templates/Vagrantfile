require 'json'
Vagrant::Config.run do |config|
  config.vm.box       = "lucid64"
  config.vm.box_url   = "http://files.vagrantup.com/lucid64.box"
  config.vm.host_name = "elzar.thinkrelevance.com"
  config.vm.network     "172.25.5.5"
  config.vm.provision :shell, :path => "upgrade-chef.sh"
  config.vm.provision :chef_solo do |chef|
    chef.cookbooks_path = ["site-cookbooks", "cookbooks"]
    chef.roles_path = "roles"
    chef.data_bags_path = "data_bags"
    json = JSON.parse File.read('dna.json')
    chef.run_list = json['run_list']
    chef.json = json
  end
end
