require 'spec_helper'

describe 'nfs::idmap' do

  context 'with default values' do
    let :facts do
      {
        :osfamily => 'RedHat',
        :domain   => 'example.com',
      }
    end

    it {
      should contain_package('idmap_package').with({
        'ensure' => 'installed',
        'name'   => 'nfs-utils-lib',
      })
    }

    it {
      should contain_file('idmapd_conf').with({
        'ensure'  => 'file',
        'path'    => '/etc/idmapd.conf',
        'owner'   => 'root',
        'group'   => 'root',
        'mode'    => '0644',
        'require' => 'Package[idmap_package]',
      })
    }

    it {
      should contain_file('idmapd_conf') \
        .with_content(/^#Domain = local.domain.edu$/) \
        .with_content(/^Verbosity = 0$/) \
        .with_content(/^Nobody-User = nobody$/) \
        .with_content(/^Nobody-Group = nobody$/) \
        .with_content(/^Method = nsswitch$/) \
        .with_content(/^#Local-Realms = EXAMPLE.COM$/) \
    }

    it {
      should_not contain_file('idmapd_conf') \
        .with_content(/^LDAP_server/) \
        .with_content(/^LDAP_base/) \
    }

    it {
      should contain_service('idmapd_service').with({
        'ensure'     => 'running',
        'name'       => 'rpcidmapd',
        'enable'     => 'true',
        'hasstatus'  => 'true',
        'hasrestart' => 'true',
        'subscribe'  => 'File[idmapd_conf]',
      })
    }
  end

  context 'with idmap_domain set to a valid domain, example.com' do
    let :facts do
      { :osfamily => 'RedHat' }
    end

    let :params do
      { :idmap_domain => 'example.com' }
    end

    it {
      should contain_file('idmapd_conf').with_content(/^Domain = example.com$/)
    }
  end

  context 'with idmap_domain set to valid.tld on EL 5' do
    let :params do
      {
        :idmap_domain   => 'valid.tld',
      }
    end
    let :facts do
      {
        :osfamily => 'RedHat',
        :lsbmajdistrelease => '5',
      }
    end

    it {
      should contain_file('idmapd_conf').with({
        'ensure' => 'file',
        'path'   => '/etc/idmapd.conf',
        'owner'  => 'root',
        'group'  => 'root',
        'mode'   => '0644',
      })
      should contain_file('idmapd_conf').with_content(/Domain = valid.tld/)
    }
  end

  context 'with idmap_domain set to valid.tld on EL 6' do
    let :params do
      {
        :idmap_domain   => 'valid.tld',
      }
    end
    let :facts do
      {
        :osfamily => 'RedHat',
        :lsbmajdistrelease => '6',
      }
    end

    it {
      should contain_file('idmapd_conf').with({
        'ensure' => 'file',
        'path'   => '/etc/idmapd.conf',
        'owner'  => 'root',
        'group'  => 'root',
        'mode'   => '0644',
      })
      should contain_file('idmapd_conf').with_content(/Domain = valid.tld/)
    }
  end

  context 'with ldap_base set to a single valid base, dc=edu' do
    let :facts do
      { :osfamily => 'RedHat' }
    end

    let :params do
      { :ldap_base => 'dc=edu' }
    end

    it {
      should contain_file('idmapd_conf').with_content(/^LDAP_base = dc=edu$/)
    }
  end

  context 'with ldap_base set to an array of valid domains, [\'dc=local\',\'dc=domain\',\'dc=edu\']' do
    let :facts do
      { :osfamily => 'RedHat' }
    end

    let :params do
      { :ldap_base => ['dc=local','dc=domain','dc=edu'] }
    end

    it {
      should contain_file('idmapd_conf').with_content(/^LDAP_base = dc=local,dc=domain,dc=edu$/)
    }
  end

  context 'with local_realms set to a single valid domain, foo.bar' do
    let :facts do
      { :osfamily => 'RedHat' }
    end

    let :params do
      { :local_realms => 'foo.bar' }
    end

    it {
      should contain_file('idmapd_conf').with_content(/^#Local-Realms = FOO.BAR$/)
    }
  end

  context 'with local_realms set to an array of valid domains, [\'foo.bar\',\'bar.foo\']' do
    let :facts do
      { :osfamily => 'RedHat' }
    end

    let :params do
      { :local_realms => ['foo.bar','bar.foo'] }
    end

    it {
      should contain_file('idmapd_conf').with_content(/^#Local-Realms = FOO.BAR,BAR.FOO$/)
    }
  end

  context 'with ldap_server set to a valid host, ldap.example.com' do
    let :facts do
      { :osfamily => 'RedHat' }
    end

    let :params do
      { :ldap_server => 'ldap.example.com' }
    end

    it {
      should contain_file('idmapd_conf').with_content(/^LDAP_server = ldap.example.com$/)
    }
  end

  context 'with an invalid ldap_server set' do
    let :facts do
      { :osfamily => 'RedHat' }
    end

    let :params do
      { :ldap_server => 'invalid' }
    end

    it 'should fail' do
      expect {
        should raise_error(Puppet::Error, /ldap_server parameter, <invalid>, is not a valid name./)
      }
    end
  end

  context 'with verbosity set to a valid number, 1' do
    let :facts do
      { :osfamily => 'RedHat' }
    end

    let :params do
      { :verbosity => '1' }
    end

    it {
      should contain_file('idmapd_conf').with_content(/^Verbosity = 1$/)
    }
  end

  context 'with an invalid verbosity set' do
    let :facts do
      { :osfamily => 'RedHat' }
    end

    let :params do
      { :verbosity => 'invalid' }
    end

    it 'should fail' do
      expect {
        should raise_error(Puppet::Error, /verbosity parameter, <invalid>, does not match regex./)
      }
    end
  end

  context 'with translation_method set to a single valid entry, static' do
    let :facts do
      { :osfamily => 'RedHat' }
    end

    let :params do
      { :translation_method => 'static' }
    end

    it {
      should contain_file('idmapd_conf').with_content(/^Method = static$/)
    }
  end

  context 'with translation_method set to an array of valid entries, [\'nsswitch\',\'static\']' do
    let :facts do
      { :osfamily => 'RedHat' }
    end

    let :params do
      { :translation_method => ['nsswitch','static'] }
    end

    it {
      should contain_file('idmapd_conf').with_content(/^Method = nsswitch,static$/)
    }
  end

  context 'with an invalid translation_method set as a single value' do
    let :facts do
      { :osfamily => 'RedHat' }
    end

    let :params do
      { :translation_method => 'invalid' }
    end

    it 'should fail' do
      expect {
        should raise_error(Puppet::Error, /translation_method parameter, <invalid>, does not match regex. Valid values include nsswitch, umich_ldap, and static./)
      }
    end
  end

  # GH: TODO
#  context 'with an invalid translation_method set as not the first value in an array' do
#    let :facts do
#      { :osfamily => 'RedHat' }
#    end
#
#    let :params do
#      { :translation_method => ['nsswitch','invalid','umich_ldap'] }
#    end
#
#    it 'should fail' do
#      expect {
#        should raise_error(Puppet::Error, /translation_method parameter, <nsswitchinvalidumich_ldap>, does not match regex. Valid values include nsswitch, umich_ldap, and static./)
#      }
#    end
#  end
end
