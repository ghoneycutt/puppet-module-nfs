require 'spec_helper'
describe 'nfs' do

  describe 'class nfs' do

    context 'default options for RHEL 5' do
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
    end

    context 'default options for RHEL 6' do
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
