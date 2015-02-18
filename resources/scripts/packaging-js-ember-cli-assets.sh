#!/usr/bin/env bash
set -e

set -x

echo
echo "Remove old assets from the gitz"
git rm -r $WORKSPACE/{assets-outdirs}

echo
echo "Entering build directory and building assets"
cd $WORKSPACE/{assets-tempdir}
ember build --environment=production -output-path=$WORKSPACE/{assets-outdirs}

echo
echo "Push rebuilt assets to git repository"

git add $WORKSPACE/{assets-outdirs}
git commit -m "Build frontend assets for commit $GIT_COMMIT"
git push origin HEAD:{scm_branch}
