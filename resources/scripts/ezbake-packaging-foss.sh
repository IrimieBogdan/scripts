#!/usr/bin/env bash

set -x
set -e

if [ ! -z "{script_dir}" ] ;then
    pushd {script_dir}
fi

echo
echo "Configure Ruby"
set +x
source /usr/local/rvm/scripts/rvm
rvm use ruby-1.9.3-p484
set -x

echo
echo "Show version information:"
lein version

echo
echo "Clear local puppetlabs Maven artifacts."
# This is necessary
rm -rf $HOME/.m2/repository/puppetlabs/*

echo
echo "Create ezbake staging directory."
lein run -- stage {ezbake_package_name} "{maven_artifact_name}-version=$LEIN_PROJECT_VERSION"

pushd "target/staging"

echo
echo "Run pl:jenkin:uber_build w/ 5s polling interval"
rake package:bootstrap
rake pl:jenkins:uber_build[5]

echo
echo "Create .props file to pass PACKAGE_BUILD_VERSION to next job."

set +x
cat > "$WORKSPACE/.props" <<PROPS
PACKAGE_BUILD_VERSION=$(rake pl:print_build_param[ref] | tail -n 1)
PROPS
set -x

cat "$WORKSPACE/.props"
popd
