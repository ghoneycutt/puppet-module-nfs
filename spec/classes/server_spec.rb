require 'spec_helper'

describe 'nfs::server' do
  context 'with default params' do
    let( :facts) { {  'osfamily'          => 'RedHat',
                      'lsbmajdistrelease' => '6',
    } }

    it {
      should contain_file('exports_d').with({
        'path'   => '/tmp/exports.d',
        'ensure' => 'directory',
      })
      should contain_file('exports_d/header').with({
        'path' => '/tmp/exports.d/00-header',
        'content' => "#\n# This file is managed by pupped\n#\n",
      })
    }
  end

  context 'with custom exports data' do
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
