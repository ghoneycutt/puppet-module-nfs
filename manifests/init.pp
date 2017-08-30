# == Class: nfs
#
# Manages NFS
#
class nfs (
  Boolean               $hiera_hash  = true,
  String                $nfs_package = 'USE_DEFAULTS',
  String                $nfs_service = 'USE_DEFAULTS',
  Variant[Undef, Hash]  $mounts      = undef,
) {

  case $::osfamily {
    'RedHat': {
      $default_nfs_package = 'nfs-utils'

      case $::operatingsystemmajrelease {
        '6': {
          require ::rpcbind
          include ::nfs::idmap
          $default_nfs_service = 'nfs'
        }
        '7': {
          require ::rpcbind
          include ::nfs::idmap
          $default_nfs_service = undef
        }
        default: {
          fail("nfs module only supports EL 6 and 7 and operatingsystemmajrelease was detected as <${::operatingsystemmajrelease}>.")
        }
      }
    }
    'Solaris': {
      $default_nfs_service = 'nfs/client'

      case $::kernelrelease {
        '5.10': {
          $default_nfs_package = [
            'SUNWnfsckr',
            'SUNWnfscr',
            'SUNWnfscu',
            'SUNWnfsskr',
            'SUNWnfssr',
            'SUNWnfssu',
          ]
        }
        '5.11': {
          $default_nfs_package = [
            'service/file-system/nfs',
            'system/file-system/nfs',
          ]
        }
        default: {
          fail("nfs module only supports Solaris 5.10 and 5.11 and kernelrelease was detected as <${::kernelrelease}>.")
        }
      }
    }
    'Suse' : {
      include ::nfs::idmap
      $default_idmap_service = 'rpcidmapd'

      case $::operatingsystemmajrelease {
        '11','12': {
          $default_nfs_package = 'nfs-client'
          $default_nfs_service = 'nfs'
        }
        default: {
          fail("nfs module only supports Suse 11 and 12 and operatingsystemmajrelease was detected as <${::operatingsystemmajrelease}>.")
        }
      }
    }

    default: {
      fail("nfs module only supports osfamilies RedHat, Solaris and Suse, and <${::osfamily}> was detected.")
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

  package { $nfs_package_real:
    ensure => present,
  }

  if $nfs_service_real {
    service { 'nfs_service':
      ensure    => running,
      name      => $nfs_service_real,
      enable    => true,
      subscribe => Package[$nfs_package_real],
    }
  }

  if $mounts != undef {
    if $hiera_hash == true {
      $mounts_real = lookup('nfs::mounts', Hash, 'hash')
    } else {
      $mounts_real = $mounts
    }

    $mounts_real.each |$k,$v| {
      ::types::mount { $k:
        * => $v,
      }
    }
  }
}
