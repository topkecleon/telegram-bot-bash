#!/usr/bin/env bash
#### $$VERSION$$ 0.70-dev-20-g753f1b3

# common variables
export TESTME DIRME TESTDIR LOGFILE REFDIR TESTNAME
 TESTME="$(basename "$0")"
 DIRME="$(pwd)"
 TESTDIR="$1"
 LOGFILE="${TESTDIR}/${TESTME}.log"
 REFDIR="${TESTME%.sh}"
 TESTNAME="${REFDIR//-/ }"

# common filenames
export TOKENFILE ACLFILE COUNTFILE ADMINFILE
 TOKENFILE="token"
 ACLFILE="botacl"
 COUNTFILE="count"
 ADMINFILE="botadmin"

# SUCCESS NOSUCCES
export SUCCESS NOSUCCESS
SUCCESS="   OK"
NOSUCCESS="   FAILED!"

echo "Running ${TESTNAME#? } ..."
echo "............................" 
[ "${TESTDIR}" = "" ] && echo "${NOSUCCESS} not called from testsuite, exit" && exit 1

# reset env for test
unset IFS; set -f
export TERM=""

