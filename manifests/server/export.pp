# == Define nfs::server::export ==
#
# This def creates fragments to be joined into exports file.
# Do not call this def. directly.
#
# === Parameters: ===
# export_path:  Path to directory being exported
# clients:      Array of client specifications as defined in exports(5)
# options:      String of options used for each client in clients list.
#               See exports(5).
#
# === Example: ===
# /srv/data 10.2.3.4(rw)
#
# nfs::server::export { 'data':
#   export_path => '/srv/data',
#   clients     => [ '10.2.3.4' ],
#   options     => 'rw',
# }
#
define nfs::server::export (
  $export_path,
  $clients,
  $options = 'ro',
) {

  include 'nfs::server'

  file { "${nfs::server::exports_d}/${name}" :
    ensure  => present,
    content => template( 'nfs/export.erb' ),
    require => File[ 'exports_d' ],
    notify  => Exec[ 'create_exports' ],
  }
}
