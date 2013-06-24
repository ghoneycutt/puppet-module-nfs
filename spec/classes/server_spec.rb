require 'spec_helper'
describe 'nfs::server' do

  describe 'class nfs::server' do

    context 'default options for EL 5' do
      let :facts do 
        {
          :osfamily => 'RedHat',
          :lsbmajdistrelease => '5',
        }
      end

      it { should include_class('nfs::server')}
      it { should include_class('nfs::data')}

      it { 
        should contain_exec('update_nfs_exports').with({
          'command' => 'exportfs -ra',
          'path'    => '/bin:/usr/bin:/sbin:/usr/sbin',
        })
      }

      it {
        should contain_file('nfs_exports').with({
          'path'  => '/etc/exports',
          'owner' => 'root',
          'group' => 'root',
          'mode'  => '0644',
        })
      }

      it {
        should contain_service('nfs_service').with({
          'ensure' => 'running',
          'name'   => 'nfs',
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
        should contain_exec('update_nfs_exports').with({
          'command' => 'exportfs -ra',
          'path'    => '/bin:/usr/bin:/sbin:/usr/sbin',
        })
      }

      it {
        should contain_file('nfs_exports').with({
          'path'  => '/etc/exports',
          'owner' => 'root',
          'group' => 'root',
          'mode'  => '0644',
        })
      }

      it {
        should contain_service('nfs_service').with({
          'ensure' => 'running',
          'name'   => 'nfs',
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
