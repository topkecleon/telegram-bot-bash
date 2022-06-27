#!/usr/bin/env bash
# file: git-add.sh
#
# works together with git pre-push.sh and ADD all changed files since last push

#### $$VERSION$$ v1.52-1-g0dae2db

#shellcheck disable=SC1090
source "${0%/*}/dev.inc.sh"

# check for last commit date
if [ ! -f "${LASTCOMMIT}" ]; then
	if ! touch -d "$(git log -1 --format=%cD)" "${LASTCOMMIT}"; then
		printf "No previous commit found, use \"git add\" instead ... Abort\n"
		exit
	fi
fi

set +f
FILES="$(find ./*  -newer "${LASTCOMMIT}" | grep -v -e 'DIST\/' -e 'STANDALONE\/' -e 'JSON.sh')"
set -f
# FILES="$(find ./* -newer .git/.lastpush)"
[ "${FILES}" = "" ] && printf "Nothing changed since last commit ...\n" && exit

# run pre_commit on files
dev/hooks/pre-commit.sh

printf "Add files to repo: "
# shellcheck disable=SC2086
for file in ${FILES}
do
	[ -d "${file}" ] && continue
	printf "%s" "${file} "
done
printf " - Done.\n"

# stay with "." for (re)moved files!
git add .

