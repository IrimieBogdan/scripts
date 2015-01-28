#!/usr/bin/env bash

cd {assets-builddir}

npm install
bower install
node_modules/ember-cli/bin/ember test --environment=ci
