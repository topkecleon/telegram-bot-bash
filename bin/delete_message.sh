#!/bin/bash
#===============================================================================
#
#          FILE: bin/delete_message.sh
# 
#         USAGE: delete_message.sh [-h|--help]  "CHAT[ID]" "MESSAGE[ID]" [debug]
# 
#   DESCRIPTION: delete a message in the given user/group
# 
#       OPTIONS: CHAT[ID] - ID number of CHAT or BOTADMIN 
#                MESSAGE[ID] - message to delete
#
#                -h - display short help
#                --help -  this help
#
#                Set BASHBOT_HOME to your installation directory
#
#	LICENSE: WTFPLv2 http://www.wtfpl.net/txt/copying/
#        AUTHOR: KayM (gnadelwartz), kay@rrr.de
#       CREATED: 03.01.2021 15:37
#
#### $$VERSION$$ v1.25-dev-14-g2fe6d4b
#===============================================================================

####
# parse args
DELETE="delete_message"
case "$1" in
	'')
		printf "missing arguments\n"
		;&
	"-h"*)
		printf 'usage: send_edit_message [-h|--help] [format] "CHAT[ID]" "MESSAGE[ID]" "message ..."  [debug]\n'
		exit 1
		;;
	'--h'*)
		sed -n '3,/###/p' <"$0"
		exit 1
		;;
esac


# set bashbot environment
# shellcheck disable=SC1090
source "${0%/*}/bashbot_env.inc.sh" "$3" # $3 debug

####
####
# ready, do stuff here -----
if [ "$1" == "BOTADMIN" ]; then
	CHAT="${BOT_ADMIN}"
else
	CHAT="$1"
fi

# delete message
"${DELETE}" "${CHAT}" "$2"

[ "${BOTSENT[OK]}" = "true" ] && BOTSENT[ID]="$2"

# output send message result
jssh_printDB "BOTSENT" | sort -r

