#!/usr/bin/env bash
# file: git-add.sh
#
# works together with git pre-push.sh and ADD all changed files since last push

#### $$VERSION$$ v1.2-dev2-64-gf4d64f7

# magic to ensure that we're always inside the root of our application,
# no matter from which directory we'll run script
GIT_DIR=$(git rev-parse --git-dir 2>/dev/null)
if [ "$GIT_DIR" != "" ] ; then
	cd "$GIT_DIR/.." || exit 1
else
	echo "Sorry, no git repository $(pwd)" && exit 1
fi

[ ! -f .git/.lastcommit ] && echo "No previous commit or hooks not installed, use \"git add\" instead ... Abort" && exit

set +f
FILES="$(find ./*  -newer .git/.lastpush| grep -v -e 'DIST\/' -e 'STANDALONE\/' -e 'JSON.sh')"
set -f
# FILES="$(find ./* -newer .git/.lastpush)"
[ "${FILES}" = "" ] && echo "Noting changed since last commit ..." && exit

# run pre_commit on files
dev/hooks/pre-commit.sh

echo -e "Add files to repo: \c"
# shellcheck disable=SC2086
for file in ${FILES}
do
	[ -d "${file}" ] && continue
	echo -e "${file} \c"
	git add "$file"
done
echo " - Done."

