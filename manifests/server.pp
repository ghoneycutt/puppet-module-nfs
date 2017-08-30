# == Class: nfs::server
#
# Manages an NFS Server
#
class nfs::server (
  Stdlib::Absolutepath   $exports_path   = '/etc/exports',
  String                 $exports_owner  = 'root',
  String                 $exports_group  = 'root',
  Pattern[/^[0-7]{4}$/]  $exports_mode   = '0644',
) inherits nfs {

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

  if $::osfamily == 'RedHat' and $::operatingsystemmajrelease != '7' {
    Service['nfs_service'] {
      ensure     => running,
      enable     => true,
      hasstatus  => true,
      hasrestart => true,
      require    => File['nfs_exports'],
    }
  }
}
