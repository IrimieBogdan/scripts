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
echo "Run leiningen's release task:"
lein release

echo
echo "Append to .props file to pass PACKAGE_BUILD_VERSION to next job."

set +x
cat >> .props <<DOWNSTREAM_BUILD_PARAMETERS
REF=$(lein with-profile ci pprint :version | tail -n 1 | cut -d\" -f2)
DOWNSTREAM_BUILD_PARAMETERS
set -x

cat .props
