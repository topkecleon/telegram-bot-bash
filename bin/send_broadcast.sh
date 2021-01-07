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
#### $$VERSION$$ v1.25-dev-34-gda214ab
#===============================================================================
# shellcheck disable=SC2059

####
# minimum messages seen in a chat before send a broadcast to it
MINCOUNT=2

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
	'')
		printf "missing missing arguments\n"
		;&
	"-h"*)
		printf 'usage: send_message [-h|--help] [--groups|--both] [format] "message ...." [debug]\n'
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
	printf "${ORANGE}Countfile not found or empty,${NC}\n"
fi

	# loop over users
	printf "${GREEN}Sending broadcast message to all users of ${BOT_NAME}${NC}${GREY}"

{ 	# dry run
	[ -z "${DOIT}" ] && printf "${NC}\n${ORANGE}DRY RUN! use --doit as first argument to execute broadcast...${NC}\n"

	for USER in ${!SENDALL[*]}
	do
		# send to users, groups or both ...
		[[ -z "${GROUPSALSO}" && "${USER}" == *"-"* ]] && continue
		[[ "${SENDTO}" != "users" && "${USER}" != *"-"* ]] && continue
		# ignore everything not a user or group
		[[ ! "${USER}" =~ ^[0-9-]*$ ]] && continue
		# ignore chats with no count or lower MINCOUNT
		[[ ! "${SENDALL[${USER}]}" =~ ^[0-9]*$ || "${SENDALL[${USER}]}" -lt "${MINCOUNT}" ]] && continue 
		(( COUNT++ ))
		if [ -z "${DOIT}" ]; then
			printf  "${SEND} ${USER} $1 $2\n" 
		else
			"${SEND}" "${USER}" "$1" "$2"
			printf  "." 1>&2
			# ups, kicked or banned ...
			if [ "${BOTSENT[ERROR]}" = "403" ]; then
				# remove chat from future broadcasts
				jssh_insertKeyDB "${USER}" "${SENDALL[${USER}]} banned" "${COUNTFILE}"
				printf "${ORANGE}Warning: bot banned from chat${NC} %s ${ORANGE}after${NC} %s ${ORANGE}commands${NC}\n"\
						"${USER}" "${SENDALL[${USER}]}"
			fi
			sleep 0.1
		fi
	done
	# printout final stats message
	printf "${NC}\n${GREEN}Message${NC} $1 ${GREEN}sent to${NC} ${COUNT} ${GREEN}${SENDTO}${GROUPSALSO}.${NC}\n"
} | more

