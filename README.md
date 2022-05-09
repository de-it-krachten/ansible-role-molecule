[![CI](https://github.com/de-it-krachten/ansible-role-molecule/workflows/CI/badge.svg?event=push)](https://github.com/de-it-krachten/ansible-role-molecule/actions?query=workflow%3ACI)


# ansible-role-molecule

Install & manage molecule for testing Ansible roles


Platforms
--------------

Supported platforms

- RHEL 8
- RockyLinux 8
- AlmaLinux 8
- Debian 11 (Bullseye)
- Ubuntu 20.04 LTS (Focal Fossa)
- Ubuntu 22.04 LTS (Jammy Jellyfish)
- Fedora 35

Note:
<sup>1</sup> : no automated testing is performed on these platforms

Role Variables
--------------
<pre><code>
# base directory for all virtual environments
molecule_venv_root: /usr/local/venv

# list of all virtual environments
molecule_venvs:
  - name: ansible4
    recreate: false
    python: /usr/bin/python3
    site_packages: true
    packages:
      - "ansible>=4,<5"
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
      - python-consul
      - pyhcl
      - requests
  - name: ansible5
    recreate: false
    python: /usr/bin/python3.8
    site_packages: true
    packages:
      - "ansible>=5,<6"
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
      - python-consul
      - pyhcl
      - requests
</pre></code>


Example Playbook
----------------

<pre><code>
- name: sample playbook for role 'molecule'
  hosts: all
  vars:
  tasks:
    - name: Include role 'molecule'
      include_role:
        name: molecule
</pre></code>
