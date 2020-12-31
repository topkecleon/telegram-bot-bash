#!/bin/bash
#===============================================================================
#
#          FILE: bin/send_file.sh
# 
#         USAGE: send_file.sh [-h|--help] "CHAT[ID]" "file" "caption ...." [debug]
# 
#   DESCRIPTION: send a file to the given user/group
# 
#       OPTIONS: CHAT[ID] - ID number of CHAT or BOTADMIN to send to yourself
#                file - file to send, must be an absolute path or relative to pwd
#                       Note: must not contain .. or . and located below BASHBOT_ETC
#                caption - message to send with file
#
#                -h - display short help
#                --help -  this help
#
#                Set BASHBOT_HOME to your installation directory
#
#	LICENSE: WTFPLv2 http://www.wtfpl.net/txt/copying/
#        AUTHOR: KayM (gnadelwartz), kay@rrr.de
#       CREATED: 25.12.2020 20:24
#
#### $$VERSION$$ v1.21-dev-0-g2e878fd
#===============================================================================

####
# parse args
SEND="upload_file"
case "$1" in
	'')
		printf "missing arguments\n"
		;&
	"-h"*)
		printf 'usage: send_file [-h|--help] "CHAT[ID]" "file" "caption ...." [debug]\n'
		exit 1
		;;
	'--h'*)
		sed -n '3,/###/p' <"$0"
		exit 1
		;;
esac

# set bashbot environment
# shellcheck disable=SC1090
source "${0%/*}/bashbot_env.inc.sh" "$4" # $4 debug

####
# ready, do stuff here -----
if [ "$1" == "BOTADMIN" ]; then
	CHAT="${BOT_ADMIN}"
else
	CHAT="$1"
fi

FILE="$2"
[[ "$2" != "/"* ]] && FILE="${PWD}/$2"

# send message in selected format
"${SEND}" "${CHAT}" "${FILE}" "$3"

# output send message result
jssh_printDB "BOTSENT" | sort -r

