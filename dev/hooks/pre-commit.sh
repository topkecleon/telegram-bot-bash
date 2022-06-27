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

printf "Running pre-commit hook\n............................\n" 

unset IFS; set -f

# check for shellcheck
if command -v  shellcheck >/dev/null 2>&1; then
	printf "Test all scripts with shellcheck\n"
else
	printf "Error: shellcheck is not installed. Please install shellcheck\n"
	exit 1
fi

# run shellcheck before commit
set +f
FILES="$(find ./* -name '*.sh' | grep -v -e 'DIST\/' -e 'STANDALONE\/' -e 'JSON.sh')"
set -f
FILES="${FILES} $(sed '/^#/d' <"dev/shellcheck.files")"
if [ "${FILES}" != "" ]; then
	# shellcheck disable=SC2086
	shellcheck -o all -e SC2249,SC2154 -x ${FILES} || exit 1
	printf "    OK\n............................\n"
else
	# something went wrong
	exit 1
fi

# get version strings
REMOTEVER="$(git ls-remote -t --refs 2>/dev/null | tail -1 | sed -e 's/.*\/v//' -e 's/-.*//')"
VERSION="$(git describe --tags | sed -e 's/-.*//' -e 's/v//' -e 's/,/./')"
[ -z "${REMOTEVER}" ] && REMOTEVER="${VERSION}"

# LOCAL version must greater than latest REMOTE release version
printf "Update Version of modified files\n"
if ! command -v bc &> /dev/null || (( $(printf "%s\n" "${VERSION} >= ${REMOTEVER}" | bc -l) )); then
	# update version in bashbot files on push
	set +f
	[ -f "${LASTPUSH}" ] && LASTFILES="$(find ./* -newer "${LASTPUSH}" ! -path "./DIST/*" ! -path "./STANDALONE/*")"
	[ "${LASTFILES}" = "" ] && exit
	printf " "
	# shellcheck disable=SC2086
	dev/version.sh ${LASTFILES} 2>/dev/null || exit 1
	printf "    OK\n............................\n"
else
	printf "Error: local version %s must be equal to or greater then release version%s\n" "${VERSION}" "${REMOTEVER}."
        printf "use \"git tag vx.zz\" to create a new local version\n"
	exit 1
fi

if command -v codespell &>/dev/null; then
	printf "Running codespell\n............................\n"
	codespell -q 3 --skip="*.zip,*gz,*.log,*.html,*.txt,.git*,jsonDB-keyboard,DIST,STANDALONE" -L "ba"
	printf "if there are (to many) typo's shown, consider running:\ncodespell -i 3 -w --skip=\"*.log,*.html,*.txt,.git*,examples\" -L \"ba\"\n"
else
	printf "consider installing codespell: pip install codespell\n"
fi
printf "............................\n" 

