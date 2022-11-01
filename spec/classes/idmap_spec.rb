require 'spec_helper'
describe 'nfs::idmap' do
  supported_platforms = {
    'el6' => {
      :osfamily              => 'RedHat',
      :release               => '6',
      :idmapd_service_ensure => 'running',
      :idmap_package         => 'nfs-utils-lib',
      :idmap_service_name    => 'rpcidmapd',
      :pipefs_directory      => nil,
    },
    'el7' => {
      :osfamily              => 'RedHat',
      :release               => '7',
      :idmapd_service_ensure => 'stopped',
      :idmap_package         => 'libnfsidmap',
      :idmap_service_name    => 'nfs-idmap',
      :pipefs_directory      => nil,
    },
    'el8' => {
      :osfamily              => 'RedHat',
      :release               => '8',
      :idmapd_service_ensure => 'stopped',
      :idmap_package         => 'libnfsidmap',
      :idmap_service_name    => 'nfs-idmapd',
      :pipefs_directory      => nil,
    },
    'el9' => {
      :osfamily              => 'RedHat',
      :release               => '9',
      :idmapd_service_ensure => 'stopped',
      :idmap_package         => 'libnfsidmap',
      :idmap_service_name    => 'nfs-idmapd',
      :pipefs_directory      => nil,
    },
    'suse' => {
      :osfamily              => 'Suse',
      :release               => '12',
      :idmapd_service_ensure => nil,
      :idmap_package         => 'nfsidmap',
      :idmap_service_name    => nil,
      :pipefs_directory      => '/var/lib/nfs/rpc_pipefs',
    },
  }

  unsupported_platforms = {
    'el5'      => { :osfamily => 'RedHat',  :release => '5' },
    'el10'     => { :osfamily => 'RedHat',  :release => '10' },
    'solaris9' => { :osfamily => 'Solaris', :kernelrelease => '5.9' },
    'weirdos'  => { :osfamily => 'WeirdOS', :release => '2.4.2' },
  }

  supported_platforms.sort.each do |_k, v|
    describe "on osfamily <#{v[:osfamily]}> when operatingsystemmajrelease is <#{v[:release]}>" do
      let :facts do
        {
          :osfamily                  => v[:osfamily],
          :operatingsystemmajrelease => v[:release],
          :kernelrelease             => v[:kernelrelease],
        }
      end

      it { should compile.with_all_deps }

      it { should contain_package(v[:idmap_package]).with_ensure('present') }

      it do
        should contain_file('idmapd_conf').with({
          'ensure'  => 'file',
          'path'    => '/etc/idmapd.conf',
          'content' => File.read(fixtures("idmapd_conf.#{v[:osfamily]}")),
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0644',
          'require' => "Package[#{v[:idmap_package]}]",
        })
      end

      if v[:osfamily] == 'RedHat'
        it do
          should contain_service('idmapd_service').with({
            'ensure'     => v[:idmapd_service_ensure],
            'name'       => v[:idmap_service_name],
            'enable'     => 'true',
            'hasstatus'  => 'true',
            'hasrestart' => 'true',
            'subscribe'  => 'File[idmapd_conf]',
          })
        end
      else
        it { should_not contain_service('idmapd_service') }
      end
    end
  end

  context 'with idmap_package specified as valid string <test_package>' do
    let(:params) { { :idmap_package => 'test_package' } }
    it { should contain_package('test_package').with_ensure('present') }
    it { should contain_file('idmapd_conf').with_require('Package[test_package]') }
  end

  context 'with idmapd_conf_path specified as valid string </test/idmapd.conf>' do
    let(:params) { { :idmapd_conf_path => '/test/idmapd.conf' } }
    it { should contain_file('idmapd_conf').with_path('/test/idmapd.conf') }
  end

  context 'with idmapd_conf_owner specified as valid string <test_owner>' do
    let(:params) { { :idmapd_conf_owner => 'test_owner' } }
    it { should contain_file('idmapd_conf').with_owner('test_owner') }
  end

  context 'with idmapd_conf_group specified as valid string <test_group>' do
    let(:params) { { :idmapd_conf_group => 'test_group' } }
    it { should contain_file('idmapd_conf').with_group('test_group') }
  end

  context 'with idmapd_conf_mode specified as valid string <0242>' do
    let(:params) { { :idmapd_conf_mode => '0242' } }
    it { should contain_file('idmapd_conf').with_mode('0242') }
  end

  # RedHat only service parameters
  %w[RedHat Suse].each do |os|
    describe "on #{os}" do
      let(:facts) { { :osfamily => os } }

      context 'with idmapd_service_name specified as valid string <idmapd-test>' do
        let(:params) { { :idmapd_service_name => 'idmapd-test' } }
        if os == 'RedHat'
          it { should contain_service('idmapd_service').with_name('idmapd-test') }
        else
          it { should_not contain_service('idmapd_service') }
        end
      end

      context 'with idmapd_service_ensure specified as valid string <true>' do
        let(:params) { { :idmapd_service_ensure => 'true' } }
        if os == 'RedHat'
          it { should contain_service('idmapd_service').with_ensure('true') }
        else
          it { should_not contain_service('idmapd_service') }
        end
      end

      context 'with idmapd_service_enable specified as valid boolean false' do
        let(:params) { { :idmapd_service_enable => false } }
        if os == 'RedHat'
          it { should contain_service('idmapd_service').with_enable('false') }
        else
          it { should_not contain_service('idmapd_service') }
        end
      end

      context 'with idmapd_service_hasstatus specified as valid boolean false' do
        let(:params) { { :idmapd_service_hasstatus => false } }
        if os == 'RedHat'
          it { should contain_service('idmapd_service').with_hasstatus('false') }
        else
          it { should_not contain_service('idmapd_service') }
        end
      end

      context 'with idmapd_service_hasrestart specified as valid boolean false' do
        let(:params) { { :idmapd_service_hasrestart => false } }
        if os == 'RedHat'
          it { should contain_service('idmapd_service').with_hasrestart('false') }
        else
          it { should_not contain_service('idmapd_service') }
        end
      end
    end
  end

  context 'with idmap_domain specified as valid string <idmapd.testing.local>' do
    let(:params) { { :idmap_domain => 'idmapd.testing.local' } }
    it { should contain_file('idmapd_conf').with_content(/^Domain = idmapd.testing.local$/) }
  end

  context 'with ldap_server specified as valid string <ldap.testing.local>' do
    let(:params) { { :ldap_server => 'ldap.testing.local' } }
    it { should contain_file('idmapd_conf').with_content(/^LDAP_server = ldap.testing.local$/) }
  end

  context 'with ldap_base specified as valid string <dc=local,dc=testing>' do
    let(:params) { { :ldap_base => 'dc=local,dc=testing' } }
    it { should contain_file('idmapd_conf').with_content(/^LDAP_base = dc=local,dc=testing$/) }
  end

  context 'with ldap_base specified as valid array [<dc=local,dc=test1>, <dc=local,dc=test2>]' do
    let(:params) { { :ldap_base => ['dc=local,dc=test1', 'dc=local,dc=test2'] } }
    it { should contain_file('idmapd_conf').with_content(/^LDAP_base = dc=local,dc=test1,dc=local,dc=test2$/) }
  end

  context 'with local_realms specified as valid string <realms.testing.local>' do
    let(:params) { { :local_realms => 'realms.testing.local' } }
    it { should contain_file('idmapd_conf').with_content(/^#Local-Realms = REALMS.TESTING.LOCAL$/) }
  end

  context 'with local_realms specified as valid array [<realm1.test.local>, <realm2.test.local>]' do
    let(:params) { { :local_realms => ['realm1.test.local', 'realm2.test.local'] } }
    it { should contain_file('idmapd_conf').with_content(/^#Local-Realms = REALM1.TEST.LOCAL,REALM2.TEST.LOCAL$/) }
  end

  context 'with translation_method as valid string <umich_ldap>' do
    let(:params) { { :translation_method => 'umich_ldap' } }
    it { should contain_file('idmapd_conf').with_content(/^Method = umich_ldap$/) }
  end

  context 'with translation_method as valid array [<umich_ldap>, <static>]' do
    let(:params) { { :translation_method => %w[umich_ldap static] } }
    it { should contain_file('idmapd_conf').with_content(/^Method = umich_ldap,static$/) }
  end

  context 'with nobody_user as valid string <somebody>' do
    let(:params) { { :nobody_user => 'somebody' } }
    it { should contain_file('idmapd_conf').with_content(/^Nobody-User = somebody$/) }
  end

  context 'with nobody_group as valid string <somegroup>' do
    let(:params) { { :nobody_group => 'somegroup' } }
    it { should contain_file('idmapd_conf').with_content(/^Nobody-Group = somegroup$/) }
  end

  context 'with verbosity as valid integer <242>' do
    let(:params) { { :verbosity => 242 } }
    it { should contain_file('idmapd_conf').with_content(/^Verbosity = 242$/) }
  end

  context 'with pipefs_directory as valid string </test/rpc_pipefs>' do
    let(:params) { { :pipefs_directory => '/test/rpc_pipefs' } }
    it { should contain_file('idmapd_conf').with_content(%r{^Pipefs-Directory = /test/rpc_pipefs$}) }
  end

  unsupported_platforms.sort.each do |_k, v|
    describe "on unsupported osfamily <#{v[:osfamily]}> when #{v[:release].nil? ? 'kernel' : 'operatingsystemmaj'}release is <#{v[:release]}#{v[:kernelrelease]}>" do
      let :facts do
        {
          :osfamily                  => v[:osfamily],
          :operatingsystemmajrelease => v[:release],
          :kernelrelease             => v[:kernelrelease],
        }
      end

      it 'should fail' do
        expect { should contain_class(subject) }.to raise_error(Puppet::Error, /idmap only supports/)
      end
    end
  end

  describe 'variable type and content validations' do
    mandatory_params = {} if mandatory_params.nil?

    validations = {
      'absolute_path' => {
        :name    => %w[idmapd_conf_path pipefs_directory],
        :valid   => %w[/absolute/filepath /absolute/directory/],
        :invalid => ['../invalid', 3, 2.42, %w[array], { 'ha' => 'sh' }, true, false, nil],
        :message => '(expects a match for Variant\[Stdlib::Windowspath|expects a Stdlib::Absolutepath = Variant)', # Puppet 4|5
      },
      'array/string translation_method' => {
        :name    => %w[translation_method],
        :valid   => ['nsswitch', 'umich_ldap', 'static', %w[nsswitch static]],
        :invalid => ['string', { 'ha' => 'sh' }, 3, 2.42, true],
        :message => 'expects a value of type Array or Pattern',

      },
      'boolean' => {
        :name    => %w[idmapd_service_enable idmapd_service_hasstatus idmapd_service_hasrestart],
        :valid   => [true, false],
        :invalid => ['true', 'false', %w[array], { 'ha' => 'sh' }, 3, 2.42, nil],
        :message => 'expects a Boolean value',
      },
      'integer' => {
        :name    => %w[verbosity],
        :valid   => [3, 242],
        :invalid => ['3', %w[array], { 'ha' => 'sh' }, 2.42, true, nil],
        :message => 'Evaluation Error: Error while evaluating a Resource Statement',
      },
      'string' => {
        :name    => %w[idmap_package idmapd_conf_owner idmapd_conf_group idmapd_service_name nobody_user nobody_group],
        :valid   => %w[string],
        :invalid => [%w[array], { 'ha' => 'sh' }, 3, 2.42, true],
        :message => 'expects a String value',
      },
      'string/array' => {
        :name    => %w[local_realms],
        :valid   => ['string', %w[array]],
        :invalid => [{ 'ha' => 'sh' }, 3, 2.42, true],
        :message => 'expects a value of type String or Array,',
      },
      'string for domain' => {
        :name    => %w[idmap_domain],
        :valid   => %w[test.domain],
        :invalid => ['test,domain', %w[array], { 'ha' => 'sh' }, 3, 2.42, true],
        :message => '(expects a String value|is not a valid name)',
      },
      'string for service ensure' => {
        :name    => %w[idmapd_service_ensure],
        :valid   => %w[stopped running],
        :invalid => ['string', %w[array], { 'ha' => 'sh' }, 3, 2.42, true],
        :message => '(expects a String value|Valid values are stopped, running)',
      },
      'string for mode' => {
        :name    => %w[idmapd_conf_mode],
        :valid   => %w[0777 0644 0242],
        :invalid => ['0999', %w[array], { 'ha' => 'sh' }, 3, 2.42, true],
        :message => 'expects a match for Pattern\[\/\^\[0-7\]\{4\}\$\/\]',
      },
      'undef/string' => {
        :name    => %w[ldap_server],
        :valid   => %w[string],
        :invalid => [%w[array], { 'ha' => 'sh' }, 3, 2.42, true],
        :message => 'expects a value of type Undef or String',
      },
      'undef/string for domain' => {
        :name    => %w[ldap_server],
        :valid   => %w[test.domain],
        :invalid => ['test,domain', %w[array], { 'ha' => 'sh' }, 3, 2.42, true],
        :message => '(expects a value of type Undef or String|is not a valid name)',
      },
      'undef/string/array' => {
        :name    => %w[ldap_base],
        :valid   => ['string', %w[array]],
        :invalid => [{ 'ha' => 'sh' }, 3, 2.42, true],
        :message => 'expects a value of type Undef, String, or Array',
      },
    }

    validations.sort.each do |type, var|
      var[:name].each do |var_name|
        var[:params] = {} if var[:params].nil?
        var[:valid].each do |valid|
          context "when #{var_name} (#{type}) is set to valid #{valid} (as #{valid.class})" do
            let(:params) { [mandatory_params, var[:params], { :"#{var_name}" => valid, }].reduce(:merge) }
            it { should compile }
          end
        end

        var[:invalid].each do |invalid|
          context "when #{var_name} (#{type}) is set to invalid #{invalid} (as #{invalid.class})" do
            let(:params) { [mandatory_params, var[:params], { :"#{var_name}" => invalid, }].reduce(:merge) }
            it { is_expected.to compile.and_raise_error(/#{var[:message]}/) }
          end
        end
      end # var[:name].each
    end # validations.sort.each
  end # describe 'variable type and content validations'
end
