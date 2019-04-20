#!/usr/bin/env bash
#### $$VERSION$$ 0.70-dev-18-g7512681

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
echo "Check check new files ..."
for file in ${TESTFILES}
do
	ls -d "${TESTDIR}/${file}" >>"${LOGFILE}"
	diff -q "${TESTDIR}/${file}" "${REFDIR}/${file}" >>"${LOGFILE}"
	
done
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
