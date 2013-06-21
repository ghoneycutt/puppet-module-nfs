require 'spec_helper'
describe 'nfs::idmap' do

  describe 'class nfs::idmap' do

    context 'default options for RHEL 5' do
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
      }

      it {
        should contain_service('idmapd_service').with({
          'ensure' => 'running',
          'name'   => 'rpcidmapd',
          'enable' => 'true',
        })
      }
    end

    context 'default options for RHEL 6' do
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
      }

      it {
        should contain_service('idmapd_service').with({
          'ensure' => 'running',
          'name'   => 'rpcidmapd',
          'enable' => 'true',
        })
      }
    end
    describe 'debian systems should fail' do
      let(:facts) { {:osfamily => 'debian' } }
      it do 
        expect {
          should include_class('rsyslog')
        }.to raise_error(Puppet::Error,/nfs module only supports osfamily 'RedHat' and debian was detected./)
      end
    end

    describe 'SuSE systems should fail' do
      let(:facts) { {:osfamily => 'suse' } }
      it do 
        expect {
          should include_class('rsyslog')
        }.to raise_error(Puppet::Error,/nfs module only supports osfamily 'RedHat' and suse was detected./)
      end
    end

    describe 'Gentoo systems should fail' do
      let(:facts) { {:osfamily => 'Gentoo' } }
      it do 
        expect {
          should include_class('rsyslog')
        }.to raise_error(Puppet::Error,/nfs module only supports osfamily 'RedHat' and Gentoo was detected./)
      end
    end

    describe 'Solaris systems should fail' do
      let(:facts) { {:osfamily => 'solaris' } }
      it do 
        expect {
          should include_class('rsyslog')
        }.to raise_error(Puppet::Error,/nfs module only supports osfamily 'RedHat' and solaris was detected./)
      end
    end
  end
end
