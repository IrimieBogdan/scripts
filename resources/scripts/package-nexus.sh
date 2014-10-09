#!/usr/bin/env bash

export NEXUS_JENKINS_USERNAME=jenkins
export NEXUS_JENKINS_PASSWORD=Qu@lity!

set -e

LEIN=$(mktemp lein.XXXXXX)
wget https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein -O ${LEIN}
chmod +x ${LEIN}

./${LEIN:-lein} version
./${LEIN:-lein} deploy

set -x
cat > packaging.props <<DOWNSTREAM_BUILD_PARAMETERS
GIT_REF=$(git show-ref HEAD)
LEIN_PROJECT_VERSION=$(lein with-profile ci pprint :version | tail -n 1 | cut -d\" -f2)
DOWNSTREAM_BUILD_PARAMETERS
set +x

set +e # failed commands after this do not indicate job failure

rm ${LEIN}
