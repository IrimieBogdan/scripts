#!/bin/bash +x
source /usr/local/rvm/scripts/rvm
rvm use $RUBY_VER

rm -rf .bundle*

umask 0002 # Ensure rvm's group voodoo works correctly

# Need to do a bundle install before we enable `set -e`. Because bundler sucks.
bundle install {unit-bundler-opts}

set -e
set -x

env {unit-rspec-env} bundle exec rspec -fd -c spec {unit-rspec-extra}
