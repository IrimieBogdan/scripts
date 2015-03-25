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

BEAKER_ROOT="${{BEAKER_ROOT:-{beaker_root}}}"
BEAKER_KEYFILE="${{BEAKER_KEYFILE:-$HOME/.ssh/id_rsa-acceptance}}"
BEAKER_LOADPATH="${{BEAKER_LOADPATH:-{beaker_loadpath}}}"
BEAKER_OPTIONSFILE="${{BEAKER_OPTIONSFILE:-{beaker_optionsfile}}}"
BEAKER_HELPER="${{BEAKER_HELPER:-{beaker_helper}}}"
BEAKER_PRESUITE="${{BEAKER_PRESUITE:-{beaker_presuite}}}"
BEAKER_TESTSUITE="${{BEAKER_TESTSUITE:-$(echo {beaker_testsuite} | tr ' ' ',')}}"
BEAKER_POSTSUITE="${{BEAKER_POSTSUITE:-{beaker_postsuite}}}"
BEAKER_TYPE="${{BEAKER_TYPE:-{beaker_type}}}"

UPGRADE_FROM="${{UPGRADE_FROM:-NONE}}"

#-------------------------------------------------------------------------------
# PE-specific stuff

if [ ! -z "{is-pe}" ] ;then
    #---------------------------------------
    # Get pe info from redis

    REDIS_HOSTNAME=redis.delivery.puppetlabs.net
    redis_pe_version="$(redis-cli -h $REDIS_HOSTNAME get {pe_family}_pe_version)"

    if [ ! -z "{pe_dep_versions}" ] ;then
      export pe_dep_versions="{pe_dep_versions}"
    fi

    # very hackish. PLATFORM will typically be strings such as "debian6" or
    # "sles10" but for windows integration testing the variable will be set to
    # "64" or "32" presumably to indicate which of 32 vs 64 bit binary to
    # install.
    if [ "$PLATFORM" == 32 ] ;then
      export pe_use_win32=1
    fi

    if [ "$UPGRADE_FROM" != "NONE" ] ;then
      export pe_upgrade_version="${{pe_version:-$redis_pe_version}}"
      export pe_upgrade_family={pe_family}
      export pe_version=$UPGRADE_FROM
      export pe_family=$UPGRADE_FROM
      export pe_dist_dir="http://neptune.puppetlabs.lan/{pe_family}/ci-ready/"
    else
      export pe_version="${{pe_version:-$redis_pe_version}}"
      export pe_family="{pe_family}"
      export pe_dist_dir="http://neptune.puppetlabs.lan/{pe_family}/ci-ready/"
    fi
else
    unset IS_PE
fi

#-------------------------------------------------------------------------------
# Configure Ruby
#
# TODO: Remove hard dependency on rvm here so this script can be useful outside
# of CI.

export GEM_SOURCE="http://rubygems.delivery.puppetlabs.net"

set +x
source /usr/local/rvm/scripts/rvm
rvm use {rvm_ruby_version}
set -x

unset pushd
unset popd

#-------------------------------------------------------------------------------
# Bundle install
#
# Using JJB we set the beaker_root to {beaker_root}. Here we use that value to
# set the correct working directory before bundle installing and running beaker
# commands.
#

if [ ! -z "$BEAKER_ROOT" ] ;then
  pushd $BEAKER_ROOT
fi

rm -rf .bundle* Gemfile.lock install_log.*

bundle install --without development

#-------------------------------------------------------------------------------
# Generate Beaker host.cfg

if [ "$PLATFORM" == centos7 ] \
    || [ "$PLATFORM" == oracle7 ] \
    || [ "$PLATFORM" == redhat7 ] \
    || [ "$PLATFORM" == scientific7 ] \
    || [ "$PLATFORM" == sles12 ]
then
  export LAYOUT=${{LAYOUT//32/64}}
fi

{genconfig} > hosts.cfg
cat hosts.cfg

#-------------------------------------------------------------------------------
# Run Beaker

{additional_exports}

set +x
BEAKER="bundle exec beaker --xml --debug --root-keys --repo-proxy"
BEAKER="$BEAKER --preserve-hosts {preserve_hosts} --config hosts.cfg"
BEAKER="$BEAKER --type $BEAKER_TYPE"
BEAKER="$BEAKER --keyfile $BEAKER_KEYFILE"
BEAKER="$BEAKER --tests $BEAKER_TESTSUITE"

if [ ! -z "$BEAKER_HELPER" ] ;then
  BEAKER="$BEAKER --helper $BEAKER_HELPER"
fi

if [ ! -z "$BEAKER_OPTIONSFILE" ] ;then
  BEAKER="$BEAKER --options-file $BEAKER_OPTIONSFILE"
fi

if [ ! -z "$BEAKER_POSTSUITE" ] ;then
  BEAKER="$BEAKER --post-suite $BEAKER_POSTSUITE"
fi

if [ ! -z "$BEAKER_PRESUITE" ] ;then
  BEAKER="$BEAKER --pre-suite $BEAKER_PRESUITE"
fi

if [ ! -z "$BEAKER_LOADPATH" ] ;then
  BEAKER="$BEAKER --load-path $BEAKER_LOADPATH"
fi
set -x

$BEAKER
