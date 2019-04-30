#!/usr/bin/env bash
#### $$VERSION$$ v0.7-rc1-0-g8279bdb

# include common functions and definitions
# shellcheck source=test/ALL-tests.inc.sh
source "./ALL-tests.inc.sh"

TESTTOKEN="bashbottestscript"
TESTFILES="${TOKENFILE} ${ACLFILE} ${COUNTFILE} ${ADMINFILE}"

set -e

# run bashbot first time with init
"${TESTDIR}/bashbot.sh" init >"${LOGFILE}"  <<EOF
$TESTTOKEN
nobody
botadmin
EOF
echo "${SUCCESS}"

# compare files with refrence files
echo "Check new files after init ..."
export FAIL="0"
for file in ${TESTFILES}
do
	ls -d "${TESTDIR}/${file}" >>"${LOGFILE}"
	if ! diff -q "${TESTDIR}/${file}" "${REFDIR}/${file}" >>"${LOGFILE}"; then echo "${NOSUCCESS} Fail diff ${file}!"; FAIL="1"; fi
	
done
[ "${FAIL}" != "0" ] && exit "${FAIL}"
echo "${SUCCESS}"

echo "Test Sourcing of bashbot.sh ..."
trap exit 1 EXIT
cd "${TESTDIR}" || exit

# shellcheck source=./bashbot.sh
source "${TESTDIR}/bashbot.sh" source
trap '' EXIT
cd "${DIRME}" || exit 1
echo "${SUCCESS}"

echo "Test bashbot.sh count"
cp "${REFDIR}/count.test" "${TESTDIR}/count"
"${TESTDIR}/bashbot.sh" count

