#!/usr/bin/env bash
# this has to run once atfer git clone
# and every time we create new hooks
#### $$VERSION$$ v0.70-dev2-17-g92ad9e4

# magic to ensure that we're always inside the root of our application,
# no matter from which directory we'll run script
GIT_DIR=$(git rev-parse --git-dir)
cd "$GIT_DIR/.." || exit 1

HOOKDIR="dev/hooks"

echo -n "Installing hooks..."
for hook in pre-commit pre-push
do
   rm -f "${GIT_DIR}/hooks/${hook}"
   if [ -f "${HOOKDIR}/${hook}.sh" ]; then
	echo -n " $hook"
	ln -s "../../${HOOKDIR}/${hook}.sh" "${GIT_DIR}/hooks/${hook}"
   fi
done
echo " Done!"
