#!/usr/bin/env bash

export NEXUS_JENKINS_USERNAME=jenkins
export NEXUS_JENKINS_PASSWORD=Qu@lity!

set -e
set -x

echo
echo "Show version information:"
lein version

echo
echo "Deploying to maven repository:"
lein with-profile ci pprint :repositories
lein with-profile ci pprint :deploy-repositories

lein deploy

echo
echo "Create .props file to pass LEIN_PROJECT_VERSION to next job."
set +x
cat > "$WORKSPACE/.props" <<PROPS
LEIN_PROJECT_VERSION=$(lein with-profile ci pprint :version | tail -n 1 | cut -d\" -f2)
PROPS
set -x

cat "$WORKSPACE/.props"
