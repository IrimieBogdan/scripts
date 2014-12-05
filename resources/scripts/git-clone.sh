#!/usr/bin/env bash

GIT_REF="${{GIT_REF:-{git-branch}}}"

set -x
set -e

echo
echo "Clone git repository."
git clone {git-repo} {git-dir-name}

if [ ! -z "$GIT_REF" ] ;then
    cd {git-dir-name}

    echo
    echo "Checkout given ref"
    git checkout $GIT_REF
fi
