#!/usr/bin/env bash
# file: make-distribution.sh
# creates files and arcchives to dirtribute bashbot
#
#### $$VERSION$$ v0.98-dev-63-g0b8c047

# magic to ensure that we're always inside the root of our application,
# no matter from which directory we'll run script
GIT_DIR=$(git rev-parse --git-dir 2>/dev/null)
if [ "$GIT_DIR" != "" ] ; then
	cd "$GIT_DIR/.." || exit 1
else
	echo "Sorry, no git repository $(pwd)" && exit 1
fi

VERSION="$(git describe --tags | sed -e 's/-[0-9].*//' -e 's/v//')"

DISTNAME="telegram-bot-bash"
DISTDIR="./DIST/${DISTNAME}" 
DISTFILES="bashbot.rc bashbot.sh commands.sh mycommands.sh mycommands.sh.clean doc examples modules addons LICENSE README.md README.txt README.html"

# run tests first!

for test in dev/all-test*.sh
do
   [ ! -x "${test}" ] && continue
   if ! "${test}" ; then
	echo "Test ${test} failed, can't create dist!"
	exit 1
  fi
done

# create dir for distribution and copy files
mkdir -p "${DISTDIR}" 2>/dev/null
# shellcheck disable=SC2086
echo "Copy files"
# shellcheck disable=SC2086
cp -r ${DISTFILES} "${DISTDIR}"
cd "${DISTDIR}" || exit 1

# do not overwrite on update
echo "Create .dist files"
for file in mycommands.sh bashbot.rc addons/*.sh
do
	[ "${file}" = "addons/*.sh" ] && continue
	mv "${file}" "${file}.dist"
done

# dwonload JSON.sh
echo "Inject JSON.sh"
JSONSHFILE="JSON.sh/JSON.sh"
if [ ! -f "${JSONSHFILE}" ]; then
	mkdir "JSON.sh" 2>/dev/null
	curl -sL -o "${JSONSHFILE}" "https://cdn.jsdelivr.net/gh/dominictarr/JSON.sh/JSON.sh"
	chmod +x "${JSONSHFILE}" 
fi

# make html doc
echo "Create html doc"
#shellcheck disable=SC1090
source "$GIT_DIR/../dev/make-html.sh"

# create archive
cd .. || exit 1
echo "Create dist archives"
zip -rq "${DISTNAME}-${VERSION}.zip" "${DISTNAME}"
tar -czf "${DISTNAME}-${VERSION}.tar.gz" "${DISTNAME}"

echo "Done!"

# shellcheck disable=SC2086
ls -ld ${DISTNAME}-${VERSION}.*


