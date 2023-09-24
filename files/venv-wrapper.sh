#!/bin/bash

FILENAME=$(realpath -s $0)
LINK="${FILENAME##*/}"
VENV_ROOT=/usr/local/venv

case $LINK in
  ansible7)
    source ${VENV_ROOT}/${LINK}/bin/activate
    ansible "$@"
    exit $?
    ;;
  ansible8)
    source ${VENV_ROOT}/${LINK}/bin/activate
    ansible "$@"
    exit $?
    ;;
  ansible-lint)
    source ${VENV_ROOT}/ansible-lint/bin/activate
    ansible-lint "$@"
    exit $?
    ;;
  yamllint)
    source ${VENV_ROOT}/ansible-lint/bin/activate
    yamllint "$@"
    exit $?
    ;;
  molecule)
    source ${VENV_ROOT}/molecule/bin/activate
    molecule "$@"
    exit $?
    ;;
  ansible)
    source ${VENV_ROOT}/molecule/bin/activate
    ansible "$@"
    exit $?
    ;;
  ansible-galaxy)
    source ${VENV_ROOT}/molecule/bin/activate
    ansible-galaxy "$@"
    exit $?
    ;;
  ansible-playbook)
    source ${VENV_ROOT}/molecule/bin/activate
    ansible-playbook "$@"
    exit $?
    ;;
  *)
    echo "Unsupported link '${LINK}'" >&2
    exit 1
    ;;
esac
