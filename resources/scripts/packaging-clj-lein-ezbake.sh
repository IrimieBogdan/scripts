#!/usr/bin/env bash

echo
echo "Configure Ruby"
source /usr/local/rvm/scripts/rvm
rvm use ruby-1.9.3-p484

export NEXUS_JENKINS_USERNAME=jenkins
export NEXUS_JENKINS_PASSWORD=Qu@lity!

set -x
set -e

echo
echo "Show version information:"
lein version

echo
echo "Clear local puppetlabs Maven artifacts."
MAVEN_ARTIFACT_GROUP=$(lein with-profile ci pprint :group | tail -n 1 | cut -d\" -f2)
MAVEN_ARTIFACT_NAME=$(lein with-profile ci pprint :name | tail -n 1 | cut -d\" -f2)
rm -rf $HOME/.m2/repository/$MAVEN_ARTIFACT_GROUP/$MAVEN_ARTIFACT_NAME

echo
echo "Deploying to maven repository:"
lein with-profile ci pprint :repositories
lein with-profile ci pprint :deploy-repositories
echo

lein deploy

echo
echo "Create ezbake staging directory."
lein with-profile ezbake ezbake stage

pushd "target/staging"

echo
echo "Run pl:jenkin:uber_build w/ 5s polling interval"
rake package:bootstrap
rake pl:jenkins:uber_build[5]

echo
echo "Create .props file to pass PACKAGE_BUILD_VERSION to next job."

set +x
cat > "$WORKSPACE/.props" <<PROPS
{package_build_version_varname}=$(rake pl:print_build_param[ref] | tail -n 1)
PROPS
set -x

cat "$WORKSPACE/.props"
popd
