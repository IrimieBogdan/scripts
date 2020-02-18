#!/bin/bash
set -ex

modules=( puppetlabs-registry puppetlabs-iis )

script_path=$(pwd)
for module_name in "${modules[@]}"
do
  osascript &>/dev/null <<EOF
      tell application "iTerm"
        activate
        tell current window to set tb to create tab with default profile
        tell current session of current window to write text "cd ${script_path}"
        tell current session of current window to write text "MODULE=${module_name} PASSWORD=${PASSWORD} GEM_SOURCE=${GEM_SOURCE} FACTER_GEM_VERSION=${FACTER_GEM_VERSION} ./run_acceptance.sh "
      end tell
EOF
done
