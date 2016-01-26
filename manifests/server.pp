# == Class: nfs::server
#
# Manages an NFS Server
#
class nfs::server (
  $exports_path   = '/etc/exports',
  $exports_owner  = 'root',
  $exports_group  = 'root',
  $exports_mode   = '0644',
  $exports_data   = '',
  $ensure         = 'present',
) inherits nfs {
  $exports_gen = hiera_hash('exports_data',{})
  if !empty($exports_gen) {
    concat { "$exports_path":
      ensure  => "$ensure",
      path    => "$exports_path",
      owner   => "$exports_owner",
      group   => "$exports_group",
      mode    => "$exports_mode",
      order   => 'numeric',
    }
    # template vars:
      # * message
    concat::fragment { "${exports_path}-general}":
      target  => "$exports_path",
      order   => 0,
      content => template("${module_name}/exports_header.erb"),
    }
    create_resources('nfs::exports_data', $exports_gen)
  }

  exec { 'update_nfs_exports':
    command     => 'exportfs -ra',
    path        => '/bin:/usr/bin:/sbin:/usr/sbin',
    refreshonly => true,
  }

  Service['nfs_service'] {
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => File['nfs_exports'],
  }
}

