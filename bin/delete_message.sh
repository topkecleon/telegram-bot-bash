#!/bin/bash
# shellcheck disable=SC1090,SC2034
#===============================================================================
#
#          FILE: bin/delete_message.sh
# 
USAGE='delete_message.sh [-h|--help]  "CHAT[ID]" "MESSAGE[ID]" [debug]'
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
#### $$VERSION$$ v1.51-0-g6e66a28
#===============================================================================

####
# parse args
DELETE="delete_message"

# set bashbot environment
source "${0%/*}/bashbot_env.inc.sh" "${3:-debug}" # $3 debug
print_help "$1"

####
# ready, do stuff here -----
if [ "$1" == "BOTADMIN" ]; then
	CHAT="${BOTADMIN}"
else
	CHAT="$1"
fi

# delete message
"${DELETE}" "${CHAT}" "$2"

[ "${BOTSENT[OK]}" = "true" ] && BOTSENT[ID]="$2"

# output send message result
print_result
