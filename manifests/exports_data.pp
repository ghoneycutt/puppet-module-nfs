define nfs::exports_data (
  $config_title = "$title",
  $message = 'This File is managed by Puppet - NFS Module',
  $path = '',
  $host = '',
  $options = '',
) {
  # template vars:
    # * path
    # * host
    # * options
  concat::fragment { "${config_title}-exports}":
    target  => "${::nfs::exports::config_name}",
    order   => 10,
    content => epp("${module_name}/exports_body.epp", {path    => $path,
                                                       host    => $host,
                                                       options => $options}),
  }
}

