#!/usr/bin/env bash

set -x
set -e

if [ ! "$COMMIT_CHANGES" = "true" ] ;then
    exit 0
fi

#-------------------------------------------------------------------------------
# Check build parameters

if [ ! -z "$DEPLIST" ] ;then

    if [ ! "$GIT_REF" = "master" ] ;then
        echo "GIT_VER must be 'master' when changing dependency versions."
        exit 0
    fi

    pushd {name}

    #---------------------------------------------------------------------------
    # Update git repository

    git add project.clj
    git commit -m "Set $DEPLIST"
    git push origin master

    popd
fi
