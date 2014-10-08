#!/usr/bin/env bash

set -e
set -x

#-------------------------------------------------------------------------------
# Configure Ruby

source /usr/local/rvm/scripts/rvm
rvm use ruby-1.9.3-p484

# Set Java JDK version based on current matrix value of JDK_BIN_PATH which
# should be a path to the bin directory of the desired JDK.
#

if [ ! -z "${JDK_BIN_PATH}" ] ;then
	export PATH="${JDK_BIN_PATH:-}:${PATH}"
fi

java -version

# Run JRuby tests.
#

lein version
rake spec

