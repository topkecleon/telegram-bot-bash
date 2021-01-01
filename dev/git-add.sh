#!/usr/bin/env bash
# file: git-add.sh
#
# works together with git pre-push.sh and ADD all changed files since last push

#### $$VERSION$$ v1.21-pre-3-gbbbf57c

# magic to ensure that we're always inside the root of our application,
# no matter from which directory we'll run script
GIT_DIR=$(git rev-parse --git-dir 2>/dev/null)
if [ "$GIT_DIR" != "" ] ; then
	cd "$GIT_DIR/.." || exit 1
else
	printf "Sorry, no git repository %s\n" "$(pwd)" && exit 1
fi

[ ! -f .git/.lastcommit ] && printf "No previous commit or hooks not installed, use \"git add\" instead ... Abort\n" && exit

set +f
FILES="$(find ./*  -newer .git/.lastpush| grep -v -e 'DIST\/' -e 'STANDALONE\/' -e 'JSON.sh')"
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
	git add "$file"
done
printf " - Done.\n"

