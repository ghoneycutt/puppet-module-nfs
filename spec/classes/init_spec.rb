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

  context 'on unsupported lsbdistid of osfamily Debian' do
    let :facts do
      {
        :osfamily  => 'Debian',
        :lsbdistid => 'unsupported',
      }
    end

    it 'should fail' do
      expect {
        should raise_error(Puppet::Error, /nfs module only supports lsbdistid Debian and Ubuntu of osfamily Debian. Detected lsbdistid is <unsupported>./)
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

    it { should compile.with_all_deps }

    it { should contain_class('nfs::idmap') }
    it { should_not contain_class('rpcbind') }

    it {
      should contain_package('nfs_package').with({
        'ensure' => 'installed',
        'name'   => 'nfs-utils',
      })
    }

    it {
      should contain_service('nfs_service').with({
        'ensure'    => 'running',
        'name'      => 'nfs',
        'enable'    => true,
        'subscribe' => 'Package[nfs_package]',
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

    it { should compile.with_all_deps }

    it { should contain_class('nfs::idmap') }
    it { should contain_class('rpcbind') }

    it {
      should contain_package('nfs_package').with({
        'ensure' => 'installed',
        'name'   => 'nfs-utils',
      })
    }

    it {
      should contain_service('nfs_service').with({
        'ensure'    => 'running',
        'name'      => 'nfs',
        'enable'    => true,
        'subscribe' => 'Package[nfs_package]',
      })
    }
  end

  context 'on Ubuntu' do
    let(:facts) do
      { :osfamily  => 'Debian',
        :lsbdistid => 'Ubuntu',
      }
    end

    it { should compile.with_all_deps }

    it { should_not contain_class('nfs::idmap') }
    it { should contain_class('rpcbind') }

    it {
      should contain_package('nfs_package').with({
        'ensure' => 'installed',
        'name'   => 'nfs-common',
      })
    }

    it {
      should_not contain_service('nfs_service').with({
        'ensure'    => 'running',
        'name'      => 'nfs-common',
        'enable'    => true,
        'subscribe' => 'Package[nfs_package]',
      })
    }
  end

  context 'on Debian' do
    let(:facts) do
      { :osfamily  => 'Debian',
        :lsbdistid => 'Debian',
      }
    end

    it { should compile.with_all_deps }

    it { should_not contain_class('nfs::idmap') }
    it { should contain_class('rpcbind') }

    it {
      should contain_package('nfs_package').with({
        'ensure' => 'installed',
        'name'   => 'nfs-common',
      })
    }

    it {
      should contain_service('nfs_service').with({
        'ensure'    => 'running',
        'name'      => 'nfs-common',
        'enable'    => true,
        'subscribe' => 'Package[nfs_package]',
      })
    }
  end

  context 'on Suse' do
    let(:facts) { { :osfamily => 'Suse' } }

    it { should compile.with_all_deps }

    it { should contain_class('nfs::idmap') }
    it { should_not contain_class('rpcbind') }

    it {
      should contain_package('nfs_package').with({
        'ensure' => 'installed',
        'name'   => 'nfs-client',
      })
    }

    it {
      should contain_service('nfs_service').with({
        'ensure'    => 'running',
        'name'      => 'nfs',
        'enable'    => true,
        'subscribe' => 'Package[nfs_package]',
      })
    }
  end

  context 'on Solaris' do
    let(:facts) { { :osfamily => 'Solaris' } }

    it { should compile.with_all_deps }

    it { should_not contain_class('nfs::idmap') }
    it { should_not contain_class('rpcbind') }

    it {
      should contain_package('nfs_package').with({
        'ensure' => 'installed',
        'name'   => [ 'SUNWnfsckr',
                      'SUNWnfscr',
                      'SUNWnfscu',
                      'SUNWnfsskr',
                      'SUNWnfssr',
                      'SUNWnfssu' ],
      })
    }

    it {
      should contain_service('nfs_service').with({
        'ensure'    => 'running',
        'name'      => 'nfs/client',
        'enable'    => true,
        'subscribe' => 'Package[nfs_package]',
      })
    }
  end

  describe 'with hiera_hash parameter specified' do
    context 'as a non-boolean' do
      let(:params) { { :hiera_hash => 'not_a_boolean' } }
      let(:facts) do
        { :osfamily          => 'RedHat',
          :lsbmajdistrelease => '6',
        }
      end

      it 'should fail' do
        expect { should raise_error(Puppet::Error) }
      end
    end

    ['true',true].each do |value|
      context "as #{value}" do
        let(:params) { { :hiera_hash => value } }
        let(:facts) do
          { :osfamily          => 'RedHat',
            :lsbmajdistrelease => '6',
          }
        end

        it { should compile.with_all_deps }

        it { should contain_class('nfs') }
      end
    end

    ['false',false].each do |value|
      context "as #{value}" do
        let(:params) { { :hiera_hash => value } }
        let(:facts) do
          { :osfamily          => 'RedHat',
            :lsbmajdistrelease => '6',
          }
        end

        it { should compile.with_all_deps }

        it { should contain_class('nfs') }
      end
    end
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
