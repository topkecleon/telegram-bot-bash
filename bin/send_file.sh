#!/bin/bash
# shellcheck disable=SC1090,SC2034
#===============================================================================
#
#          FILE: bin/send_file.sh
#
USAGE='send_file.sh [-h|--help] "CHAT[ID]" "file|URL" "caption ...." [type] [debug]'
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
#### $$VERSION$$ v1.51-0-g6e66a28
#===============================================================================

####
# parse args
SEND="send_file"

# set bashbot environment
source "${0%/*}/bashbot_env.inc.sh" "${5:-debug}" # $5 debug
print_help "$1"

####
# ready, do stuff here -----
if [ "$1" == "BOTADMIN" ]; then
	CHAT="${BOTADMIN}"
else
	CHAT="$1"
fi

FILE="$2"
# convert to absolute path if not start with / or http://
[[ ! ( "$2" == "/"* ||  "$2" =~ ^https*:// || "$2" == "file_id://"*) ]] && FILE="${PWD}/$2"

# send message in selected format
"${SEND}" "${CHAT}" "${FILE}" "$3" "$4"

# output send message result
print_result
