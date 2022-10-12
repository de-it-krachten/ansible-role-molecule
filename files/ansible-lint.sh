#!/bin/bash
#
#=====================================================================
#
# Name        :
# Version     :
# Author      :
# Description :
#
#
#=====================================================================
unset Debug
#export Debug="set -x"
$Debug


##############################################################
#
# Defining standard variables
#
##############################################################

# Set temporary PATH
export PATH=/bin:/usr/bin:/sbin:/usr/sbin:$PATH

# Get the name of the calling script
FILENAME=$(readlink -f $0)
BASENAME="${FILENAME##*/}"
BASENAME_ROOT=${BASENAME%%.*}
DIRNAME="${FILENAME%/*}"

# Define temorary files, debug direcotory, config and lock file
TMPDIR=/tmp
VARTMPDIR=/var/tmp
TMPFILE=${TMPDIR}/${BASENAME}.${RANDOM}.${RANDOM}
DEBUGDIR=${TMPDIR}/${BASENAME_ROOT}_${USER}
CONFIGFILE=${DIRNAME}/${BASENAME_ROOT}.cfg
LOCKFILE=${VARTMP}/${BASENAME_ROOT}.lck

# Logfile & directory
LOGDIR=$DIRNAME
LOGFILE=${LOGDIR}/${BASENAME_ROOT}.log

# Set date/time related variables
DATESTAMP=$(date "+%Y%m%d")
TIMESTAMP=$(date "+%Y%m%d.%H%M%S")

# Figure out the platform
OS=$(uname -s)

# Get the hostname
HOSTNAME=$(hostname -s)


##############################################################
#
# Defining custom variables
#
##############################################################

# Append script directory to $PATH 
export PATH=$PATH:$DIRNAME

# Set temporary directory for custom modules
ANSIBLE_LIBRARY_TMP=$(mktemp -d)


##############################################################
#
# Defining standarized functions
#
#############################################################

FUNCTIONS="${DIRNAME}/functions.sh ${DIRNAME}/functions_ansible.sh"
for Functions in ${FUNCTIONS}
do
  if [[ -f ${Functions} ]]
  then
     . ${Functions}
  fi
done


##############################################################
#
# Defining customized functions
#
#############################################################

function Usage
{

  cat << EOF | grep -v "^#"

$BASENAME

Usage : $BASENAME <flags> <arguments>

Flags :

   -d|--debug   : Debug mode (set -x)
   -D|--dry-run : Dry run mode
   -h|--help    : Prints this help message
   -v|--verbose : Verbose output

#   -F           : Auto fix errors encountered (uses ansible-fix.sh)
   -x           : Prepare playbook project (uses ansible-galaxy)
   -X           : Do NOT prepare playbook project

EOF

}

function Overwrite_virtualenv
{

  # For ansible-lint, the migration from v4 -> v5 is breaking
  # venv 'ansible29' contains ansible-lint 4.2.0 (before migration)
  # venv 'ansible29x' contains ansible-lint 5.4.0 (after migration)

  if [[ -f .venv.mapping ]]
  then

    # Get current venv and the one it is mapped to
    Venv=$(basename $VIRTUAL_ENV)
    Venv_alt=$(awk '$1=="'$Venv'" {print $2}' .venv.mapping)
    # Leave this function if nothing found
    [[ -z $Venv_alt ]] && return 0

    # Activate the alternate venv
    Venv_alt_path=$(dirname $VIRTUAL_ENV)/${Venv_alt}
    if [[ -n $Venv_alt && -f ${Venv_alt_path}/bin/activate ]]
    then
      echo "Switching to alternative venv '${Venv_alt_path}'"
      source ${Venv_alt_path}/bin/activate
    fi

  fi

}

function Check_version
{

  # Write version to stderr
  ansible-lint --version >&2

  # ansible-lint
  Ansible_lint_version=$(ansible-lint --version | awk '$1=="ansible-lint" {print $2}')
  Ansible_lint_major_version=$(echo $Ansible_lint_version | cut -f1 -d.)

  # Only accept ansible-lint v4
  [[ $Ansible_lint_major_version -lt 4 ]] && echo "Please upgrade to ansible-lint v4 or higher!" >&2 && exit 1

  # Set some version specific settings
  [[ $Ansible_lint_major_version == 4 ]] && Args="--parseable-severity" && InputF=pep8
  [[ $Ansible_lint_major_version =~ (5|6) ]] && Args="-f codeclimate" && InputF=json

}

function Install_pip
{

  if ! pip3 show $1 >/dev/null 2>&1
  then
    echo "Installing pip package '$1'"
    pip3 install $1 || exit 1
  fi

}

function Prepare
{

  # Only needed for playbooks with ansible-lint v4 or v5
  [[ $Ansible_repo_type != playbook || $Ansible_lint_major_version -ge 6 ]] && return

  # Delete all roles in requirements.yml
  echo "Deleting all external roles in directory 'roles'"
  ansible-galaxy.sh -Cq

  # Include roles from other galaxy/git etc
  echo "Retrieving all roles as configured in roles/requirements.yml"
  ansible-galaxy.sh -q

#  # Search for custom libraries and add to ANSIBLE_LIBRARY
#  Libraries=`ls -d roles/*/library 2>/dev/null`
#  if [[ -n $Libraries ]]
#  then
#    echo "Copy all custom modules"
#    [[ -z $ANSIBLE_LIBRARY ]] && ANSIBLE_LIBRARY=${ANSIBLE_LIBRARY} || ANSIBLE_LIBRARY=${ANSIBLE_LIBRARY}:${ANSIBLE_LIBRARY_TMP}
#    export ANSIBLE_LIBRARY
#
#    # Copy custom modules
#    for Library in $Libraries
#    do
#      cp $Library/* ${ANSIBLE_LIBRARY_TMP}
#    done
#  fi
#
#  # Delete all roles in requirements.yml
#  if [[ $Retrieve_roles == false ]]
#  then
#    echo "Deleting all external roles in directory 'roles'"
#    ansible-galaxy.sh -Cq
#  fi

}

function Input_json
{

  # Get the amount of issues
  Issue=0
  Issues=`jq '.|length' ${TMPFILE}`

  # Loop over each item
  exec 3<<< `jq -r '.[] | @base64' ${TMPFILE}`
  while read -u3 line
  do

    # Increment the issue count
    Issue=$(($Issue+1))

    # Skip if empty array
    [[ -z $line ]] && continue

    path=`echo "$line" | base64 -d | jq -r '.location.path'`
    #check_name=`echo "$line" | base64 -d | jq -r '.check_name' | sed "s/.*\[//;s/\].*//"`
    check_name=`echo "$line" | base64 -d | jq -r '.check_name'`
    linenr=`echo "$line" | base64 -d | jq -r '.location.lines.begin.line' 2>/dev/null`
    [[ -z $linenr ]] && linenr=`echo "$line" | base64 -d | jq -r '.location.lines.begin'`
    severity=`echo "$line" | base64 -d | jq -r '.severity'`
    description=`echo "$line" | base64 -d | jq -r '.description' | sed -z 's/\n/@@/g;s/@@$/\n/'`

    eval Format_${Output_format}
    Errors=$(($Errors+1))

  done
  exec 3<&-

  # In case no issues were found, write an ampty array
  [[ $Output_format == json && $Issues -eq 0 ]] && echo "[]"

}

function Input_pep8
{

  # Get the amount of issues
  Issues=`cat ${TMPFILE} | wc -l`
  [[ $Issues -eq 0 ]] && return 0

  # Loop over each item
  exec 3<<< `cat ${TMPFILE}`
  while read -u3 line
  do
    echo "$line"
    Errors=$(($Errors+1))
  done
  exec 3<&-

}


function Format_json
{

  # For the first issue, open the array
  [[ $Issue == 1 ]] && echo -e "[\c"

  # Write the issue as dict
  echo "$line" | base64 -d
  [[ $Issue != $Issues ]] && echo -e ",\c"

  # For the last issues, close the array
  [[ $Issue == $Issues ]] && echo -e "]"

}


function Format_parsable
{

  if [[ $Verbose == true ]]
  then
    echo "$path|$linenr|$check_name|$severity|$description|" | sed -z 's/@@/\\n/g'
  else
    echo "$path|$linenr|$check_name|$severity|" | sed -z 's/@@/\\n/g'
  fi

}

function Format_readable
{

  description=`echo $description | sed "s/@@/\n/g" | sed "s/^/  /"`

  cat <<EOF
-----------------------------------------------------------
path: $path
linenr: $linenr
check_name: $check_name
severity: $severity
description: $description
-----------------------------------------------------------
EOF

}

function Format_column
{

  Sep="::"

  if [[ $Verbose == true ]]
  then
    Headers="path${Sep}linenr${Sep}check_name${Sep}severity${Sep}description"
  else
    Headers="path${Sep}linenr${Sep}check_name${Sep}severity"
  fi

  # Write header
  [[ $Header_written != true ]] && echo "$Headers" && Header_written=true

  # Write 
  Line=$(echo \"$Headers\" | sed -r "s/([a-z_]+)/\$\\1/g")
  eval echo $Line

}

function Format_csv
{

  Sep=","

  if [[ $Verbose == true ]]
  then
    Headers="path${Sep}linenr${Sep}check_name${Sep}severity${Sep}description"
  else  
    Headers="path${Sep}linenr${Sep}check_name${Sep}severity"
  fi

  # Write header
  [[ $Header_written != true ]] && echo "$Headers" && Header_written=true

  # Write 
  Line=$(echo \"$Headers\" | sed -r "s/([a-z_]+)/\$\\1/g")
  eval echo $Line

}

function Csv2table
{

  # Skip if nothing to do
  [[ ! -s ${TMPFILE}csv ]] && return 0

  # Ensure requirements are installed
  Install_pip prettytable

  # Create table
  cat <<EOF > ${TMPFILE}table
#!/usr/bin/env python3
from prettytable import from_csv
with open("${TMPFILE}csv", "r") as fp: 
    x = from_csv(fp)
x.align["path"] = "l"
x.align["linenr"] = "r"
print(x)
EOF

  chmod +x ${TMPFILE}table
  ${TMPFILE}table

}


function Printf
{
  printf "%-80s%-10s\n" $File $1
}

function Wrapper
{

  VENV_ROOT=/data/venv

  local Errors=0

  for venv in ${VENV_ROOT}/*
  do
    echo "================================================================================"
    echo "Activating venv '$venv'"
    echo "================================================================================"
    source $venv/bin/activate
    ansible-lint.sh $Quiet1 || Errors=$(($Errors+1))
  done
  return $Errors

}


##############################################################
#
# Main programs
#
#############################################################

# Make sure temporary files are cleaned at exit
# trap 'rm -f ${TMPFILE}*' EXIT
trap 'rm -fr ${TMPFILE}* ${ANSIBLE_LIBRARY_TMP}' EXIT
trap 'exit 1' HUP QUIT KILL TERM INT

# Set the defaults
Verbose=false
Dry_run=false
Echo=

Continue_on_error=true
Show_error_count=true
Single_file=false
Parallel=false
Parallel_count=4
Fix=false
#Retrieve_roles=false
Retrieve_roles=true
Prepare=true
Output_format=table

# parse command line into arguments and check results of parsing
while getopts :adDf:FhqrvxX OPT
do
  # Support long options
  if [[ $OPT = "-" ]] ; then
    OPT="${OPTARG%%=*}"       # extract long option name
    OPTARG="${OPTARG#$OPT}"   # extract long option argument (may be empty)
    OPTARG="${OPTARG#=}"      # if long option argument, remove assigning `=`
  fi

  case $OPT in
     a) Wrapper
        exit $?
        ;;
     d|debug)
        Verbose=true
        Verbose1="-v"
        Debug1="-d"
        set -vx
        ;;
     D|dry-run)
        Dry_run=true
        Dry_run1="-D"
        Echo=echo
        ;;
     f) Output_format="$OPTARG"
        ;;
     F) Fix=true
        ;;
     h) Usage
        exit 0
        ;;
     q) Quiet1="-q"
        ;;
     r) Retrieve_roles=true
        ;;
     v|verbose)
        Verbose=true
        Verbose1="-v"
        ;;
     x) Prepare=true
        ;;
     X) Prepare=false
        ;;
     *) echo "Unknown flag -$OPT given!" >&2
        exit 1
        ;;
  esac

  # Set flag to be use by Test_flag
  eval ${OPT}flag=1

done
shift $(($OPTIND -1))

Overwrite_virtualenv
Check_version
Ansible_type

if [[ $Ansible_lint_major_version == 4 && $Output_format != pep8 ]]
then
  echo "This version of ansible-lint only supports pep8" >&2
  echo "Falling back to pep8 with severity" >&2
  Output_format=parsable
fi

# Playbook preparation
[[ $Prepare == true ]] && Prepare

# Set error/issue count to '0'
Errors=0
Issue=0

# Run ansible-lint
ansible-lint $Quiet1 $Verbose1 $Args $Tags2skip "$@" >${TMPFILE}
Errors=$(($Errors+$?))

# Delete messages we expect in verbose mode
sed -i "/^Found /d;/^Examining/d;/^Unknown file type/d" ${TMPFILE}

# Convert input
case $Output_format in
  column)
    eval Input_${InputF} | column -t -s "::"
    ;;
  table)
    Output_format=csv
    eval Input_${InputF} > ${TMPFILE}csv
    Csv2table
    ;;
  *)
    eval Input_${InputF}
    ;;
esac

# Exit now
exit $Errors
