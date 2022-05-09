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
#export PATH=/bin:/usr/bin:/sbin:/usr/sbin:$PATH

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
#LOGDIR=$DIRNAME
LOGDIR=$TMPDIR
#LOGFILE=${LOGDIR}/${BASENAME_ROOT}.log
LOGFILE=${LOGDIR}/${BASENAME_ROOT}.${TIMESTAMP}.log

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

MOLECULE_DISTRO=${MOLECULE_DISTRO:-'rockylinux8'}
export MOLECULE_DISTRO


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

Runs 'molecule <phase>'

Usage : $BASENAME <flags>

Flags :

   -d          : Debug mode (set -x)
   -h          : Prints this help message

   -c <path>   : Path where role is located (default=current path)
   -e key=val  : Extra vars for molecule
   -k          : Do not destroy the container
   -m <mode>   : Molecule phase to execute (default=test)
   -p          : Execute dependency phase before test (default)
                 Useful when depending on custom tasks from other roles (e.g. lint)
   -P          : Do NOT run the dependency phase before test
   -s <names>  : Scenario(s) to execute (divided by comma's)
   -x          : Fail if deprecation warning is found
   -X          : Fail if warning is found (non-deprecation)

Examples:

Do not delete container
\$ $BASENAME -k

Only create containers
\$ $BASENAME -m create


EOF

}

function Executable_test
{

  Executable=$1
  Exec=`command -v $Executable`

  if [[ -z $Exec ]]
  then
    echo "$Executable not found!" >&2
    echo "You might have to switch to a(nother) virtualenv" >&2
    exit 1
  fi

}

function Discard_deprecation
{

  cat <<EOF > ${TMPFILE}dep
\[DEPRECATION WARNING\]: docker_image_facts
EOF

}

function Discard_warning
{

  cat <<EOF > ${TMPFILE}warn
EOF

}

function Fix_requirements
{

  if [[ -z $CI_JOB_TOKEN ]]
  then
    echo "No variable 'CI_JOB_TOKEN' defined!" >&2
    return 1
  fi

#  if [[ -f roles/requirements.yml ]]
#  then
#    [[ ! -f roles/requirements.yml.org ]] && cp roles/requirements.yml roles/requirements.yml.org
#    sed -i -r "s|git@([a-zA-Z0-9\.\-\_]*):(.*)|https://gitlab-ci-token:$CI_JOB_TOKEN@\\1/\\2|" roles/requirements.yml
#  fi

}

function Fix_requirements_role
{

  if [[ -z $CI_JOB_TOKEN ]]
  then
    echo "No variable 'CI_JOB_TOKEN' defined!" >&2
    return 1
  fi

  if [[ -f molecule/default/requirements.yml ]]
  then
    [[ ! -f molecule/default/requirements.yml.org ]] && cp molecule/default/requirements.yml molecule/default/requirements.yml.org
    sed -i -r "s|git@([a-zA-Z0-9\.\-\_]*):(.*)|https://gitlab-ci-token:$CI_JOB_TOKEN@\\1/\\2|" molecule/default/requirements.yml
  fi

}

function Check_role
{

  Scenario=${1:-'default'}

  # Message
  Role=`basename $PWD`
  echo "Processing role '$Role'"

  # Test for valid repo
  if [[ ! -f meta/main.yml ]]
  then
    echo "No valid ansible repository found!" >&2
    echo "Make sure 'meta/main.yml' exists" >&2
    exit 1
  fi

  # Create symlink with alternate role name
  Alt_role=`cat .ansible.alt_role 2>/dev/null`
  if [[ -n $Alt_role ]]
  then
    cd ..
    if [[ ! -L $Alt_role ]]
    then
      echo "Creating symlink '$Alt_role' -> '$Role'"
      ln -fs $Role $Alt_role
    fi
    cd - >/dev/null
  fi

  #
  for Mode in `echo $Modes | sed "s/,/ /g"`
  do
    Execute_molecule $Mode
  done

}

function Execute_molecule
{

  local Mode=$1

  # Set variables for molecule
  export MOLECULE_DEBUG=$Debug
  export PY_COLORS=1
  export ANSIBLE_FORCE_COLOR=1

  case $Mode in
    test)
      Molecule_args="--destroy=$Destroy --scenario-name=$Scenario"
      ;;
  esac

  Cmd=$(echo molecule $Verbose1 $Args $Mode $Molecule_args)

  [[ $Verbose == true ]] && echo "Executing '$Cmd'"
  [[ $Dry_run == true ]] && return 0

  # Execute the command
  eval $Cmd 2>&1 | tee ${TMPFILE}

  # Fail when molecule gave an error
  if [[ ${PIPESTATUS[0]} -ne 0 ]]
  then
    echo "#############################################################" >&2
    echo "Molecule encountered one or more errors" >&2
    echo "#############################################################" >&2
    exit 1
  fi

  # Fail when a deprecation warning was given and failure is required
  if [[ $Fail_on_deprecation_warning == true ]]
  then
    Discard_deprecation
    grep -v -f ${TMPFILE}dep ${TMPFILE} > ${TMPFILE}dep1
    if grep -q "\[DEPRECATION WARNING\]" ${TMPFILE}dep1
    then
      echo "#############################################################"
      echo "One or more deprecation warnings found!" >&2
      echo "#############################################################"
      exit 1
    fi
  fi

  # Fail when a warning was given and failure is required
  if [[ $Fail_on_warning == true ]]
  then
    Discard_warning
    grep -v -f ${TMPFILE}warn ${TMPFILE} > ${TMPFILE}warn1
    if grep -q "\[WARNING\]" ${TMPFILE}warn1
    then
      echo "#############################################################"
      echo "One or more warnings found!" >&2
      echo "#############################################################"
      exit 1
    fi
  fi

}



##############################################################
#
# Main programs
#
#############################################################

# Make sure temporary files are cleaned at exit
trap 'rm -f ${TMPFILE}*' EXIT
trap 'exit 1' HUP QUIT KILL TERM INT

# Defaults
Debug=false
Dry_run=false
Verbose=false
Destroy=always
Fail_on_deprecation_warning=false
Fail_on_warning=false
Scenarios=default
Modes=test
#Pre_dependency=true
Pre_dependency=false
Verbose_level=0

# parse command line into arguments and check results of parsing
while getopts :c:de:Dhkm:Ps:vxXZ: OPT
do
   case $OPT in
     c) Role_path=$OPTARG
        ;;
     d) set -vx
        Debug=true
        ;;
     D) Dry_run=true
        Verbose=true
        ;;
     e) # Write variables to file
        Args="$Args -e $OPTARG"
        ;;
     h) Usage
        exit 0
        ;;
     k) Destroy=never
        ;;
     m) Modes=$OPTARG
        ;;
     p) Pre_dependency=true
        ;;
     P) Pre_dependency=false
        ;;
     s) Scenarios="$OPTARG"
        ;;
     v) Verbose=true
        Verbose_level=$(($Verbose_level+1))
        Verbose1="$Verbose1 -v"
        ;;
     x) Fail_on_deprecation_warning=true
        ;;
     X) Fail_on_warning=true
        ;;
     Z) Molecule_distributions=$(echo $Molecule_distributions $OPTARG)
        ;;
     *) echo "Unknown flag -$OPT given!" >&2
        exit 1
        ;;
   esac

   # Set flag to be use by Test_flag
   eval ${OPT}flag=1

done
shift $(($OPTIND -1))

# Test for all needed executables
Executable_test ansible
Executable_test ansible-playbook
Executable_test molecule

# Write output to screen + logfile
if [[ $Dry_run == false ]]
then
  { coproc tee { tee $LOGFILE ;} >&3 ;} 3>&1
  exec >&${tee[1]} 2>&1
fi

# Switch to the role path if specified
[[ -n ${Role_path} ]] && cd ${Role_path}

# Check if we are dealing with a combined playbook & roles repository
if [[ -d roles ]]
then
  # Clean all present roles not directlry part of this repository
  ansible-requirements-clean.sh -F -v
  Nested_roles=true
  Roles=`ls roles | grep -v requirements.yml`
elif [[ ( ! -d tasks && ! -d library ) || -d group_vars || -d playbooks ]]
then
  echo "Not an Ansible role, but rather a playbook repository"
  exit 0
else
  Nested_roles=false
  Roles=current
fi

# Fix requirement.yml (git/pubkey --> https/token)
Fix_requirements

# Loop through all roles
for Role in $Roles
do

  [[ $Role != current ]] && echo "----------------------- Testing role '$Role' ----------------------------"

  # Jump to role directory when included in playbook repo
  [[ $Nested_roles == true ]] && cd roles/$Role

  # Fix requirement.yml (git/pubkey --> https/token)
  Fix_requirements_role

  # Create molecule.yml from template
  if [[ -f molecule/default/molecule.yml.j2 ]]
  then

    if [[ -z $Molecule_distributions ]]
    then
      export MOLECULE_DISTROS="json:[\"$MOLECULE_DISTRO\"]"
    else
      Molecule_distributions=$(echo $Molecule_distributions | sed "s/ /,/g")
      export MOLECULE_DISTROS="json:$(echo [$Molecule_distributions] | yq -c -j .)"
    fi

    cd molecule/default
    rm -f molecule.yml
    e2j2 -f molecule.yml.j2 || exit 1
    cd - >/dev/null
  fi

  # Execute dependency phase
  [[ $Pre_dependency == true ]] && molecule dependency --scenario-name=$Scenario

  for Scenario in `echo $Scenarios | sed "s/,/ /g"`
  do
    Check_role $Scenario
  done

  # Retrun to the main directory
  [[ $Nested_roles == true ]] && cd - >/dev/null
done

echo "Log file : $LOGFILE"

# Exit w/out errors
exit 0
