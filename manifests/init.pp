# == Class: nfs
#
# Manages NFS
#
class nfs (
  $nfs_package = 'USE_DEFAULTS',
) {

  include nfs::idmap

  case $::osfamily {
    'redhat': {
      case $::lsbmajdistrelease {
        '5': {
          $default_nfs_package = 'nfs-utils'
        }
        '6': {
          $default_nfs_package =  ['nfs-utils','rpcbind']
        }
        default: {
          fail("nfs module only supports EL 5 and 6 and lsbmajdistrelease was detected as <${::lsbmajdistrelease}>.")
        }
      }
    }
    default: {
      fail("nfs module only supports osfamily RedHat and <${::osfamily}> was detected.")
    }
  }

  if $nfs_package == 'USE_DEFAULTS' {
    $nfs_package_real = $default_nfs_package
  } else {
    $nfs_package_real = $nfs_package
  }

  package { 'nfs_package':
    ensure => installed,
    name   => $nfs_package_real,
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
