#!/bin/bash
# shellcheck disable=SC1090,SC2034,SC2059
#===============================================================================
#
#          FILE: bin/any_command.sh
#
USAGE='any_command.sh [-h|--help] [--force|--reference] bot_command args ...'
# 
#   DESCRIPTION: execute (almost) any bashbot command/function
#                can be used for testing commands while bot development
# 
#       OPTIONS: -- force - execute unknown commands/functions
#		      by default only commands in 6_reference.md are allowed
#
#                -h - display short help
#                --help -  this help
#
#                Set BASHBOT_HOME to your installation directory
#
#	LICENSE: WTFPLv2 http://www.wtfpl.net/txt/copying/
#        AUTHOR: KayM (gnadelwartz), kay@rrr.de
#       CREATED: 30.01.2021 10:24
#
#### $$VERSION$$ v1.51-0-g6e66a28
#===============================================================================

####
# parse args
COMMAND=""

# set bashbot environment
source "${0%/*}/bashbot_env.inc.sh" "debug" # debug
print_help "$1"


error=""
# check options
if [[ "$1" = "--force"  ]]; then
	# skip checks
	shift
else
	# check for --ref 
	ref="$1"; [[ "$1" == "--ref"* ]] && shift
	if [ "${#1}" -lt  11 ];then
		printf "${RED}Command must be minimum 11 characters!${NC}\n"
		error=3
	fi
	if [[ "$1" != *"_"* ]];then
		printf "${RED}Command must contain _ (underscore)!${NC}\n"
		error=3
	fi
	# simple hack to get allowed commands from doc
	if grep -q "^##### $1" <<<"$(sed -n -e '/^##### _is_/,$ d' -e '/^##### /p' "${BASHBOT_HOME:-..}doc/"6_*)"; then
		# oiutput reference and exit
		if [[ "${ref}" == "--ref"* ]]; then
			sed -n -e '/^##### '"$1"'/,/^##/ p' "${BASHBOT_HOME:-..}doc/"6_*
			exit
		fi
	else
		printf "Command ${GREY}%s${NC} not found in 6_reference.md, use ${GREY}--force${NC} to execute!\n" "$1"
		error=4
	fi
	[ -n "${error}" ] && exit "${error}"
fi


####
# ready, do stuff here -----
COMMAND="$1"
if [ "$2" == "BOTADMIN" ]; then
	ARG1="${BOTADMIN}"
else
	ARG1="$2"
fi

# clear result and response
BOTSENT=()
UPD=()

# send message in selected format
"${COMMAND}" "${ARG1}"  "${@:3}"

# output result an telegram response
print_result
print_response
