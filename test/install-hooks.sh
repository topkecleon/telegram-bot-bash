#!/usr/bin/env bash
# this has to run once atfer git clone
# and every time we create new hooks

# magic line to ensure that we're always inside the root of our application,
# no matter from which directory we'll run script
cd "${0%/*}/.." || exit 1

GIT_DIR=$(git rev-parse --git-dir)

echo -n "Installing hooks..."
for hook in pre-commit pre-push
do
   rm -f "$GIT_DIR/hooks/${hook}"
   if [ -f "test/${hook}.sh" ]; then
	echo -n " $hook"
	ln -s "../../test/${hook}.sh" "$GIT_DIR/hooks/${hook}"
   fi
done
echo " Done!"
