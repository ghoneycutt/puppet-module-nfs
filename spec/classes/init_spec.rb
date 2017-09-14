require 'spec_helper'
describe 'nfs' do
  let(:params) { { :hiera_hash => false } }

  describe 'on unsupported' do
    context 'osfamily' do
      let(:facts) { { :osfamily => 'Unsupported' } }

      it 'should fail' do
        expect {
          should raise_error(Puppet::Error, /nfs module only supports osfamilies RedHat, Solaris and Suse, and <Unsupported> was detected\./)
        }
      end
    end

    context 'version of EL' do
      let :facts do
        { :osfamily                  => 'RedHat',
          :operatingsystemmajrelease => '4',
        }
      end

      it 'should fail' do
        expect {
          should raise_error(Puppet::Error, /nfs module only supports EL 6 and 7 and operatingsystemmajrelease was detected as <4>\./)
        }
      end
    end

    context 'version of Suse' do
      let :facts do
        { :osfamily          => 'Suse',
          :operatingsystemmajrelease => '9',
        }
      end

      it 'should fail' do
        expect {
          should raise_error(Puppet::Error, /nfs module only supports Suse 11 and 12 and operatingsystemmajrelease was detected as <9>\./)
        }
      end
    end

    context 'version of Solaris' do
      let :facts do
        { :osfamily          => 'Solaris',
          :kernelrelease => '5.8',
        }
      end

      it 'should fail' do
        expect {
          should raise_error(Puppet::Error, /nfs module only supports Solaris 5\.10 and 5\.11 and kernelrelease was detected as <5\.8>\./)
        }
      end
    end
  end

  platforms = {
    'el6' =>
      { :osfamily        => 'RedHat',
        :release         => '6',
        :include_idmap   => true,
        :include_rpcbind => true,
        :packages        => ['nfs-utils',],
        :service         => 'nfs',
        :service_ensure  => 'stopped',
        :service_enable  => false,
      },
    'el7' =>
      { :osfamily        => 'RedHat',
        :release         => '7',
        :include_idmap   => true,
        :include_rpcbind => true,
        :packages        => ['nfs-utils',],
        :service         => nil,
        :service_ensure  => 'stopped',
        :service_enable  => false,
      },
    'solaris10' =>
      { :osfamily        => 'Solaris',
        :kernelrelease   => '5.10',
        :include_idmap   => false,
        :include_rpcbind => false,
        :packages        => ['SUNWnfsckr','SUNWnfscr','SUNWnfscu','SUNWnfsskr','SUNWnfssr','SUNWnfssu'],
        :service         => 'nfs/client',
        :service_ensure  => 'running',
        :service_enable  => true,
      },
    'solaris11' =>
      { :osfamily        => 'Solaris',
        :kernelrelease   => '5.11',
        :include_idmap   => false,
        :include_rpcbind => false,
        :packages        => ['service/file-system/nfs','system/file-system/nfs'],
        :service         => 'nfs/client',
        :service_ensure  => 'running',
        :service_enable  => true,
      },
    'suse11' =>
      { :osfamily        => 'Suse',
        :release         => '11',
        :include_idmap   => true,
        :include_rpcbind => false,
        :packages        => ['nfs-client',],
        :service         => 'nfs',
        :service_ensure  => 'running',
        :service_enable  => true,
      },
    'suse12' =>
      { :osfamily        => 'Suse',
        :release         => '12',
        :include_idmap   => true,
        :include_rpcbind => false,
        :packages        => ['nfs-client',],
        :service         => 'nfs',
        :service_ensure  => 'running',
        :service_enable  => true,
      },
  }
  describe 'with default values for parameters' do
    platforms.sort.each do |k,v|
      context "where osfamily is <#{v[:osfamily]}> kernelrelease is <#{v[:kernelrelease]}> and release is <#{v[:release]}>" do
        let :facts do
          { :osfamily                  => v[:osfamily],
            :operatingsystemmajrelease => v[:release],
            :kernelrelease             => v[:kernelrelease],
          }
        end

        # This is to build an array such that it will be accepted by the
        # service's subscribe attribute.
        service_subscribe = Array.new

        it { should compile.with_all_deps }

        if v[:include_idmap] == true
          it { should contain_class('nfs::idmap') }
        else
          it { should_not contain_class('nfs::idmap') }
        end

        if v[:include_rpcbind] == true
          it { should contain_class('rpcbind') }
        else
          it { should_not contain_class('rpcbind') }
        end

        v[:packages].each do |pkg|
          it {
            should contain_package(pkg).with({
              'ensure' => 'present',
            })
          }
          # Building the array of Packages for service's subscribe attribute.
          service_subscribe << "Package[#{pkg}]"
        end

        if v[:service]
          it {
            should contain_service('nfs_service').with({
              'ensure'    => v[:service_ensure],
              'name'      => v[:service],
              'enable'    => v[:service_enable],
              'subscribe' => service_subscribe,
            })
          }
        else
          it { should_not contain_service('nfs_service') }
        end
      end
    end
  end

  describe 'with hiera_hash parameter specified' do
    context 'as a non-boolean' do
      let(:params) { { :hiera_hash => 'not_a_boolean' } }
      let(:facts) do
        { :osfamily                  => 'RedHat',
          :operatingsystemmajrelease => '6',
        }
      end

      it 'should fail' do
        expect { should raise_error(Puppet::Error) }
      end
    end

    [true].each do |value|
      context "as #{value}" do
        let(:params) { { :hiera_hash => value } }
        let(:facts) do
          { :osfamily                  => 'RedHat',
            :operatingsystemmajrelease => '6',
          }
        end

        it { should compile.with_all_deps }

        it { should contain_class('nfs') }
      end
    end

    [false].each do |value|
      context "as #{value}" do
        let(:params) { { :hiera_hash => value } }
        let(:facts) do
          { :osfamily                  => 'RedHat',
            :operatingsystemmajrelease => '6',
          }
        end

        it { should compile.with_all_deps }

        it { should contain_class('nfs') }
      end
    end
  end

  context 'with the mounts parameter set' do
    let :facts do
      { :osfamily                  => 'RedHat',
        :operatingsystemmajrelease => '6',
      }
    end

    let :params do
      {
        :hiera_hash => false,
        :mounts     => {
          '/var/foo' => {
            'ensure' => 'present',
            'fstype' => 'nfs',
            'device' => '/net/foo',
          }
        }
      }
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
      { :osfamily                  => 'RedHat',
        :operatingsystemmajrelease => '6',
      }
    end

    let :params do
      { :mounts => 'i should be a hash' }
    end

    it 'should fail' do
      expect { should raise_error(Puppet::Error) }
    end
  end

  describe 'with server set to true' do
    let :params do
      {
        :server => true,
      }
    end

    ['6','7'].each do |ver|
      context "and with default values for parameters on EL #{ver}" do
        let :facts do
          {
            :osfamily                  => 'RedHat',
            :operatingsystemmajrelease => ver,
          }
        end

        it { should compile.with_all_deps }

        it { should contain_class('nfs') }
        it { should contain_class('nfs::idmap') }

        it {
          should contain_file('nfs_exports').with({
            'ensure' => 'file',
            'path'   => '/etc/exports',
            'owner'  => 'root',
            'group'  => 'root',
            'mode'   => '0644',
            'notify' => 'Exec[update_nfs_exports]',
          })
        }

        it {
          should contain_exec('update_nfs_exports').with({
            'command'     => 'exportfs -ra',
            'path'        => '/bin:/usr/bin:/sbin:/usr/sbin',
            'refreshonly' => 'true',
          })
        }

        if ver == '7'
          it { should_not contain_service('nfs_service') }
        else
          it {
            should contain_service('nfs_service').with({
              'ensure'     => 'running',
              'name'       => 'nfs',
              'enable'     => 'true',
              'hasstatus'  => 'true',
              'hasrestart' => 'true',
              'require'    => 'Exec[update_nfs_exports]',
            })
          }
        end
      end
    end
  end
end
