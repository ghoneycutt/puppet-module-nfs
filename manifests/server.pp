# == Class: nfs::server
#
# Manages an NFS Server
#
class nfs::server {

  include nfs::data

  require 'nfs'

  file { 'nfs_exports':
    ensure => file,
    source => [ "puppet:///modules/nfs/exports.${::fqdn}",
                $nfs::data::exports_source,
              ],
    path   => $nfs::data::exports_path,
    owner  => $nfs::data::exports_owner,
    group  => $nfs::data::exports_group,
    mode   => $nfs::data::exports_mode,
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
    require    => File['nfs_exports'],
  }
}
