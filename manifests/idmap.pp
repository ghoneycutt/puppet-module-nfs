# == Class: nfs::idmap
#
# Manages idmapd
#
class nfs::idmap (
  $idmap_package             = 'nfs-utils-lib',
  $idmapd_conf_path          = '/etc/idmapd.conf',
  $idmapd_conf_owner         = 'root',
  $idmapd_conf_group         = 'root',
  $idmapd_conf_mode          = '0644',
  $idmapd_service_name       = 'rpcidmapd',
  $idmapd_service_enable     = true,
  $idmapd_service_hasstatus  = true,
  $idmapd_service_hasrestart = true,
  # idmapd.conf options
  $idmap_domain              = 'UNSET',
  $ldap_server               = 'UNSET',
  $ldap_base                 = 'UNSET',
  $local_realms              = $::domain,
  $translation_method        = 'nsswitch',
  $nobody_user               = 'nobody',
  $nobody_group              = 'nobody',
  $verbosity                 = '0',
) {

  $is_ldap_server_valid = is_domain_name($ldap_server)
  if $is_ldap_server_valid != true {
    fail("ldap_server parameter, <${ldap_server}>, is not a valid name.")
  }
  validate_re($verbosity, '^(\d+)$', "verbosity parameter, <${verbosity}>, does not match regex.")

  $ldap_base_type = type($ldap_base)

  case $ldap_base_type {
    'String': {
      $ldap_base_real = $ldap_base
    }
    'Array': {
      $ldap_base_real = inline_template('<%= ldap_base.join(\',\') %>')
    }
    default: {
      fail("valid types for ldap_base are String and Array. Detected type is <${ldap_base_type}>")
    }
  }

  $local_realms_type = type($local_realms)

  case $local_realms_type {
    'String': {
      $local_realms_real = $local_realms
    }
    'Array': {
      $local_realms_real = inline_template('<%= local_realms.join(\',\') %>')
    }
    default: {
      fail("valid types for local_realms are String and Array. Detected type is <${local_realms_type}>")
    }
  }

  $translation_method_type = type($translation_method)

  case $translation_method_type {
    'String': {
      $translation_method_real = $translation_method
      validate_re($translation_method_real, '^(nsswitch|umich_ldap|static)$', "translation_method, <${translation_method}>, does not match regex.")
    }
    'Array': {
      $translation_method_real = inline_template('<%= translation_method.join(\',\') %>')
      # GH: TODO: write valid regex
    }
    default: {
      fail("valid types for translation_method are String and Array. Detected type is <${translation_method_type}>")
    }
  }

  case $::osfamily {
    'Redhat' : {
      $idmap_package_real = $idmap_package
    }
    'Suse' : {
      $idmap_package_real = 'nfsidmap'
    }
    default: {
      fail( "idmap only supports Redhat and Suse osfamilies, not ${::osfamily}" )
    }
  }

  package { 'idmap_package':
    ensure => installed,
    name   => $idmap_package_real,
  }

  file { 'idmapd_conf':
    ensure  => file,
    path    => $idmapd_conf_path,
    content => template('nfs/idmapd.conf.erb'),
    owner   => $idmapd_conf_owner,
    group   => $idmapd_conf_group,
    mode    => $idmapd_conf_mode,
    require => Package['idmap_package'],
  }

  if $::osfamily != 'Suse' {

    service { 'idmapd_service':
      ensure     => running,
      name       => $idmapd_service_name,
      enable     => $idmapd_service_enable,
      hasstatus  => $idmapd_service_hasstatus,
      hasrestart => $idmapd_service_hasrestart,
      subscribe  => File['idmapd_conf'],
    }
  }
}
