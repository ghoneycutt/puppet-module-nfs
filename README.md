# puppet-module-nfs #

[![Build Status](https://travis-ci.org/ghoneycutt/puppet-module-nfs.png?branch=master)](https://travis-ci.org/ghoneycutt/puppet-module-nfs)

Puppet module to manage NFS client and server

===

# Compatibility #

This module has been tested to work on the following systems with Puppet v3.

 * Debian 6 (client only)
 * EL 5
 * EL 6
 * Solaris 10
 * Suse 11
 * Ubuntu 12.04 LTS

===

# Parameters #

hiera_hash
-----------
Boolean to use hiera_hash which merges all found instances of nfs::mounts in Hiera. This is useful for specifying mounts at different levels of the hierarchy and having them all included in the catalog. This will default to `true` in future versions.

- *Default*: false

nfs_package
-----------
Name of the NFS package

- *Default*: Uses system defaults as specified in module

nfs_service
-----------
Name of the NFS service

- *Default*: Uses system defaults as specified in module

mounts
------
Hash of mounts to be mounted on system. See below.

- *Default*: undef

===

# Manage mounts
This works by passing the nfs::mounts hash to the create_resources() function. Thus, you can provide any valid parameter for mount. See the [Type Reference](http://docs.puppetlabs.com/references/stable/type.html#mount) for a complete list.

## Example:
Mount nfs.example.com:/vol1 on /mnt/vol1 and nfs.example.com:/vol2 on /mnt/vol2

<pre>
nfs::mounts:
  /mnt/vol1:
    ensure: present
    device: nfs.example.com:/vol1
    options: rw,rsize=8192,wsize=8192
    fstype: nfs
  old_log_file_mount:
    name: /mnt/vol2
    ensure: present
    device: nfs.example.com:/vol2
    fstype: nfs
</pre>

## Creating Hiera data from existing system
This module contains `ext/fstabnfs2yaml.rb`, which is a script that will parse `/etc/fstab` and print out the nfs::mounts hash in YAML with which you can copy/paste into Hiera.
