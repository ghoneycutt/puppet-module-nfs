# == Class: nfs::data
#
# Data for NFS module
#
class nfs::data {

  if $::osfamily != 'RedHat' {
    fail("nfs module only supports osfamily \'RedHat\' and ${::osfamily} was detected.")
  }

  # nfs
  ######
  case $::lsbmajdistrelease {
    '5': {
      $default_nfs_package =  hiera('nfs::nfs_package','nfs-utils')
    }
    '6': {
      $default_nfs_package =  hiera('nfs::nfs_package',['nfs-utils','rpcbind'])
    }
    default: {
      fail("nfs module only supports EL 5 and 6 and lsbmajdistrelease was detected as ${::lsbmajdistrelease}")
    }
  }
  $nfs_package = hiera('nfs::nfs_package',$default_nfs_package)

  # nfs::idmap
  #############
  $idmap_package = hiera('nfs_idmap_package','nfs-utils-lib')

  $idmapd_conf_path  = hiera('nfs_idmapd_conf_path','/etc/idmapd.conf')
  $idmapd_conf_owner = hiera('nfs_idmapd_conf_owner','root')
  $idmapd_conf_group = hiera('nfs_idmapd_conf_group','root')
  $idmapd_conf_mode  = hiera('nfs_idmapd_conf_mode','0644')

  $idmapd_service_name       = hiera('nfs_idmapd_service_name','rpcidmapd')
  $idmapd_service_enable     = hiera('nfs_idmapd_service_enable','true')
  $idmapd_service_hasstatus  = hiera('nfs_idmapd_service_hasstatus','true')
  $idmapd_service_hasrestart = hiera('nfs_idmapd_service_hasrestart','true')

  $idmap_domain = hiera('nfs_idmap_domain','UNSET')
}
