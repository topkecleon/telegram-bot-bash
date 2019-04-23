#!/usr/bin/env bash
# this has to run once atfer git clone
# and every time we create new hooks
#### $$VERSION$$ v0.70-dev2-15-g03f22c9

# magic to ensure that we're always inside the root of our application,
# no matter from which directory we'll run script
GIT_DIR=$(git rev-parse --git-dir)
cd "$GIT_DIR/.." || exit 1

VERSION="$(git describe --tags | sed -e 's/-.*//' -e 's/v//')"

DISTNAME="telegram-bot-bash"
DISTDIR="./dist/${DISTNAME}" 
DISTFILES="bashbot.rc  bashbot.sh  commands.sh  mycommands.sh doc  examples modules LICENSE  README.md  README.txt"

# run tests first!

for test in dev/hooks/* "test/ALL-tests.sh"
do
   if ! "${test}" ; then
	echo "Test ${test} failed, can't create dist!"
	exit 1
  fi
done

# create dir for sitribution and copy files
mkdir -p "${DISTDIR}" 2>/dev/null
# shellcheck disable=SC2086
cp -r ${DISTFILES} "${DISTDIR}"
cd "${DISTDIR}" || exit 1

# additional stuff
mv "commands.sh" "commands.sh.dist"
mv "mycommands.sh" "mycommands.sh.dist"

JSONSHFILE="JSON.sh/JSON.sh"
if [ ! -f "${JSONSHFILE}" ]; then
	mkdir "JSON.sh" 2>/dev/null;
	curl -sL -o "${JSONSHFILE}" "https://cdn.jsdelivr.net/gh/dominictarr/JSON.sh/JSON.sh"
	chmod +x "${JSONSHFILE}" 
fi

# create archive
cd .. || exit 1
zip -rq "${DISTNAME}-${VERSION}.zip" "${DISTNAME}"
tar -czf "${DISTNAME}-${VERSION}.tar.gz" "${DISTNAME}"


# shellcheck disable=SC2086
ls -ld ${DISTNAME}-${VERSION}.*


