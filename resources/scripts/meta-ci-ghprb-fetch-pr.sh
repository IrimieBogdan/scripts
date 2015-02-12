#!/usr/bin/env bash

# This script is intended primarily as a helper for jobs downstream of those
# triggered by github PR to populate the $WORKSPACE git repository with the PR
# branches. This ensures that other scripts operating in the context of a github
# PR trigger don't have to worry about the details of the specific PR being
# tested since after the $WORKSPACE git repository will contain two branches,
# one representing the current origin/master, the other representing the PR
# head.
#
# This script also takes care to only fetch the PR branches that we are directly
# concerned with as a result of a PR trigger which can save some bandwidth in
# the case of repos containing a larger history.

set -x
set -e

echo
echo "Fetch Github PRs"
git fetch origin +refs/pull/$ghprbPullId/*:refs/remotes/origin/pr/$ghprbPullId/*

echo
echo "Make master and PR branches available for compare script."
git checkout -b master origin/master
git checkout -b merged-pr origin/pr/$ghprbPullId/merge
