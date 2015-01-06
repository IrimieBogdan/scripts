#!/usr/bin/env bash
#
# This script is intended to be used as a general purpose 'execute shell' build
# step. It does impose some requirements on projects whose pipeline builders
# wish to use it:
#
# * The root directory of the project must contain a Gemfile with:
# ** beaker
# ** sqa-utils
#

set -e
set -x

#-------------------------------------------------------------------------------
# Variables

BEAKER_KEYFILE="${{BEAKER_KEYFILE:-$HOME/.ssh/id_rsa-acceptance}}"
BEAKER_LOADPATH="${{BEAKER_LOADPATH:-{beaker_loadpath}}}"
BEAKER_OPTIONSFILE="${{BEAKER_OPTIONSFILE:-{beaker_optionsfile}}}"
BEAKER_HELPER="${{BEAKER_HELPER:-{beaker_helper}}}"
BEAKER_PRESUITE="${{BEAKER_PRESUITE:-{beaker_presuite}}}"
BEAKER_TESTSUITE="${{BEAKER_TESTSUITE:-$(echo {beaker_testsuite} | tr ' ' ',')}}"
BEAKER_POSTSUITE="${{BEAKER_POSTSUITE:-{beaker_postsuite}}}"

#-------------------------------------------------------------------------------
# PE-specific stuff

if [ ! -z "{is-pe}" ] ;then
    #---------------------------------------
    # Get pe info from redis

    REDIS_HOSTNAME=redis.delivery.puppetlabs.net
    pe_version="$(redis-cli -h $REDIS_HOSTNAME get ${{pe_family}}_pe_version)"

    export pe_version="${{pe_version_override:-$pe_version}}"
    #export pe_dep_versions="$(pwd)/config/versions/pe_version"
    export pe_dist_dir="http://neptune.puppetlabs.lan/$pe_family/ci-ready/"

    #---------------------------------------
    # Beaker variables
    BEAKER_TYPE="pe"
else
    unset IS_PE
    BEAKER_TYPE="foss"
fi

#-------------------------------------------------------------------------------
# Configure Ruby & Bundle install
#
# TODO: Remove hard dependency on rvm here so this script can be useful outside
# of CI.

export GEM_SOURCE="http://rubygems.delivery.puppetlabs.net"

set +x
source /usr/local/rvm/scripts/rvm
rvm use ruby-1.9.3-p484
set -x

rm -rf .bundle* Gemfile.lock install_log.*

bundle install --without development

#-------------------------------------------------------------------------------
# Generate Beaker host.cfg

if [ $PLATFORM == centos7 ] \
    || [ $PLATFORM == oracle7 ] \
    || [ $PLATFORM == redhat7 ] \
    || [ $PLATFORM == sles12 ]
then
  export LAYOUT=${{LAYOUT//32/64}}
fi

bundle exec genconfig $PLATFORM-$LAYOUT > hosts.cfg

#-------------------------------------------------------------------------------
# Run Beaker

{additional_exports}

bundle exec beaker           \
  --xml                      \
  --debug                    \
  --root-keys                \
  --repo-proxy               \
  --preserve-hosts {preserve_hosts}       \
  --config hosts.cfg                      \
  --type "$BEAKER_TYPE"                   \
  --keyfile "$BEAKER_KEYFILE"             \
  --load-path "$BEAKER_LOADPATH"          \
  --options-file "$BEAKER_OPTIONSFILE"    \
  --pre-suite "$BEAKER_PRESUITE"          \
  --post-suite "$BEAKER_POSTSUITE"        \
  --helper "$BEAKER_HELPER"               \
  --tests "$BEAKER_TESTSUITE"
