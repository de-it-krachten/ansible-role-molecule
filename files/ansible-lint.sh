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

function Check_version
{

  # ansible-lint
  Ansible_lint_version=$(ansible-lint --version | awk '$1=="ansible-lint" {print $2}')
  Ansible_lint_major_version=$(echo $Ansible_lint_version | cut -f1 -d.)

  # Only accept ansible-lint v4
  [[ $Ansible_lint_major_version -lt 4 ]] && echo "Please upgrade to ansible-lint v4 or higher!" >&2 && exit 1

  # Set some version specific settings
  [[ $Ansible_lint_major_version == 4 ]] && Args="--parseable-severity" && Output_format=legacy
  [[ $Ansible_lint_major_version =~ (5|6) ]] && Args="-f codeclimate"

}

function Format_json
{

  echo "$line" | base64 -d
  [[ $Issue != $Issues ]] && echo -e ",\c"

}


function Format_parsable
{

  echo "$path|$linenr|$check_name|$severity|$description|" | sed -z 's/@@/\\n/g'

}

function Format_readable
{
 
  cat <<EOF
  path: $path
  linenr: $linenr
  check_name: $check_name
  severity: $severity
  description: $description
EOF

}

function Printf
{
  printf "%-80s%-10s\n" $File $1
}

function Prepare
{

  # Delete all roles in requirements.yml
  echo "Deleting all external roles in directory 'roles'"
  ansible-galaxy.sh -Cq

  # Include roles from other galaxy/git etc
  echo "Retrieving all roles as configured in roles/requirements.yml"
  ansible-galaxy.sh -q

  # Search for custom libraries and add to ANSIBLE_LIBRARY
  Libraries=`ls -d roles/*/library 2>/dev/null`
  if [[ -n $Libraries ]]
  then
    echo "Copy all custom modules"
    [[ -z $ANSIBLE_LIBRARY ]] && ANSIBLE_LIBRARY=${ANSIBLE_LIBRARY} || ANSIBLE_LIBRARY=${ANSIBLE_LIBRARY}:${ANSIBLE_LIBRARY_TMP}
    export ANSIBLE_LIBRARY

    # Copy custom modules
    for Library in $Libraries
    do
      cp $Library/* ${ANSIBLE_LIBRARY_TMP}
    done
  fi

  # Delete all roles in requirements.yml
  # if [[ $Retrieve_roles == false ]]
  if [[ $Ansible_type == roles ]]
  then
    echo "Deleting all external roles in directory 'roles'"
    ansible-galaxy.sh -Cq
  fi 

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
Retrieve_roles=false
Prepare=true
Output_format=parsable

# parse command line into arguments and check results of parsing
while getopts :dDf:FhrvxX OPT
do
  # Support long options
  if [[ $OPT = "-" ]] ; then
    OPT="${OPTARG%%=*}"       # extract long option name
    OPTARG="${OPTARG#$OPT}"   # extract long option argument (may be empty)
    OPTARG="${OPTARG#=}"      # if long option argument, remove assigning `=`
  fi

  case $OPT in
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

Check_version
Ansible_type

# Playbook preparation
[[ $Prepare == true && $Ansible_repo_type == playbook ]] && Prepare

# Run ansible-lint
ansible-lint -q -f codeclimate $Tags2skip >${TMPFILE} 2>/dev/null

# Set error count to '0'
Errors=0
Issue=0
Issues=`jq '.|length' ${TMPFILE}`

# For json, write array starting
[[ $Output_format == json ]] && echo -e "[\c"

# Loop over each item
exec 3<<< `jq -r '.[] | @base64' ${TMPFILE}`
while read -u3 line
do

  # Increment the issue count
  Issue=$(($Issue+1))

  # Skip if empty array
  [[ -z $line ]] && continue

  path=`echo "$line" | base64 -d | jq -r '.location.path'`
  check_name=`echo "$line" | base64 -d | jq -r '.check_name' | sed "s/.*\[//;s/\].*//"`
  linenr=`echo "$line" | base64 -d | jq -r '.location.lines.begin.line' 2>/dev/null`
  [[ -z $linenr ]] && linenr=`echo "$line" | base64 -d | jq -r '.location.lines.begin'`
  severity=`echo "$line" | base64 -d | jq -r '.severity'`
  description=`echo "$line" | base64 -d | jq -r '.description' | sed -z 's/\n/@@/g;s/@@$/\n/'`

  eval Format_${Output_format}
  Errors=$(($Errors+1))

done

# For json, write array closing 
[[ $Output_format == json ]] && echo -e "]"

# Exit now
exit $Errors
