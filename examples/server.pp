class { 'nfs':
  server => true,
}

file_line { 'exports_test':
  path => '/etc/exports',
  line => '/home/vagrant 192.168.42.0/24(sync,no_root_squash)',
}
