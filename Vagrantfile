# -*- mode: ruby -*-
# vi: set ft=ruby :
#
# Environment variables may be used to control the behavior of the Vagrant VM's
# defined in this file. This is intended as a special-purpose affordance and
# should not be necessary in normal situations. In particular, nfs-server and
# nfs-server-<platform>, use the same IP address by default, creating a
# potential IP conflict. If there is a need to run multiple server instances
# simultaneously, avoid the IP conflict by setting the ALTERNATE_IP environment
# variable:
#
#     ALTERNATE_IP=192.168.42.9 vagrant up nfs-server-enterprise
#
# NOTE: The client VM instances assume the server VM is accessible on the
# default IP address, therefore using an ALTERNATE_IP is not expected to behave
# well with client instances.
#
if not Vagrant.has_plugin?('vagrant-vbguest')
  abort <<-EOM

vagrant plugin vagrant-vbguest is required.
https://github.com/dotless-de/vagrant-vbguest
To install the plugin, please run, 'vagrant plugin install vagrant-vbguest'.

  EOM
end

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.synced_folder ".", "/vagrant", type: "virtualbox"

  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--memory", "512"]
  end

  config.vm.define "nfs-server", primary: true, autostart: true do |server|
    server.vm.box = 'centos/7'
    server.vm.hostname = 'nfs-server.example.com'
    server.vm.network :private_network, ip: ENV['ALTERNATE_IP'] || '192.168.42.10'
    server.vm.provision :shell, :path => "vagrant/provision.sh"
    # EL7 acting as a server must specify this option
    server.vm.provision :shell, :inline => "echo 'nfs::idmap::idmapd_service_ensure: running' >> /etc/puppetlabs/code/environments/production/hieradata/common.yaml"
    server.vm.provision :shell, :inline => "puppet apply /vagrant/examples/server.pp"
    server.vm.provision :shell, :inline => "echo 'testing if /mnt/test/nfs_works exists'; test -f /mnt/test/nfs_works"
  end

  # This system is meant to be started without 'nfs-server' running.
  config.vm.define "nfs-server-el6", autostart: false do |server|
    server.vm.box = "centos/6"
    server.vm.hostname = 'nfs-server.example.com'
    server.vm.network :private_network, ip: ENV['ALTERNATE_IP'] || '192.168.42.10'
    server.vm.provision :shell, :path => "vagrant/provision.sh"
    server.vm.provision :shell, :inline => "puppet apply /vagrant/examples/server.pp"
    server.vm.provision :shell, :inline => "echo 'testing if /mnt/test/nfs_works exists'; test -f /mnt/test/nfs_works"
  end

  config.vm.define "el7-client", autostart: true do |client|
    client.vm.box = "centos/7"
    client.vm.hostname = 'el7-client.example.com'
    client.vm.network  :private_network, ip: "192.168.42.11"
    client.vm.provision :shell, :path => "vagrant/provision.sh"
    client.vm.provision :shell, :inline => "puppet apply /vagrant/examples/client.pp"
    client.vm.provision :shell, :inline => "echo 'testing if /mnt/test/nfs_works exists'; test -f /mnt/test/nfs_works"
  end

  config.vm.define "el6-client", autostart: false do |client|
    client.vm.box = "centos/6"
    client.vm.hostname = 'el6-client.example.com'
    client.vm.network  :private_network, ip: "192.168.42.12"
    client.vm.provision :shell, :path => "vagrant/provision.sh"
    client.vm.provision :shell, :inline => "puppet apply /vagrant/examples/client.pp"
    client.vm.provision :shell, :inline => "echo 'testing if /mnt/test/nfs_works exists'; test -f /mnt/test/nfs_works"
  end

  config.vm.define "solaris10-client", autostart: false do |client|
    client.vm.box = "tnarik/solaris10-minimal"
    client.vm.hostname = 'solaris10-client.example.com'
    client.vm.network  :private_network, ip: "192.168.42.13"
    client.vm.provision :shell, :path => "vagrant/provision_solaris.sh"
    client.vm.provision :shell, :inline => "puppet apply /vagrant/examples/client.pp"
    client.vm.provision :shell, :inline => "echo 'testing if /mnt/test/nfs_works exists'; test -f /mnt/test/nfs_works"
  end

  config.vm.define "solaris11-client", autostart: false do |client|
    client.vm.box = "plaurin/solaris-11_3"
    client.vm.hostname = 'solaris11-client.example.com'
    client.ssh.password = "1vagrant"
    client.vm.network  :private_network, ip: "192.168.42.14"
    client.vm.provision :shell, :path => "vagrant/provision_solaris.sh"
    client.vm.provision :shell, :inline => "puppet apply /vagrant/examples/client.pp"
    client.vm.provision :shell, :inline => "echo 'testing if /mnt/test/nfs_works exists'; test -f /mnt/test/nfs_works"
  end

  config.vm.define "sles11-client", autostart: false do |client|
    client.vm.box = "elastic/sles-11-x86_64"
    client.vm.hostname = 'sles11-client.example.com'
    client.vm.network  :private_network, ip: "192.168.42.15"
    client.vm.provision :shell, :path => "vagrant/provision_suse.sh"
    client.vm.provision :shell, :inline => "puppet apply /vagrant/examples/client.pp"
    client.vm.provision :shell, :inline => "echo 'testing if /mnt/test/nfs_works exists'; test -f /mnt/test/nfs_works"
  end

  config.vm.define "sles12-client", autostart: false do |client|
    client.vm.box = "elastic/sles-12-x86_64"
    client.vm.hostname = 'sles12-client.example.com'
    client.vm.network  :private_network, ip: "192.168.42.16"
    client.vm.provision :shell, :path => "vagrant/provision_suse.sh"
    client.vm.provision :shell, :inline => "puppet apply /vagrant/examples/client.pp"
    client.vm.provision :shell, :inline => "echo 'testing if /mnt/test/nfs_works exists'; test -f /mnt/test/nfs_works"
  end
end
