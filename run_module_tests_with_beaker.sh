#!/bin/bash

set -ex

# modules=(   accounts acl apache apt augeas_core bolt_shim bootstrap certregen chocolatey )
win_modules=( iis reboot powershell )
modules=( kubernetes )

#  host_core ibm_installation_manager iis java k5login_core macdslocal_core mailalias_core maillist_core motd nagios_core ntp panos pipelines postgresql powershell puppet_metrics_collector puppetdb python_task_helper registry resource_api scheduled_task selinux_core service sqlserver sshkeys_core stdlib tagmail tomcat translate vcsrepo websphere_application_server windows yumrepo_core zfs_core zone_core

for module_name in "${modules[@]}"
do
  p_module=puppetlabs-${module_name}
  git_url="git@github.com:puppetlabs/${p_module}.git"
  osascript &>/dev/null <<EOF
      tell application "iTerm"
        activate
        tell current window to set tb to create tab with default profile
        tell current session of current window to write text "cd ~/Workspace/modules/tests && git clone ${git_url} && cd ${p_module} && bundle && export 'PUPPET_GEM_VERSION=~> 6.10' && GEM_BOLT=true bundle && beaker-hostgenerator ubuntu1604-64a > spec/acceptance/nodesets/default.yml && ssh-add ~/.ssh/id_rsa-acceptance && BEAKER_debug=true BEAKER_destroy=onpass PUPPET_INSTALL_TYPE=agent BEAKER_PUPPET_AGENT_SHA='1fe6a7f5b055bee30f6717831df0a10735d3191f' bundle exec rspec spec/acceptance"
      end tell
EOF
done

for module_name in "${modules[@]}"
do
  p_module=puppetlabs-${module_name}
  git_url="git@github.com:puppetlabs/${p_module}.git"
  osascript &>/dev/null <<EOF
      tell application "iTerm"
        activate
        tell current window to set tb to create tab with default profile
        tell current session of current window to write text "cd ${p_module} && bundle && export 'PUPPET_GEM_VERSION=~> 6.10' && GEM_BOLT=true bundle && beaker-hostgenerator redhat7-64a > spec/acceptance/nodesets/default.yml && ssh-add ~/.ssh/id_rsa-acceptance && BEAKER_debug=true BEAKER_destroy=onpass PUPPET_INSTALL_TYPE=agent BEAKER_PUPPET_AGENT_SHA='1fe6a7f5b055bee30f6717831df0a10735d3191f' bundle exec rspec spec/acceptance"
      end tell
EOF
done

#  host_core ibm_installation_manager iis java k5login_core macdslocal_core mailalias_core maillist_core motd nagios_core ntp panos pipelines postgresql powershell puppet_metrics_collector puppetdb python_task_helper registry resource_api scheduled_task selinux_core service sqlserver sshkeys_core stdlib tagmail tomcat translate vcsrepo websphere_application_server windows yumrepo_core zfs_core zone_core

for module_name in "${win_modules[@]}"
do
  p_module=puppetlabs-${module_name}
  git_url="git@github.com:puppetlabs/${p_module}.git"
  osascript &>/dev/null <<EOF
      tell application "iTerm"
        activate
        tell current window to set tb to create tab with default profile
        tell current session of current window to write text "cd ~/Workspace/modules/tests && git clone ${git_url} && cd ${p_module} && bundle && export 'PUPPET_GEM_VERSION=~> 6.10' && GEM_BOLT=true bundle && beaker-hostgenerator windows2012r2-64a > spec/acceptance/nodesets/default.yml && ssh-add ~/.ssh/id_rsa-acceptance && BEAKER_debug=true BEAKER_destroy=onpass PUPPET_INSTALL_TYPE=agent BEAKER_PUPPET_AGENT_SHA='1fe6a7f5b055bee30f6717831df0a10735d3191f' bundle exec rspec spec/acceptance"
      end tell
EOF
done
