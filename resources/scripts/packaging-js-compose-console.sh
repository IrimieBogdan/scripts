#!/usr/bin/env bash

set -x
set -e

cd $WORKSPACE/{assets-composedir}

./compose.sh manifest.json

cd $WORKSPACE/{assets-tempdir}

# install phantomjs locally
npm install phantomjs@1.9.8 --save

# install bower locally
npm install bower --save

npm install

# list the npm package versions
npm ls --depth 0

# alias the local npm bin directory
export PATH=$(npm bin):$PATH

bower install

ember g pe-base-styles

ember test --port {testem-port}

ember build --environment=production -output-path=$WORKSPACE/.tmp/pe-console-ui/resources/dist/
