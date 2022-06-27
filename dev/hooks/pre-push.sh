#!/usr/bin/env bash
#### $$VERSION$$ v1.52-1-g0dae2db

############
# NOTE: you MUST run install-hooks.sh again when updating this file!

# magic to ensure that we're always inside the root of our application,
# no matter from which directory we'll run script
GIT_DIR=$(git rev-parse --git-dir)
cd "${GIT_DIR}/.." || exit 1

export HOOKDIR="dev/hooks"
LASTPUSH='.git/.lastpush'

# if any command inside script returns error, exit and return that error 
set -e

printf "Running pre-push hook\n............................\n"

unset IFS; set -f

# note date of last push for version
touch "${LASTPUSH}"
