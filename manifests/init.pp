# == Class: nfs
#
# Manages NFS
#
class nfs (
  Boolean                $hiera_hash         = true,
  Variant[Array, String] $nfs_package        = 'USE_DEFAULTS',
  String                 $nfs_service        = 'USE_DEFAULTS',
  String                 $nfs_service_ensure = 'USE_DEFAULTS',
  String                 $nfs_service_enable = 'USE_DEFAULTS',
  Variant[Undef, Hash]   $mounts             = undef,
  Boolean                $server             = false,
  Stdlib::Absolutepath   $exports_path       = '/etc/exports',
  String                 $exports_owner      = 'root',
  String                 $exports_group      = 'root',
  Pattern[/^[0-7]{4}$/]  $exports_mode       = '0644',
) {

  case $::osfamily {
    'RedHat': {
      $default_nfs_package = [ 'nfs-utils' ]

      case $::operatingsystemmajrelease {
        '6': {
          require ::rpcbind
          include ::nfs::idmap
          $default_nfs_service = 'nfs'
          $default_nfs_service_ensure = 'stopped'
          $default_nfs_service_enable = false
        }
        /7|8/: {
          require ::rpcbind
          include ::nfs::idmap
          $default_nfs_service = undef
          $default_nfs_service_ensure = 'stopped'
          $default_nfs_service_enable = false
        }
        default: {
          fail("nfs module only supports EL 6, 7 and 8 and operatingsystemmajrelease was detected as <${::operatingsystemmajrelease}>.")
        }
      }
    }
    'Solaris': {
      if $server == true {
        fail('This platform is not configured to be an NFS server.')
      }

      $default_nfs_service = 'nfs/client'
      $default_nfs_service_ensure = 'running'
      $default_nfs_service_enable = true

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
      if $server == true {
        fail('This platform is not configured to be an NFS server.')
      }

      include ::nfs::idmap
      $default_idmap_service = 'rpcidmapd'

      case $::operatingsystemmajrelease {
        '11','12': {
          $default_nfs_package = [ 'nfs-client' ]
          $default_nfs_service = 'nfs'
          $default_nfs_service_ensure = 'running'
          $default_nfs_service_enable = true
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
    $nfs_package_array = $default_nfs_package
  } else {
    $nfs_package_array = any2array($nfs_package)
  }

  if $nfs_service == 'USE_DEFAULTS' {
    $nfs_service_real = $default_nfs_service
  } else {
    $nfs_service_real = $nfs_service
  }

  if $server == true {
    $nfs_service_ensure_real = 'running'
    $nfs_service_enable_real = true
  } else {
    if $nfs_service_ensure == 'USE_DEFAULTS' {
      $nfs_service_ensure_real = $default_nfs_service_ensure
    } else {
      validate_re($nfs_service_ensure, '^(stopped)|(running)$', "for nfs::nfs_service_ensure valid values are stopped, running")
      $nfs_service_ensure_real = $nfs_service_ensure
    }

    if $nfs_service_enable == 'USE_DEFAULTS' {
      $nfs_service_enable_real = $default_nfs_service_enable
    } else {
      $nfs_service_enable_real = $nfs_service_enable
    }
  }

  package { $nfs_package_array:
    ensure => present,
  }

  if $server == true {

    file { 'nfs_exports':
      ensure => file,
      path   => $exports_path,
      owner  => $exports_owner,
      group  => $exports_group,
      mode   => $exports_mode,
      notify => Exec['update_nfs_exports'],
    }

    exec { 'update_nfs_exports':
      command     => 'exportfs -ra',
      path        => '/bin:/usr/bin:/sbin:/usr/sbin',
      refreshonly => true,
    }

    $service_require = 'Exec[update_nfs_exports]'
  } else {
    $service_require = undef
  }

  if $nfs_service_real {
    # Some implmentations of NFS still need to run a service for the client
    # even though the system is not an NFS server.
    service { 'nfs_service':
      ensure     => $nfs_service_ensure_real,
      name       => $nfs_service_real,
      enable     => $nfs_service_enable_real,
      hasstatus  => true,
      hasrestart => true,
      require    => $service_require,
      subscribe  => Package[$nfs_package_array],
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
