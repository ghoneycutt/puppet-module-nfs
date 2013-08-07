require 'spec_helper'

describe 'nfs::server' do

  context 'with default options' do
    let :facts do
      {
        :osfamily          => 'RedHat',
        :lsbmajdistrelease => '6',
      }
    end

    it { should include_class('nfs') }
    it { should include_class('nfs::idmap') }
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
