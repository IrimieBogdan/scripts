#!/usr/bin/env bash

set -x
set +x

#-------------------------------------------------------------------------------
# Check build parameters

if [ -z "$DEP_VERSION" ] ;then
	echo 'Must set $DEP_VERSION'
	exit 1
fi

if [ -z "$DEP_NAME" ] ;then
	echo 'Must set $DEP_NAME'
	exit 1
fi

#-------------------------------------------------------------------------------
# Announce versions of stuff

echo
lein version
echo

#-------------------------------------------------------------------------------
# Run dependency-updating script

./utils/update-dep.sh {name}/project.clj $DEP_VERSION $DEP_NAME puppetlabs

