#!/usr/bin/env bash
#### $$VERSION$$ v0.70-dev2-17-g92ad9e4

# magic to ensure that we're always inside the root of our application,
# no matter from which directory we'll run script
GIT_DIR=$(git rev-parse --git-dir)
cd "$GIT_DIR/.." || exit 1

export HOOKDIR="dev/hooks"

REMOTEVER="$(git ls-remote -t --refs 2>/dev/null | tail -1 | sed 's/.*\/v//')"
VERSION="$(git describe --tags | sed -e 's/-.*//' -e 's/v//')"


# if any command inside script returns error, exit and return that error 
set -e

echo "Running pre-push hook"
echo "............................" 

unset IFS; set -f

# LOCAL version must greater than latest REMOTE release version
if (( $(echo "${VERSION} > ${REMOTEVER}" | bc -l) )); then
	# update version in bashbot files on push
	echo -n " "
	dev/version.sh 2>/dev/null || exit 1
	echo "    OK"
else
	echo "Error: local version ${VERSION} must be greater than latest release version."
        echo "use \"git tag ...\" to create a local version greater than ${REMOTEVER}"
	exit 1
fi

