#!/bin/bash
#===============================================================================
#
#          FILE: bin/send_message.sh
# 
USAGE='send_message.sh [-h|--help] "CHAT[ID]" "message ...." "buttons" [debug]'
# 
#   DESCRIPTION: send a message to the given user/group
# 
#       OPTIONS: CHAT[ID] - ID number of CHAT or BOTADMIN to send to yourself
#                message - message to send
#                buttons - buttons to send as button array
#
#                -h - display short help
#                --help -  this help
#
#                Set BASHBOT_HOME to your installation directory
#
#	LICENSE: WTFPLv2 http://www.wtfpl.net/txt/copying/
#        AUTHOR: KayM (gnadelwartz), kay@rrr.de
#       CREATED: 18.01.2021 11:34
#
#### $$VERSION$$ v1.31-dev-4-g0ee6973
#===============================================================================

####
# parse args
SEND="send_inline_keyboard"
case "$1" in
	'')
		printf "missing arguments\n"
		;&
	"-h"*)
		printf 'usage: %s\n' "${USAGE}"
		exit 1
		;;
	'--h'*)
		sed -n '3,/###/p' <"$0"
		exit 1
		;;
esac

# set bashbot environment
# shellcheck disable=SC1090
source "${0%/*}/bashbot_env.inc.sh" "${4:-debug}" # $4 debug

####
# ready, do stuff here -----
if [ "$1" == "BOTADMIN" ]; then
	CHAT="${BOT_ADMIN}"
else
	CHAT="$1"
fi

# send message in selected format
"${SEND}" "${CHAT}" "$2" "$3"

# output send message result
jssh_printDB "BOTSENT" | sort -r

