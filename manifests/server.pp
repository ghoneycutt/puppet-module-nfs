# == Class: nfs::server
#
# Manages an NFS Server
#
class nfs::server(
  $exports_data  = {},
  $exports_path  = '/etc/exports',
  $exports_owner = 'root',
  $exports_group = 'root',
  $exports_mode  = '0644',
  $exports_d     = '/etc/exports.d',
) {

  include nfs::data

  require 'nfs'

  create_resources( nfs::server::export, $exports_data )

  file { 'exports_d':
    path   => $exports_d,
    ensure => directory,
  }

  file { 'exports_d/header' :
    path    => "${exports_d}/00-header",
    ensure  => present,
    content => "#\n# This file is managed by pupped\n#\n",
    require => File[ 'exports_d' ],
  }

  exec { 'create_exports':
    command     => "cat ${exports_d}/* > ${exports_path}",
    path        => '/bin:/usr/bin',
    before      => File[ 'exports_file' ],
    refreshonly => true,
  }

  file { 'exports_file':
    path   => $exports_path,
    ensure => file,
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

  service { 'nfs_service':
    ensure     => running,
    name       => 'nfs',
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => File['exports_file'],
  }
}


