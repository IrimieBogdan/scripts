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
echo "Deploy {deployment} of ci-job-configs to {jenkins_instance}"
./utils/deploy.sh update {jenkins_instance} {deployment}

