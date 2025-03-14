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
- AlmaLinux 8
- AlmaLinux 9
- Ubuntu 22.04 LTS
- Ubuntu 24.04 LTS

Note:
<sup>1</sup> : no automated testing is performed on these platforms

## Role Variables
### defaults/main.yml
<pre><code>
# Should python be installed by this role
molecule_python_install: false

# Python version to use
molecule_python: /usr/bin/python3

# Should molecule virtual environments be created by this role
molecule_python_venv: true

# base directory for all virtual environments
molecule_venv_root: /usr/local/venv

# list of OS packages required
molecule_os_packages:
  - jq
  - git

# list of all virtual environments
molecule_venvs:
  - name: docker-compose
    state: present
    recreate: false
    python: "{{ molecule_python }}"
    site_packages: false
    user: "{{ molecule_virtualenv_user | default('root') }}"
    packages:
      - "docker<7"
      - "docker-compose"
  - name: ansible11
    state: present
    recreate: false
    python: "{{ molecule_python }}"
    site_packages: false
    user: "{{ molecule_virtualenv_user | default('root') }}"
    packages:
      - "ansible>=11,<12"
      - ansible-lint
      - molecule
      # - docker
      # - docker-compose
      - lxml
      - dnspython
      - jmespath
      - netaddr
      - requests
  - name: e2j2
    state: present
    recreate: false
    python: "{{ molecule_python }}"
    site_packages: false
    user: "{{ molecule_virtualenv_user | default('root') }}"
    packages:
      - e2j2
      - jinja2-ansible-filters
  - name: yq
    state: present
    recreate: false
    python: "{{ molecule_python }}"
    site_packages: false
    user: "{{ molecule_virtualenv_user | default('root') }}"
    packages:
      - yq

# List of direct links or indirect via wrapper
molecule_links:
  - { link: /usr/local/bin/molecule, cmd: /usr/local/venv/ansible11/bin/molecule, direct: false }
  - { link: /usr/local/bin/ansible, cmd: /usr/local/venv/ansible11/bin/ansible, direct: true }
  - { link: /usr/local/bin/ansible-galaxy, cmd: /usr/local/venv/ansible11/bin/ansible-galaxy, direct: true }
  - { link: /usr/local/bin/ansible-playbook, cmd: /usr/local/venv/ansible11/bin/ansible-playbook, direct: true }
  - { link: /usr/local/bin/ansible-lint, cmd: /usr/local/venv/ansible11/bin/ansible-lint, direct: false }
  - { link: /usr/local/bin/yamllint, cmd: /usr/local/venv/ansible11/bin/yamllint, direct: true }
  - { link: /usr/local/bin/e2j2, cmd: /usr/local/venv/e2j2/bin/e2j2, direct: true }
  - { link: /usr/local/bin/yq, cmd: /usr/local/venv/yq/bin/yq, direct: true }
  - { link: /usr/local/bin/docker-compose, cmd: /usr/local/venv/docker-compose/bin/docker-compose, direct: true }
</pre></code>

### defaults/family-RedHat-8.yml
<pre><code>
# Install python 3.11
molecule_python311: true

# Python version to use
molecule_python: /usr/bin/python3.11
</pre></code>

### defaults/family-RedHat-9.yml
<pre><code>
# Install python 3.11
molecule_python311: true

# Python version to use
molecule_python: /usr/bin/python3.11
</pre></code>

### defaults/Ubuntu-22.yml
<pre><code>
# Install python 3.11
molecule_python311: true

# Python version to use
molecule_python: /usr/bin/python3.11
</pre></code>




## Example Playbook
### molecule/default/converge.yml
<pre><code>
- name: sample playbook for role 'molecule'
  hosts: all
  become: 'yes'
  vars:
    molecule_python_install: true
  roles:
    - deitkrachten.python
  tasks:
    - name: Include role 'molecule'
      ansible.builtin.include_role:
        name: molecule
</pre></code>
