#!/bin/bash

# using this instead of "rpm -Uvh" to resolve dependencies
function rpm_install() {
    package=$(echo $1 | awk -F "/" '{print $NF}')
    wget --quiet $1
    yum install -y ./$package
    rm -f $package
}

release=$(awk -F \: '{print $5}' /etc/system-release-cpe)

rpm --import http://yum.puppetlabs.com/RPM-GPG-KEY-puppet

yum install -y wget

# install and configure puppet
rpm -qa | grep -q puppet
if [ $? -ne 0 ]
then

    rpm_install https://yum.puppetlabs.com/puppetlabs-release-pc1-el-${release}.noarch.rpm
    yum -y install puppet-agent
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

fi

# Place a file to be found on the client's mount /mnt/test
touch /home/vagrant/nfs_works

# Add nfs server to /etc/hosts
echo "192.168.42.10 nfs-server.example.com nfs-server" >> /etc/hosts

# use local nfs module
puppet resource file /etc/puppetlabs/code/environments/production/modules/nfs ensure=link target=/vagrant

# setup module dependencies
puppet module install puppetlabs/stdlib --version 4.16.0
puppet module install ghoneycutt/rpcbind --version 1.7.0
puppet module install ghoneycutt/common --version 1.7.0
puppet module install ghoneycutt/types --version 1.12.0
