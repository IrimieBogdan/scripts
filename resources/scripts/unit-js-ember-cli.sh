#!/usr/bin/env bash

cd {assets-builddir}

npm install

# install bower locally
npm install bower

# alias the local npm bin directory
export PATH=$(npm bin):$PATH

bower install
ember test --environment=ci
