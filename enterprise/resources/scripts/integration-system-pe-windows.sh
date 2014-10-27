#!/usr/bin/env bash

set -e
set -x

#-------------------------------------------------------------------------------
# Variables

KEYFILE="$HOME/.ssh/id_rsa-acceptance"
BEAKER_LOADPATH="{beaker_loadpath}"
BEAKER_PRESUITE="{beaker_presuite}"
BEAKER_TESTSUITE="$(echo {beaker_testsuite} | tr ' ' ',')"

export GEM_SOURCE="http://rubygems.delivery.puppetlabs.net"

#---------------------------------------
# Get pe info from redis

REDIS_HOSTNAME=redis.delivery.puppetlabs.net
pe_version="$(redis-cli -h $REDIS_HOSTNAME get ${{pe_family}}_pe_version)"

export pe_version="${{pe_version_override:-$pe_version}}"

#---------------------------------------
# PE variables

#export pe_dep_versions="$(pwd)/config/versions/pe_version"

export pe_dist_dir="http://neptune.puppetlabs.lan/$pe_family/ci-ready/"

#-------------------------------------------------------------------------------
# Configure Ruby & Bundle install

set +x
source /usr/local/rvm/scripts/rvm
rvm use ruby-1.9.3-p484
set -x

rm -rf .bundle* Gemfile.lock install_log.*

bundle install --without development

#-------------------------------------------------------------------------------
# Generate Beaker host.cfg

if [ $ARCH == 32 ] ;then
  export pe_use_win32=1
fi

bundle exec genconfig centos6-64mcd-$AGENT-a > hosts.cfg

#-------------------------------------------------------------------------------
# Run Beaker

bundle exec beaker           \
  --xml                      \
  --debug                    \
  --root-keys                \
  --repo-proxy               \
  --preserve-hosts {preserve_hosts}    \
  --config hosts.cfg         \
  --keyfile $KEYFILE       \
  --load-path "$BEAKER_LOADPATH" \
  --pre-suite "$BEAKER_PRESUITE" \
  --tests "$BEAKER_TESTSUITE"
