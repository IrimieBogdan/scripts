#!/bin/bash +x +e

source /usr/local/rvm/scripts/rvm
rvm use 1.9.3-p484

set -e
set -x

rm -rf pe-facter
git clone --depth 1 -b {scm_branch} git@github.com:puppetlabs/pe-facter pe-facter
RUBYLIB=$(pwd)/pe-facter/lib

rm -rf pe-license
git clone --depth 1 -b {scm_branch} git@github.com:puppetlabs/pe-license pe-license
RUBYLIB=$RUBYLIB:$(pwd)/pe-license/lib

rm -rf pe-puppet
git clone --depth 1 -b {scm_branch} git@github.com:puppetlabs/pe-puppet pe-puppet
RUBYLIB=$RUBYLIB:$(pwd)/pe-puppet/lib

rm -rf pe-puppetdb
git clone --depth 1 -b {scm_branch} git@github.com:puppetlabs/pe-puppetdb pe-puppetdb
export RUBYLIB=$RUBYLIB:$(pwd)/pe-puppetdb/puppet/lib

rspec spec
