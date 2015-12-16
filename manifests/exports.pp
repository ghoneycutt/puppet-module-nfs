class nfs::exports (
  $config_name = '/etc/exports',
  $ensure = 'present',
  $exports_data = '',
  $owner = 'root',
  $group = 'root',
  $mode = '0644',
  $message = 'This File is managed by Puppet - NFS Module',
) {
  $exports_gen = hiera_hash('exports_data',{})
  if !empty($exports_gen) {
    concat { "$config_name":
      ensure  => "$ensure",
      path    => "$config_name",
      owner   => "$owner",
      group   => "$group",
      mode    => "$mode",
      order   => 'numeric',
    }
    # template vars:
      # * message
    concat::fragment { "${config_name}-general}":
      target  => "$config_name",
      order   => 0,
      content => epp("${module_name}/exports_header.epp",{message => $message}),
    }
    create_resources('nfs::exports_data', $exports_gen)
  }
}

