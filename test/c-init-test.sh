#!/usr/bin/env bash
#===============================================================================
#
#          FILE: c-init-test.sh
# 
#         USAGE: must run only from dev/all-tests.sh
#
#   DESCRIPTION: test "bashbot.sh init" and sourcing bashbot.sh
# 
#	LICENSE: WTFPLv2 http://www.wtfpl.net/txt/copying/
#        AUTHOR: KayM (gnadelwartz), kay@rrr.de
#
#### $$VERSION$$ v1.52-1-g0dae2db
#===============================================================================

# include common functions and definitions
# shellcheck source=test/ALL-tests.inc.sh
source "./ALL-tests.inc.sh"

TESTFILES="${TOKENFILE} ${ACLFILE} ${COUNTFILE} ${BLOCKEDFILE} ${ADMINFILE}"

#set -e

# run bashbot first time with init
printf "Run bashbot init ...\n"
"${TESTDIR}/bashbot.sh" init >"${LOGFILE}"  <<EOF
${TESTTOKEN}
nobody
botadmin

EOF
printf "%s\n" "${SUCCESS}"

# compare files with reference files
printf "Check new files after init ...\n"
export FAIL="0"
for file in ${TESTFILES}
do
	ls -d "${TESTDIR}/${file}" >>"${LOGFILE}"
	diff -q "${TESTDIR}/${file}" "${REFDIR}/${file}" >>"${LOGFILE}" || { printf "%s\n" "${NOSUCCESS} Fail diff ${file}!"; FAIL="1"; }
done
[ "${FAIL}" != "0" ] && exit "${FAIL}"
printf "%s\n" "${SUCCESS}"

trap exit 1 EXIT
cd "${TESTDIR}" || exit

printf "%s\n" "Test if ${JSONSHFILE} exists ..."
[ ! -x "${JSONSHFILE}" ] && { printf "%s\n" "${NOSUCCESS} json.sh not found"; exit 1; }

printf "Test Sourcing of bashbot.sh ...\n"
# shellcheck source=./bashbot.sh
source "${TESTDIR}/bashbot.sh" source

printf "Test Sourcing of commands.sh ...\n"
source "${TESTDIR}/commands.sh" source 

trap '' EXIT
cd "${DIRME}" || exit 1

printf "%s\n" "${SUCCESS}"

