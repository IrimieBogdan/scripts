#!/bin/bash
set -e

modules=( puppetlabs-acl puppetlabs-bootstrap puppetlabs-chocolatey puppetlabs-concat puppetlabs-exec puppetlabs-facter_task puppetlabs-inifile puppetlabs-java_ks puppetlabs-motd puppetlabs-package puppetlabs-registry puppetlabs-resource puppetlabs-scheduled_task puppetlabs-service puppetlabs-stdlib puppetlabs-wsus_client puppetlabs-puppet_conf )

script_path=$(pwd)
results_file_name=results_$(date +%s)
mkdir -p $results_file_name

for module_name in "${modules[@]}"
do
  MODULE=${module_name} PASSWORD=${PASSWORD} GEM_SOURCE=${GEM_SOURCE} FACTER_GEM_VERSION=${FACTER_GEM_VERSION} ./run_acceptance.sh &>$results_file_name/${module_name} &
  pids[$i]=$!
  ((i=i+1))
  sleep 20
done

# wait for all pids
echo "Waiting for jobs to finish, check results directory"
for pid in ${pids[*]}; do
    echo "waiting for pid $pid"
    wait $pid
done