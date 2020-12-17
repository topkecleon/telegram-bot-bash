#!/bin/bash - 
#===============================================================================
#
#          FILE: send_message.sh
# 
#         USAGE: send_message.sh [-h|--help] [format] "CHAT[ID]" "message ...." [debug]
# 
#   DESCRIPTION: send a message to the given user/group
# 
#       OPTIONS: format - normal, markdown, html (optional)
#                CHAT[ID] - ID number of CHAT
#                message - message to send in specified format
#                    if no format is givern send_message() format is used
#
#                -h - display short help
#                --help -  this help
#
#                Set BASHBOT_HOME to your installation directory
#
#	LICENSE: WTFPLv2 http://www.wtfpl.net/txt/copying/
#        AUTHOR: KayM (gnadelwartz), kay@rrr.de
#       CREATED: 16.12.2020 11:34:27
#
#### $$VERSION$$ v1.2-dev2-33-g1dd546b
#===============================================================================

# set where your bashbot lives
BASHBOT_HOME="$(cd "${BASH_SOURCE[0]%/*}" >/dev/null 2>&1 && pwd)/../"

# check for botconfig.jssh
if [ ! -r "${BASHBOT_HOME}/botconfig.jssh" ]; then
	echo "No bashbot config file in ${BASHBOT_HOME}"
	exit 3
fi

# parse args
SEND="send_message"
case "$1" in
	"nor*"|"tex*")
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
	'')
		echo "missing missing arguments"
		;&
	"-h"*)
		echo "usage: send_message [-h|--help] [format] "CHAT[ID]" "message ...." [debug]"
		exit 1
		;;
	'--h'*)
		sed -n '3,/###/p' <"$0"
		exit 1
		;;
esac

if [[ "$1" == *[!0-9-]* ]]; then
	echo "CHAT[ID] is not a number! use: $0 -h for help"
	exit 2
fi

# source bashbot and send message
# shellcheck disable=SC1090
source "${BASHBOT_HOME}/bashbot.sh" source "$3"
"${SEND}" "$1" "$2"

# output result
jssh_printDB "BOTSENT" | sort -r

