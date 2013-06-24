# == Class: nfs::idmap
#
# Manages idmapd
#
class nfs::idmap (
  $idmap_domain = $nfs::data::idmap_domain,
) {

  include nfs::data

  package { 'idmap_package':
    ensure => installed,
    name   => $nfs::data::idmap_package,
  }

  file { 'idmapd_conf':
    ensure  => file,
    path    => $nfs::data::idmapd_conf_path,
    content => template('nfs/idmapd.conf.erb'),
    owner   => $nfs::data::idmapd_conf_owner,
    group   => $nfs::data::idmapd_conf_group,
    mode    => $nfs::data::idmapd_conf_mode,
    require => Package['idmap_package'],
  }

  service { 'idmapd_service':
    ensure     => running,
    name       => $nfs::data::idmapd_service_name,
    enable     => $nfs::data::idmapd_service_enable,
    hasstatus  => $nfs::data::idmapd_service_hasstatus,
    hasrestart => $nfs::data::idmapd_service_hasrestart,
    subscribe  => File['idmapd_conf'],
    require    => [ Service['network'],
                    File['nsswitch_config_file'],
                  ],
  }
}
