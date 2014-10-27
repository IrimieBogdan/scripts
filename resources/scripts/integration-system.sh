#!/usr/bin/env bash

set -e
set -x

#-------------------------------------------------------------------------------
# Install ruby jank

set +x
source /usr/local/rvm/scripts/rvm
rvm use ruby-1.9.3-p484
set -x

rm -f Gemfile.lock

bundle install --path vendor/bundle

#-------------------------------------------------------------------------------
# Run acceptance tests.

export BEAKER_POSTSUITE="acceptance/suites/post_suite"
export BEAKER_LOADPATH="acceptance/lib"
export BEAKER_OPTS="--keyfile ${HOME}/.ssh/id_rsa-acceptance --preserve-hosts onfail --xml --log-level debug"
export BEAKER_OPTIONSFILE="acceptance/config/beaker/options.rb"
export BEAKER_TYPE=foss

unset IS_PE

bundle exec rake test:acceptance:beaker
