require 'spec_helper'
describe 'nfs' do
  supported_platforms = {
    'el6' => {
      osfamily:        'RedHat',
      release:         '6',
      include_idmap:   true,
      include_rpcbind: true,
      packages:        ['nfs-utils'],
      service:         'nfs',
      service_ensure:  'stopped',
      service_enable:  false,
      server:          true,
    },
    'el7' => {
      osfamily:        'RedHat',
      release:         '7',
      include_idmap:   true,
      include_rpcbind: true,
      packages:        ['nfs-utils'],
      service:         nil,
      service_ensure:  'stopped',
      service_enable:  false,
      server:          true,
    },
    'el8' => {
      osfamily:        'RedHat',
      release:         '8',
      include_idmap:   true,
      include_rpcbind: true,
      packages:        ['nfs-utils'],
      service:         nil,
      service_ensure:  'stopped',
      service_enable:  false,
      server:          true,
    },
    'solaris10' => {
      osfamily:        'Solaris',
      kernelrelease:   '5.10',
      include_idmap:   false,
      include_rpcbind: false,
      packages:        ['SUNWnfsckr', 'SUNWnfscr', 'SUNWnfscu', 'SUNWnfsskr', 'SUNWnfssr', 'SUNWnfssu'],
      service:         'nfs/client',
      service_ensure:  'running',
      service_enable:  true,
      server:          false,
    },
    'solaris11' => {
      osfamily:        'Solaris',
      kernelrelease:   '5.11',
      include_idmap:   false,
      include_rpcbind: false,
      packages:        ['service/file-system/nfs', 'system/file-system/nfs'],
      service:         'nfs/client',
      service_ensure:  'running',
      service_enable:  true,
      server:          false,
    },
    'suse11' => {
      osfamily:        'Suse',
      release:         '11',
      include_idmap:   true,
      include_rpcbind: false,
      packages:        ['nfs-client'],
      service:         'nfs',
      service_ensure:  'running',
      service_enable:  true,
      server:          false,
    },
    'suse12' => {
      osfamily:        'Suse',
      release:         '12',
      include_idmap:   true,
      include_rpcbind: false,
      packages:        ['nfs-client'],
      service:         'nfs',
      service_ensure:  'running',
      service_enable:  true,
      server:          false,
    },
  }

  unsupported_platforms = {
    'el5'      => { osfamily:  'RedHat',  release: '5' },
    'el9'      => { osfamily:  'RedHat',  release: '9' },
    'suse9'    => { osfamily:  'Suse',    release: '9' },
    'suse13'   => { osfamily:  'Suse',    release: '13' },
    'solaris9' => { osfamily:  'Solaris', kernelrelease: '5.9' },
    'weirdos'  => { osfamily:  'WeirdOS', release: '2.4.2' },
  }

  supported_platforms.sort.each do |_k, v|
    describe "on osfamily <#{v[:osfamily]}> when #{v[:release].nil? ? 'kernel' : 'operatingsystemmaj'}release is <#{v[:release]}#{v[:kernelrelease]}>" do
      let :facts do
        {
          os: {
            family:  v[:osfamily],
            release: {
              major: v[:release],
            },
          },
          kernelrelease:             v[:kernelrelease],
        }
      end

      # Building the array of Packages for service's subscribe attribute.
      service_subscribe_array = []
      v[:packages].each do |pkg|
        service_subscribe_array << "Package[#{pkg}]"
      end

      context 'with default values for parameters' do
        it { is_expected.to compile.with_all_deps }

        if v[:include_idmap] == true
          it { is_expected.to contain_class('nfs::idmap') }
        else
          it { is_expected.not_to contain_class('nfs::idmap') }
        end

        if v[:include_rpcbind] == true
          it { is_expected.to contain_class('rpcbind') }
        else
          it { is_expected.not_to contain_class('rpcbind') }
        end

        v[:packages].each do |pkg|
          it { is_expected.to contain_package(pkg).with_ensure('present') }
        end

        if v[:service]
          it do
            is_expected.to contain_service('nfs_service').with(
              {
                'ensure'    => v[:service_ensure],
                'name'      => v[:service],
                'enable'    => v[:service_enable],
                'subscribe' => service_subscribe_array,
              },
            )
          end
        else
          it { is_expected.not_to contain_service('nfs_service') }
        end
      end

      context 'with nfs_package specified as valid array [array]' do
        let(:params) { { nfs_package: ['array'] } }

        it { is_expected.to contain_package('array').with_ensure('present') }

        if v[:service]
          it { is_expected.to contain_service('nfs_service').with_subscribe(['Package[array]']) }
        end
      end

      context 'with nfs_package specified as valid array [test packages]' do
        let(:params) { { nfs_package: ['test', 'packages'] } }

        it { is_expected.to contain_package('test').with_ensure('present') }
        it { is_expected.to contain_package('packages').with_ensure('present') }

        if v[:service]
          it { is_expected.to contain_service('nfs_service').with_subscribe(['Package[test]', 'Package[packages]']) }
        end
      end

      context 'with nfs_service specified as valid string <nfs-test>' do
        let(:params) { { nfs_service: 'nfs-test' } }

        it { is_expected.to contain_service('nfs_service').with_name('nfs-test') }
      end

      context 'with nfs_service_ensure specified as valid string <running> and nfs_service is also specified' do
        let(:params) do
          {
            nfs_service_ensure: 'running',
            nfs_service:        'nfs-test',
          }
        end

        it { is_expected.to contain_service('nfs_service').with_ensure('running') }
      end

      context 'with nfs_service_enable specified as valid string <false> and nfs_service is also specified' do
        let(:params) do
          {
            nfs_service_enable: 'false',
            nfs_service:        'nfs-test',
          }
        end

        it { is_expected.to contain_service('nfs_service').with_enable('false') }
      end

      context 'with server specified as valid boolean <true>' do
        let(:params) { { server: true } }

        if v[:server]
          it do
            is_expected.to contain_file('nfs_exports').with(
              {
                'ensure' => 'file',
                'path'   => '/etc/exports',
                'owner'  => 'root',
                'group'  => 'root',
                'mode'   => '0644',
                'notify' => 'Exec[update_nfs_exports]',
              },
            )
          end

          it do
            is_expected.to contain_exec('update_nfs_exports').with(
              {
                'command'     => 'exportfs -ra',
                'path'        => '/bin:/usr/bin:/sbin:/usr/sbin',
                'refreshonly' => 'true',
              },
            )
          end

          if v[:service]
            it do
              is_expected.to contain_service('nfs_service').with(
                {
                  'ensure'    => 'running',
                  'enable'    => 'true',
                },
              )
            end
          else
            it { is_expected.not_to contain_service('nfs_service') }
          end

        else
          it 'fail' do
            expect { is_expected.to contain_class(:subject) }.to raise_error(Puppet::Error, %r{This platform is not configured to be an NFS server})
          end
        end
      end

      context 'with exports_path specified as valid string </test/exports> and server is set to true' do
        let(:params) do
          {
            exports_path: '/test/exports',
            server:       true,
          }
        end

        if v[:server]
          it { is_expected.to contain_file('nfs_exports').with_path('/test/exports') }
        else
          it 'fail' do
            expect { is_expected.to contain_class(:subject) }.to raise_error(Puppet::Error, %r{This platform is not configured to be an NFS server})
          end
        end
      end

      context 'with exports_owner specified as valid string <nfs_owner> and server is set to true' do
        let(:params) do
          {
            exports_owner: 'nfs_owner',
            server:        true,
          }
        end

        if v[:server]
          it { is_expected.to contain_file('nfs_exports').with_owner('nfs_owner') }
        else
          it 'fail' do
            expect { is_expected.to contain_class(:subject) }.to raise_error(Puppet::Error, %r{This platform is not configured to be an NFS server})
          end
        end
      end

      context 'with exports_group specified as valid string <nfs_group> and server is set to true' do
        let(:params) do
          {
            exports_group: 'nfs_group',
            server:        true,
          }
        end

        if v[:server]
          it { is_expected.to contain_file('nfs_exports').with_group('nfs_group') }
        else
          it 'fail' do
            expect { is_expected.to contain_class(:subject) }.to raise_error(Puppet::Error, %r{This platform is not configured to be an NFS server})
          end
        end
      end

      context 'with exports_mode specified as valid string <0242> and server is set to true' do
        let(:params) do
          {
            exports_mode: '0242',
            server:       true,
          }
        end

        if v[:server]
          it { is_expected.to contain_file('nfs_exports').with_mode('0242') }
        else
          it 'fail' do
            expect { is_expected.to contain_class(:subject) }.to raise_error(Puppet::Error, %r{This platform is not configured to be an NFS server})
          end
        end
      end
    end
  end

  describe 'with mounts specified as valid hash' do
    context 'when hiera_hash is set to true' do
      let(:params) do
        {
          mounts: {
            '/from/param' => {
              'ensure' => 'present',
              'fstype' => 'nfs',
              'device' => 'test:/from/param',
            }
          }
        }
      end

      it { is_expected.to have_types__mount_resource_count(1) }
      it do
        is_expected.to contain_types__mount('/from/hiera/fqdn').with(
          {
            'ensure' => 'present',
            'fstype' => 'nfs',
            'device' => 'test:/from/hiera/fqdn',
          },
        )
      end
    end

    context 'when hiera_hash is set to false' do
      let(:params) do
        {
          hiera_hash: false,
          mounts: {
            '/from/param' => {
              'ensure' => 'present',
              'fstype' => 'nfs',
              'device' => 'test:/from/param',
            }
          }
        }
      end

      it { is_expected.to have_types__mount_resource_count(1) }
      it do
        is_expected.to contain_types__mount('/from/param').with(
          {
            'ensure' => 'present',
            'fstype' => 'nfs',
            'device' => 'test:/from/param',
          },
        )
      end
    end
  end

  describe 'with hiera providing data from multiple levels' do
    let(:facts) do
      {
        fqdn: 'nfs.example.local',
        test: 'hiera_hash',
      }
    end

    context 'when hiera_hash set to valid boolean <true>' do
      it { is_expected.to have_types__mount_resource_count(2) }
      it { is_expected.to contain_types__mount('/from/hiera/test') }
      it { is_expected.to contain_types__mount('/from/hiera/fqdn') }
    end

    context 'when hiera_hash set to valid boolean <false>' do
      let(:params) { { hiera_hash: false } }

      it { is_expected.to have_types__mount_resource_count(1) }
      it { is_expected.to contain_types__mount('/from/hiera/fqdn') }
    end
  end

  unsupported_platforms.sort.each do |_k, v|
    describe "on unsupported [os][family] <#{v[:osfamily]}> when #{v[:release].nil? ? 'kernel' : '[os][release][major]'}release is <#{v[:release]}#{v[:kernelrelease]}>" do
      let :facts do
        {
          os: {
            family:  v[:osfamily],
            release: {
              major: v[:release],
            },
          },
          kernelrelease:             v[:kernelrelease],
        }
      end

      it 'fail' do
        expect { is_expected.to contain_class(:subject) }.to raise_error(Puppet::Error, %r{nfs module only supports})
      end
    end
  end

  describe 'variable type and content validations' do
    mandatory_params = {} if mandatory_params.nil?

    validations = {
      'absolute_path' => {
        name:    ['exports_path'],
        valid:   ['/absolute/filepath', '/absolute/directory/'],
        invalid: ['../invalid', 3, 2.42, ['array'], { 'ha' => 'sh' }, true, false, nil],
        message: '(expects a match for Variant\[Stdlib::Windowspath|expects a Stdlib::Absolutepath = Variant)', # Puppet 4|5
      },
      'array/string' => {
        name:    ['nfs_package'],
        valid:   ['string', ['array']],
        invalid: [{ 'ha' => 'sh' }, 3, 2.42, true],
        message: 'expects a value of type Array or String',
      },
      'boolean' => {
        name:    ['hiera_hash', 'server'],
        valid:   [true, false],
        invalid: ['true', 'false', ['array'], { 'ha' => 'sh' }, 3, 2.42, nil],
        message: 'expects a Boolean value',
      },
      'hash' => {
        name:    ['mounts'],
        valid:   [], # valid hashes are to complex to block test them here. types::mount is_expected.to have its own spec tests anyway.
        invalid: ['string', ['array'], 3, 2.42, true],
        message: 'expects a value of type Undef or Hash',
      },
      'string' => {
        name:    ['nfs_service', 'exports_owner', 'exports_group'],
        valid:   ['string'],
        invalid: [['array'], { 'ha' => 'sh' }, 3, 2.42, true],
        message: 'expects a String value',
      },
      'string for service enable' => {
        name:    ['nfs_service_enable'],
        valid:   ['true', 'false'], # /!\ removed 'manual' and 'mask' as it requires additinal work on provider features to be set
        invalid: [['array'], { 'ha' => 'sh' }, 3, 2.42, true],
        message: 'expects a String value',
      },
      'string for service ensure' => {
        name:    ['nfs_service_ensure'],
        valid:   ['stopped', 'running'],
        invalid: ['string', ['array'], { 'ha' => 'sh' }, 3, 2.42, true],
        message: '(expects a String value|valid values are stopped, running)',
      },
      'string for service mode' => {
        name:    ['exports_mode'],
        valid:   ['0777', '0644', '0242'],
        invalid: ['0999', ['array'], { 'ha' => 'sh' }, 3, 2.42, true],
        message: 'expects a match for Pattern\[\/\^\[0-7\]\{4\}\$\/\]',
      },
    }

    validations.sort.each do |type, var|
      mandatory_params = {} if mandatory_params.nil?
      var[:name].each do |var_name|
        var[:params] = {} if var[:params].nil?
        var[:valid].each do |valid|
          context "when #{var_name} (#{type}) is set to valid #{valid} (as #{valid.class})" do
            let(:facts) { [mandatory_facts, var[:facts]].reduce(:merge) } unless var[:facts].nil?
            let(:params) { [mandatory_params, var[:params], { "#{var_name}": valid, }].reduce(:merge) }

            it { is_expected.to compile }
          end
        end

        var[:invalid].each do |invalid|
          context "when #{var_name} (#{type}) is set to invalid #{invalid} (as #{invalid.class})" do
            let(:params) { [mandatory_params, var[:params], { "#{var_name}": invalid, }].reduce(:merge) }

            it 'fail' do
              expect { is_expected.to contain_class(:subject) }.to raise_error(Puppet::Error, %r{#{var[:message]}})
            end
          end
        end
      end # var[:name].each
    end # validations.sort.each
  end # describe 'variable type and content validations'
end
