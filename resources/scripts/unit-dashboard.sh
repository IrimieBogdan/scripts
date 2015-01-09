#!/bin/bash +x
source /usr/local/rvm/scripts/rvm
rvm use 1.9.3-p484

rm -rf .bundle*

umask 0002 # Ensure rvm's group voodoo works correctly

# Need to do a bundle install before we enable `set -e`. Because bundler sucks.
bundle install --without=mysql other_pe assets

set -e
set -x

cp config/database.yml.jenkins config/database.yml

export RAILS_ENV=test
bundle exec rake db:create
bundle exec rake db:schema:load
bundle exec rake db:migrate
bundle exec rake spec
