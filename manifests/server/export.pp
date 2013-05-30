#
# == define nfs::server::export
#
#   Stub doc. to let me past puppet-lint
# example:
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
    content => template('nfs/export.erb'),
    require => File[ 'exports_d' ],
    notify  => Exec[ 'create_exports' ],
  }
}
