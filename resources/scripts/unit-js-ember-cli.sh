#!/usr/bin/env bash

cd {assets-builddir}

npm install

# install bower locally
npm install bower

# alias the local npm bin directory
alias npm-exec='PATH=$(npm bin):$PATH'

npm-exec bower install
npm-exec ember test --environment=ci
