#!/bin/bash
set -ex

modules=( puppetlabs-registry iis )
password=$PASSWORD

for module_name in "${modules[@]}"
do
  osascript &>/dev/null <<EOF
      tell application "iTerm"
        activate
        tell current window to set tb to create tab with default profile
        tell current session of current window to write text "PASSWORD=${password} ./run_acceptance.sh ${module_name}"
      end tell
EOF
done
