#!/usr/bin/env bash
#### $$VERSION$$ v0.80-dev2-1-g0b36bc5

# common variables
export TESTME DIRME TESTDIR LOGFILE REFDIR TESTNAME
 TESTME="$(basename "$0")"
 DIRME="$(pwd)"
 TESTDIR="$1"
 LOGFILE="${TESTDIR}/${TESTME}.log"
 REFDIR="${TESTME%.sh}"
 TESTNAME="${REFDIR//-/ }"

# common filenames
export TOKENFILE ACLFILE COUNTFILE ADMINFILE DATADIR
 TOKENFILE="token"
 ACLFILE="botacl"
 COUNTFILE="count"
 ADMINFILE="botadmin"
 DATADIR="data-bot-bash"

# SUCCESS NOSUCCES
export SUCCESS NOSUCCESS
 SUCCESS="   OK"
 NOSUCCESS="   FAILED!"

# default input, reference and output files
export  INPUTFILE REFFILE OUTPUTFILE
 INPUTFILE="${DIRME}/${REFDIR}/${REFDIR}.input"
 REFFILE="${DIRME}/${REFDIR}/${REFDIR}.result"
 OUTPUTFILE="${TESTDIR}/${REFDIR}.out"

# print arrays in reproducible order
print_array() {
  local idx t
  local arrays=( "${@}" )
  for idx in "${arrays[@]}"; do
    declare -n temp="$idx"
	for t in "${!temp[@]}"; do 
  		printf '%s:\t%s\t%s\n' "$idx" "$t" "${temp[$t]}"
	done | sort
  done | grep -v '^USER:	0'
}


######
# lets go ...
echo "Running ${TESTNAME#? } ..."
echo "............................" 
[ "${TESTDIR}" = "" ] && echo "${NOSUCCESS} not called from testsuite, exit" && exit 1

# reset env for test
unset IFS; set -f
export TERM=""

