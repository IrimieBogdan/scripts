#!/usr/bin/env bash

export NEXUS_JENKINS_USERNAME=jenkins
export NEXUS_JENKINS_PASSWORD=Qu@lity!

WORKINGDIR={shell_workspace}
if [ ! -z "$WORKINGDIR" ] ;then
    pushd $WORKINGDIR
fi

set -e
set -x

echo
echo "Show version information:"
lein version

echo
echo "Run custom release tasks:"
lein vcs assert-committed
lein change version leiningen.release/bump-version :release
RELEASE_VERSION=$(lein with-profile ci pprint :version | tail -n 1 | cut -d\" -f2)
git add -A
git commit -m "Version $RELEASE_VERSION"
git tag $RELEASE_VERSION -m "Release $RELEASE_VERSION"
lein change version leiningen.release/bump-version :patch
SNAPSHOT_VERSION=$(lein with-profile ci pprint :version | tail -n 1 | cut -d\" -f2)
git add -A
git commit -m "Version $SNAPSHOT_VERSION"
git push origin HEAD:master $RELEASE_VERSION

echo
echo "Append to .props file to pass PACKAGE_BUILD_VERSION to next job."
cat >> .props <<DOWNSTREAM_BUILD_PARAMETERS
REF=$(lein with-profile ci pprint :version | tail -n 1 | cut -d\" -f2)
DOWNSTREAM_BUILD_PARAMETERS
