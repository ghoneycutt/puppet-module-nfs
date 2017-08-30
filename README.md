# puppet-module-nfs #

[![Build Status](https://travis-ci.org/ghoneycutt/puppet-module-nfs.png?branch=master)](https://travis-ci.org/ghoneycutt/puppet-module-nfs)

Puppet module to manage NFS client and server

## Components ##

### Server
----------
- Manage NFS server
- Setup of exports

### Idmap
---------
- Manage idmapd
- Setup of configuration for idmapd


## Compatibility ##

This module has been tested to work on the following systems with Puppet
v4 and v5 using the ruby versions that are shipped with each. See
`.travis.yml` for the exact matrix.

 * EL 6
 * EL 7
 * Solaris 10 (client only)
 * Solaris 11 (client only)
 * Suse 11    (client only)
 * Suse 12    (client only)

===

# Parameters #

hiera_hash
----------
Boolean to use hiera_hash which merges all found instances of
nfs::mounts in Hiera. This is useful for specifying mounts at different
levels of the hierarchy and having them all included in the catalog.

- *Default*: true

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

server
------
Boolean to specify if the system is an NFS server.

- *Default*: false

exports_path
------------
The location of the config file.
- *Default*: '/etc/exports'

exports_owner
-------------
The owner of the config file.
- *Default*: 'root'

exports_group
-------------
The group for the config file.
- *Default*: 'root'

exports_mode
------------
The mode for the config file.
- *Default*: '0644'

===

## Class `nfs::idmap` ##

### Parameters ###

idmap_package
-------------
String of the idmap package name.
- *Default*: Uses system defaults as specified in module

idmapd_conf_path
----------------
The location of the config file.
- *Default*: '/etc/idmapd.conf'

idmapd_conf_owner
-----------------
The owner of the config file.
- *Default*: 'root'

idmapd_conf_group
-----------------
The group for the config file.
- *Default*: 'root'

idmapd_conf_mode
----------------
The mode for the config file.
- *Default*: '0644'

idmapd_service_name
-------------------
String of the service name.
- *Default*: Uses system defaults as specified in module

idmapd_service_ensure
---------------------
Boolean value of ensure parameter for idmapd service. Default is based
on the platform. If running EL7 as an nfs-server, this must be set to
'running'.
- *Default*: Uses system defaults as specified in module

idmapd_service_enable
---------------------
Boolean value of enable parameter for idmapd service.
- *Default*: true

idmapd_service_hasstatus
------------------------
Boolean value of hasstatus parameter for idmapd service.
- *Default*: true

idmapd_service_hasrestart
-------------------------
Boolean value of hasrestart parameter for idmapd service.
- *Default*: true

idmap_domain
------------
String value of domain to be set as local NFS domain.
- *Default*: `$::domain`

ldap_server
-----------
String value of ldap server name.
- *Default*: undef

ldap_base
---------
String value of ldap search base.
- *Default*: undef

local_realms
------------
String or array of local kerberos realm names.
- *Default*: `$::domain`

translation_method
------------------
String or array of mapping method to be used between NFS and local IDs.
Valid values is nsswitch, umich_ldap or static.
- *Default*: 'nsswitch'

nobody_user
-----------
String of local user name to be used when a mapping cannot be completed.
- *Default*: 'nobody'

nobody_group
------------
String of local group name to be used when a mapping cannot be completed.
- *Default*: 'nobody'

verbosity
---------
Integer of verbosity level.
- *Default*: 0

pipefs_directory
----------------
String of the directory for rpc_pipefs.
- *Default*: undef - Uses system defaults as specified in module


===

# Manage mounts
This works by iterating through the nfs::mounts hash and calling the
types::mount resource. Thus, you can provide any valid parameter for
mount. See the [Type
Reference](http://docs.puppetlabs.com/references/stable/type.html#mount)
for a complete list.

## Example:
Mount nfs.example.com:/vol1 on /mnt/vol1 and nfs.example.com:/vol2 on /mnt/vol2

```yaml
nfs::mounts:
  /mnt/vol1:
    device: nfs.example.com:/vol1
    options: rw,rsize=8192,wsize=8192
    fstype: nfs
  old_log_file_mount:
    name: /mnt/vol2
    device: nfs.example.com:/vol2
    fstype: nfs
```

# Manage exports

This module manages `/etc/exports` though does not manage its contents.
Suggest using the `file_line` resource in your profile as demonstrated
below.

```puppet
class profile::nfs_server {

  include ::nfs

  file_line { 'exports_home':
    path => '/etc/exports',
    line => '/home 192.168.42.0/24(sync,no_root_squash)',
  }

  file_line { 'exports_data':
    path => '/etc/exports',
    line => '/data 192.168.23.0/24(sync,no_root_squash,rw)',
  }
}
```

## Creating Hiera data from existing system
This module contains `ext/fstabnfs2yaml.rb`, which is a script that will
parse `/etc/fstab` and print out the nfs::mounts hash in YAML with which
you can copy/paste into Hiera.
