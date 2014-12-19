#!/bin/bash

set +e

BUNDLE_PATH=`mktemp -d`

bundle install --path $BUNDLE_PATH

# {qualifier} will be substituted with a value from performance/production/clamps_project.yaml
bundle exec beaker --color --debug --type pe --config {qualifier}-leig-beaker.cfg --tests setup/scale --preserve-hosts always

rm -rf $BUNDLE_PATH

exit $result
