# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "macos-10.13"
  config.vm.network "private_network", ip: "192.168.85.72"
  config.vm.synced_folder ".", "/vagrant", type: "rsync",
    owner: "vagrant", group: "staff",
    rsync__exclude: ".git/"
end

