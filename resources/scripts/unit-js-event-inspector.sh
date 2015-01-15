#!/bin/bash

export PATH=./node_modules/.bin:$PATH
cd resources
npm install grunt-cli
npm install
bower install
bower ls
grunt karma:ci
