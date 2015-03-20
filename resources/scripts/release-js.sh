#!/usr/bin/env bash
set -x
set -e

TAGNAME=$(npm version patch -m "Release version %s")
git push origin HEAD:{scm_branch}
git push origin $TAGNAME
