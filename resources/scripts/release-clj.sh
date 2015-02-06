#!/usr/bin/env bash

export CLOJARS_JENKINS_USERNAME=puppetlabs-jenkins
export CLOJARS_JENKINS_PASSWORD=Qu@lity!

export NEXUS_JENKINS_USERNAME=jenkins
export NEXUS_JENKINS_PASSWORD=Qu@lity!

set -e
set -x

lein release
echo "Release plugin successful, pushing changes to git"
echo

git push origin --tags HEAD:{scm_branch}

echo "git push successful."
