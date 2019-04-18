#!/usr/bin/env bash

echo "Running pre-commit hook"

# if any command inside script returns error, exit and return that error 
set -e

# magic line to ensure that we're always inside the root of our application,
# no matter from which directory we'll run script
cd "${0%/*}/.."

# let's fake failing test for now 
echo "Running tests"
echo "............................" 

unset IFS; set -f

# run shellcheck before commit
FILES=$(sed '/^#/d' <"test/shellcheck.files")
if [ "$FILES" != "" ]; then
	# shellcheck disable=SC2086
	shellcheck -x ${FILES}
else
	# something went wrong
	exit 1
fi
