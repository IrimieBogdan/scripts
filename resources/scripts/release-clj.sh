#!/usr/bin/env bash

export CLOJARS_JENKINS_USERNAME=puppetlabs-jenkins
export CLOJARS_JENKINS_PASSWORD=Qu@lity!

export NEXUS_JENKINS_USERNAME=jenkins
export NEXUS_JENKINS_PASSWORD=Qu@lity!

set -e
set -x

echo
echo "Obtain initial maven version for project."
PRERELEASE_VERSION=$($LEIN pprint :version | tail -n 1 | cut -d\" -f2)

echo
echo "Fail if there are any changes to the local repo."
lein vcs assert-committed

echo
echo "Bump to next release version."
lein change version leiningen.release/bump-version release
RELEASE_VERSION=$($LEIN pprint :version | tail -n 1 | cut -d\" -f2)

git add project.clj
git commit -m "Version $RELEASE_VERSION"
RELEASE_REF=$(git describe)

echo
echo "Bump to next snapshot version."
echo "Level can be set as a build parameter but defaults to 'patch'."
lein change version leiningen.release/bump-version ${{VERSION_LEVEL:-:patch}}
POSTRELEASE_VERSION=$($LEIN pprint :version | tail -n 1 | cut -d\" -f2)
git add project.clj
git commit -m "Version $POSTRELEASE_VERSION"

# TODO
# QENG-1950 Jenkins needs to:
#  * submit PR here instead and wait for merge
git push HEAD:$BRANCH

echo
echo "Check out the $RELEASE_REF again."
git checkout $RELEASE_REF

echo
echo "Create tag and push it to git repo."
git tag $RELEASE_VERSION -m "Version $RELEASE_VERSION"
git push $RELEASE_VERSION

echo
echo "Finally, deploy release version."
lein deploy
