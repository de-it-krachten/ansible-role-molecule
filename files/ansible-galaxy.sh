#!/bin/bash

# Get the name of the calling script
FILENAME=$(readlink -f $0)
BASENAME="${FILENAME##*/}"
BASENAME_ROOT=${BASENAME%%.*}
DIRNAME="${FILENAME%/*}"

Clean_args="-v"
Dry_run=false
Quiet=false
Exit=
Path=$PWD

# parse command line into arguments and check results of parsing
while getopts :cCdDGhp:qr OPT
do
   case $OPT in
     c) Clean=true
        ;;
     C) Clean=true
        Clean_only=true
        ;;
     d) set -vx
        ;;
     D) Dry_run=true
        Dry_run1="-D"
        Clean_args="${Clean_args} -D"
        Echo=echo
        ;;
     G) Clean_args="${Clean_args} -G"
        ;;
     h) Usage
        exit 0
        ;;
     p) Path=$OPTARG
        ;;
     q) Quiet=true
        Clean_args="${Clean_args} -q"
        Exit=0
        ;;
     r) Refresh=true
        ;;
     *) echo "Unknown flag -$OPT given!" >&2
        exit 1
        ;;
   esac

   # Set flag to be use by Test_flag
   eval ${OPT}flag=1

done
shift $(($OPTIND -1))

# Switch to the ansible location
[[ $Path != $PWD ]] && cd $Path

if [[ ! -f roles/requirements.yml ]]
then
  [[ $Quiet == false ]] && echo "File 'roles/requirements.yml' could not be found!" >&2
  exit ${Exit:-1}
fi

[[ $Refresh == true || $Clean == true ]] && ${DIRNAME}/ansible-requirements-clean.sh -p ${Path} ${Clean_args}
[[ $Clean_only == true ]] && exit 0

$Echo ansible-galaxy install -r roles/requirements.yml -p roles/ --ignore-errors
