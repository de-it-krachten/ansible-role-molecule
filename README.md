[![CI](https://github.com/de-it-krachten/ansible-role-molecule/workflows/CI/badge.svg?event=push)](https://github.com/de-it-krachten/ansible-role-molecule/actions?query=workflow%3ACI)


# ansible-role-molecule

Install & manage molecule for testing Ansible roles


## Platforms

Supported platforms

- Red Hat Enterprise Linux 8<sup>1</sup>
- Red Hat Enterprise Linux 9<sup>1</sup>
- RockyLinux 8
- OracleLinux 8
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
# base directory for all virtual environments
molecule_venv_root: /usr/local/venv

# python executable for Ansible >= 5 (ansible core >= 2.12)
molecule_python_ansible5: /usr/bin/python3

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
  - name: ansible4
    recreate: false
    python: /usr/bin/python3
    site_packages: true
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
    recreate: false
    python: "{{ molecule_python_ansible5 }}"
    site_packages: true
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
</pre></code>

### vars/Fedora.yml
<pre><code>

</pre></code>

### vars/default.yml
<pre><code>

</pre></code>

### vars/family-RedHat-9.yml
<pre><code>
molecule_python_ansible5: /usr/bin/python3
</pre></code>

### vars/family-RedHat-8.yml
<pre><code>
molecule_python_ansible5: /usr/bin/python3.8
</pre></code>

### vars/family-RedHat-7.yml
<pre><code>
molecule_python_ansible5: /usr/bin/python3
</pre></code>



## Example Playbook
### molecule/default/converge.yml
<pre><code>
- name: sample playbook for role 'molecule'
  hosts: all
  vars:
  tasks:
    - name: Include role 'molecule'
      include_role:
        name: molecule
</pre></code>
