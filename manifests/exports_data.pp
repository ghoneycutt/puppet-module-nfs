define nfs::exports_data (
  $path = '',
  $host = '',
  $options = '',
) {
  # template vars:
    # * path
    # * host
    # * options
  concat::fragment { "${title}-exports}":
    target  => "${::nfs::exports::config_name}",
    order   => 10,
    content => template("${module_name}/exports_body.erb"),
  }
}

