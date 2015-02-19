#!/usr/bin/env bash
set -e

set -x

echo
echo "Remove old assets from the gitz"
cd $WORKSPACE
git rm -r {assets-outdirs}

echo
echo "Entering build directory and building assets"
cd $WORKSPACE/{assets-tempdir}

npm install

# list the npm package versions
npm ls --depth 0

# alias the local npm bin directory -- this is needed for the ember app
export PATH=$(npm bin):$PATH

ember build --environment=production -output-path=$WORKSPACE/{assets-outdirs}

echo
echo "Push rebuilt assets to git repository"
cd $WORKSPACE
git add {assets-outdirs}
git commit -m "Build frontend assets for commit $GIT_COMMIT"
git push origin HEAD:{scm_branch}
