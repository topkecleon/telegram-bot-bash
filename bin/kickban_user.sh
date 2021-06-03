#!/bin/bash
# shellcheck disable=SC1090,SC2034
#===============================================================================
#
#          FILE: bin/kickban_user.sh
# 
USAGE='kickban_user.sh [-h|--help] [-u|--unban] "CHAT[ID]" "USER[ID]" [debug]'
# 
#   DESCRIPTION: kickban or unban a user from  the given group
# 
#       OPTIONS: -u | --unban - unban user
#                CHAT[ID] - ID number of CHAT or BOTADMIN to send to yourself
#                USER[ID] - user to (un)ban
#
#                -h - display short help
#                --help -  this help
#
#
#	LICENSE: WTFPLv2 http://www.wtfpl.net/txt/copying/
#        AUTHOR: KayM (gnadelwartz), kay@rrr.de
#       CREATED: 25.01.2021 20:34
#
#### $$VERSION$$ v1.51-0-g6e66a28
#===============================================================================

####
# parse args
BAN="kick_chat_member"
case "$1" in
	"-u"|"--unban")
		BAN="unban_chat_member"
		shift
		;;
esac

# set bashbot environment
source "${0%/*}/bashbot_env.inc.sh" "${3:-debug}" # $3 debug
print_help "$1"

####
# ready, do stuff here -----

# send message in selected format
"${BAN}" "$1" "$2"

# output send message result
print_result
