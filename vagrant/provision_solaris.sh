#!/bin/bash

ver=$(uname -r)
if [ $ver == '5.10' ]; then
  echo 'System identified as Solaris 10'
  pkg='puppet-agent-1.10.5-1.i386.pkg'
  pkg_suffix='.gz'
  pkg_url='https://pm.puppetlabs.com/puppet-agent/2017.2.3/1.10.5/repos/solaris/10/PC1/puppet-agent-1.10.5-1.i386.pkg.gz'
fi

if [ $ver == '5.11' ]; then
  echo 'System identified as Solaris 11'
  pkg='puppet-agent@1.10.5,5.11-1.i386.p5p'
  pkg_suffix=''
  pkg_url='https://pm.puppetlabs.com/puppet-agent/2017.2.3/1.10.5/repos/solaris/11/PC1/puppet-agent@1.10.5,5.11-1.i386.p5p'
fi

cat > /var/sadm/install/admin/puppet <<EOF
mail=
instance=overwrite
partial=nocheck
runlevel=nocheck
idepend=nocheck
rdepend=nocheck
space=nocheck
setuid=nocheck
conflict=nocheck
action=nocheck
networktimeout=60
networkretries=3
authentication=quit
keystore=/var/sadm/security
proxy=
basedir=default
EOF

if [ ! -f "/vagrant/.puppetagents/${pkg}" ]; then
  echo 'Puppet agent does not exist locally. Downloading.'
  wget $pkg_url -O /vagrant/.puppetagents/${pkg}${pkg_suffix}
fi

if [ $ver == '5.10' ]; then
    if [ -f "/vagrant/.puppetagents/${pkg}${pkg_suffix}" ]; then
      gunzip /vagrant/.puppetagents/${pkg}${pkg_suffix}
    fi

    pkgadd -n -d /vagrant/.puppetagents/${pkg} -a /var/sadm/install/admin/puppet all
fi

if [ $ver == '5.11' ]; then
  echo 'Installing the puppet-agent package could take 20 minutes.'
  time pkg install -g "/vagrant/.puppetagents/${pkg}" puppet-agent
fi

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
echo '192.168.42.10 nfs-server.example.com nfs-server' >> /etc/hosts

# use local nfs module
puppet resource file /etc/puppetlabs/code/environments/production/modules/nfs ensure=link target=/vagrant

# setup module dependencies
puppet module install puppetlabs/stdlib --version 4.16.0
puppet module install ghoneycutt/rpcbind --version 1.7.0
puppet module install ghoneycutt/common --version 1.7.0
puppet module install ghoneycutt/types --version 1.12.0
