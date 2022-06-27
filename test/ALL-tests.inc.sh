#!/usr/bin/env bash
#===============================================================================
#
#          FILE: ALL-tests.inc.sh
# 
#         USAGE: source ALL-tests.inc.sh
#
#   DESCRIPTION: must be included from all tests,
#                setup bashbot test environment and common test functions
# 
#	LICENSE: WTFPLv2 http://www.wtfpl.net/txt/copying/
#        AUTHOR: KayM (gnadelwartz), kay@rrr.de
#
#### $$VERSION$$ v1.52-1-g0dae2db
#===============================================================================

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
export  INPUTFILE REFFILE OUTPUTFILE INPUTFILELIST
 # shellcheck disable=SC2125
 INPUTFILELIST="${DIRME}/${REFDIR}/${REFDIR}-"*".input"
 OUTPUTFILE="${TESTDIR}/${REFDIR}.out"
 INPUTFILE="${DIRME}/${REFDIR}/${REFDIR}.input"
 REFFILE="${DIRME}/${REFDIR}/${REFDIR}.result"

# reset ENVIRONMENT
export BASHBOT_URL TESTTOKEN BOTTOKEN BASHBOT_HOME BASHBOT_VAR BASHBOT_ETC
BOTTOKEN=""
BASHBOT_HOME=""
BASHBOT_VAR=""
BASHBOT_ETC=""
# do not query telegram when testing
BASHBOT_URL="https://my-json-server.typicode.com/topkecleon/telegram-bot-bash/getMe?"
TESTTOKEN="123456789:BASHBOTTESTSCRIPTbashbottestscript_"

# print arrays in reproducible order
print_array() {
  local idx t
  local arrays=( "${@}" )
  for idx in "${arrays[@]}"; do
    declare -n temp="${idx}"
	for t in "${!temp[@]}"; do 
  		printf '%s:\t%s\t%s\n' "${idx}" "${t}" "${temp[${t}]}"
	done | sort
  done | grep -v '^USER:	0'
}


compare_sorted() {
	local ret=0
	sort -d -o "$1.sort" "$1"
	sort -d -o "$2.sort" "$2"
	diff -c "$1.sort" "$2.sort" || ret=1
	[[ "$1" != "${TESTDIR}"* ]] && rm -f "$1.sort"
	[[ "$2" != "${TESTDIR}"* ]] && rm -f "$2.sort"
	return "${ret}"
}

######
# lets go ...
printf "Running %s ...\n" "${TESTNAME#? }"
printf "............................\n"
[ "${TESTDIR}" = "" ] && printf "%s not called from testsuite, exit" "${NOSUCCESS}" && exit 1

# reset env for test
unset IFS;
export TERM=""

