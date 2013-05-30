# == Class: nfs
#
# Manages NFS
#
class nfs {

  include nfs::data

#  include network
#  include nfs::idmap

  package { 'nfs_package':
    ensure => installed,
    name   => $nfs::data::nfs_package,
  }

  if $::lsbmajdistrelease == '6' {
    service { 'rpcbind':
      ensure     => running,
      name       => 'rpcbind',
      enable     => true,
      hasstatus  => true,
      hasrestart => true,
    }
  }
}
