#!/usr/bin/env bash

#-------------------------------------------------------------------------------
# Sweet Functions

# Update a single dependency in a leiningen project.clj file.
update_dep() {{
  local file="${{1:?}}"
  local project_name="${{2:?}}"
  local new_version="${{3:?}}"
  local namespace="${{4:-puppetlabs}}"

  SED_ADDRESS="\[$namespace\/$project_name "
  SED_REGEX="\".*\""
  SED_REPLACEMENT="\"$new_version\""
  SED_COMMAND="s|$SED_REGEX|$SED_REPLACEMENT|"

  set -e
  set -x

  sed -i -e "/$SED_ADDRESS/ $SED_COMMAND" $file
}}

# Update comma-separated list of leiningen deps in given files
# Note: deplist must take the form:
#   <depname>=<version>[,<depname>=<version>[...]]
update_dep_list() {{
  local file=${{1:?}}
  local deplist=${{2:?}}

  while IFS=',' read -ra ARR ;do
    for entry in "${{ARR[@]}}" ;do
      IFS='=' read -ra depver <<< "$entry"
      update_dep $file ${{depver[0]}} ${{depver[1]}} "puppetlabs"
    done
  done <<< "$deplist"
}}

#-------------------------------------------------------------------------------
# Meat and potatoes

set -x
set -e

if [ ! -z "$DEPLIST" ] ;then
  update_dep_list "project.clj" "$DEPLIST"
fi
