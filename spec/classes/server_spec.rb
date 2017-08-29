require 'spec_helper'
describe 'nfs::server' do

  ['6','7'].each do |ver|
    context "with default values for parameters on EL #{ver}" do
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
            'require'    => 'File[nfs_exports]',
          })
        }
      end
    end
  end
end
