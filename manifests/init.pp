# @summary Manages NFS
#
# @param hiera_hash
#   Boolean to use hiera_hash which merges all found instances of
#   nfs::mounts in Hiera. This is useful for specifying mounts at different
#   levels of the hierarchy and having them all included in the catalog.
#
# @param nfs_package
#   Name of the NFS package. May be a string or an array.
#
# @param nfs_service
#   Name of the NFS service.
#
# @param nfs_service_ensure
#   Ensure attribute for the NFS service.
#
# @param nfs_service_enable
#   Enable attribute for the NFS service.
#
# @param mounts
#   Hash of mounts to be mounted on system.
#
# @param server
#   Boolean to specify if the system is an NFS server.
#
# @param exports_path
#   The location of the config file.
#
# @param exports_owner
#   The owner of the config file.
#
# @param exports_group
#   The group for the config file.
#
# @param exports_mode
#   The mode for the config file.
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
  case $facts['os']['family'] {
    'RedHat': {
      $default_nfs_package = ['nfs-utils']

      case $facts['os']['release']['major'] {
        '6': {
          require rpcbind
          include nfs::idmap
          $default_nfs_service = 'nfs'
          $default_nfs_service_ensure = 'stopped'
          $default_nfs_service_enable = false
        }
        /7|8/: {
          require rpcbind
          include nfs::idmap
          $default_nfs_service = undef
          $default_nfs_service_ensure = 'stopped'
          $default_nfs_service_enable = false
        }
        default: {
          fail("nfs module only supports EL 6, 7 and 8 and facts[os][release][major] was detected as <${facts['os']['release']['major']}>.")
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

      case $facts['kernelrelease'] {
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
          fail("nfs module only supports Solaris 5.10 and 5.11 and facts[kernelrelease] was detected as <${facts['kernelrelease']}>.")
        }
      }
    }
    'Suse' : {
      if $server == true {
        fail('This platform is not configured to be an NFS server.')
      }

      include nfs::idmap
      $default_idmap_service = 'rpcidmapd'

      case $facts['os']['release']['major'] {
        '11','12': {
          $default_nfs_package = ['nfs-client']
          $default_nfs_service = 'nfs'
          $default_nfs_service_ensure = 'running'
          $default_nfs_service_enable = true
        }
        default: {
          fail("nfs module only supports Suse 11 and 12 and facts[os][release][major was detected as <${facts['os']['release']['major']}>.")
        }
      }
    }

    default: {
      fail("nfs module only supports osfamilies RedHat, Solaris and Suse, and <${facts['os']['family']}> was detected.")
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
      validate_re($nfs_service_ensure, '^(stopped)|(running)$', 'for nfs::nfs_service_ensure valid values are stopped, running')
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
