#!/bin/bash +x

set -e

. /usr/local/rvm/scripts/rvm
rvm use 1.9.3-p484

gem install rake

# to set the build description
echo "pe_ver=$(git describe)"

export PE_VER={pe_family}
rake package:bootstrap
rake pe:jenkins:uber_build[20]
ref=$(rake pl:print_build_param[ref])
rake package:implode

echo "REF=${{ref?}}" > promote.properties
echo "PKG={promote_package}" >> promote.properties
echo "BRANCH={pe_family}.x" >> promote.properties
