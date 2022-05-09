#!/bin/bash

# Get the name of the calling script
FILENAME=$(readlink -f $0)
BASENAME="${FILENAME##*/}"
BASENAME_ROOT=${BASENAME%%.*}
DIRNAME="${FILENAME%/*}"

Clean_args="-v"

# parse command line into arguments and check results of parsing
while getopts :cCdDGh OPT
do
   case $OPT in
     c) Clean=true
        ;;
     C) Clean=true
        Clean_only=true
        ;;
     d) set -vx
        ;;
     G) Clean_args="${Clean_args} -G"
        ;;
     h) Usage
        exit 0
        ;;
     *) echo "Unknown flag -$OPT given!" >&2
        exit 1
        ;;
   esac

   # Set flag to be use by Test_flag
   eval ${OPT}flag=1

done
shift $(($OPTIND -1))

[[ $Clean == true ]] && ${DIRNAME}/ansible-requirements-clean.sh ${Clean_args}
[[ $Clean_only == true ]] && exit 0

ansible-galaxy install -r roles/requirements.yml -p roles/ --ignore-errors
