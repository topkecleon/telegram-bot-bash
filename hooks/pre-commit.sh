#!/usr/bin/env bash
#### $$VERSION$$ 0.70-dev-0-g209c4b3

# magic to ensure that we're always inside the root of our application,
# no matter from which directory we'll run script
GIT_DIR=$(git rev-parse --git-dir)
cd "$GIT_DIR/.." || exit 1

echo "Running pre-commit hook"

# if any command inside script returns error, exit and return that error 
set -e

# let's fake failing test for now 
echo "Running tests"
echo "............................" 

unset IFS; set -f

# run shellcheck before commit
FILES=$(sed '/^#/d' <"hooks/shellcheck.files")
if [ "$FILES" != "" ]; then
	# shellcheck disable=SC2086
	shellcheck -x ${FILES}
else
	# something went wrong
	exit 1
fi
