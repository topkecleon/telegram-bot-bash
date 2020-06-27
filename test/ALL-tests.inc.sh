#!/usr/bin/env bash
#### $$VERSION$$ v0.98-pre2-8-ga656533

# common variables
export TESTME DIRME TESTDIR LOGFILE REFDIR TESTNAME
 TESTME="$(basename "$0")"
 DIRME="$(pwd)"
 TESTDIR="$1"
 LOGFILE="${TESTDIR}/${TESTME}.log"
 REFDIR="${TESTME%.sh}"
 TESTNAME="${REFDIR//-/ }"

# common filenames
export TOKENFILE ACLFILE COUNTFILE BLOCKEDFILE ADMINFILE DATADIR JSONSHFILE
 TOKENFILE="botconfig.jssh"
 ACLFILE="botacl"
 COUNTFILE="count.jssh"
 BLOCKEDFILE="blocked.jssh"
 ADMINFILE="botconfig.jssh"
 DATADIR="data-bot-bash"
 JSONSHFILE="JSON.sh/JSON.sh"

# SUCCESS NOSUCCES
export SUCCESS NOSUCCESS
 SUCCESS="   OK"
 NOSUCCESS="   FAILED!"

# default input, reference and output files
export  INPUTFILE REFFILE OUTPUTFILE
 INPUTFILE="${DIRME}/${REFDIR}/${REFDIR}.input"
 REFFILE="${DIRME}/${REFDIR}/${REFDIR}.result"
 OUTPUTFILE="${TESTDIR}/${REFDIR}.out"

# do not query telegram when testing
export BASHBOT_URL TESTTOKEN
BASHBOT_URL="https://my-json-server.typicode.com/topkecleon/telegram-bot-bash/getMe?"
TESTTOKEN="123456789:BASHBOTTESTSCRIPTbashbottestscript_"

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


compare_sorted() {
	local ret=0
	sort -d -o "${1}.sort" "${1}"
	sort -d -o "${2}.sort" "${2}"
	diff -c "${1}.sort" "${2}.sort" || ret=1
	rm -f "${1}.sort" "${2}.sort"
	return "$ret"
}

######
# lets go ...
echo "Running ${TESTNAME#? } ..."
echo "............................" 
[ "${TESTDIR}" = "" ] && echo "${NOSUCCESS} not called from testsuite, exit" && exit 1

# reset env for test
unset IFS;
export TERM=""

