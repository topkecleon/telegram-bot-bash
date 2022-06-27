#!/usr/bin/env bash
#############################################################
#
# File: dev/dev.inc.sh
#
# Description: common stuff for all dev scripts
#
#### $$VERSION$$ v1.52-1-g0dae2db
#############################################################

# magic to ensure that we're always inside the root of our application,
# no matter from which directory we'll run script

# shellcheck disable=SC2034
GIT_DIR=$(git rev-parse --git-dir 2>/dev/null)
BASE_DIR=$(git rev-parse --show-toplevel 2>/dev/null)
if [ "${BASE_DIR}" != "" ] ; then
	cd "${BASE_DIR}" || exit 1
else
	printf "Sorry, no git repository %s\n" "$(pwd)" && exit 1
fi

HOOKDIR="dev/hooks"
LASTCOMMIT=".git/.lastcommit"
