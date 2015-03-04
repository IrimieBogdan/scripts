#!/usr/bin/env bash

export CLOJARS_JENKINS_USERNAME=puppetlabs-jenkins
export CLOJARS_JENKINS_PASSWORD=Qu@lity!

export NEXUS_JENKINS_USERNAME=jenkins
export NEXUS_JENKINS_PASSWORD=Qu@lity!

set -x

echo
echo "Leiningen version"
lein version

echo
echo "Java version"
java -version

if lein with-profile ci 2>&1 > /dev/null ;then
  echo
  echo "Project version"
  $LEIN with-profile ci pprint :version
fi

echo
echo "Deploying to maven repository:"
lein with-profile ci pprint :repositories
lein with-profile ci pprint :deploy-repositories

set -e

echo
echo "Deploy project."
lein deploy
