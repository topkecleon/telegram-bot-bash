#!/bin/bash
# shellcheck disable=SC1090,SC2034
#===============================================================================
#
#          FILE: bin/send_message.sh
# 
USAGE='send_message.sh [-h|--help] [format] "CHAT[ID]" "message ...." [debug]'
# 
#   DESCRIPTION: send a message to the given user/group
# 
#       OPTIONS: format - normal, markdown, html, stdin, - (optional)
#                CHAT[ID] - ID number of CHAT or BOTADMIN to send to yourself
#                message - message to send in specified format
#                    if no format is givern send_message() format is used
#
#                use format "stdin" to read message from stdin or from a file:
#                  send_message.sh stdin "CHAT[ID]" <file
#                  df -h | send_message.sh - "CHAT[ID]"
#
#                -h - display short help
#                --help -  this help
#
#                Set BASHBOT_HOME to your installation directory
#
#	LICENSE: WTFPLv2 http://www.wtfpl.net/txt/copying/
#        AUTHOR: KayM (gnadelwartz), kay@rrr.de
#       CREATED: 16.12.2020 11:34
#
#### $$VERSION$$ v1.52-0-g36d8604
#===============================================================================

####
# parse args
SEND="send_message"
case "$1" in
	"nor"*|"tex"*)
		SEND="send_normal_message"
		shift
		;;
	"mark"*)
		SEND="send_markdownv2_message"
		shift
		;;
	"html")
		SEND="send_html_message"
		shift
		;;
	"stdin"|"-")
		FILE="stdin"
		shift
		;;
esac

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

# send message in selected format
if [ "${FILE}" = "stdin" ]; then
	"${SEND}" "${CHAT}" "$(cat)"
else
	"${SEND}" "${CHAT}" "$2"
fi
# output send message result
print_result
