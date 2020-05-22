#!/usr/bin/env bash
#### $$VERSION$$ v0.96-dev-7-g0153928

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

# cp bashbot files to new localtions
set +f
# shellcheck disable=SC2086
cp ${TESTDIR}/*commands.sh "${BASHBOT_ETC}" || exit 1
set -f
cp -r "${TESTDIR}/bashbot.sh" "${TESTDIR}/modules" "${BASHBOT_BIN}" || exit 1

TESTTOKEN="bashbottestscript"
TESTFILES="${TOKENFILE} ${ACLFILE} ${ADMINFILE}"


echo "Check first run in ENVIRONMENT ..."

# run bashbot first time with init
"${BASHBOT_BIN}/bashbot.sh" init >"${LOGFILE}"  <<EOF
$TESTTOKEN
nobody
botadmin
EOF
echo "${SUCCESS}"

echo "Check if files are placed in ENVIRONMENT  ..."
if [ ! -f "${BASHBOT_JSONSH}" ]; then
	echo "${NOSUCCESS} ${BASHBOT_JSONSH} missing!"
	exit 1
fi
if [ ! -d "${BASHBOT_VAR}/${DATADIR}" ]; then
	echo "${NOSUCCESS} ${DATADIR} missing!"
	exit 1
fi
if [ ! -f "${BASHBOT_VAR}/${COUNTFILE}" ]; then
	echo "${NOSUCCESS} ${BASHBOT_VAR}/${COUNTFILE} missing!"
	exit 1
fi

echo "  ... BASHBOT_VAR seems to work!"
echo "${SUCCESS}"


# compare files with refrence files
export FAIL="0"
for file in ${TESTFILES}
do
	ls -d "${BASHBOT_ETC}/${file}" >>"${LOGFILE}"
	if ! diff -q "${BASHBOT_ETC}/${file}" "${REFDIR}/${file}" >>"${LOGFILE}"; then echo "${NOSUCCESS} Fail diff ${file}!"; FAIL="1"; fi
	
done

echo "  ... BASHBOT_ETC seems to work!"
echo "${SUCCESS}"
