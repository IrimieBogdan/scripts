#!/usr/bin/env bash

cd $WORKSPACE/{assets-builddir}

# install phantomjs locally
npm install phantomjs@1.9.8

# install bower locally
npm install bower

npm install

# list the npm package versions
npm ls --depth 0

# alias the local npm bin directory
export PATH=$(npm bin):$PATH

bower install
ember test --port {testem-port} > $WORKSPACE/test-results.tap
