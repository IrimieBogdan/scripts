#!/usr/bin/env bash

cd {assets-builddir}
npm install grunt-cli
npm install
grunt test-ci
