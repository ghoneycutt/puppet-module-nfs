

include nfs
#nfs::server::export { 'foo' :
#  export_path => '/srv/data',
#  clients => [ 'kalle', 'olle', 'petter', 'niklas' ],
#  options => 'rw,no_root_squash',
#}

class { 'nfs::server' :
  exports_data => { 
    'foo' => { 'export_path' => '/srv/data', 'clients' => ['kalle'], options => 'ro' },
    'bar' => { 'export_path' => '/srv/atad', 'clients' => ['pelle'], options => 'rw' },
  }

}
