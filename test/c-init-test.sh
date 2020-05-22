#!/usr/bin/env bash
#### $$VERSION$$ v0.96-dev-7-g0153928

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
	diff -q "${TESTDIR}/${file}" "${REFDIR}/${file}" >>"${LOGFILE}" || { echo "${NOSUCCESS} Fail diff ${file}!"; FAIL="1"; }
done
[ "${FAIL}" != "0" ] && exit "${FAIL}"
echo "${SUCCESS}"

trap exit 1 EXIT
cd "${TESTDIR}" || exit

echo "Test if $JSONSHFILE exists ..."
[ ! -x "$JSONSHFILE" ] && { echo "${NOSUCCESS} Fail diff ${file}!"; exit 1; }

echo "Test Sourcing of bashbot.sh ..."
# shellcheck source=./bashbot.sh
source "${TESTDIR}/bashbot.sh" source
echo "Test Sourcing of commands.sh ..."
source "${TESTDIR}/commands.sh" source 

trap '' EXIT
cd "${DIRME}" || exit 1
echo "${SUCCESS}"

echo "Test bashbot.sh count"
cp "${REFDIR}/count.test" "${TESTDIR}/count"
#"${TESTDIR}/bashbot.sh" count
