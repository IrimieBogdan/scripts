#!/usr/bin/env bash

echo
echo "Configure Ruby"
source /usr/local/rvm/scripts/rvm
rvm use ruby-1.9.3-p484

set -x
set -e

wget https://raw.githubusercontent.com/technomancy/leiningen/2.5.1/bin/lein
chmod u+x lein

LEIN=$WORKSPACE/lein

echo
echo "Show version information:"
$LEIN version

echo
echo "Clear local Maven artifacts for this project."
MAVEN_ARTIFACT_GROUP=$($LEIN with-profile ci pprint :group | tail -n 1 | cut -d\" -f2)
MAVEN_ARTIFACT_NAME=$($LEIN with-profile ci pprint :name | tail -n 1 | cut -d\" -f2)
MAVEN_ARTIFACT_VERSION=$($LEIN with-profile ci pprint :version | tail -n 1 | cut -d\" -f2)
rm -rf $HOME/.m2/repository/$MAVEN_ARTIFACT_GROUP/$MAVEN_ARTIFACT_NAME

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

mkdir -p tmp
cd tmp
git clone -b {pe_family}.x git@github.com:puppetlabs/pe-console-services.git

cd pe-console-services

mkdir -p checkouts

TMPD=$PWD
cd checkouts
git clone $WORKSPACE $MAVEN_ARTIFACT_NAME
cd $MAVEN_ARTIFACT_NAME
git checkout $GIT_COMMIT
cd $TMPD

echo
echo "Update $MAVEN_ARTIFACT_NAME to $MAVEN_ARTIFACT_VERSION in pe-console-services"
update_dep "project.clj" $MAVEN_ARTIFACT_NAME $MAVEN_ARTIFACT_VERSION

echo
echo "Create ezbake staging directory."
$LEIN checkouts install

echo
echo "Create ezbake staging directory."
sleep {packaging_sleep}
$LEIN with-profile ezbake ezbake stage

TMPD=$PWD
cd "target/staging"

echo
echo "Run pl:jenkin:uber_build w/ 5s polling interval"
export PE_VER={pe_family}
rake package:bootstrap
rake pe:jenkins:uber_build[5]

echo
echo "Create .props file to pass PACKAGE_BUILD_VERSION to next job."

set +x
cat > "$WORKSPACE/.props" <<PROPS
{package_build_version_varname}=$(rake pl:print_build_param[ref] | tail -n 1)
PROPS
set -x

cat "$WORKSPACE/.props"
cd $TMPD
