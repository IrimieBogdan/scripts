#!/usr/bin/env bash

set -x
set +x

#-------------------------------------------------------------------------------
# Check build parameters

if [ ! -z "$DEP_VERSION" ] && [ ! -z "$DEP_NAME" ] ;then

    #---------------------------------------------------------------------------
    # Run dependency-updating script
    ./utils/update-dep.sh {name}/project.clj $DEP_VERSION $DEP_NAME puppetlabs
else
    echo "WARNING: Continuing without updating any dependency version."
fi
