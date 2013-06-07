require 'spec_helper'

describe 'nfs::server::export' do

  context 'create file fragment for one client with default options on a supported platform' do
    let( :facts) { { 'osfamily'          => 'RedHat',
                     'lsbmajdistrelease' => '6',
    } }
    let( :title) { 'data' }
    let :params do
      {
        :clients     => [ '10.2.3.4' ],
        :export_path => '/srv/data',
      }
    end

    it {
      should contain_file('/etc/exports.d/data').with({
        'ensure' => 'present',
      })
      should contain_file('/etc/exports.d/data').with_content(
%{/srv/data 10.2.3.4(ro)
})
    }
  end

  context 'create file fragment for several clients with default options on a supported platform' do
    let( :facts) { { 'osfamily'          => 'RedHat',
                     'lsbmajdistrelease' => '6',
    } }
    let( :title) { 'data' }
    let :params do
      {
        :clients     => [ '10.2.3.4', '2.3.4.5', 'kalle' ],
        :export_path => '/srv/data',
      }
    end

    it {
      should contain_file('/etc/exports.d/data').with({
        'ensure' => 'present',
      })
      should contain_file('/etc/exports.d/data').with_content(
%{/srv/data 10.2.3.4(ro) 2.3.4.5(ro) kalle(ro)
})
    }
  end
end
