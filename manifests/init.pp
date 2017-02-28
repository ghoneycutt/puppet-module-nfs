# == Class: nfs
#
# Manages NFS
#
class nfs (
  $hiera_hash                = false,
  $nfs_package               = 'USE_DEFAULTS',
  $nfs_service               = 'USE_DEFAULTS',
  $nfs_service_required_svcs = 'USE_DEFAULTS',
  $mounts                    = {},
) {

  if type3x($hiera_hash) == 'string' {
    $hiera_hash_real = str2bool($hiera_hash)
  } else {
    $hiera_hash_real = $hiera_hash
  }
  validate_bool($hiera_hash_real)

  case $::osfamily {
    'Debian': {

      include ::rpcbind

      $default_nfs_package = 'nfs-common'
      $default_nfs_service_required_svcs = undef

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
    'RedHat': {

      $default_nfs_package = 'nfs-utils'
      $default_nfs_service_required_svcs = undef

      case $::operatingsystemmajrelease {
        '5': {
          include ::nfs::idmap
          $default_nfs_service = 'nfs'
        }
        '6': {
          include ::rpcbind
          include ::nfs::idmap
          $default_nfs_service = 'nfs'
        }
        '7': {
          include ::rpcbind
          include ::nfs::idmap
          $default_nfs_service = undef
        }
        default: {
          fail("nfs module only supports EL 5, 6 and 7 and operatingsystemmajrelease was detected as <${::operatingsystemmajrelease}>.")
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

          $default_nfs_service_required_svcs = undef
        }
        '5.11': {
          $default_nfs_package = [
            'service/file-system/nfs',
            'system/file-system/nfs',
          ]

          $default_nfs_service_required_svcs = [
            'nfs/status',
            'nfs/nlockmgr',
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
      $default_nfs_service_required_svcs = undef

      case $::lsbmajdistrelease {
        '10': {
          $default_nfs_package = 'nfs-utils'
          $default_nfs_service = 'nfs'
        }
        '11','12': {
          $default_nfs_package = 'nfs-client'
          $default_nfs_service = 'nfs'
        }
        default: {
          fail("nfs module only supports Suse 10, 11 and 12 and lsbmajdistrelease was detected as <${::lsbmajdistrelease}>.")
        }
      }
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

  # nfs_package_real is either an array or a string
  if is_string($nfs_package_real) == false and is_array($nfs_package_real) == false {
    fail("nfs::nfs_package is <${nfs_package_real}> and is not a string nor an array.")
  }

  if $nfs_service == 'USE_DEFAULTS' {
    $nfs_service_real = $default_nfs_service
  } else {
    $nfs_service_real = $nfs_service
  }

  # nfs_service_real is either an array or a string
  if is_string($nfs_service_real) == false and is_array($nfs_service_real) == false {
    fail("nfs::nfs_service is <${nfs_service_real}> and is not a string nor an array.")
  }

  if $nfs_service_required_svcs == 'USE_DEFAULTS' {
    $nfs_service_required_svcs_real = $default_nfs_service_required_svcs
  } else {
    $nfs_service_required_svcs_real = $nfs_service_required_svcs
  }

  package { $nfs_package_real:
    ensure => present,
  }

  if $nfs_service_real != undef {

    service { 'nfs_service':
      ensure    => running,
      name      => $nfs_service_real,
      enable    => true,
      subscribe => Package[$nfs_package_real],
    }

    if $nfs_service_required_svcs_real != undef {

      validate_array($nfs_service_required_svcs_real)

      service { $nfs_service_required_svcs_real:
        ensure    => running,
        enable    => true,
        subscribe => Package[$nfs_package_real],
        before    => Service['nfs_service'],
      }
    }
  }

  validate_hash($mounts)
  if empty($mounts) == false {

    if $hiera_hash_real == true {
      $mounts_real = hiera_hash('nfs::mounts')
    } else {
      $mounts_real = $mounts
      notice('Future versions of the nfs module will default nfs::hiera_hash to true')
    }

    create_resources('types::mount',$mounts_real)
  }
}
