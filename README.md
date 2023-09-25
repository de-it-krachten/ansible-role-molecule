[![CI](https://github.com/de-it-krachten/ansible-role-molecule/workflows/CI/badge.svg?event=push)](https://github.com/de-it-krachten/ansible-role-molecule/actions?query=workflow%3ACI)


# ansible-role-molecule

Install & manage molecule for testing Ansible roles



## Dependencies

#### Roles
- deitkrachten.python
- deitkrachten.docker

#### Collections
- community.general

## Platforms

Supported platforms

- Red Hat Enterprise Linux 8<sup>1</sup>
- Red Hat Enterprise Linux 9<sup>1</sup>
- RockyLinux 8
- RockyLinux 9
- OracleLinux 8
- OracleLinux 9
- AlmaLinux 8
- AlmaLinux 9
- SUSE Linux Enterprise 15<sup>1</sup>
- openSUSE Leap 15
- Debian 11 (Bullseye)
- Debian 12 (Bookworm)
- Ubuntu 20.04 LTS
- Ubuntu 22.04 LTS
- Fedora 37
- Fedora 38

Note:
<sup>1</sup> : no automated testing is performed on these platforms

## Role Variables
### defaults/main.yml
<pre><code>
# Should python be installed by this role
molecule_python_install: false

# Should molecule virtual environments be created by this role
molecule_python_venv: true

# base directory for all virtual environments
molecule_venv_root: /usr/local/venv

# Install python 3.8 / 3.9
molecule_python38: false
molecule_python39: false

# list of OS packages required
molecule_os_packages:
  - jq
  - git

# list of pypi packages required
molecule_pip_packages:
  - wheel
  - e2j2
  - yq

# list of all virtual environments
molecule_venvs_empty:
  - name: ansible7
    state: "{{ molecule_ansible7_state | default('present') }}"
    recreate: false
    user: "{{ molecule_virtualenv_user | default('root') }}"
    python: "{{ molecule_ansible7_python | default('/usr/bin/python3') }}"
    site_packages: false
    packages: []
  - name: ansible8
    state: "{{ molecule_ansible8_state | default('present') }}"
    recreate: false
    user: "{{ molecule_virtualenv_user | default('root') }}"
    python: "{{ molecule_ansible8_python | default('/usr/bin/python3') }}"
    site_packages: false
    packages: []
  - name: molecule
    state: "{{ molecule_ansible7_state | default('present') }}"
    recreate: false
    user: "{{ molecule_virtualenv_user | default('root') }}"
    python: "{{ molecule_ansible7_python | default('/usr/bin/python3') }}"
    site_packages: false
    packages: []
  - name: ansible-lint
    state: "{{ molecule_ansible8_state | default('present') }}"
    recreate: false
    user: "{{ molecule_virtualenv_user | default('root') }}"
    python: "{{ molecule_ansible8_python | default('/usr/bin/python3') }}"
    site_packages: false
    packages: []


# list of all virtual environments
molecule_venvs:
  - name: ansible7
    state: "{{ molecule_ansible7_state | default('present') }}"
    python: "{{ molecule_ansible7_python | default('/usr/bin/python3') }}"
    site_packages: false
    user: "{{ molecule_virtualenv_user | default('root') }}"
    packages:
      - "ansible>=7,<8"
      - docker
      - docker-compose
      - lxml
      - dnspython
      - jmespath
      - netaddr
      - requests
  - name: ansible8
    state: "{{ molecule_ansible8_state | default('present') }}"
    recreate: false
    python: "{{ molecule_ansible8_python | default('/usr/bin/python3') }}"
    site_packages: false
    user: "{{ molecule_virtualenv_user | default('root') }}"
    packages:
      - "ansible>=8,<9"
      - docker
      - docker-compose
      - lxml
      - dnspython
      - jmespath
      - netaddr
      - requests
  - name: ansible-lint
    state: "{{ molecule_ansible8_state | default('present') }}"
    recreate: false
    python: "{{ molecule_ansible8_python | default('/usr/bin/python3') }}"
    site_packages: false
    user: "{{ molecule_virtualenv_user | default('root') }}"
    packages:
      - ansible-lint
  - name: molecule
    state: "{{ molecule_ansible8_state | default('present') }}"
    recreate: false
    python: "{{ molecule_ansible8_python | default('/usr/bin/python3') }}"
    site_packages: false
    user: "{{ molecule_virtualenv_user | default('root') }}"
    packages:
      - "molecule<5"
      - molecule-docker
      - "ansible-compat<4"
  - name: e2j2
    state: "{{ molecule_ansible8_state | default('present') }}"
    recreate: false
    python: "{{ molecule_ansible8_python | default('/usr/bin/python3') }}"
    site_packages: false
    user: "{{ molecule_virtualenv_user | default('root') }}"
    packages:
      - e2j2
      - jinja2-ansible-filters
  - name: yq
    state: "{{ molecule_ansible8_state | default('present') }}"
    recreate: false
    python: "{{ molecule_ansible8_python | default('/usr/bin/python3') }}"
    site_packages: false
    user: "{{ molecule_virtualenv_user | default('root') }}"
    packages:
      - yq
</pre></code>

### defaults/family-RedHat-8.yml
<pre><code>
# Install python 3.8 / 3.9 / 3.11
molecule_python38: false
molecule_python39: false
molecule_python311: true

# Python executable to use
molecule_ansible7_python: /usr/bin/python3.11
molecule_ansible8_python: /usr/bin/python3.11
</pre></code>

### defaults/family-RedHat-7.yml
<pre><code>
# Ansible version not supported
molecule_ansible5_state: skip
molecule_ansible6_state: skip
molecule_ansible7_state: skip
</pre></code>

### defaults/Ubuntu-20.yml
<pre><code>
# Ansible version not supported
molecule_ansible7_state: skip
</pre></code>




## Example Playbook
### molecule/default/converge.yml
<pre><code>
- name: sample playbook for role 'molecule'
  hosts: all
  become: "yes"
  vars:
    molecule_python_install: True
    python38: False
    python39: False
    python311: True
  roles:
    - deitkrachten.python
    - deitkrachten.docker
  tasks:
    - name: Include role 'molecule'
      ansible.builtin.include_role:
        name: molecule
</pre></code>
