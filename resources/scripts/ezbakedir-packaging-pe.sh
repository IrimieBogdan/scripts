#!/usr/bin/env bash

set +x
set -e

if [ -z "$PE_VER" ] ;then
	echo 'Must set $PE_VER'
	exit 1
fi

echo
echo "Configure Ruby"
source /usr/local/rvm/scripts/rvm
rvm use ruby-1.9.3-p484

echo
echo "Show version information:"
lein version

echo
echo "Create ezbake staging directory."
lein run -- stage {name}

pushd "target/staging"

echo
echo "Run pl:jenkin:uber_build w/ 5s polling interval"
rake package:bootstrap
rake pe:jenkins:uber_build[5]

echo
echo "Create .props file to pass PACKAGE_BUILD_VERSION to next job."
cat > "$WORKSPACE/.props" <<PROPS
PACKAGE_BUILD_VERSION=$(rake pl:print_build_param[ref] | tail -n 1)
PROPS
popd
