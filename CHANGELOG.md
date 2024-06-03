# [1.7.0](https://github.com/de-it-krachten/ansible-role-molecule/compare/v1.6.2...v1.7.0) (2024-06-03)


### Features

* Add support for Ubuntu 24.04 LTS + Fedora 40 ([c44d453](https://github.com/de-it-krachten/ansible-role-molecule/commit/c44d453ddb95b32fad67cc5dc580aad9a8095f65))

## [1.6.2](https://github.com/de-it-krachten/ansible-role-molecule/compare/v1.6.1...v1.6.2) (2024-04-12)


### Bug Fixes

* Update scripts ([67b3520](https://github.com/de-it-krachten/ansible-role-molecule/commit/67b35207ef22641845c0354fc431b033e694d17c))

## [1.6.1](https://github.com/de-it-krachten/ansible-role-molecule/compare/v1.6.0...v1.6.1) (2023-11-11)


### Bug Fixes

* Fix yq/e2j2 binary location for collection install ([757fb02](https://github.com/de-it-krachten/ansible-role-molecule/commit/757fb02c05a1f1d48f5e835d6d374803506a24f3))

# [1.6.0](https://github.com/de-it-krachten/ansible-role-molecule/compare/v1.5.0...v1.6.0) (2023-10-25)


### Bug Fixes

* Add support for collections/requirements.yml ([2699f51](https://github.com/de-it-krachten/ansible-role-molecule/commit/2699f5126c92021ea41f4cda4f5b31ec4da49ac4))
* Fix loop label to string ([342c271](https://github.com/de-it-krachten/ansible-role-molecule/commit/342c2714de975e8077818db103c2354cc31d9541))
* Move tools into separate virtual environments ([8801bea](https://github.com/de-it-krachten/ansible-role-molecule/commit/8801bea1fdb82fdef6480a900af5c01aa8d90234))


### Features

* Split up different tools into separate venv ([098bfd0](https://github.com/de-it-krachten/ansible-role-molecule/commit/098bfd0a91c3cc9e4ee20d242d23a65c369be49b))
* Update supported platforms & CI ([a2f06e2](https://github.com/de-it-krachten/ansible-role-molecule/commit/a2f06e2e59c4675609a52c4b968b7bccd1bf60e6))

# [1.5.0](https://github.com/de-it-krachten/ansible-role-molecule/compare/v1.4.0...v1.5.0) (2023-05-06)


### Features

* Move to namespaced role names ([61c5b34](https://github.com/de-it-krachten/ansible-role-molecule/commit/61c5b3415aa35c3dd7c311cff3fb886563bc14b2))
* Update molecule-test.sh to support multiple providers ([4a592a9](https://github.com/de-it-krachten/ansible-role-molecule/commit/4a592a9ecedff7dff9a8fe35c2c4994b28278d3c))

# [1.4.0](https://github.com/de-it-krachten/ansible-role-molecule/compare/v1.3.0...v1.4.0) (2023-01-11)


### Bug Fixes

* Fix issue with molecule-test.sh ([fb49b8c](https://github.com/de-it-krachten/ansible-role-molecule/commit/fb49b8ccc54d3b80c3368690977fd1ad0efdddf6))
* Make python installation optional ([13db41b](https://github.com/de-it-krachten/ansible-role-molecule/commit/13db41b8ec29ff7bedaa57cf3f2059a35b0afb28))
* Make python related tasks optional ([cb78371](https://github.com/de-it-krachten/ansible-role-molecule/commit/cb78371d6a46875b3c554036f9288dd8dcdcc82f))


### Features

* Add ansible6/ansible7 virtual environments ([ce8ff70](https://github.com/de-it-krachten/ansible-role-molecule/commit/ce8ff70f2bee75428deff7369e5054fd33d718b6))
* Add extra scripts for collection support ([a9461ad](https://github.com/de-it-krachten/ansible-role-molecule/commit/a9461ad924cdc4fca7ab379695a237bcfa41c706))

# [1.3.0](https://github.com/de-it-krachten/ansible-role-molecule/compare/v1.2.0...v1.3.0) (2022-10-12)


### Features

* Add wrapper around ansible-lint ([97cbde9](https://github.com/de-it-krachten/ansible-role-molecule/commit/97cbde999374db9b2537a3307895b18fb9de4487))
* Move to FQCN ([8440509](https://github.com/de-it-krachten/ansible-role-molecule/commit/8440509d07fb89ec6a32a05765bda36065b96c5a))
* Update CI to latest standards ([23525a6](https://github.com/de-it-krachten/ansible-role-molecule/commit/23525a621b18c99196269c7911e1c614959780c7))

# [1.2.0](https://github.com/de-it-krachten/ansible-role-molecule/compare/v1.1.1...v1.2.0) (2022-07-28)


### Features

* Implement ansible-lint v6 support ([eeb145a](https://github.com/de-it-krachten/ansible-role-molecule/commit/eeb145aaa1e94e38befe8df6106f87351588df59))

## [1.1.1](https://github.com/de-it-krachten/ansible-role-molecule/compare/v1.1.0...v1.1.1) (2022-07-05)


### Bug Fixes

* Insert latest molecule-test.sh due to hostvars issue ([62dc605](https://github.com/de-it-krachten/ansible-role-molecule/commit/62dc605c748ff2b9cc50a202bc65172b54b05038))

# [1.1.0](https://github.com/de-it-krachten/ansible-role-molecule/compare/v1.0.2...v1.1.0) (2022-07-04)


### Features

* Add RHEL9 support ([d029823](https://github.com/de-it-krachten/ansible-role-molecule/commit/d02982327832f17b7a9138619e562bcb96b957dc))

## [1.0.2](https://github.com/de-it-krachten/ansible-role-molecule/compare/v1.0.1...v1.0.2) (2022-05-30)


### Bug Fixes

* update scripts to latest versions ([c5a7074](https://github.com/de-it-krachten/ansible-role-molecule/commit/c5a70746f5d256e6f7e15907d237aff60482c14d))

## [1.0.1](https://github.com/de-it-krachten/ansible-role-molecule/compare/v1.0.0...v1.0.1) (2022-05-10)


### Bug Fixes

* remove functions.sh from ansible-requirements-clean.sh ([6af2472](https://github.com/de-it-krachten/ansible-role-molecule/commit/6af24728877000b79607e5cb108e57cc94a95f8c))
* remove obsolete roles from meta/requirements.yml ([28b4ee2](https://github.com/de-it-krachten/ansible-role-molecule/commit/28b4ee22157b472d63ea6f1d45f5d1b52252cdf3))

# 1.0.0 (2022-05-10)


### Features

* initial release ([7730791](https://github.com/de-it-krachten/ansible-role-molecule/commit/7730791fa8a14c373ac0d91bc94081278859d526))
