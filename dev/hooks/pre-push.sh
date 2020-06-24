#!/usr/bin/env bash
#### $$VERSION$$ v0.98-pre-0-g03700cd

############
# NOTE: you MUST run install-hooks.sh again when updating this file!

# magic to ensure that we're always inside the root of our application,
# no matter from which directory we'll run script
GIT_DIR=$(git rev-parse --git-dir)
cd "$GIT_DIR/.." || exit 1

export HOOKDIR="dev/hooks"
LASTPUSH='.git/.lastpush'

# if any command inside script returns error, exit and return that error 
set -e

echo "Running pre-push hook"
echo "............................" 

unset IFS; set -f

if which codespell &>/dev/null; then
	echo "Running codespell"
	echo "............................" 
	codespell -B 1 --skip="*.log,*.html,*.txt,.git*" -L "ba"
	echo "if there are (to many) typo's shown, consider running:"
	echo "codespell -i 3 -w --skip=\"*.log,*.html,*.txt,.git*\" -L \"ba\""
else
	echo "consider installing codespell: pip install codespell"
fi
echo "............................" 
# note date of last push for version
touch "${LASTPUSH}"
