#!/bin/bash

# MODULE=puppetlabs-registry GEM_SOURCE= FACTER_GEM_VERSION= ./run_acceptance.sh

VM_HOST=$(floaty get win-2019-x86_64 | awk '{print $2}')

echo "Running for $MODULE"

bolt script run 1_install_ruby.ps1 2.5.7 \
  --targets winrm://$VM_HOST \
  --user Administrator \
  --password $PASSWORD \
  --no-ssl-verify \
  --debug

bolt script run 2_clone_repo.ps1 $MODULE \
  --targets winrm://$VM_HOST \
  --user Administrator \
  --password $PASSWORD \
  --no-ssl-verify \
  --debug

bolt script run 3_bundle_install.ps1 $MODULE $GEM_SOURCE $FACTER_GEM_VERSION \
  --targets winrm://$VM_HOST \
  --user Administrator \
  --password $PASSWORD \
  --no-ssl-verify \
  --debug

bolt script run 4_run_tests.ps1 $MODULE \
--targets winrm://$VM_HOST \
--user Administrator \
--password $PASSWORD \
--no-ssl-verify \
--debug
