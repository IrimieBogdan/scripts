#!/bin/bash
set -e

# modules=( puppetlabs-acl puppetlabs-bootstrap puppetlabs-chocolatey puppetlabs-concat puppetlabs-exec puppetlabs-facter_task puppetlabs-inifile puppetlabs-java_ks puppetlabs-motd puppetlabs-package puppetlabs-registry puppetlabs-resource puppetlabs-scheduled_task puppetlabs-service puppetlabs-stdlib puppetlabs-wsus_client puppetlabs-puppet_conf )
#modules=( puppetlabs-acl puppetlabs-bootstrap puppetlabs-chocolatey puppetlabs-concat puppetlabs-exec puppetlabs-facter_task puppetlabs-inifile puppetlabs-java_ks puppetlabs-motd puppetlabs-package puppetlabs-registry puppetlabs-resource puppetlabs-scheduled_task puppetlabs-service puppetlabs-stdlib puppetlabs-wsus_client puppetlabs-puppet_conf puppetlabs-host_core puppetlabs-ibm_installation_manager puppetlabs-iis puppetlabs-java puppetlabs-k5login_core puppetlabs-macdslocal_core puppetlabs-mailalias_core puppetlabs-maillist_core  puppetlabs-nagios_core puppetlabs-ntp puppetlabs-panos puppetlabs-pipelines puppetlabs-postgresql puppetlabs-powershell puppetlabs-puppet_metrics_collector puppetlabs-puppetdb puppetlabs-python_task_helper  puppetlabs-resource_api  puppetlabs-selinux_core  puppetlabs-sqlserver puppetlabs-sshkeys_core puppetlabs-tagmail puppetlabs-tomcat puppetlabs-translate puppetlabs-vcsrepo puppetlabs-websphere_application_server puppetlabs-windows puppetlabs-yumrepo_core puppetlabs-zfs_core puppetlabs-zone_core )
modules=( cisco_ios device_manager provision puppetlabs-accounts puppetlabs-acl puppetlabs-apache puppetlabs-apt puppetlabs-azure puppetlabs-bootstrap puppetlabs-chocolatey puppetlabs-concat puppetlabs-docker puppetlabs-dsc puppetlabs-dsc_lite puppetlabs-exec puppetlabs-facter_task puppetlabs-firewall puppetlabs-haproxy puppetlabs-helm puppetlabs-ibm_installation_manager puppetlabs-iis puppetlabs-inifile puppetlabs-java puppetlabs-java_ks puppetlabs-kubernetes puppetlabs-motd puppetlabs-mysql puppetlabs-ntp puppetlabs-package puppetlabs-panos puppetlabs-postgresql puppetlabs-powershell puppetlabs-puppet_conf puppetlabs-reboot puppetlabs-registry puppetlabs-resource puppetlabs-resource_api puppetlabs-rook puppetlabs-satellite_pe_tools puppetlabs-scheduled_task puppetlabs-service puppetlabs-sqlserver puppetlabs-stdlib puppetlabs-tagmail puppetlabs-tomcat puppetlabs-translate puppetlabs-vcsrepo puppetlabs-vsphere puppetlabs-websphere_application_server puppetlabs-windows puppetlabs-wsus_client )
script_path=$(pwd)
results_file_name=results_$(date +%s)
mkdir -p $results_file_name

for module_name in "${modules[@]}"
do
  ./run_unit_tests.sh ${module_name} &>$results_file_name/${module_name} &
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
