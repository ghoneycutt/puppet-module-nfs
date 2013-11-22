require 'spec_helper'

describe 'nfs' do

  context 'on unsupported osfamily' do
    let :facts do
      { :osfamily => 'AIX' }
    end

    it 'should fail' do
      expect {
        should raise_error(Puppet::Error, /nfs module only supports osfamilies Debian and RedHat and <AIX> was detected./)
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
    it { should_not include_class('rpcbind') }

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

  context 'on Debian' do
    let(:facts) { { :osfamily => 'Debian' } }

    it { should_not include_class('nfs::idmap') }
    it { should_not include_class('rpcbind') }

    it {
      should contain_package('nfs_package').with({
        'ensure' => 'installed',
        'name'   => 'nfs-common',
      })
    }

    it {
      should contain_service('nfs-common').with({
        'ensure'    => 'running',
        'enable'    => true,
        'subscribe' => 'Package[nfs_package]',
      })
    }
  end

  context 'with the mounts parameter set' do
    let :facts do
      { :osfamily          => 'RedHat',
        :lsbmajdistrelease => '6',
      }
    end

    let :params do
      { :mounts => {
        '/var/foo' => {
          'ensure' => 'present',
          'fstype' => 'nfs',
          'device' => '/net/foo',
        }
      } }
    end

    it {
      should contain_mount('/var/foo').with({
        'ensure' => 'present',
        'fstype' => 'nfs',
        'device' => '/net/foo',
      })
    }
  end

  context 'with the mounts parameter set to an incorrect type' do
    let :facts do
      { :osfamily          => 'RedHat',
        :lsbmajdistrelease => '6',
      }
    end

    let :params do
      { :mounts => 'i should be a hash' }
    end

    it 'should fail' do
      expect {
        should raise_error(Puppet::Error)
      }
    end
  end
end
