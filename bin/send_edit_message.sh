#!/bin/bash
#===============================================================================
#
#          FILE: bin/send_message.sh
# 
USAGE='send_edit_message.sh [-h|--help] [format|caption] "CHAT[ID]" "MESSAGE[ID]" "message ...." [debug]'
# 
#   DESCRIPTION: replace a message in the given user/group
# 
#       OPTIONS: format - normal, markdown, html or caption for file caption (optional)
#                CHAT[ID] - ID number of CHAT or BOTADMIN to send to yourself
#                MESSAGE[ID] - message to replace
#                message - message to send in specified format
#                    if no format is given send_normal_message() format is used
#
#                -h - display short help
#                --help -  this help
#
#                Set BASHBOT_HOME to your installation directory
#
#	LICENSE: WTFPLv2 http://www.wtfpl.net/txt/copying/
#        AUTHOR: KayM (gnadelwartz), kay@rrr.de
#       CREATED: 23.12.2020 16:52
#
#### $$VERSION$$ v1.30-dev-17-geab8408
#===============================================================================

####
# parse args
SEND="edit_normal_message"
case "$1" in
	"nor"*|"tex"*)
		SEND="edit_normal_message"
		shift
		;;
	"mark"*)
		SEND="edit_markdownv2_message"
		shift
		;;
	"htm"*)
		SEND="edit_html_message"
		shift
		;;
	"cap"*)
		SEND="edit_message_caption"
		shift
		;;
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

