#!/usr/bin/env bash
set -e

echo
echo "Configure Ruby"
source /usr/local/rvm/scripts/rvm
rvm use ruby-1.9.3-p484

set -x

echo
echo "Remove old assets from the gitz"
git rm -r {assets-outdirs}

# set our umask to ensure we can install gems sanely to shared rvm dir
# but keep the old one around so perms aren't weird on built files
OLD_UMASK=`umask`
umask 0002

echo
echo "Install sass from Gemfile"
bundle install

# Restore umask to system default now that our gem is in place
umask $OLD_UMASK

echo
echo "Enter assets dir and commence build"
set +x
pushd {assets-builddir}
set -x

npm install grunt-cli
npm install
grunt build

set +x
popd
set -x

echo
echo "Push rebuilt assets to git repository"

git add {assets-outdirs}
git commit -m "Build frontend assets for commit $GIT_COMMIT"
git push origin HEAD:{scm_branch}
