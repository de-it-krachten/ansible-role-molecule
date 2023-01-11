#!/bin/bash

set -e

[[ `id -un` != root ]] && Sudo=sudo

source_dir=https://raw.githubusercontent.com/de-it-krachten/ansible-role-molecule/dev/files
bin_dir=/usr/local/bin

scripts="
ansible-collections.sh
ansible-galaxy.sh
ansible-lint.sh
ansible-requirements-clean.sh
functions_ansible.sh
molecule-test.sh
"

for script in $scripts
do
  curl -s -o /tmp/${script} ${source_dir}/${script}
  $Sudo cp /tmp/${script} ${bin_dir}/${script}
  $Sudo chmod 755 ${bin_dir}/${script}
done
