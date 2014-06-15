VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "centos64-x86_64-20140116"
  config.vm.box_url = "https://github.com/2creatives/vagrant-centos/releases/download/v6.4.2/centos64-x86_64-20140116.box"

  config.vm.provider :virtualbox do |v|
    v.memory = 1024
  end

  config.vm.define "gpdb-chef" do |gpdb|
    gpdb.vm.hostname = "gpdb-chef"
    gpdb.vm.provider :virtualbox do |v|
      v.name = "greenplum-base-chef"
    end

    gpdb.vm.network :private_network, ip: "192.168.2.13"

    gpdb.vm.provision :shell, inline: "yum update -y"
    gpdb.vm.provision :shell, inline: "curl -s -L https://www.opscode.com/chef/install.sh | bash"
    gpdb.vm.provision "chef_solo" do |chef|
      chef.custom_config_path = "custom_chef_config.rb"

      chef.add_recipe "greenplum"
    end
  end

end
