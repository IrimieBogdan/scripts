#!/usr/bin/env bash

set -e
set -x

#-------------------------------------------------------------------------------
# Set variable defaults

export GEM_SOURCE=${{GEM_SOURCE:-{gem_source}}}
export RVM_RUBY_VERSION=${{RVM_RUBY_VERSION:-{rvm_ruby_version}}}

{additional_exports}

#-------------------------------------------------------------------------------
# Configure Ruby

source /usr/local/rvm/scripts/rvm
rvm use $RVM_RUBY_VERSION

#-------------------------------------------------------------------------------
# Set Java JDK version based on current matrix value of JDK_BIN_PATH which
# should be a path to the bin directory of the desired JDK.

if [ ! -z "$JDK_BIN_PATH" ] ;then
    export PATH="$JDK_BIN_PATH:$PATH"
fi

#-------------------------------------------------------------------------------
# Print interesting system information

echo
echo "Print Java version"
java -version

echo
echo "Install Leiningen 2.5.1"
mkdir -p tmp/bin
cd tmp/bin
wget https://raw.githubusercontent.com/technomancy/leiningen/2.5.1/bin/lein
chmod u+x lein
cd ../../

export PATH=$WORKSPACE/tmp/bin:$PATH

echo
echo "Print Leiningen version"
./tmp/bin/lein version


lein version
lein run -m org.jruby.Main -e 'load "META-INF/jruby.home/bin/rake"' spec
