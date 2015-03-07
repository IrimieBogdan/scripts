#!/bin/bash +x

set -e

. /usr/local/rvm/scripts/rvm
rvm use 1.9.3-p484

# to set the build description
echo "pe_ver=$(git describe)"

if [ ! -z "{script_dir}" ] ;then
    pushd "{script_dir}"
fi

export PE_VER={pe_family}
rake package:bootstrap
rake pe:jenkins:uber_build[20]
ref=$(rake pl:print_build_param[ref])
rake package:implode

set +x
cat > "$WORKSPACE/packaging-repo.props" <<PROPS
REF=${{ref?}}
PKG={promote_package}
BRANCH={pe_family}.x
{package_build_version_varname}=${{ref?}}
PROPS
set -x

cat "$WORKSPACE/packaging-repo.props"
