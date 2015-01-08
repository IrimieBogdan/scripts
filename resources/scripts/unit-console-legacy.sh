#!/bin/bash

echo "rvm_project_rvmrc=0" > .rvmrc
export HOME=`pwd`

source /usr/local/rvm/scripts/rvm
rvm use 1.9.3-p484

set -e
set -x

# So much hate right now
rm -rf oh_god_why
mkdir oh_god_why
cd oh_god_why
git clone git@github.com:puppetlabs/console.git --depth 1 --branch "{pe_family}.x"
# TODO: Do we need to checkout a specific tag/branch of console, or is master fine?
mkdir {name}
cd {name}
ln -s ../../.git ./.git
git checkout $GIT_COMMIT .

set +e
umask 0002 # Be a good RVM citizen
groups
rm -rf .bundle*
bundle install
set -e

bundle exec rspec --format d spec/

test_result=$?

rm -rf .bundle

exit $test_result
