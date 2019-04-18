#!/usr/bin/env bash
# this has to run once atfer git clone
# and every time we create new hooks
#### $$VERSION$$ 0.70-dev-0-g209c4b3

# magic to ensure that we're always inside the root of our application,
# no matter from which directory we'll run script
GIT_DIR=$(git rev-parse --git-dir)
cd "$GIT_DIR/.." || exit 1

echo -n "Installing hooks..."
for hook in pre-commit pre-push
do
   rm -f "$GIT_DIR/hooks/${hook}"
   if [ -f "hooks/${hook}.sh" ]; then
	echo -n " $hook"
	ln -s "../../hooks/${hook}.sh" "$GIT_DIR/hooks/${hook}"
   fi
done
echo " Done!"
