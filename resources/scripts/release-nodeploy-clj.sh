#!/usr/bin/env bash

echo
echo "Configure Ruby"
source /usr/local/rvm/scripts/rvm
rvm use ruby-1.9.3-p484

set -e

echo
echo "Show version information:"
lein version

echo
echo "Release and Build {name}"
set -x
lein change version leiningen.release/bump-version :release
RELEASE_VERSION=$(lein with-profile ci pprint :version | tail -n 1 | cut -d\" -f2)
git add project.clj
git commit -m "Version $RELEASE_VERSION"
git tag $RELEASE_VERSION -m "Release $RELEASE_VERSION"
set +x

echo
echo "Create ezbake staging directory."
set -x
lein with-profile ezbake ezbake stage
set +x


echo
echo "Run pl:jenkin:uber_build w/ 5s polling interval"

pushd "target/staging"
set -x
export PE_VER={pe_family}
rake package:bootstrap
rake pe:jenkins:uber_build[5]
set +x
popd

echo $PWD

echo
echo "{name} build was successful, bump to next snapshot version"
set -x
lein change version leiningen.release/bump-version :patch
SNAPSHOT_VERSION=$(lein with-profile ci pprint :version | tail -n 1 | cut -d\" -f2)
git add project.clj
git commit -m "Version $SNAPSHOT_VERSION"
set +x

echo
echo "Push current HEAD and $RELEASE_VERSION tag to {scm_branch}"
set -x
git remote -v
git push origin $RELEASE_VERSION
git push origin HEAD:{scm_branch}
set +x

echo
echo "Append to .props file to pass REF to Package-Promotion job."
set +x
cat >> .props <<DOWNSTREAM_BUILD_PARAMETERS
REF=$RELEASE_VERSION
DOWNSTREAM_BUILD_PARAMETERS
set -x

cat .props
