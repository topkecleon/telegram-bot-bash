#!/usr/bin/env bash
##############################################################
#
# File: make-distribution.sh
#
# Description: creates files and arcchives to distribute bashbot
#
# Options: --notest - skip tests
#
#### $$VERSION$$ v1.52-1-g0dae2db
##############################################################

#shellcheck disable=SC1090
source "${0%/*}/dev.inc.sh"

VERSION="$(git describe --tags | sed -e 's/-[0-9].*//' -e 's/v//')"

DISTNAME="telegram-bot-bash"
DISTDIR="./DIST/${DISTNAME}" 
DISTMKDIR="data-bot-bash logs bin bin/logs addons"

DISTFILES="bashbot.sh commands.sh mycommands.sh.clean bin doc examples scripts modules LICENSE README.md README.txt README.html"
DISTFILESDEV="dev/make-standalone.sh dev/inject-json.sh dev/make-html.sh dev/obfuscate.sh"
DISTFILESDIST="mycommands.sh mycommands.conf bashbot.rc $(echo "addons/"*.sh)"

# run tests first!
for test in $1 dev/all-test*.sh
do
   [[ "${test}" == "--notest"* ]] && break
   [ ! -x "${test}" ] && continue
   if ! "${test}" ; then
	printf "ERROR: Test %s failed, can't create dist!\n" "${test}"
	exit 1
  fi
done

# create dir for distribution and copy files
mkdir -p "${DISTDIR}" 2>/dev/null

printf "Copy files\n"
# shellcheck disable=SC2086
cp -r ${DISTFILES} "${DISTDIR}"
mkdir -p "${DISTDIR}/dev"
# shellcheck disable=SC2086
cp ${DISTFILESDEV} "${DISTDIR}/dev"
cd "${DISTDIR}" || exit 1

printf "Create directories\n"
# shellcheck disable=SC2250
for dir in $DISTMKDIR
do
	[ ! -d "${dir}" ] && mkdir "${dir}"
done

# do not overwrite on update
printf "Create .dist files\n"
for file in ${DISTFILESDIST}
do
	[ "${file}" = "addons/*.sh" ] && continue
	cp "${BASE_DIR}/${file}" "${file}.dist"
done

# inject JSON.sh into distribution
# shellcheck disable=SC1090
source "${BASE_DIR}/dev/inject-json.sh"

# make html doc
printf "Create html doc\n"
# shellcheck disable=SC1090,SC1091
source "../../dev/make-html.sh"

# create archive
cd .. || exit 1
printf "Create dist archives\n"
# shellcheck disable=SC2046
zip -rq - "${DISTNAME}" --exclude $(cat  "${BASE_DIR}/dev/${0##*/}.exclude") >"${DISTNAME}-${VERSION}.zip"
tar --exclude-ignore="${BASE_DIR}/dev/${0##*/}.exclude" -czf "${DISTNAME}-${VERSION}.tar.gz" "${DISTNAME}"

printf "%s Done!\n" "$0"

# shellcheck disable=SC2086
ls -ld "${DISTNAME}-${VERSION}".*

# an empty DEBUG.log is created ... :-(
rm -f "${BASE_DIR}/test/"*.log
