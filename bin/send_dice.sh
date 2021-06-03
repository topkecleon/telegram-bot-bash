#!/bin/bash
# shellcheck disable=SC1090,SC2034
#===============================================================================
#
#          FILE: bin/send_dice.sh
#
USAGE='send_dice.sh [-h|--help] "CHAT[ID]" "emoji" [debug]'
# 
#   DESCRIPTION: send an animated emoji (dice) to given chat
# 
#       OPTIONS: CHAT[ID] - ID number of CHAT or BOTADMIN to send to yourself
#                emoji - must be one of: “🎲”, “🎯”, “🏀”, “⚽” “🎰” "🎳"
#                        :game_die: :dart: :basketball: :soccer: :slot_machine: :bowling:
#
#                -h - display short help
#                --help -  this help
#
#                Set BASHBOT_HOME to your installation directory
#
#	LICENSE: WTFPLv2 http://www.wtfpl.net/txt/copying/
#        AUTHOR: KayM (gnadelwartz), kay@rrr.de
#       CREATED: 07.02.2021 18:45
#
#### $$VERSION$$ v1.51-0-g6e66a28
#===============================================================================

####
# parse args
SEND="send_dice"

# set bashbot environment
source "${0%/*}/bashbot_env.inc.sh" "${3:-debug}" # $5 debug
print_help "$1"

####
# ready, do stuff here -----
if [ "$1" == "BOTADMIN" ]; then
	CHAT="${BOTADMIN}"
else
	CHAT="$1"
fi

# send message in selected format
"${SEND}" "${CHAT}" "$2"

# output send message result
print_result
