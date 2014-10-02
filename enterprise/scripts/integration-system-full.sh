#!/usr/bin/env bash

set -x

#git checkout "${JVMPUPPET_REF}"

#-------------------------------------------------------------------------------
# Prepare external acceptance testing repository. Whoops, definitely not
# necessary for FOSS since FOSS is a submodule of jvm-puppet. Leaving it here as
# an example when getting started with puppetdb.
#

mkdir -p ./tmp
ACCEPTANCE_REPO="https://github.com/waynr/puppet"
ACCEPTANCE_LOCALPATH="tmp/puppet"
ACCEPTANCE_REF="${ACCEPTANCE_REF:-quickfix}"

git clone "${ACCEPTANCE_REPO}" "${ACCEPTANCE_LOCALPATH}"

if [ ! -z "${ACCEPTANCE_REF}" ] ;then
	pushd "${ACCEPTANCE_LOCALPATH}"
	git checkout "${ACCEPTANCE_REF}"
	popd
fi

export BEAKER_TESTSUITE="${ACCEPTANCE_LOCALPATH}/acceptance/tests"
export BEAKER_POSTSUITE="acceptance/suites/post_suite"
export BEAKER_LOADPATH="${ACCEPTANCE_LOCALPATH}/acceptance/lib"

#-------------------------------------------------------------------------------
# Additional Beaker configuration.
#

export BEAKER_OPTS="--keyfile ${HOME}/.ssh/id_rsa-acceptance --xml --preserve-hosts ${PRESERVE_HOSTS}"
export BEAKER_OPTIONSFILE="acceptance/config/beaker/options.rb"
export BEAKER_TYPE=foss
unset IS_PE

#-------------------------------------------------------------------------------
# Install ruby jank

set +x
source /usr/local/rvm/scripts/rvm
rvm use ruby-1.9.3-p484

#-------------------------------------------------------------------------------
# Bungler commands.
#

bundle install --path vendor/bundle

bundle exec rake test:acceptance:beaker
EXIT_CODE=$?

rm -rf "tmp/puppet"
exit $EXIT_CODE
