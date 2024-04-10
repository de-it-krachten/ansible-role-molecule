[![CI](https://github.com/de-it-krachten/ansible-role-molecule/workflows/CI/badge.svg?event=push)](https://github.com/de-it-krachten/ansible-role-molecule/actions?query=workflow%3ACI)


# ansible-role-molecule

Install & manage molecule for testing Ansible roles



## Dependencies

#### Roles
- deitkrachten.python
- deitkrachten.docker

#### Collections
None

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

# list of all virtual environments
molecule_venvs_empty:
  - name: docker-compose
    state: "{{ molecule_ansible8_state | default('present') }}"
    recreate: false
    user: "{{ molecule_virtualenv_user | default('root') }}"
    python: "{{ molecule_ansible8_python | default('/usr/bin/python3') }}"
    site_packages: false
    packages: []
##  - name: ansible8
##    state: "{{ molecule_ansible8_state | default('present') }}"
##    recreate: false
##    user: "{{ molecule_virtualenv_user | default('root') }}"
##    python: "{{ molecule_ansible8_python | default('/usr/bin/python3') }}"
##    site_packages: false
##    packages: []
##  - name: ansible9
##    state: "{{ molecule_ansible9_state | default('present') }}"
##    recreate: false
##    user: "{{ molecule_virtualenv_user | default('root') }}"
##    python: "{{ molecule_ansible9_python | default('/usr/bin/python3') }}"
##    site_packages: false
##    packages: []
##  - name: e2j2
##    state: "{{ molecule_ansible8_state | default('present') }}"
##    recreate: false
##    python: "{{ molecule_ansible8_python | default('/usr/bin/python3') }}"
##    site_packages: false
##    user: "{{ molecule_virtualenv_user | default('root') }}"
##    packages: []
##  - name: yq
##    state: "{{ molecule_ansible8_state | default('present') }}"
##    recreate: false
##    python: "{{ molecule_ansible8_python | default('/usr/bin/python3') }}"
##    site_packages: false
##    user: "{{ molecule_virtualenv_user | default('root') }}"
##    packages: []


# list of all virtual environments
molecule_venvs:
  - name: docker-compose
    state: "{{ molecule_ansible8_state | default('present') }}"
    recreate: false
    python: "{{ molecule_ansible8_python | default('/usr/bin/python3') }}"
    site_packages: false
    user: "{{ molecule_virtualenv_user | default('root') }}"
    packages:
      - "docker<7"
      - "docker-compose"
##  - name: ansible8
##    state: "{{ molecule_ansible8_state | default('present') }}"
##    recreate: false
##    python: "{{ molecule_ansible8_python | default('/usr/bin/python3') }}"
##    site_packages: false
##    user: "{{ molecule_virtualenv_user | default('root') }}"
##    packages:
##      - "ansible>=8,<9"
##      # - "ansible-compat<4"
##      - ansible-lint
##      - "molecule<5"
##      - docker
##      - docker-compose
##      - lxml
##      - dnspython
##      - jmespath
##      - netaddr
##      - requests
##  - name: ansible9
##    state: "{{ molecule_ansible9_state | default('present') }}"
##    recreate: false
##    python: "{{ molecule_ansible9_python | default('/usr/bin/python3') }}"
##    site_packages: false
##    user: "{{ molecule_virtualenv_user | default('root') }}"
##    packages:
##      - "ansible>=9,<10"
##      # - "ansible-compat<4"
##      - ansible-lint
##      - "molecule<5"
##      - docker
##      - docker-compose
##      - lxml
##      - dnspython
##      - jmespath
##      - netaddr
##      - requests
##  - name: e2j2
##    state: "{{ molecule_ansible8_state | default('present') }}"
##    recreate: false
##    python: "{{ molecule_ansible8_python | default('/usr/bin/python3') }}"
##    site_packages: false
##    user: "{{ molecule_virtualenv_user | default('root') }}"
##    packages:
##      - e2j2
##      - jinja2-ansible-filters
##  - name: yq
##    state: "{{ molecule_ansible8_state | default('present') }}"
##    recreate: false
##    python: "{{ molecule_ansible8_python | default('/usr/bin/python3') }}"
##    site_packages: false
##    user: "{{ molecule_virtualenv_user | default('root') }}"
##    packages:
##      - yq

# List of direct links or indirect via wrapper
molecule_links:
#  - { link: /usr/local/bin/ansible7, cmd: /usr/local/venv/ansible7/bin/ansible, direct: true }
  - { link: /usr/local/bin/ansible8, cmd: /usr/local/venv/ansible8/bin/ansible, direct: true }
  - { link: /usr/local/bin/ansible9, cmd: /usr/local/venv/ansible9/bin/ansible, direct: true }
  - { link: /usr/local/bin/molecule, cmd: /usr/local/venv/ansible9/bin/molecule, direct: false }
  - { link: /usr/local/bin/ansible, cmd: /usr/local/venv/ansible9/bin/ansible, direct: true }
  - { link: /usr/local/bin/ansible-galaxy, cmd: /usr/local/venv/ansible9/bin/ansible-galaxy, direct: true }
  - { link: /usr/local/bin/ansible-playbook, cmd: /usr/local/venv/ansible9/bin/ansible-playbook, direct: true }
  - { link: /usr/local/bin/ansible-lint, cmd: /usr/local/venv/ansible9/bin/ansible-lint, direct: false }
  - { link: /usr/local/bin/yamllint, cmd: /usr/local/venv/ansible9/bin/yamllint, direct: true }
  - { link: /usr/local/bin/e2j2, cmd: /usr/local/venv/e2j2/bin/e2j2, direct: true }
  - { link: /usr/local/bin/yq, cmd: /usr/local/venv/yq/bin/yq, direct: true }
  - { link: /usr/local/bin/docker-compose, cmd: /usr/local/venv/docker-compose/bin/docker-compose, direct: true }
</pre></code>

### defaults/Ubuntu-20.yml
<pre><code>
# Install python 3.9
molecule_python39: true

# Python executable to use
molecule_ansible7_python: /usr/bin/python3.9
molecule_ansible8_python: /usr/bin/python3.9
</pre></code>

### defaults/family-RedHat-7.yml
<pre><code>
# Ansible version not supported
molecule_ansible5_state: skip
molecule_ansible6_state: skip
molecule_ansible7_state: skip
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




## Example Playbook
### molecule/default/converge.yml
<pre><code>
- name: sample playbook for role 'molecule'
  hosts: all
  become: 'yes'
  vars:
    molecule_python_install: true
    python38: false
    python39: true
    python311: true
  roles:
    - deitkrachten.python
    - deitkrachten.docker
  tasks:
    - name: Include role 'molecule'
      ansible.builtin.include_role:
        name: molecule
</pre></code>
