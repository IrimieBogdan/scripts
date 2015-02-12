#!/bin/bash +x
source /usr/local/rvm/scripts/rvm
rvm use 1.9.3-p484

rm -rf .bundle*

umask 0002 # Ensure rvm's group voodoo works correctly

# Need to do a bundle install before we enable `set -e`. Because bundler sucks.
bundle install {unit-bundler-opts}

set -e
set -x

[ -s ".rspec" ] || echo '-fd -c' > .rspec

bundle exec rake spec

echo "REF=$GIT_COMMIT" > promote.properties
echo "MODULE_NAME={module_name}" >> promote.properties
echo "BRANCH={scm_branch}" >> promote.properties
