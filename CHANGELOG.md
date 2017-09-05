# Change Log

## [v2.0.0](https://github.com/ghoneycutt/puppet-module-nfs/tree/v2.0.0)

[Full Changelog](https://github.com/ghoneycutt/puppet-module-nfs/compare/v1.13.0...v2.0.0)

**Closed issues:**

- idmapd service should not be running on RedHat 7 [\#77](https://github.com/ghoneycutt/puppet-module-nfs/issues/77)
- client services [\#76](https://github.com/ghoneycutt/puppet-module-nfs/issues/76)
- mount directories [\#75](https://github.com/ghoneycutt/puppet-module-nfs/issues/75)
- ghoneycutt-common dependency conflict? [\#73](https://github.com/ghoneycutt/puppet-module-nfs/issues/73)
- nfs\_service missing dependencies under Solaris/OmniOS [\#63](https://github.com/ghoneycutt/puppet-module-nfs/issues/63)
- Is there an inheritance issue in nfs::server? [\#50](https://github.com/ghoneycutt/puppet-module-nfs/issues/50)
- On RHEL7 $default\_nfs\_service is undef should be 'nfs-server'? [\#49](https://github.com/ghoneycutt/puppet-module-nfs/issues/49)
- Module doesn't function.... [\#48](https://github.com/ghoneycutt/puppet-module-nfs/issues/48)
- CentOS requires the package redhat-lsb [\#41](https://github.com/ghoneycutt/puppet-module-nfs/issues/41)
- suse 10 or 11 or both need sysconfig set to use TCP for nfs mount protocol [\#12](https://github.com/ghoneycutt/puppet-module-nfs/issues/12)
- SuSE and Solaris support [\#4](https://github.com/ghoneycutt/puppet-module-nfs/issues/4)
- create define - nfs::export [\#1](https://github.com/ghoneycutt/puppet-module-nfs/issues/1)

**Merged pull requests:**

- Document known issue with Suse [\#80](https://github.com/ghoneycutt/puppet-module-nfs/pull/80) ([ghoneycutt](https://github.com/ghoneycutt))
- V2 [\#78](https://github.com/ghoneycutt/puppet-module-nfs/pull/78) ([ghoneycutt](https://github.com/ghoneycutt))

## [v1.13.0](https://github.com/ghoneycutt/puppet-module-nfs/tree/v1.13.0) (2017-02-27)
[Full Changelog](https://github.com/ghoneycutt/puppet-module-nfs/compare/v1.12.1...v1.13.0)

**Merged pull requests:**

- Support Puppet \>= 4.9 [\#74](https://github.com/ghoneycutt/puppet-module-nfs/pull/74) ([Phil-Friderici](https://github.com/Phil-Friderici))

## [v1.12.1](https://github.com/ghoneycutt/puppet-module-nfs/tree/v1.12.1) (2016-11-18)
[Full Changelog](https://github.com/ghoneycutt/puppet-module-nfs/compare/v1.12.0...v1.12.1)

**Merged pull requests:**

- Fix deps [\#72](https://github.com/ghoneycutt/puppet-module-nfs/pull/72) ([ghoneycutt](https://github.com/ghoneycutt))

## [v1.12.0](https://github.com/ghoneycutt/puppet-module-nfs/tree/v1.12.0) (2016-08-31)
[Full Changelog](https://github.com/ghoneycutt/puppet-module-nfs/compare/v1.11.3...v1.12.0)

**Merged pull requests:**

- Add support for Ruby v2.3.1 [\#71](https://github.com/ghoneycutt/puppet-module-nfs/pull/71) ([ghoneycutt](https://github.com/ghoneycutt))

## [v1.11.3](https://github.com/ghoneycutt/puppet-module-nfs/tree/v1.11.3) (2016-05-24)
[Full Changelog](https://github.com/ghoneycutt/puppet-module-nfs/compare/v1.11.2...v1.11.3)

**Merged pull requests:**

- Support Puppet 4.5 [\#70](https://github.com/ghoneycutt/puppet-module-nfs/pull/70) ([Phil-Friderici](https://github.com/Phil-Friderici))

## [v1.11.2](https://github.com/ghoneycutt/puppet-module-nfs/tree/v1.11.2) (2015-12-15)
[Full Changelog](https://github.com/ghoneycutt/puppet-module-nfs/compare/v1.11.1...v1.11.2)

## [v1.11.1](https://github.com/ghoneycutt/puppet-module-nfs/tree/v1.11.1) (2015-12-15)
[Full Changelog](https://github.com/ghoneycutt/puppet-module-nfs/compare/v1.11.0...v1.11.1)

**Closed issues:**

- nfs::mount ensure: mounted does not work [\#45](https://github.com/ghoneycutt/puppet-module-nfs/issues/45)

**Merged pull requests:**

- Puppet v430 [\#64](https://github.com/ghoneycutt/puppet-module-nfs/pull/64) ([ghoneycutt](https://github.com/ghoneycutt))

## [v1.11.0](https://github.com/ghoneycutt/puppet-module-nfs/tree/v1.11.0) (2015-09-18)
[Full Changelog](https://github.com/ghoneycutt/puppet-module-nfs/compare/v1.10.0...v1.11.0)

**Closed issues:**

- Using nfs::idmap on Debian 7, a proposed patch [\#61](https://github.com/ghoneycutt/puppet-module-nfs/issues/61)
- On RHEL 6.3 using facter version 1.6.18 the fact "$operatingsystemmajrelease" is not defined this affects nfs::idmap.pp [\#58](https://github.com/ghoneycutt/puppet-module-nfs/issues/58)
-  Missing package for idmap service on rhel7 in nfs::idmap [\#55](https://github.com/ghoneycutt/puppet-module-nfs/issues/55)
- puppet 4 compatibility [\#53](https://github.com/ghoneycutt/puppet-module-nfs/issues/53)

**Merged pull requests:**

- Add Suse 12 support [\#62](https://github.com/ghoneycutt/puppet-module-nfs/pull/62) ([jwennerberg](https://github.com/jwennerberg))
- Fix Travis-ci matrix so that each feature release is tested [\#60](https://github.com/ghoneycutt/puppet-module-nfs/pull/60) ([ghoneycutt](https://github.com/ghoneycutt))
- Test against latest bugfix of each feature release [\#57](https://github.com/ghoneycutt/puppet-module-nfs/pull/57) ([ghoneycutt](https://github.com/ghoneycutt))

## [v1.10.0](https://github.com/ghoneycutt/puppet-module-nfs/tree/v1.10.0) (2015-05-25)
[Full Changelog](https://github.com/ghoneycutt/puppet-module-nfs/compare/v1.9.0...v1.10.0)

**Merged pull requests:**

- WIP [\#54](https://github.com/ghoneycutt/puppet-module-nfs/pull/54) ([ghoneycutt](https://github.com/ghoneycutt))

## [v1.9.0](https://github.com/ghoneycutt/puppet-module-nfs/tree/v1.9.0) (2015-05-20)
[Full Changelog](https://github.com/ghoneycutt/puppet-module-nfs/compare/v1.8.1...v1.9.0)

**Merged pull requests:**

- Remove lsb [\#51](https://github.com/ghoneycutt/puppet-module-nfs/pull/51) ([rnelson0](https://github.com/rnelson0))

## [v1.8.1](https://github.com/ghoneycutt/puppet-module-nfs/tree/v1.8.1) (2015-05-19)
[Full Changelog](https://github.com/ghoneycutt/puppet-module-nfs/compare/v1.8.0...v1.8.1)

**Merged pull requests:**

- Fix style issue - missing default for case statement [\#52](https://github.com/ghoneycutt/puppet-module-nfs/pull/52) ([ghoneycutt](https://github.com/ghoneycutt))
- Update travis config [\#47](https://github.com/ghoneycutt/puppet-module-nfs/pull/47) ([ghoneycutt](https://github.com/ghoneycutt))

## [v1.8.0](https://github.com/ghoneycutt/puppet-module-nfs/tree/v1.8.0) (2015-02-16)
[Full Changelog](https://github.com/ghoneycutt/puppet-module-nfs/compare/v1.7.0...v1.8.0)

**Closed issues:**

- Tight coupling [\#3](https://github.com/ghoneycutt/puppet-module-nfs/issues/3)

**Merged pull requests:**

- Add support for EL7 [\#44](https://github.com/ghoneycutt/puppet-module-nfs/pull/44) ([ghoneycutt](https://github.com/ghoneycutt))

## [v1.7.0](https://github.com/ghoneycutt/puppet-module-nfs/tree/v1.7.0) (2014-05-28)
[Full Changelog](https://github.com/ghoneycutt/puppet-module-nfs/compare/v1.6.3...v1.7.0)

**Closed issues:**

- NFS server or client service\(s\)? [\#35](https://github.com/ghoneycutt/puppet-module-nfs/issues/35)
- Allow setting NFS service enabled = false [\#31](https://github.com/ghoneycutt/puppet-module-nfs/issues/31)
- puppet module install ghoneycutt/nfs failes [\#30](https://github.com/ghoneycutt/puppet-module-nfs/issues/30)

**Merged pull requests:**

- Prep for 1 7 0 release [\#39](https://github.com/ghoneycutt/puppet-module-nfs/pull/39) ([ghoneycutt](https://github.com/ghoneycutt))
- Solaris11 [\#38](https://github.com/ghoneycutt/puppet-module-nfs/pull/38) ([ghoneycutt](https://github.com/ghoneycutt))
- Typos fixed [\#34](https://github.com/ghoneycutt/puppet-module-nfs/pull/34) ([seanscottking](https://github.com/seanscottking))

## [v1.6.3](https://github.com/ghoneycutt/puppet-module-nfs/tree/v1.6.3) (2014-02-06)
[Full Changelog](https://github.com/ghoneycutt/puppet-module-nfs/compare/v1.6.2...v1.6.3)

**Merged pull requests:**

- Update README with idmap and server information [\#29](https://github.com/ghoneycutt/puppet-module-nfs/pull/29) ([kentjohansson](https://github.com/kentjohansson))

## [v1.6.2](https://github.com/ghoneycutt/puppet-module-nfs/tree/v1.6.2) (2014-02-01)
[Full Changelog](https://github.com/ghoneycutt/puppet-module-nfs/compare/v1.6.1...v1.6.2)

**Merged pull requests:**

- Support Puppet v3.4 and Ruby v2.0.0 [\#28](https://github.com/ghoneycutt/puppet-module-nfs/pull/28) ([ghoneycutt](https://github.com/ghoneycutt))

## [v1.6.1](https://github.com/ghoneycutt/puppet-module-nfs/tree/v1.6.1) (2014-01-28)
[Full Changelog](https://github.com/ghoneycutt/puppet-module-nfs/compare/v1.6.0...v1.6.1)

**Merged pull requests:**

- Fixed: deprecated variables access in templates [\#27](https://github.com/ghoneycutt/puppet-module-nfs/pull/27) ([Phil-Friderici](https://github.com/Phil-Friderici))
- Gemfile to reflect that 2.7 support has been dropped [\#26](https://github.com/ghoneycutt/puppet-module-nfs/pull/26) ([ghoneycutt](https://github.com/ghoneycutt))
- Travis [\#25](https://github.com/ghoneycutt/puppet-module-nfs/pull/25) ([ghoneycutt](https://github.com/ghoneycutt))
- Remove Travis work around for ruby v1.8.7 [\#24](https://github.com/ghoneycutt/puppet-module-nfs/pull/24) ([ghoneycutt](https://github.com/ghoneycutt))

## [v1.6.0](https://github.com/ghoneycutt/puppet-module-nfs/tree/v1.6.0) (2014-01-17)
[Full Changelog](https://github.com/ghoneycutt/puppet-module-nfs/compare/v1.5.0...v1.6.0)

**Merged pull requests:**

- Support suse 10 [\#23](https://github.com/ghoneycutt/puppet-module-nfs/pull/23) ([ghoneycutt](https://github.com/ghoneycutt))

## [v1.5.0](https://github.com/ghoneycutt/puppet-module-nfs/tree/v1.5.0) (2014-01-14)
[Full Changelog](https://github.com/ghoneycutt/puppet-module-nfs/compare/v1.4.0...v1.5.0)

**Merged pull requests:**

- 330 support merge hash [\#21](https://github.com/ghoneycutt/puppet-module-nfs/pull/21) ([ghoneycutt](https://github.com/ghoneycutt))
- Rakefile to conform with other modules [\#20](https://github.com/ghoneycutt/puppet-module-nfs/pull/20) ([ghoneycutt](https://github.com/ghoneycutt))

## [v1.4.0](https://github.com/ghoneycutt/puppet-module-nfs/tree/v1.4.0) (2013-12-21)
[Full Changelog](https://github.com/ghoneycutt/puppet-module-nfs/compare/v1.3.0...v1.4.0)

**Merged pull requests:**

- Support solaris suse ubuntu [\#19](https://github.com/ghoneycutt/puppet-module-nfs/pull/19) ([ghoneycutt](https://github.com/ghoneycutt))

## [v1.3.0](https://github.com/ghoneycutt/puppet-module-nfs/tree/v1.3.0) (2013-11-25)
[Full Changelog](https://github.com/ghoneycutt/puppet-module-nfs/compare/v1.2.0...v1.3.0)

**Merged pull requests:**

- Refactor nfs mounts [\#16](https://github.com/ghoneycutt/puppet-module-nfs/pull/16) ([ghoneycutt](https://github.com/ghoneycutt))

## [v1.2.0](https://github.com/ghoneycutt/puppet-module-nfs/tree/v1.2.0) (2013-11-22)
[Full Changelog](https://github.com/ghoneycutt/puppet-module-nfs/compare/v1.1.0...v1.2.0)

**Merged pull requests:**

- v1.2.0 - Support Debian 6 as nfs client [\#15](https://github.com/ghoneycutt/puppet-module-nfs/pull/15) ([ghoneycutt](https://github.com/ghoneycutt))

## [v1.1.0](https://github.com/ghoneycutt/puppet-module-nfs/tree/v1.1.0) (2013-09-27)
**Closed issues:**

- include rpcbind instead of managing the rpcbind service [\#6](https://github.com/ghoneycutt/puppet-module-nfs/issues/6)

**Merged pull requests:**

- Add misc spec tests [\#14](https://github.com/ghoneycutt/puppet-module-nfs/pull/14) ([MWinther](https://github.com/MWinther))
- Added generic mount functionality [\#13](https://github.com/ghoneycutt/puppet-module-nfs/pull/13) ([MWinther](https://github.com/MWinther))
- Update testing framework for Travis [\#11](https://github.com/ghoneycutt/puppet-module-nfs/pull/11) ([jwennerberg](https://github.com/jwennerberg))
- Include rpcbind module instead of managing the rpcbind serivce [\#10](https://github.com/ghoneycutt/puppet-module-nfs/pull/10) ([jwennerberg](https://github.com/jwennerberg))
- Puppet v3 support [\#9](https://github.com/ghoneycutt/puppet-module-nfs/pull/9) ([ghoneycutt](https://github.com/ghoneycutt))



\* *This Change Log was automatically generated by [github_changelog_generator](https://github.com/skywinder/Github-Changelog-Generator)*
