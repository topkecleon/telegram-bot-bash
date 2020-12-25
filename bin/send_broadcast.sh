#!/bin/bash
#===============================================================================
#
#          FILE: bin/broadcast_message.sh
# 
#         USAGE: broadcast_message.sh [-h|--help] [--doit] [--groups|--both] [format] "message ...." [debug]
# 
#   DESCRIPTION: send a message to all users the bot have seen (listet in count.jssh)
# 
#       OPTIONS: --doit - broadcast is dangerous, simulate run without --doit
#                --groups - send to groups instead of users
#                --both - send to users and groups
#
#                format - normal, markdown, html (optional)
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
#       CREATED: 16.12.2020 16:14
#
#### $$VERSION$$ v1.2-dev2-73-gf281ae0
#===============================================================================

####
# broadcast is dangerous, without --doit we do a dry run ...
if [ "$1" = "--doit" ]; then
	DOIT="yes"
	shift
fi

####
# send to users by default, --group sends groups, --both to both
SENDTO="users"
if [ "$1" = "--both" ]; then
	GROUPSALSO=" and groups"
	shift
elif [ "$1" = "--groups" ]; then
	SENDTO="groups"
	GROUPSALSO=" only"
	shift
fi

####
# parse args -----------------
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
		echo 'usage: send_message [-h|--help] [--groups|--both] [format] "message ...." [debug]'
		exit 1
		;;
	'--h'*)
		sed -n '3,/###/p' <"$0"
		exit 1
		;;
esac

# set bashbot environment
# shellcheck disable=SC1090
source "${0%/*}/bashbot_env.inc.sh" "$2" # $3 debug


# read in users 
declare -A SENDALL
jssh_readDB_async "SENDALL" "${COUNTFILE}"
if [ -z "${SENDALL[*]}" ]; then
	echo -e "${ORANGE}Countfile not found or empty,${NC} "
fi

	# loop over users
	echo -e "${GREEN}Sending broadcast message to all users of $(getConfigKey "botname")${NC}${GREY}\c"

{ 	# dry run
	[ -z "${DOIT}" ] && echo -e "${NC}\n${ORANGE}DRY RUN! use --doit as first argument to execute broadcast...${NC}"

	for USER in ${!SENDALL[*]}
	do
		# send to users, groups or both ...
		[[ -z "${GROUPSALSO}" && "${USER}" == *"-"* ]] && continue
		[[ "${SENDTO}" != "users" && "${USER}" != *"-"* ]] && continue
		# ignore everything not a user or group
		[[ ! "${USER}" =~ ^[0-9-]*$ ]] && continue
		(( COUNT++ ))
		if [ -z "${DOIT}" ]; then
			echo  "${SEND}" "${USER}" "$1" "$2" 
		else
			"${SEND}" "${USER}" "$1" "$2"
			echo -e ".\c" 1>&2
			sleep 0.1
		fi
	done
	echo -e "${NC}\nMessage \"$1\" sent to ${COUNT} ${SENDTO}${GROUPSALSO}."
} | more
