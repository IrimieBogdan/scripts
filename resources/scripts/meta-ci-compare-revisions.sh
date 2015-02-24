#!/usr/bin/env bash

set -x
set -e

echo
echo "Display shell environment:"

printenv | sort

echo
echo "Display python version:"
python --version

echo
echo "Install virtualenv."
virtualenv local
source local/bin/activate

echo
echo "Install development version of jenkins job builder."
pushd jenkins-job-builder
python setup.py develop
popd

echo
echo "compare head of master against merged head of PR"
./utils/compare.sh -d production -f compare-xml-enterprise.diff enterprise origin/master origin/merged-pr
./utils/compare.sh -d production -f compare-xml-platform.diff platform origin/master origin/merged-pr

