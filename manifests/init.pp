# == Class: nfs
#
# Manages NFS
#
class nfs (
  $nfs_package = 'USE_DEFAULTS',
  $mounts      = undef,
) {

  include nfs::idmap

  case $::osfamily {
    'redhat': {
      case $::lsbmajdistrelease {
        '5': {
          $default_nfs_package = 'nfs-utils'
        }
        '6': {
          $default_nfs_package =  'nfs-utils'
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
    include rpcbind
  }

  if $mounts != undef {
    $mounts_type = type($mounts)
    if $mounts_type == 'hash' {
      create_resources(mount, $mounts)
    } else {
      fail("Mounts parameter needs to be of type hash. Detected type is <${::mounts_type}>.")
    }
  }
}
