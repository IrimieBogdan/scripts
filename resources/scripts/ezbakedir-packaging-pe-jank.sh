#!/usr/bin/env bash

echo
lein version
echo

set -e
output=$(lein run -- build {name})
set +e


job_url=$(echo "$output" | awk '/Jenkins job created at.*packaging/ &#123; print $5 &#123; ')

echo "Job url is: $job_url"
echo "Polling build job for status..."
sleep 2
while curl -sL "$job_url/api/xml?xpath=//build/building&depth=1" | grep -q -i true; do
  echo "."
  sleep 10
done

# The following works on Jenkins 1.577, may need to rethink it for other
# versions. Derp.
if curl -s "$job_url/1/api/json?pretty=true" \
  | grep "result" | grep -q "SUCCESS" ;then
  echo
  echo "Packaging SUCCESS, See $job_url for details."
  echo
else
  echo
  echo "Packaging FAILURE, see $job_url for details."
  echo
  exit 1
fi

sleep 30 # give the packaging job time to finish setting up the repo

echo
echo "Create .props file to pass PACKAGE_BUILD_VERSION to next job."
pushd "target/staging"

set +x
cat > "$WORKSPACE/.props" <<PROPS
PACKAGE_BUILD_VERSION=$(rake pl:print_build_param[ref] | tail -n 1)
PROPS
set -x

cat "$WORKSPACE/.props"
popd
