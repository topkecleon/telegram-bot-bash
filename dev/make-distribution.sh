#!/usr/bin/env bash
# file: make-distribution.sh
# creates files and arcchives to dirtribute bashbot
#
#### $$VERSION$$ v1.2-dev2-49-gf56b7ae

# magic to ensure that we're always inside the root of our application,
# no matter from which directory we'll run script
GIT_DIR=$(git rev-parse --git-dir 2>/dev/null)
if [ "$GIT_DIR" != "" ] ; then
	[[ "$GIT_DIR" != "/"* ]] && GIT_DIR="${PWD}/${GIT_DIR}"
	cd "$GIT_DIR/.." || exit 1
else
	echo "Sorry, no git repository $(pwd)" && exit 1
fi

VERSION="$(git describe --tags | sed -e 's/-[0-9].*//' -e 's/v//')"

DISTNAME="telegram-bot-bash"
DISTDIR="./DIST/${DISTNAME}" 
DISTFILES="bashbot.rc bashbot.sh commands.sh mycommands.sh mycommands.sh.clean bin doc examples scripts modules addons LICENSE README.md README.txt README.html"

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
if [ ! -r "${JSONSHFILE}" ]; then
	mkdir "JSON.sh" 2>/dev/null
	curl -sL -o "${JSONSHFILE}" "https://cdn.jsdelivr.net/gh/dominictarr/JSON.sh/JSON.sh"
	chmod +x "${JSONSHFILE}" 
fi
echo "Inject JSON.awk"
JSONSHFILE="JSON.sh/JSON.awk"
if [ ! -r "${JSONSHFILE}" ]; then
	curl -sL -o "${JSONSHFILE}" "https://cdn.jsdelivr.net/gh/step-/JSON.awk/JSON.awk" 
	curl -sL -o "${JSONSHFILE%/*}/awk-patch.sh" "https://cdn.jsdelivr.net/gh/step-/JSON.awk/tool/patch-for-busybox-awk.sh"
	bash "${JSONSHFILE%/*}/awk-patch.sh" "${JSONSHFILE%/*}/JSON.awk"
fi
rm -f "${JSONSHFILE%/*}"/*.bak

# make html doc
echo "Create html doc"
# shellcheck disable=SC1090,SC1091
source "../../dev/make-html.sh"

# create archive
cd .. || exit 1
echo "Create dist archives"
# shellcheck disable=SC2046
zip -rq - "${DISTNAME}" --exclude $(cat  "$GIT_DIR/../dev/${0##*/}.exclude") >"${DISTNAME}-${VERSION}.zip"
tar --exclude-ignore="$GIT_DIR/../dev/${0##*/}.exclude" -czf "${DISTNAME}-${VERSION}.tar.gz" "${DISTNAME}"

echo "Done!"

# shellcheck disable=SC2086
ls -ld ${DISTNAME}-${VERSION}.*


