#!/usr/bin/env bash

set -x
set +x

#-------------------------------------------------------------------------------
# Check build parameters

if [ ! -z "$DEP_VERSION" ] && [ ! -z "$DEP_NAME" ] ;then

    if [ ! "$GIT_VER" = "master" ] ;then
        echo "GIT_VER must be 'master' when changing dependency versions."
        exit 0
    fi

    pushd {name}

    #---------------------------------------------------------------------------
    # Update git repository

    git add project.clj
    git commit -m "Set $DEP_NAME to $DEP_VERSION"
    git push origin master

    popd
fi
