#!/bin/bash
set -ex

module=$1
echo $1

mkdir -p /tmp/modules_tests/
cd /tmp/modules_tests/
git clone git@github.com:puppetlabs/${module}.git
cd /Users/gheorghe.popescu/Workspace/test/${module}
echo " gem 'facter', path: '/Users/gheorghe.popescu/Workspace/facter-ng'" >> Gemfile
bundle update -j8
bundle exec rake parallel_spec
echo $?
rm -rf /tmp/modules_tests/${module}
