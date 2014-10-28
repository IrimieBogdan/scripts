#!/usr/bin/env bash

pe_version="$(redis-cli -h $REDIS_HOSTNAME get ${{pe_family}}_pe_version)"
export pe_version="${{pe_version_override:-$pe_version}}"

set +x
cat >> "$WORKSPACE/.props" <<PROPS
pe_version="$pe_version"
PROPS
set -x

cat "$WORKSPACE/.props"
