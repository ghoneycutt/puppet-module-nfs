# == Class: nfs
#
# Manages NFS
#
class nfs (
  $nfs_package = 'USE_DEFAULTS',
  $mounts      = undef,
) {

  case $::osfamily {
    'Debian': {
      $default_nfs_package = 'nfs-common'

      service { 'nfs-common':
        ensure    => running,
        enable    => true,
        subscribe => Package['nfs_package'],
      }
    }
    'Redhat': {

      include nfs::idmap

      case $::lsbmajdistrelease {
        '5': {
          $default_nfs_package = 'nfs-utils'
        }
        '6': {
          include rpcbind

          $default_nfs_package =  'nfs-utils'
        }
        default: {
          fail("nfs module only supports EL 5 and 6 and lsbmajdistrelease was detected as <${::lsbmajdistrelease}>.")
        }
      }
    }
    default: {
      fail("nfs module only supports osfamilies Debian and RedHat and <${::osfamily}> was detected.")
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

  if $mounts != undef {
    $mounts_type = type($mounts)
    if $mounts_type == 'hash' {
    $mount_targets = keys($mounts) 
    file {"${mount_targets}": ensure => 'directory', owner => 'root', group => 'root', } 
      create_resources(mount, $mounts)
    } else {
      fail("Mounts parameter needs to be of type hash. Detected type is <${::mounts_type}>.")
    }
  }
}
