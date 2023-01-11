[![CI](https://github.com/de-it-krachten/ansible-role-molecule/workflows/CI/badge.svg?event=push)](https://github.com/de-it-krachten/ansible-role-molecule/actions?query=workflow%3ACI)


# ansible-role-molecule

Install & manage molecule for testing Ansible roles



## Dependencies

#### Roles
None

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
- Debian 11 (Bullseye)
- Ubuntu 20.04 LTS
- Ubuntu 22.04 LTS
- Fedora 35
- Fedora 36

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
molecule_venvs:
  - name: ansible29
    state: "{{ molecule_ansible29_state | default('present') }}"
    recreate: false
    python: /usr/bin/python3
    site_packages: false
    packages:
      - ansible==2.9.27
      - ansible-lint==5.4.0
      - molecule[ansible]
      - molecule[lint]
      - molecule-docker
      - molecule-vagrant
      - python-vagrant
      - docker
      - docker-compose
      - lxml
      - dnspython
      - jmespath
      - netaddr
      - requests
  - name: ansible4
    state: "{{ molecule_ansible4_state | default('present') }}"
    recreate: false
    python: /usr/bin/python3
    site_packages: false
    packages:
      - "ansible>=4,<5"
      - ansible-lint==5.4.0
      - molecule[ansible]
      - molecule[lint]
      - molecule-docker
      - molecule-vagrant
      - python-vagrant
      - docker
      - docker-compose
      - lxml
      - dnspython
      - jmespath
      - netaddr
      - requests
  - name: ansible5
    state: "{{ molecule_ansible5_state | default('present') }}"
    recreate: false
    python: "{{ molecule_ansible5_python | default('/usr/bin/python3') }}"
    site_packages: false
    packages:
      - "ansible>=5,<6"
      - ansible-lint==5.4.0
      - molecule[ansible]
      - molecule[lint]
      - molecule-docker
      - molecule-vagrant
      - python-vagrant
      - docker
      - docker-compose
      - lxml
      - dnspython
      - jmespath
      - netaddr
      - requests
  - name: ansible6
    state: "{{ molecule_ansible6_state | default('present') }}"
    recreate: false
    python: "{{ molecule_ansible6_python | default('/usr/bin/python3') }}"
    site_packages: false
    packages:
      - "ansible>=6,<7"
      - ansible-lint
      - molecule[ansible]
      - molecule[lint]
      - molecule-docker
      - molecule-vagrant
      - python-vagrant
      - docker
      - docker-compose
      - lxml
      - dnspython
      - jmespath
      - netaddr
      - requests
  - name: ansible7
    state: "{{ molecule_ansible7_state | default('present') }}"
    recreate: false
    python: "{{ molecule_ansible7_python | default('/usr/bin/python3') }}"
    site_packages: false
    packages:
      - "ansible>=7,<8"
      - ansible-lint
      - molecule[ansible]
      - molecule[lint]
      - molecule-docker
      - molecule-vagrant
      - python-vagrant
      - docker
      - docker-compose
      - lxml
      - dnspython
      - jmespath
      - netaddr
      - requests
</pre></code>

### defaults/Ubuntu-20.yml
<pre><code>
# Ansible version not supported
molecule_ansible7_state: skip
</pre></code>

### defaults/family-RedHat-8.yml
<pre><code>
# Install python 3.8 / 3.9
molecule_python38: true
molecule_python39: true

# Python executable to use
molecule_ansible5_python: /usr/bin/python3.8
molecule_ansible6_python: /usr/bin/python3.8
molecule_ansible7_python: /usr/bin/python3.9
</pre></code>

### defaults/family-RedHat-7.yml
<pre><code>
# Ansible version not supported
molecule_ansible5_state: skip
molecule_ansible6_state: skip
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
  tasks:
    - name: Include role 'molecule'
      ansible.builtin.include_role:
        name: molecule
</pre></code>
