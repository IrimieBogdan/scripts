#!/bin/bash
set -ex

modules=( puppetlabs-registry puppetlabs-iis )

script_path=$(pwd)
mkdir -p results

for module_name in "${modules[@]}"
do
  MODULE=${module_name} PASSWORD=${PASSWORD} GEM_SOURCE=${GEM_SOURCE} FACTER_GEM_VERSION=${FACTER_GEM_VERSION} ./run_acceptance.sh &>results/${module_name} &
  pids[${i}]=$!
done

# wait for all pids
echo "Waiting for jobs to finish, check results directory"
for pid in ${pids[*]}; do
    wait $pid
done