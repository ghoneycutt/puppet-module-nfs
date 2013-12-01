# == Class: nfs
#
# Manages NFS
#
class nfs (
  $nfs_package = 'USE_DEFAULTS',
  $nfs_service = 'USE_DEFAULTS',
  $mounts      = undef,
) {

  case $::osfamily {
    'Debian': {

      include rpcbind
      $default_nfs_package = 'nfs-common'

      case $::lsbdistid {
        'Debian': {
          $default_nfs_service = 'nfs-common'
        }
        'Ubuntu': {
          $default_nfs_service = undef
        }
        default: {
          fail("nfs module only supports lsbdistid Debian and Ubuntu of osfamily Debian. Detected lsbdistid is <${::lsbdistid}>.")
        }
      }
    }
    'Redhat': {
      include nfs::idmap
      $default_nfs_service = 'nfs'

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
    'Solaris': {
      $default_nfs_package = ['SUNWnfsckr',
                              'SUNWnfscr',
                              'SUNWnfscu',
                              'SUNWnfsskr',
                              'SUNWnfssr',
                              'SUNWnfssu']

      $default_nfs_service = 'nfs/client'
    }
    'Suse' : {
      include nfs::idmap

      $default_nfs_package = 'nfs-client'
      $default_nfs_service = 'nfs'
    }

    default: {
      fail("nfs module only supports osfamilies Debian, RedHat, Solaris and Suse, and <${::osfamily}> was detected.")
    }
  }

  if $nfs_package == 'USE_DEFAULTS' {
    $nfs_package_real = $default_nfs_package
  } else {
    $nfs_package_real = $nfs_package
  }

  if $nfs_service == 'USE_DEFAULTS' {
    $nfs_service_real = $default_nfs_service
  } else {
    $nfs_service_real = $nfs_service
  }

  package { 'nfs_package':
    ensure => installed,
    name   => $nfs_package_real,
  }

  if $nfs_service_real {
    service { 'nfs_service':
      ensure    => running,
      name      => $nfs_service_real,
      enable    => true,
      subscribe => Package['nfs_package'],
    }
  }

  if $mounts != undef {
    validate_hash($mounts)
    create_resources('types::mount',$mounts)
  }
}
