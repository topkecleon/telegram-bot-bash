#!/usr/bin/env bash
# this has to run once atfer git clone
# and every time we create new hooks
#### $$VERSION$$ v0.96-dev-7-g0153928

# magic to ensure that we're always inside the root of our application,
# no matter from which directory we'll run script
GIT_DIR=$(git rev-parse --git-dir 2>/dev/null)
if [ "$GIT_DIR" != "" ] ; then
	cd "$GIT_DIR/.." || exit 1
else
	echo "Sorry, no git repository $(pwd)" && exit 1
fi

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
