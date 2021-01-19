#!/bin/bash
#===============================================================================
#
#          FILE: bin/send_message.sh
# 
USAGE='send_message.sh [-h|--help] "CHAT[ID]" "message" "text|url" ...'
# 
#   DESCRIPTION: send a send buttons in a row to the given user/group
# 
#       OPTIONS: CHAT[ID] - ID number of CHAT or BOTADMIN to send to yourself
#                message - message to send
#                text|url - buttons to send in a row, each as "button text|url"
#                     e.g. "Amazon|https://www.amzon.com" "Mydealz|https://mydealz.de" ...
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
#### $$VERSION$$ v1.31-dev-9-g6c91a32
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
source "${0%/*}/bashbot_env.inc.sh" "debug"

####
# ready, do stuff here -----
if [ "$1" == "BOTADMIN" ]; then
	CHAT="${BOT_ADMIN}"
else
	CHAT="$1"
fi
TEXT="$2"
shift 2

# send message in selected format
"${SEND}" "${CHAT}" "${TEXT}" "$(_button_row "$@")"

# output send message result
jssh_printDB "BOTSENT" | sort -r

