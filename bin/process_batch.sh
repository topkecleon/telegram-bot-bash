#!/bin/bash
# shellcheck disable=SC1090,SC2034,SC2059
#===============================================================================
#
#          FILE: bin/process_batch.sh
#
USAGE='process_update.sh [-h|--help] -w|--watch [-n|--lines n] [file] [debug]'
# 
#   DESCRIPTION: processes last 10 telegram updates in file, one update per line
#                 
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
#### $$VERSION$$ v1.45-dev-52-g84ff8ce
#===============================================================================

####
# parse args
COMMAND="process_multi_updates"
lines="-n 10"

case "$1" in
	"-f"|"--follow")
		follow="-f"
		shift
		;;
	"-n"|"--lines")
		lines="-n $2"
		shift 2
		;;
esac

# set bashbot environment
source "${0%/*}/bashbot_env.inc.sh" "debug" # debug
print_help "${1:-nix}"


# empty file is webhook
file="${WEBHOOK}"
[ -n "$1" ] && file="$1"

if [[ ! -r "${file}" || -d "${file}" ]]; then
	printf "%b\n" "File ${GREY}${file}${NC} is not readable or is a directory."
	exit 1
fi

####
# ready, do stuff here -----
trap 'kill $(jobs -p) 2>/dev/null' EXIT HUP QUIT

# shellcheck disable=SC2086,SC2248
tail ${follow} ${lines} "${file}" |\
    while IFS="" read -r input
    do 
	# read json from stdin and convert update format
	json='{"result": ['"${input}"']}'
	UPDATE="$(${JSONSHFILE} -b -n <<<"${json}" 2>/dev/null)"

	# process telegram update
	"${COMMAND}" "$1"
    done 
