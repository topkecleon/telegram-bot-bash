#!/usr/bin/env bash
#===============================================================================
#
#          FILE: e-env-test.sh
# 
#         USAGE: must run only from dev/all-tests.sh
#
#   DESCRIPTION: test  BASHBOT_xxx variables working as expected
# 
#	LICENSE: WTFPLv2 http://www.wtfpl.net/txt/copying/
#        AUTHOR: KayM (gnadelwartz), kay@rrr.de
#
#### $$VERSION$$ v1.52-1-g0dae2db
#===============================================================================

# include common functions and definitions
# shellcheck source=test/ALL-tests.inc.sh
source "./ALL-tests.inc.sh"

set -e

#cd "${TESTDIR}" || exit 1

# source bashbot.sh function, uncomment if you want to test functions
# shellcheck source=./bashbot.sh
# source "\/bashbot.sh" source

# start writing your tests here ...
# test setting of env variables to different locations

export BASHBOT_ETC="${TESTDIR}/env/etc/bashbot"
export BASHBOT_VAR="${TESTDIR}/env/var/bashbot"
export BASHBOT_JSONSH="${TESTDIR}/env/local/bin/JSON.sh"
BASHBOT_BIN="${TESTDIR}/env/local/bin"

# create dirs
mkdir -p "${BASHBOT_ETC}" || exit 1
mkdir -p "${BASHBOT_VAR}" || exit 1
mkdir -p "${BASHBOT_BIN}" || exit 1

# cp bashbot files to new locations
set +f
# shellcheck disable=SC2086
cp ${TESTDIR}/*commands.sh "${BASHBOT_ETC}" || exit 1
set -f
cp -r "${TESTDIR}/bashbot.sh" "${TESTDIR}/modules" "${TESTDIR}/JSON.sh/JSON.sh" "${BASHBOT_BIN}" || exit 1

TESTFILES="${TOKENFILE} ${ACLFILE}"


printf "Check first run in ENVIRONMENT ...\n"
mkdir "${BASHBOT_VAR}/${DATADIR}"

# run bashbot first time with init
"${BASHBOT_BIN}/bashbot.sh" init >"${LOGFILE}"  <<EOF
${TESTTOKEN}
nobody
botadmin
EOF
printf "%s\n" "${SUCCESS}"

printf "Check if files are placed in ENVIRONMENT  ...\n"
if [ ! -f "${BASHBOT_JSONSH}" ]; then
	printf "%s\n" "${NOSUCCESS} ${BASHBOT_JSONSH} missing!"
	exit 1
fi
if [ ! -d "${BASHBOT_VAR}/${DATADIR}" ]; then
	printf "%s\n" "${NOSUCCESS} ${DATADIR} missing!"
	exit 1
fi
if [ ! -f "${BASHBOT_VAR}/${COUNTFILE}" ]; then
	printf "%s\n" "${NOSUCCESS} ${BASHBOT_VAR}/${COUNTFILE} missing!"
	exit 1
fi

printf "  ... BASHBOT_VAR seems to work!\n"
printf "%s\n" "${SUCCESS}"


# compare files with reference files
export FAIL="0"
for file in ${TESTFILES}
do
	ls -d "${BASHBOT_ETC}/${file}" >>"${LOGFILE}"
	if ! diff -q "${BASHBOT_ETC}/${file}" "${REFDIR}/${file}" >>"${LOGFILE}"; then printf "%s\n" "${NOSUCCESS} Fail diff ${file}!"; FAIL="1"; fi
	
done

printf "  ... BASHBOT_ETC seems to work!\n"
printf "%s\n" "${SUCCESS}"
