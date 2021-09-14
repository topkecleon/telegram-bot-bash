#!/bin/bash
# shellcheck disable=SC1090,SC2034,SC2059
#===============================================================================
#
#          FILE: bin/process_batch.sh
#
USAGE='process_batch.sh [-h|--help] [-s|--startbot] [-w|--watch] [-n|--lines n] [file] [debug]'
# 
#   DESCRIPTION: processes last 10 telegram updates in file, one update per line
#                 
#                -s --startbot load addons, start TIMER, trigger startup actions
#                -w --watch watch for new updates added to file
#                -n --lines read only last "n" lines
#                file   to read updates from 
#			empty means read from webhook pipe
#                
#                -h - display short help
#                --help -  this help
#
#	LICENSE: WTFPLv2 http://www.wtfpl.net/txt/copying/
#        AUTHOR: KayM (gnadelwartz), kay@rrr.de
#       CREATED: 27.02.2021 13:14
#
#### $$VERSION$$ v1.51-0-g6e66a28
#===============================================================================

####
# parse args
COMMAND="process_multi_updates"
lines="-n 10"
mode="batch"

opt=0
while [[ "${opt}" -lt 5 && "$1" == "-"* ]]
do
    (( opt++ )) 
    case "$1" in
	"-s"|"--startbot")
		startbot="yes"
		shift
		;;
	"-w"|"--watch")
		follow="-f"
		mode="webhook"
		shift
		;;
	"-n"|"--lines")
		lines="-n $2"
		shift 2
		;;
    esac
done

# set bashbot environment
source "${0%/*}/bashbot_env.inc.sh" "debug" # debug
print_help "${1:-nix}"

# empty file is webhook
file="${WEBHOOK}"
[ -n "$1" ] && file="$1"

# start bot
if [ -n "${startbot}" ]; then
	# warn when starting bot without pipe
	[ -p "${file}" ] || printf "%(%c)T: %b\n" -1 "${ORANGE}Warning${NC}: File is not a pipe:${GREY} ${file##*/}${NC}"
	start_bot "$2" "${mode}"
	printf "%(%c)T: %b\n" -1 "${GREEN}Bot startup actions done, start ${mode} updates ...${NC}"
fi
# check file exist
if [[ ! -r "${file}" || -d "${file}" ]]; then
	printf "%(%c)T: %b\n" -1 "${RED}Error${NC}: File not readable:${GREY} ${file}${NC}."
	exit 1
fi

####
# ready, do stuff here -----

# kill all sub processes on exit
trap 'printf "%(%c)T: %s\n" -1 "Bot in '"${mode}"' mode stopped"; kill $(jobs -p) 2>/dev/null; wait $(jobs -p) 2>/dev/null; send_normal_message "'"${BOTADMIN}"'" "Bot '"${BOTNAME} ${mode}"' stopped ..."' EXIT HUP QUIT

# wait after (first) update to avoid processing to many in parallel
UPDWAIT="0.5"
# use tail to read appended updates
# shellcheck disable=SC2086,SC2248
tail ${follow} ${lines} "${file}" 2>/dev/null |\
    while IFS="" read -r input 2>/dev/null
    do 
	# read json from stdin and convert update format
	# replace any ID named BOTADMIN with ID of bot admin
	: "${input//\"id\":BOTADMIN,/\"id\":${BOTADMIN},}"
	json='{"result": ['"${_}"']}'
	UPDATE="$(${JSONSHFILE} -b -n <<<"${json}" 2>/dev/null)"

	# process telegram update
	"${COMMAND}" "$2"
	sleep "${UPDWAIT}"
	UPDWAIT="0.05"
    done 
