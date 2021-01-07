#!/bin/bash
#===============================================================================
#
#          FILE: bin/send_file.sh
# 
#         USAGE: send_file.sh [-h|--help] "CHAT[ID]" "file|URL" "caption ...." [type] [debug]
# 
#   DESCRIPTION: send a file to the given user/group
# 
#       OPTIONS: CHAT[ID] - ID number of CHAT or BOTADMIN to send to yourself
#                file - local file to send, must be an absolute path or relative to pwd
#                       Note: must not contain .. or . and located below BASHBOT_ETC
#                URL - send an URL instead local file
#
#                caption - message to send with file
#                type - photo, video, sticker, voice, document (optional)
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
#### $$VERSION$$ v1.25-dev-34-gda214ab
#===============================================================================

####
# parse args
SEND="send_file"
case "$1" in
	'')
		printf "missing arguments\n"
		;&
	"-h"*)
		printf 'usage: send_file [-h|--help] "CHAT[ID]" "file" "caption ...." [type] [debug]\n'
		exit 1
		;;
	'--h'*)
		sed -n '3,/###/p' <"$0"
		exit 1
		;;
esac

# set bashbot environment
# shellcheck disable=SC1090
source "${0%/*}/bashbot_env.inc.sh" "$5" # $5 debug

####
# ready, do stuff here -----
if [ "$1" == "BOTADMIN" ]; then
	CHAT="${BOT_ADMIN}"
else
	CHAT="$1"
fi

FILE="$2"
# convert to absolute path if not start with / or http://
[[ ! ( "$2" == "/"* ||  "$2" =~ ^https*:// || "$2" == "file_id://"*) ]] && FILE="${PWD}/$2"

# send message in selected format
"${SEND}" "${CHAT}" "${FILE}" "$3" "$4"

# output send message result
jssh_printDB "BOTSENT" | sort -r

