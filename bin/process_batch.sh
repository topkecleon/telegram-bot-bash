#!/bin/bash
# shellcheck disable=SC1090,SC2034,SC2059
#===============================================================================
#
#          FILE: bin/process_batch.sh
#
USAGE='process_update.sh [-h|--help] [-s|--startbot] [-w|--watch] [-n|--lines n] [file] [debug]'
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
#### $$VERSION$$ v1.45-dev-72-g7500ca0
#===============================================================================

####
# parse args
COMMAND="process_multi_updates"
lines="-n 10"

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
	[ -p "${file}" ] || printf "%b\n" "${ORANGE}Warning${NC}: File is not a pipe:${GREY} ${file##*/}${NC}"
	start_bot "$2" "webhook"
	printf "${GREEN}Bot start actions done, start reading updates ....${NN}"
fi
# check file exist
if [[ ! -r "${file}" || -d "${file}" ]]; then
	printf "%b\n" "${RED}Error${NC}: File not readable:${GREY} ${file}${NC}."
	exit 1
fi

####
# ready, do stuff here -----

# kill all sub processes on exit
trap 'kill $(jobs -p) 2>/dev/null; send_normal_message "'"${BOTADMIN}"'" "Bot '"${BOTNAME}"' webhook stopped ..."; printf "Bot in batch mode killed!\n"' EXIT HUP QUIT

# use tail to read appended updates
# shellcheck disable=SC2086,SC2248
tail ${follow} ${lines} "${file}" |\
    while IFS="" read -r input
    do 
	# read json from stdin and convert update format
	# replace any ID named BOTADMIN with ID of bot admin
	: "${input//\"id\":BOTADMIN,/\"id\":${BOTADMIN},}"
	json='{"result": ['"${_}"']}'
	UPDATE="$(${JSONSHFILE} -b -n <<<"${json}" 2>/dev/null)"

	# process telegram update
	"${COMMAND}" "$2"
    done 
