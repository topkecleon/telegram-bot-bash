#!/usr/bin/env bash
#### $$VERSION$$ v1.0-0-g99217c4

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

echo "Running pre-commit hook"
echo "............................" 

unset IFS; set -f

# check for shellcheck
if command -v  shellcheck >/dev/null 2>&1; then
	echo "Test all scripts with shellcheck"
else
	echo "Error: shellcheck is not installed. Please install shellcheck"
	exit 1
fi

# run shellcheck before commit
set +f
FILES="$(find ./* -name '*.sh' | grep -v 'DIST\/' | grep -v 'STANDALONE\/')"
set -f
FILES="${FILES} $(sed '/^#/d' <"dev/shellcheck.files")"
if [ "$FILES" != "" ]; then
	# shellcheck disable=SC2086
	shellcheck -x ${FILES} || exit 1
	echo "    OK"
	echo "............................" 
else
	# something went wrong
	exit 1
fi

REMOTEVER="$(git ls-remote -t --refs 2>/dev/null | tail -1 | sed -e 's/.*\/v//' -e 's/-.*//')"
VERSION="$(git describe --tags | sed -e 's/-.*//' -e 's/v//' -e 's/,/./')"


# LOCAL version must greater than latest REMOTE release version
echo "Update Version of modified files" 
if (( $(echo "${VERSION} >= ${REMOTEVER}" | bc -l) )); then
	# update version in bashbot files on push
	set +f
	[ -f "${LASTPUSH}" ] && LASTFILES="$(find ./* -newer "${LASTPUSH}")"
	[ "${LASTFILES}" = "" ] && exit
	echo -n " "
	# shellcheck disable=SC2086
	dev/version.sh ${LASTFILES} 2>/dev/null || exit 1
	echo "    OK"
	echo "............................" 
else
	echo "Error: local version ${VERSION} must be equal to or greater then release version ${REMOTEVER}."
        echo "use \"git tag vx.zz\" to create a new local version"
	exit 1
fi

if which codespell &>/dev/null; then
	echo "Running codespell"
	echo "............................" 
	codespell -B 1 --skip="*.log,*.html,*.txt,.git*,jsonDB-keyboard" -L "ba"
	echo "if there are (to many) typo's shown, consider running:"
	echo "codespell -i 3 -w --skip=\"*.log,*.html,*.txt,.git*,examples\" -L \"ba\""
else
	echo "consider installing codespell: pip install codespell"
fi
echo "............................" 

