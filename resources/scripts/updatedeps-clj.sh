#!/usr/bin/env bash

set -x
set -e

#-------------------------------------------------------------------------------
# Check build parameters

if [ ! -z "$DEP_VERSION" ] && [ ! -z "$DEP_NAME" ] ;then

    if [ ! "$GIT_REF" = "master" ] ;then
        echo "GIT_VER must be 'master' when changing dependency versions."
        exit 1
    fi

    #---------------------------------------------------------------------------
    # Run dependency-updating script
    ./utils/update-dep.sh {name}/project.clj $DEP_VERSION $DEP_NAME puppetlabs

fi
