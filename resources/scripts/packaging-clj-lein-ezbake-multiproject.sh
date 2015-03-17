#!/usr/bin/env bash

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

# Given a git repository, a git ref, and a checkout_name...
# Clone the git repo, checkout the ref in that repo, and update the current
# project's dependency string to match that of the project in the git repo.
checkout_and_update_dep() {{
  local git_repo="${{1:?}}"
  local git_ref="${{2:?}}"
  local checkout_name="${{3:?}}"

  mkdir -p checkouts

  pushd checkouts
    git clone $git_repo $checkout_name
    pushd $checkout_name
      mkdir -p $WORKSPACE/tmp
      ln -sf $WORKSPACE/tmp tmp

      git checkout $git_ref

      local maven_artifact_name=$(lein pprint :name | tail -n 1 | cut -d\" -f2)
      local maven_artifact_group=$(lein pprint :group | tail -n 1 | cut -d\" -f2)
      local maven_artifact_version=$(lein pprint :version | tail -n 1 | cut -d\" -f2)

      lein install

    popd # back to checkouts directory
  popd # back to original directory

  echo
  echo "Update $checkout_name to $maven_artifact_version in $ezbake_project_version"
  update_dep "project.clj" $maven_artifact_name $maven_artifact_version $maven_artifact_group
}}

set -x
set -e

echo
echo "Show version information:"
lein version

echo
java -version

MAVEN_ARTIFACT_NAME=$(lein pprint :name | tail -n 1 | cut -d\" -f2)

echo
echo "Clone {packaging_github_project} and set that as the working directory."
mkdir -p tmp
cd tmp
git clone -b \
  {packaging_git_branch} \
  git@github.com:puppetlabs/{packaging_github_project}.git \
  {packaging_github_project}

pushd {packaging_github_project}

echo
echo "Make sure local project.clj has :local-repo."
sed -i -e '/(defproject.*/ a  :local-repo "tmp/m2-local"' project.clj

mkdir -p $WORKSPACE/tmp
ln -sf $WORKSPACE/tmp tmp

echo
echo "Check out $MAVEN_ARTIFACT_NAME and update its dependency in {packaging_github_project}."
checkout_and_update_dep $WORKSPACE $GIT_COMMIT $MAVEN_ARTIFACT_NAME

if [ "{acceptance_github_project}" = "{packaging_github_project}" ] ;then
  lein install
elif [ ! -z "{acceptance_github_project}" ] && \
  [ ! -z "{acceptance_git_branch}" ] ;then
  echo
  echo "Check out {acceptance_github_project} and update its dependency in {packaging_github_project}."
  checkout_and_update_dep \
    git@github.com:puppetlabs/{acceptance_github_project}.git \
    {acceptance_git_branch} \
    {acceptance_github_project}
fi

echo
echo "Install checkouts projects."
lein checkouts install

echo
echo "Create ezbake staging directory."
sleep {packaging_sleep}
lein with-profile ezbake ezbake stage

rm -rf Gemfile Gemfile.lock # some projects specify a hard rake version
                            # dependency which breaks this job

cd "target/staging"

set +x
echo
echo "Configure Ruby"
source /usr/local/rvm/scripts/rvm
rvm use ruby-1.9.3-p484
set -x

echo
echo "Run pl:jenkin:uber_build w/ 5s polling interval"
if [ ! -z "{pe_family}" ] ;then
  export PE_VER={pe_family}
  rake package:bootstrap
  rake pe:jenkins:uber_build[5]
else
  rake package:bootstrap
  rake pl:jenkins:uber_build[5]
fi

echo
echo "Create .props file to pass {package_build_version_varname} to next job."

set +x
cat > "$WORKSPACE/.props" <<PROPS
{package_build_version_varname}=$(rake pl:print_build_param[ref] | tail -n 1)
PROPS
set -x

cat "$WORKSPACE/.props"
