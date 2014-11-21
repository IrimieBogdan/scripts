#!/usr/bin/env bash

set -x

#-------------------------------------------------------------------------------
# Prepare external acceptance testing repository.
#

mkdir -p ./tmp
#ACCEPTANCE_REPO="https://github.com/waynr/puppet"
#ACCEPTANCE_REF="${{ACCEPTANCE_REF:-quickfix}}"

ACCEPTANCE_LOCALPATH="ruby/puppet"

#git clone "$ACCEPTANCE_REPO" "$ACCEPTANCE_LOCALPATH"

if [ ! -z "$ACCEPTANCE_REF" ] ;then
	pushd "$ACCEPTANCE_LOCALPATH"
	git checkout "$ACCEPTANCE_REF"
	popd
fi

export BEAKER_TESTSUITE="$ACCEPTANCE_LOCALPATH/acceptance/tests"
export BEAKER_POSTSUITE="acceptance/suites/post_suite"
export BEAKER_LOADPATH="$ACCEPTANCE_LOCALPATH/acceptance/lib"

#-------------------------------------------------------------------------------
# Additional Beaker configuration.
#

export BEAKER_OPTS="--keyfile $HOME/.ssh/id_rsa-acceptance --xml --preserve-hosts $PRESERVE_HOSTS"
export BEAKER_OPTIONSFILE="acceptance/config/beaker/options.rb"
export BEAKER_TYPE=foss
unset IS_PE

#-------------------------------------------------------------------------------
# Configure Ruby

export GEM_SOURCE="http://rubygems.delivery.puppetlabs.net"
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
