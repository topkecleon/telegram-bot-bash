#!/usr/bin/env bash
# file: git-add.sh
#
# works together with git pre-push.sh and add all changed files sind last push

#### $$VERSION$$ v0.70-dev3-1-g55dab95

# magic to ensure that we're always inside the root of our application,
# no matter from which directory we'll run script
GIT_DIR=$(git rev-parse --git-dir)
cd "$GIT_DIR/.." || exit 1

FILES="$(find ./* -newer .git/.lastpush)"
[ "${FILES}" = "" ] && echo "Noting changed since last push!" && exit

# shellcheck disable=SC2086
echo Add ${FILES} to repo ...

# shellcheck disable=SC2086
git add ${FILES}
