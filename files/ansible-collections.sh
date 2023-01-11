#!/bin/bash

TMPFILE=$(mktemp)

trap 'rm -f $TMPFILE' EXIT

# Get all collections
Collections=`ls -d .collections roles/*/.collections 2>/dev/null`

# Exit if none are found
if [[ -z $Collections ]]
then
  echo "No collections to be installed."
  exit 0
fi

# Merge al collections into one
echo "collections:" > ${TMPFILE}
for x in $Collections
do
  yq -y .collections $x
done | sort -u | grep -v ansible.builtin >> ${TMPFILE}

# Display list of collections
cat ${TMPFILE}

# Install all collections
ansible-galaxy collection install -r ${TMPFILE}
echo

exit 0
