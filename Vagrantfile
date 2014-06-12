Vagrant.configure("2") do |config|
  config.vm.box = "centos64-x86_64-20140116"

  config.vm.provider :virtualbox do |v, override|
    # override.vm.box_url = "http://puppet-vagrant-boxes.puppetlabs.com/centos-64-x64-vbox4210-nocm.box"
    v.memory = 1024
  end

  config.vm.synced_folder "remote", "/var/local"


  config.vm.define :mdw do |mdw_config|
    mdw_config.vm.network :private_network, ip: "192.168.2.11"
    mdw_config.vm.provision :shell, path: "gp.sh"
    mdw_config.vm.provision :shell, path: "gpInstall.sh"
  end

end
