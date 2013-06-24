require 'spec_helper'
describe 'nfs' do

  describe 'class nfs' do

    context 'default options for EL 5' do
      let :facts do 
        {
          :osfamily => 'RedHat',
          :lsbmajdistrelease => '5',
        }
      end

      it { should include_class('nfs')}

      it { 
        should contain_package('nfs_package').with({
          'name' => 'nfs-utils',
          'ensure' => 'installed',
        })
      }

      it {
        should_not contain_service('rpcbind').with({
          'ensure' => 'running',
          'name'   => 'rpcbind',
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

      it { should include_class('nfs')}

      it { 
        should contain_package('nfs_package').with({
          'name' => ["nfs-utils", "rpcbind"],
          'ensure' => 'installed',
        })
      }

      it {
        should contain_service('rpcbind').with({
          'ensure' => 'running',
          'name'   => 'rpcbind',
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
