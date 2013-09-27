# puppet-module-nfs #

[![Build Status](https://travis-ci.org/ghoneycutt/puppet-module-nfs.png?branch=master)](https://travis-ci.org/ghoneycutt/puppet-module-nfs)

Puppet module to manage NFS

===

# Compatibility #
 * EL 5
 * EL 6

===

# Parameters #

nfs_package
-----------
Name of the NFS package

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
    fstype: nfs
  old_log_file_mount:
    name: /mnt/vol2
    ensure: present
    device: nfs.example.com:/vol2
    fstype: nfs
</pre>
