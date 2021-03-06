#!/bin/bash
#
#=====================================================================
#
# Name        : molecule-test.sh
# Author      : Mark van Huijstee
# Description : Execute molecule test on ansible role
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

# Set date/time related variables
DATESTAMP=$(date "+%Y%m%d")
TIMESTAMP=$(date "+%Y%m%d.%H%M%S")

# Logfile & directory
#LOGDIR=$DIRNAME
LOGDIR=$TMPDIR
#LOGFILE=${LOGDIR}/${BASENAME_ROOT}.log
LOGFILE=${LOGDIR}/${BASENAME_ROOT}.${TIMESTAMP}.log

# Figure out the platform
OS=$(uname -s)

# Get the hostname
HOSTNAME=$(hostname -s)


##############################################################
#
# Defining custom variables
#
##############################################################

MOLECULE_YAML=molecule/\$Scenario/molecule-test.yml
MOLECULE_VERSION=$(PY_COLORS=0 molecule --version | awk '/^molecule/ {print $2}')
MOLECULE_DISTRO=${MOLECULE_DISTRO:-'rockylinux8'}
export MOLECULE_DISTRO


##############################################################
#
# Defining standarized functions
#
#############################################################

#FUNCTIONS=${DIRNAME}/functions.sh
#if [[ -f ${FUNCTIONS} ]]
#then
#   . ${FUNCTIONS}
#else
#   echo "Functions file '${FUNCTIONS}' could not be found!" >&2
#   exit 1
#fi


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
   -D          : Execute as dry-run
   -h          : Prints this help message
   -v          : Verbose mode

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
   -Z <x,y>    : Distributions to test

Examples:

Test on Debian 10+11 only
\$ BASENAME -Z debian10,debian11

Do not delete container after testing
\$ $BASENAME -k

Only create containers
\$ $BASENAME -m create

EOF

}

function Setup
{

  Install_pip e2j2
  Install_pip yq

}

function Install_pip
{

  if ! pip show $1 >/dev/null 2>&1
  then
    echo "Installing pip package '$1'"
    pip install $1 || exit 1
  fi

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

function Fail_on_error
{

  # Fail when molecule gave an error
  if [[ ${PIPESTATUS[0]} -ne 0 ]]
  then
    echo "#############################################################" >&2
    echo "Molecule encountered one or more errors" >&2
    echo "#############################################################" >&2
    exit 1
  fi

}

function Fail_on_deprecation_warning
{

  # Get all deprecation warnings we should ignore
  yq -y .deprecation_warnings.ignore ${Molecule_yaml} 2>/dev/null | \
  sed "/null/d;/\.\.\./d" | \
  sed "s/- '//;s/'$//;s/''/'/g;s/\[/\\\[/;s/\]/\\\]/" > ${TMPFILE}dep

  # Get all deprecation warning not to be ignored
  grep "\[DEPRECATION WARNING\]" ${TMPFILE} | grep -v -f ${TMPFILE}dep > ${TMPFILE}dep1

  # Throw error if warning is found
  if [[ -s ${TMPFILE}dep1 ]]
  then
    echo "#############################################################" >&2
    echo "One or more deprecation warnings found!" >&2
    echo "#############################################################" >&2
    cat ${TMPFILE}dep1 >&2
    exit 1
  fi

}

function Fail_on_warning
{

  # Get all warnings we should ignore
  yq -y .warnings.ignore ${Molecule_yaml} 2>/dev/null | \
  sed "/null/d;/\.\.\./d" | \
  sed "s/- '//;s/'$//;s/''/'/g;s/\[/\\\[/;s/\]/\\\]/" > ${TMPFILE}warn

  # Get all deprecation warning not to be ignored
  grep "\[WARNING\]" ${TMPFILE} | grep -v -f ${TMPFILE}warn > ${TMPFILE}warn1

  # Throw error if warning is found
  if [[ -s ${TMPFILE}warn1 ]]
  then
    echo "#############################################################" >&2
    echo "One or more warnings found!" >&2
    echo "#############################################################" >&2
    cat ${TMPFILE}warn1 >&2
    exit 1
  fi

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

  if [[ -f molecule/$Scenario/requirements.yml ]]
  then
    [[ ! -f molecule/$Scenario/requirements.yml.org ]] && cp molecule/$Scenario/requirements.yml molecule/$Scenario/requirements.yml.org
    sed -i -r "s|git@([a-zA-Z0-9\.\-\_]*):(.*)|https://gitlab-ci-token:$CI_JOB_TOKEN@\\1/\\2|" molecule/$Scenario/requirements.yml
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
    *)
      Molecule_args="--scenario-name=$Scenario"
      ;;
  esac

  Cmd=$(echo molecule $Verbose1 $Args $Mode $Molecule_args)

  [[ $Verbose == true ]] && echo "Executing '$Cmd'"
  [[ $Dry_run == true ]] && return 0

  # Execute the command
  eval $Cmd 2>&1 | tee ${TMPFILE}

  # Save the exit code
  Exit_code=${PIPESTATUS[0]}

  # Fail when molecule gave an error
  [[ $Exit_code -ne 0 ]] && Fail_on_error

  # Fail when a deprecation warning was given and failure is required
  [[ $Fail_on_deprecation_warning == true ]] && Fail_on_deprecation_warning

  # Fail when a warning was given and failure is required
  [[ $Fail_on_warning == true ]] && Fail_on_warning

  # Exit using the exide code of molecule
  [[ $Exit_code -gt 0 ]] && exit $Exit_code

}

function Render_molecule_yaml
{

  # export Scenario
  export Scenario

  # Create molecule.yml from template
  if [[ -f molecule/$Scenario/molecule.yml.j2 ]]
  then

    # Create JSON with all distributions we want 
    Distros=$(echo $Molecule_distributions | sed "s/,/ /g;s/ /|/g")
    Distros_json=$(yq -cj '. | map(select(.name|test("'$Distros'")))' .molecule-platforms.yml)

    # Show settings in verbose mode
    [[ $Verbose == true ]] && echo "$Distros_json" | jq .

    # Render molecule.yml
    export MOLECULE_DISTROS="json:${Distros_json}"
    cd molecule/$Scenario
    rm -f molecule.yml
    e2j2 -f molecule.yml.j2 || exit 1

    # Quick fix for nested jinja host_vars
    sed -i -r "s/(hostvars\[.*)/\"{{ \\1 }}\"/" molecule.yml

    cd - >/dev/null
  fi

}


##############################################################
#
# Main programs
#
#############################################################

# Make sure temporary files are cleaned at exit
trap 'rm -f ${TMPFILE}* ; echo "Log file : $LOGFILE"' EXIT
trap 'exit 1' HUP QUIT KILL TERM INT

# Defaults
Debug=false
Dry_run=false
Verbose=false
Destroy=always
Destroy_and_setup=false
Fail_on_deprecation_warning=false
Fail_on_warning=false
Scenarios=default
Modes=test
#Pre_dependency=true
Pre_dependency=false
Verbose_level=0
Log=true

# parse command line into arguments and check results of parsing
while getopts :c:de:DhkKLm:Ps:vxXZ: OPT
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
     e) Args="$Args -e $OPTARG"
        ;;
     h) Usage
        exit 0
        ;;
     k) Destroy=never
        ;;
     K) Destroy_and_setup=true
        ;;
     L) Log=false
        ;;
     m) Modes=$OPTARG
        ;;
     p) Pre_dependency=true
        ;;
     P) Pre_dependency=false
        ;;
     s) Scenarios=`echo $OPTARG | sed "s/,/ /g"`
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

# Molecule_distributions: fallback onto '$MOLECULE_DISTRO'
Molecule_distributions=${Molecule_distributions:-${MOLECULE_DISTRO}}

# destro, create and test without destroy
if [[ $Destroy_and_setup == true ]]
then
  ${DIRNAME}/${BASENAME} -L -m destroy -Z "${Molecule_distributions}" $Verbose1
  ${DIRNAME}/${BASENAME} -L -m create -Z "${Molecule_distributions}" $Verbose1 || exit $?
  ${DIRNAME}/${BASENAME} -L -k -Z "${Molecule_distributions}" $Verbose1 || exit $?
  exit 0
fi

# Ensure all required packages are installed
Setup

# Test for all needed executables
Executable_test ansible
Executable_test ansible-playbook
Executable_test molecule

# Write output to screen + logfile
if [[ $Dry_run == false && $Log == true ]]
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

  # Execute dependency phase
  [[ $Pre_dependency == true ]] && molecule dependency --scenario-name=$Scenario

  # Loop over all scenarios
  for Scenario in $Scenarios
  do

    # Display scenario
    echo "Proccessing scenario '$Scenario'"

    # Substitute scenario name
    eval Molecule_yaml=$MOLECULE_YAML

    # Show if $Molecule_yaml is present
    if [[ -f $Molecule_yaml ]]
    then
      echo "Found '$Molecule_yaml'"
    fi

    # Render molecule.yml from jinja2 template
    Render_molecule_yaml

    # Test the ansible role against this scenario
    Check_role $Scenario

  done

  # Retrun to the main directory
  [[ $Nested_roles == true ]] && cd - >/dev/null
done

# Exit w/out errors
exit 0
