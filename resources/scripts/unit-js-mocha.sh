#!/usr/bin/env bash

# install mocha locally
npm install mocha

npm install

# list the npm package versions
npm ls --depth 0

# alias the local npm bin directory
export PATH=$(npm bin):$PATH

mocha test
