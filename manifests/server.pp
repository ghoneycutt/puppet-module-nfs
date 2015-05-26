# == Class: nfs::server
#
# Manages an NFS Server
#
class nfs::server (
  $exports_path   = '/etc/exports',
  $exports_owner  = 'root',
  $exports_group  = 'root',
  $exports_mode   = '0644',
  $package        = 'USE_DEFAULTS',
  $service        = 'USE_DEFAULTS',
) inherits nfs {

  validate_absolute_path($exports_path)
  validate_string($exports_owner)
  validate_string($exports_group)

  if $::osfamily == 'RedHat' and $::operatingsystemmajrelease == '7' {
    $default_service = 'nfs-server'
  } else {
    $default_service = $::nfs::nfs_service_real
  }

  if $service == 'USE_DEFAULTS' {
    $service_real = $default_service
  } else {
    $service_real = $service
  }
  validate_string($service_real)

  Package <| tag == 'nfs' |> -> File <| title == 'nfs_exports' |>

  # GH: TODO - use file fragment pattern
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

  # if the nfs class has the service as undef, then there will be no service
  # resource to override.
  if $::nfs::nfs_service_real {
    Service['nfs_service'] {
      ensure     => running,
      name       => $service_real,
      enable     => true,
      hasstatus  => true,
      hasrestart => true,
      require    => File['nfs_exports'],
    }
  } else {
    service { 'nfs_service':
      ensure     => running,
      name       => $service_real,
      enable     => true,
      hasstatus  => true,
      hasrestart => true,
      require    => File['nfs_exports'],
    }
  }
}
