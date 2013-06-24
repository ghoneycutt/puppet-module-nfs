require 'spec_helper'
describe 'nfs::idmap' do

  context 'default options for EL 5' do
    let :params do
      {
        :idmap_domain   => 'UNSET',
      }
    end
    let :facts do 
      {
        :osfamily => 'RedHat',
        :lsbmajdistrelease => '5',
      }
    end

    it { should include_class('nfs::idmap')}
    it { should include_class('nfs::data')}

    it { 
      should contain_package('idmap_package').with({
        'name' => 'nfs-utils-lib',
        'ensure' => 'installed',
      })
    }

    it {
      should contain_file('idmapd_conf').with({
        'path'  => '/etc/idmapd.conf',
        'owner' => 'root',
        'group' => 'root',
        'mode'  => '0644',
      })
      should contain_file('idmapd_conf').with_content(/#Domain = local.domain.edu\n\n\n/)
    }

    it {
      should contain_service('idmapd_service').with({
        'ensure' => 'running',
        'name'   => 'rpcidmapd',
        'enable' => 'true',
      })
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

  context 'default options for EL 6' do
    let :params do
      {
        :idmap_domain   => 'UNSET',
      }
    end
    let :facts do 
      {
        :osfamily => 'RedHat',
        :lsbmajdistrelease => '6',
      }
    end

    it { should include_class('nfs::idmap')}
    it { should include_class('nfs::data')}

    it { 
      should contain_package('idmap_package').with({
        'name' => 'nfs-utils-lib',
        'ensure' => 'installed',
      })
    }

    it {
      should contain_file('idmapd_conf').with({
        'path'  => '/etc/idmapd.conf',
        'owner' => 'root',
        'group' => 'root',
        'mode'  => '0644',
      })
      should contain_file('idmapd_conf').with_content(/#Domain = local.domain.edu\n\n\n/)
    }

    it {
      should contain_service('idmapd_service').with({
        'ensure' => 'running',
        'name'   => 'rpcidmapd',
        'enable' => 'true',
      })
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

  context 'on unsupported platform, Debian, should fail' do
    let(:facts) { {:osfamily => 'debian' } }
    it do 
      expect {
        should include_class('rsyslog')
      }.to raise_error(Puppet::Error,/nfs module only supports osfamily 'RedHat' and debian was detected./)
    end
  end
end
