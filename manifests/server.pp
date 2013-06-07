# == Class: nfs::server
#
# Manages an NFS Server
#
class nfs::server(
  $exports_data  = undef,
  $exports_path  = '/etc/exports',
  $exports_owner = 'root',
  $exports_group = 'root',
  $exports_mode  = '0644',
  $exports_d     = '/etc/exports.d',
) {

  require 'nfs'

  if "${::osfamily}_${::lsbmajdistrelease}" !~ /^RedHat_[56]$/ {
    fail( "Unsupported platform: ${::osfamily} ${::lsbrelease}. Supported OSes are RedHat 5 and 6" )
  }

  if $exports_data {
    create_resources( nfs::server::export, $exports_data )
  }

  file { 'exports_d':
    ensure => directory,
    path   => $exports_d,
  }

  file { 'exports_d/header':
    ensure  => present,
    path    => "${exports_d}/00-header",
    content => "# This file is being maintained by Puppet\n# DO NOT EDIT\n",
    require => File[ 'exports_d' ],
  }

  exec { 'create_exports':
    command     => "cat ${exports_d}/* > ${exports_path}",
    path        => '/bin:/usr/bin',
    before      => File[ 'exports_file' ],
    refreshonly => true,
  }

  file { 'exports_file':
    ensure => file,
    path   => $exports_path,
    owner  => $exports_owner,
    group  => $exports_group,
    mode   => $exports_mode,
    notify => Exec[ 'update_nfs_exports' ],
  }

  exec { 'update_nfs_exports':
    command     => 'exportfs -ra',
    path        => '/bin:/usr/bin:/sbin:/usr/sbin',
    refreshonly => true,
  }

  service { 'nfs_service':
    ensure     => running,
    name       => 'nfs',
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => File[ 'exports_file' ],
  }
}


