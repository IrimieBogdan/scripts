#!/usr/bin/env bash

cd dev-resources/{name}
npm install grunt-cli
npm install
grunt test-ci
