# == Class: nfs::idmap
#
# Manages idmapd
#
class nfs::idmap(
  $domain             = undef,
  $package            = undef,
  $conf_path          = '/etc/idmapd.conf',
  $conf_owner         = 'root',
  $conf_group         = 'root',
  $conf_mode          = '0644',
  $service_name       = 'rpcidmapd',
  $service_ensure     = 'running',
  $service_enable     = true,
  $service_hasstatus  = true,
  $service_hasrestart = true,
) {

  if $package {
    $use_package = $package
  } else {
    case "${::osfamily}_${::lsbmajdistrelease}" {
      'RedHat_5': {
        $use_package = 'nfs-utils'
      }
      'RedHat_6': {
        $use_package = [ 'nfs-utils', 'rpcbind' ]
      }
      default: {
        fail( 'No idmap package supplied, and this module only figures out defauls for RedHat 5 and 6' )
      }
    }
  }

  package { 'idmap_package':
    ensure => installed,
    name   => $use_idmap_package,
  }

  file { 'idmapd_conf':
    ensure  => file,
    path    => $conf_path,
    content => template( 'nfs/idmapd.conf.erb'),
    owner   => $conf_owner,
    group   => $conf_group,
    mode    => $conf_mode,
    require => Package[ 'idmap_package'],
  }

  service { 'idmapd_service':
    ensure     => $service_ensure,
    name       => $service_name,
    enable     => $service_enable,
    hasstatus  => $service_hasstatus,
    hasrestart => $service_hasrestart,
    subscribe  => File[ 'idmapd_conf'],
    require    => [ Service[ 'network'],
                    File[ 'nsswitch_config_file'],
                  ],
  }
}
