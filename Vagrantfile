# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "apscommode/macos-10.15"
  config.vm.box_version = "10.15.1"
  config.vm.network "private_network", ip: "192.168.85.72"
  config.vm.synced_folder ".", "/Users/Shared/vagrant", type: "rsync",
    owner: "vagrant", group: "staff",
    rsync__exclude: ".git/"
end

