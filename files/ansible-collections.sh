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
TMPDIR=$(mktemp -d)
TMPFILE=${TMPDIR}/${BASENAME}.${RANDOM}.${RANDOM}

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

TMP_PATH=/tmp/ansible-fqcn-converter


##############################################################
#
# Defining standarized functions
#
#############################################################

FUNCTIONS=${DIRNAME}/functions.sh
if [[ -f ${FUNCTIONS} ]]
then
   . ${FUNCTIONS}
#else
#   echo "Functions file '${FUNCTIONS}' could not be found!" >&2
#   exit 1
fi


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

EOF

}


##############################################################
#
# Main programs
#
#############################################################

# Make sure temporary files are cleaned at exit
trap 'rm -fr ${TMPDIR}' EXIT
trap 'exit 1' HUP QUIT KILL TERM INT

# Set the defaults
Verbose=false
Dry_run=false
Echo=

Roledir=roles

# parse command line into arguments and check results of parsing
while getopts :dDhr:v-: OPT
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
      set -vx
      ;;
    D|dry-run)
      Dry_run=true
      Dry_run1="-D"
      Echo=echo
      ;;
    h|help)
      Usage
      exit 0
      ;;
    r|roledir)
      Roledir=$OPTARG
      ;;
    v|verbose)
      Verbose=true
      Verbose1="-v"
      ;;
    *)
      echo "Unknown flag -$OPT given!" >&2
      exit 1
      ;;
  esac

  # Set flag to be use by Test_flag
  eval ${OPT}flag=1

done
shift $(($OPTIND -1))

# Write all generic requirements
cat <<EOF >${TMPFILE}base
---
collections:
  - community.docker
  - community.general
  - ansible.posix
EOF

# Get all collection files
Collection_files=$(ls .collections ${Roledir}/*/.collections ${TMPFILE}base 2>/dev/null)

# Get all collections
Collections=$(yq .collections $Collection_files | jq -s 'add|sort|unique' | yq -jc .)
export collections="json:$Collections"

# Exit if none are found
if [[ -z $Collections ]]
then
  echo "No collections to be installed."
  exit 0
fi

# Create collection using jinja2 template
export collections="json:$Collections"
cat <<EOF > ${TMPFILE}.j2
---
collections:
{% for collection in collections %}
  - name: {{ collection | regex_replace(':.*') }}
{%- set version = (collection | regex_replace('.*:')) -%}
{% if version != collection %}
    version: {{ version }}
{% endif%}
{% endfor %}
EOF
e2j2 -f ${TMPFILE}.j2

# Display list of collections
cat ${TMPFILE} | sed "/^$/d"

# Install all collections
ansible-galaxy collection install -r ${TMPFILE}
echo

# Process playbook collections
if [[ -f collections/requirements.yml ]]
then
  ansible-galaxy collection install -r collections/requirements.yml
fi

exit 0
