#!/bin/bash

release=$(grep ^CPE_NAME /etc/os-release | awk -F : '{print $5}')

rpm --import http://yum.puppetlabs.com/RPM-GPG-KEY-puppet

rm -f /usr/bin/puppet
for i in erb facter gem hiera irb puppet rake rdoc ri ruby testrb
do
  rm -f /usr/local/bin/$i
done

zypper -n install http://yum.puppetlabs.com/puppetlabs-release-pc1-sles-${release}.noarch.rpm
zypper -n install puppet-agent

ln -s /opt/puppetlabs/puppet/bin/puppet /usr/bin/puppet

cat > /etc/puppetlabs/puppet/hiera.yaml <<EOF
---
version: 5
hierarchy:
  - name: Common
    path: common.yaml
defaults:
  data_hash: yaml_data
  datadir: /etc/puppetlabs/code/environments/production/hieradata
EOF

cat > /etc/puppetlabs/code/environments/production/hieradata/common.yaml <<EOF
---
nfs::mounts:
  /mnt/test:
    device: nfs-server.example.com:/home/vagrant
    options: rw,rsize=8192,wsize=8192
    fstype: nfs
EOF

# Add nfs server to /etc/hosts
echo "192.168.42.10 nfs-server.example.com nfs-server" >> /etc/hosts

# use local nfs module
puppet resource file /etc/puppetlabs/code/environments/production/modules/nfs ensure=link target=/vagrant

# setup module dependencies
puppet module install puppetlabs/stdlib --version 4.16.0
puppet module install ghoneycutt/rpcbind --version 1.7.0
puppet module install ghoneycutt/common --version 1.7.0
puppet module install ghoneycutt/types --version 1.12.0
