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

# python executable for Ansible >= 5 (ansible core >= 2.12)
molecule_python_ansible5: /usr/bin/python3

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
