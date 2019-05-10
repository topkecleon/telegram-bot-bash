#!/usr/bin/env bash
# this has to run once atfer git clone
# and every time we create new hooks
#### $$VERSION$$ v0.80-dev2-1-g0b36bc5

# magic to ensure that we're always inside the root of our application,
# no matter from which directory we'll run script
GIT_DIR=$(git rev-parse --git-dir)
cd "$GIT_DIR/.." || exit 1

VERSION="$(git describe --tags | sed -e 's/-[0-9].*//' -e 's/v//')"

DISTNAME="telegram-bot-bash"
DISTDIR="./dist/${DISTNAME}" 
DISTFILES="bashbot.rc  bashbot.sh  commands.sh  mycommands.sh doc  examples modules LICENSE  README.md  README.txt README.html"

# run tests first!

for test in "dev/all-tests.sh"
do
   if ! "${test}" ; then
	echo "Test ${test} failed, can't create dist!"
	exit 1
  fi
done

# create dir for distribution and copy files
mkdir -p "${DISTDIR}" 2>/dev/null
# shellcheck disable=SC2086
cp -r ${DISTFILES} "${DISTDIR}"
cd "${DISTDIR}" || exit 1

# additional stuff
mv "bashbot.rc" "bashbot.rc.dist"
mv "commands.sh" "commands.sh.dist"
mv "mycommands.sh" "mycommands.sh.dist"

JSONSHFILE="JSON.sh/JSON.sh"
if [ ! -f "${JSONSHFILE}" ]; then
	mkdir "JSON.sh" 2>/dev/null
	curl -sL -o "${JSONSHFILE}" "https://cdn.jsdelivr.net/gh/dominictarr/JSON.sh/JSON.sh"
	chmod +x "${JSONSHFILE}" 
fi

# make html doc
mkdir html  2>/dev/null
cp README.html html/index.html
find doc -iname "*.md" -type f -exec sh -c 'pandoc -s -S -M "title=Bashobot Documentation - ${0%.md}.html"  "${0}" -o "./html/$(basename ${0%.md}.html)"' {} \;
find examples -iname "*.md" -type f -exec sh -c 'pandoc -s -S -M "title=Bashobot Documentation - ${0%.md}.html"  "${0}" -o "${0%.md}.html"' {} \;
find README.html html examples -iname "*.html" -type f -exec sh -c 'sed -i -E "s/href=\"(\.\.\/)*doc\//href=\"\1html\//g;s/href=\"(.*).md(#.*)*\"/href=\"\1.html\"/g" ${0}' {} \;

# create archive
cd .. || exit 1
zip -rq "${DISTNAME}-${VERSION}.zip" "${DISTNAME}"
tar -czf "${DISTNAME}-${VERSION}.tar.gz" "${DISTNAME}"


# shellcheck disable=SC2086
ls -ld ${DISTNAME}-${VERSION}.*


