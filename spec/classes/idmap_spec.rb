require 'spec_helper'
describe 'nfs::idmap' do

  describe 'class nfs::idmap' do

    context 'default options for EL 5' do
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

    context 'default options for EL 6' do
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

    context 'on unsupported platform, Debian, should fail' do
      let(:facts) { {:osfamily => 'debian' } }
      it do 
        expect {
          should include_class('rsyslog')
        }.to raise_error(Puppet::Error,/nfs module only supports osfamily 'RedHat' and debian was detected./)
      end
    end
  end
end
