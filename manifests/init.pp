# == Class: nfs
#
# Manages NFS
#
class nfs(
  $package     = undef,
  $use_network = true,
  $use_idmap   = true,
) {

  if $use_network {
    include network
  }
  if $use_idmap {
    include nfs::idmap
  }

notice ($package)

  if $package {
    $use_package = $package
  } else {
    case "${::osfamily}_${::lsbmajdistrelease}" {
      'RedHat_5': {
        $use_package = 'nfs-utils'
      }
      'RedHat_6': {
        $use_package = [ 'nfs-utils', 'rpcbind' ]
      }
      default: {
        fail( 'No NFS package name supplied, and this module only figures out defauls for RedHat 5 and 6' )
      }
    }
  }

notice ($use_package)

  package { 'nfs_package':
    ensure => installed,
    name   => $use_package,
  }

  if $::osfamily == 'RedHat' and $::lsbmajdistrelease == '6' {
    service { 'rpcbind':
      ensure     => running,
      name       => 'rpcbind',
      enable     => true,
      hasstatus  => true,
      hasrestart => true,
    }
  }
}
