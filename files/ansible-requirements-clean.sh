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


##############################################################
#
# Defining standarized functions
#
#############################################################

FUNCTIONS=${DIRNAME}/functions.sh
if [[ -f ${FUNCTIONS} ]]
then
   . ${FUNCTIONS}
else
   echo "Functions file '${FUNCTIONS}' could not be found!" >&2
   exit 1
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

function Gitignore
{

  if ! grep -q "^roles/${Role}$" .gitignore
  then
    [[ $Verbose == true ]] && echo "Appending 'roles/${Role}' to .gitignore"
    echo "roles/${Role}" >> .gitignore
  fi

  if ! grep -q "^roles/${Role}/$" .gitignore
  then
    [[ $Verbose == true ]] && echo "Appending 'roles/${Role}/' to .gitignore"
    echo "roles/${Role}/" >> .gitignore
  fi

}

function Yamlloop
{

  # Check for roles[]
  if yq -j .roles $Reqfile >/dev/null 2>&1
  then
    Roles=$(yq -j .roles $Reqfile | jq -r '.[] | @base64')
  else
    Roles=$(yq -j . $Reqfile | jq -r '.[] | @base64')
  fi

  for row in $Roles
  do
    role=$(echo ${row} | base64 --decode | jq -r .name 2>/dev/null | sed "s/null//")
    [[ -z $role ]] && role=$(echo ${row} | base64 --decode | jq -r .role 2>/dev/null | sed "s/null//")
    [[ -z $role ]] && role=$(echo ${row} | base64 --decode | jq -r .name 2>/dev/null | sed "s/null//")
    [[ -z $role ]] && role=$(echo ${row} | base64 --decode | jq -r .src 2>/dev/null | sed "s/null//")
    [[ -z $role ]] && role=$(echo ${row} | base64 --decode)
    echo "$role"
  done

}


##############################################################
#
# Main programs
#
#############################################################

# Make sure temporary files are cleaned at exit
trap 'rm -f ${TMPFILE}*' EXIT
trap 'exit 1' HUP QUIT KILL TERM INT

# Set the defaults
Debug_level=0
Verbose=false
Verbose_level=0
Dry_run=false
Force=false
Echo=
Gitignore=true

# parse command line into arguments and check results of parsing
while getopts :dDFGhv-: OPT
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
    F)
      Force=true
      ;;
    G)
      Gitignore=false
      ;;
    h|help)
      Usage
      exit 0
      ;;
    v|verbose)
      Verbose=true
      Verbose_level=$(($Verbose_level+1))
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

# parameters
Reqfile=${1:-'roles/requirements.yml'}

Galaxy=`which ansible-galaxy 2>/dev/null`
if [[ ! -x $Galaxy ]]
then
  echo "ansible-galaxy executable not found!" >&2
  exit 1
fi

#Roles=`ansible-galaxy list -p roles/ 2>&1 | grep ^- | sed -r "s/^(- )(.*),.*/\2/"`
Roles=$(Yamlloop)
for Role in $Roles
do

  [[ $Gitignore == true ]] && Gitignore

  if [[ -e roles/$Role ]]
  then
    if [[ -L roles/$Role ]]
    then
      echo "Leaving symbolic link 'roles/$Role'" >&2
      continue
    elif [[ -d roles/$Role/.git ]]
    then
      if [[ $Force == true ]]
      then
        $Echo rm -fr roles/$Role
      else
        echo "Leaving repository 'roles/$Role' due to presence of .git directory" >&2
      fi
    elif [[ -d roles/$Role ]]
    then
      [[ $Verbose == true ]] && echo "Removing 'role/$Role'" >&2
      $Echo rm -fr roles/$Role
    fi
  else
    [[ $Verbose == true ]] && echo "Role '$Role' not found"
  fi
done
