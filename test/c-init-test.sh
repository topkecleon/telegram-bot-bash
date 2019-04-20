#!/usr/bin/env bash
#### $$VERSION$$ 0.70-dev-19-g3183419

TESTME="$(basename "$0")"
DIRME="$(pwd)"
TESTDIR="$1"

LOGFILE="${TESTDIR}/${TESTME}.log"
REFDIR="${TESTME%.sh}"

TOKENFILE="token"
TESTTOKEN="bashbottestscript"
TESTFILES="${TOKENFILE} botacl count botadmin"

set -e

# let's fake failing test for now 
echo "Running bashbot init"
echo "............................" 
# change to test env
[ "${TESTDIR}" = "" ] && echo "not called from testsuite, exit" && exit


unset IFS; set -f

# run bashbot first time with init
export TERM=""
"${TESTDIR}/bashbot.sh" init >"${LOGFILE}"  <<EOF
$TESTTOKEN
nobody
botadmin
EOF
echo "OK"

# compare files with refrence files
echo "Check new files after init ..."
export FAIL="0"
for file in ${TESTFILES}
do
	ls -d "${TESTDIR}/${file}" >>"${LOGFILE}"
	if ! diff -q "${TESTDIR}/${file}" "${REFDIR}/${file}" >>"${LOGFILE}"; then echo "  ERROR: Fail diff ${file}!"; FAIL="1"; fi
	
done
[ "${FAIL}" != "0" ] && exit "${FAIL}"
echo "OK"

echo "Test Sourcing of bashbot.sh ..."
trap exit 1 EXIT
cd "${TESTDIR}" || exit

# shellcheck source=./bashbot.sh
source "${TESTDIR}/bashbot.sh" source
trap '' EXIT
cd "${DIRME}" || exit 1

echo "Test bashbot.sh count"
cp "${REFDIR}/count.test" "${TESTDIR}/count"
"${TESTDIR}/bashbot.sh" count

exit 1
