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
#### $$VERSION$$ v1.21-pre-32-gd70a461
#===============================================================================

############
# set where your bashbot lives
export BASHBOT_HOME BASHBOT_ETC BASHBOT_VAR FILE_REGEX

# default: one dir up 
BASHBOT_HOME="$(cd "${BASH_SOURCE[0]%/*}" >/dev/null 2>&1 && pwd)/../"
[ "${BASHBOT_HOME}" = "/../" ] && BASHBOT_HOME="../"

# set you own BASHBOT_HOME if different, e.g.
# BASHBOT_HOME="/usr/local/telegram-bot-bash"
BASHBOT_VAR="${BASHBOT_HOME}"
BASHBOT_ETC="${BASHBOT_HOME}"

#####
# if files are not readable, eviroment is wrong or bashbot is not initialized

# source bashbot
if [ ! -r "${BASHBOT_HOME}/bashbot.sh" ]; then
	echo "Bashbot.sh not found in \"${BASHBOT_HOME}\""
	exit 4
fi

# check for botconfig.jssh readable
if [ ! -r "${BASHBOT_ETC}/botconfig.jssh" ]; then
	echo "Bashbot config file in \"${BASHBOT_ETC}\" does not exist or is not readable."
	exit 3
fi
# check for count.jssh readable
if [ ! -r "${BASHBOT_VAR}/count.jssh" ]; then
	echo "Bashbot count file in \"${BASHBOT_VAR}\" does not exist or is not readable. Did you run bashbot init?"
	exit 3
fi

# shellcheck disable=SC1090
source "${BASHBOT_HOME}/bashbot.sh" source "$1"

# overwrite bot FILE regex to BASHBOT_VAR
# change this to the location you want to allow file uploads from
UPLOADDIR="${BASHBOT_VAR%/bin*}"
FILE_REGEX="${UPLOADDIR}/.*"

# get and check ADMIN and NAME
BOT_ADMIN="$(getConfigKey "botadmin")"
BOT_NAME="$(getConfigKey "botname")"
[[ -z "${BOT_ADMIN}" || "${BOT_ADMIN}" == "?" ]] && echo -e "${ORANGE}Warning: Botadmin not set, did you forget to sent command${NC} /start"
[[ -z "${BOT_NAME}"  ]] && echo -e "${ORANGE}Warning: Botname not set, did you ever run bashbot?"


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
export  INPUTFILE REFFILE INPUTFILE2 REFFILE2 OUTPUTFILE
 OUTPUTFILE="${TESTDIR}/${REFDIR}.out"
 INPUTFILE="${DIRME}/${REFDIR}/${REFDIR}.input"
 REFFILE="${DIRME}/${REFDIR}/${REFDIR}.result"
 INPUTFILE2="${DIRME}/${REFDIR}/${REFDIR}2.input"
 REFFILE2="${DIRME}/${REFDIR}/${REFDIR}2.result"

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
	[[ "${1}" != "${TESTDIR}"* ]] && rm -f "${1}.sort"
	[[ "${2}" != "${TESTDIR}"* ]] && rm -f "${2}.sort"
	return "$ret"
}

######
# lets go ...
printf "Running %s ...\n" "${TESTNAME#? }"
printf "............................\n"
[ "${TESTDIR}" = "" ] && printf "%s not called from testsuite, exit" "${NOSUCCESS}" && exit 1

# reset env for test
unset IFS;
export TERM=""

