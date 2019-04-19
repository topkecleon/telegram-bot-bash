#!/usr/bin/env bash
#### $$VERSION$$ 0.70-dev-11-g41b8e69

# magic to ensure that we're always inside the root of our application,
# no matter from which directory we'll run script
GIT_DIR=$(git rev-parse --git-dir)
cd "$GIT_DIR/.." || exit 1

TESTME="$(basename "$0")"
set -e

# let's fake failing test for now 
echo "Running bashbot init"
echo "............................" 
# change to test env
[ "$1" = "" ] && echo "not called from testsuite, exit" && exit
cd "$1" || exit 1


unset IFS; set -f

# run bashbot first time with init
export TERM=""
"${1}/bashbot.sh" init >"${TESTME}.log"  <<EOF
bashbottestscript
nobody
botadmin
EOF
