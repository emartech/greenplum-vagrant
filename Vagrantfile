VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "centos-20140617-chef"
  config.vm.box_url = "http://bit.ly/boxes_centos-20140714-chef"

  config.vm.define :gpdb do |gpdb|
    gpdb.vm.hostname = "gpdb"
    gpdb.vm.network :private_network, ip: "192.168.2.13"

    gpdb.vm.provider :virtualbox do |v|
      v.memory = 1024
    end

    gpdb.berkshelf.enabled = true
    gpdb.vm.provision :chef_solo do |chef|
      chef.custom_config_path = "custom_chef_config.rb"

      chef.add_recipe "greenplum"
    end
  end

end
