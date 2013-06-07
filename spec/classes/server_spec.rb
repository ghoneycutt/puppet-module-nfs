require 'spec_helper'

describe 'nfs::server' do
  context 'with default params on supported platform' do
    let( :facts) { {  'osfamily'          => 'RedHat',
                      'lsbmajdistrelease' => '6',
    } }

    it {
      should contain_file('exports_d').with({
        'path'   => '/etc/exports.d',
        'ensure' => 'directory',
      })
      should contain_file('exports_d/header').with({
        'path' => '/etc/exports.d/00-header',
        'content' => "# This file is being maintained by Puppet\n# DO NOT EDIT\n",
      })
    }
  end
  context 'with custom exports data on supported platform' do
    let( :facts) { {  'osfamily'          => 'RedHat',
                      'lsbmajdistrelease' => '6',
    } }
    let( :params) { { 'exports_data' =>
      { 'data' => {
        'export_path' => '/srv/data',
        'clients'     => [ '10.2.3.4' ],
        'options'     => 'rw',
      } },
      'exports_owner' => 'qnilpau',
      'exports_group' => 'gbgusers',
      'exports_mode'  => '0644',
    } }

    it {
      should contain_file('exports_file').with({
        'owner'  => 'qnilpau',
        'group'  => 'gbgusers',
        'mode'   => '0644',
        'ensure' => 'file',
      })

    }
  end
end
