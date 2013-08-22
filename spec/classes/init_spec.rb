require 'spec_helper'

describe 'nfs' do

  context 'on unsupported osfamily' do
    let :facts do
      { :osfamily => 'Debian' }
    end

    it 'should fail' do
      expect {
        should raise_error(Puppet::Error, /nfs module only supports osfamily RedHat and <Debian> was detected./)
      }
    end
  end

  context 'on unsupported EL version' do
    let :facts do
      {
        :osfamily          => 'RedHat',
        :lsbmajdistrelease => '4',
      }
    end

    it 'should fail' do
      expect {
        should raise_error(Puppet::Error, /nfs module only supports EL 5 and 6 and lsbmajdistrelease was detected as <4>./)
      }
    end
  end

  context 'on EL 5' do
    let :facts do
      {
        :osfamily          => 'RedHat',
        :lsbmajdistrelease => '5',
      }
    end

    it { should include_class('nfs::idmap') }
    it {
      should contain_package('nfs_package').with({
        'ensure' => 'installed',
        'name'   => 'nfs-utils',
      })
    }
  end

  context 'on EL 6' do
    let :facts do
      {
        :osfamily          => 'RedHat',
        :lsbmajdistrelease => '6',
      }
    end

    it { should include_class('nfs::idmap') }
    it { should include_class('rpcbind') }
    it {
      should contain_package('nfs_package').with({
        'ensure' => 'installed',
        'name'   => 'nfs-utils',
      })
    }
  end
end
