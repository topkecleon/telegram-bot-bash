#!/usr/bin/env bash
# this has to run once atfer git clone
# and every time we create new hooks
#### $$VERSION$$ v1.30-dev-20-g541a279

#shellcheck disable=SC1090
source "${0%/*}/dev.inc.sh"

HOOKDIR="dev/hooks"

printf "Installing hooks..."
for hook in pre-commit post-commit pre-push
do
   rm -f "${GIT_DIR}/hooks/${hook}"
   if [ -f "${HOOKDIR}/${hook}.sh" ]; then
	printf "%s"" ${hook}"
	ln -s "../../${HOOKDIR}/${hook}.sh" "${GIT_DIR}/hooks/${hook}"
   fi
done
printf " Done!\n"
