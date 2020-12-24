#!/bin/bash
#===============================================================================
#
#          FILE: bin/bashbot_stats.sh
# 
#         USAGE: bashbot_stats.sh [-h|--help]
# 
#   DESCRIPTION: output bashbot user stats
# 
#       OPTIONS: -h - display short help
#                --help -  this help
#
#                Set BASHBOT_HOME to your installation directory
#
#	LICENSE: WTFPLv2 http://www.wtfpl.net/txt/copying/
#        AUTHOR: KayM (gnadelwartz), kay@rrr.de
#       CREATED: 23.12.2020 20:34
#
#### $$VERSION$$ v1.2-dev2-61-geba9216
#===============================================================================

# set bashbot environment
# shellcheck disable=SC1090
source "${0%/*}/bashbot_env.inc.sh"

####
# parse args
case "$1" in
	"-h"*)
		echo "usage: send_message [-h|--help] [debug]"
		exit 1
		;;
	'--h'*)
		sed -n '3,/###/p' <"$0"
		exit 1
		;;
esac

# source bashbot and send message
# shellcheck disable=SC1090
source "${BASHBOT_HOME}/bashbot.sh" source "$1"

####
# ready, do stuff here -----

ME="$(getConfigKey "botname")"
echo -e "${GREEN}Hi I'm ${ME}.${NC}"
declare -A STATS
jssh_readDB_async "STATS" "${COUNTFILE}"
for MSG in ${!STATS[*]}
do
	[[ ! "${MSG}" =~ ^[0-9-]*$ ]] && continue
	(( USERS++ ))
done
for MSG in ${STATS[*]}
do
	(( MESSAGES+=MSG ))
done
if [ "${USERS}" != "" ]; then
	echo -e "${GREY}A total of ${NC}${MESSAGES}${GREY} messages from ${NC}${USERS}${GREY} users are processed.${NC}"
else
	echo -e "${ORANGE}No one used your bot so far ...${NC}"
fi
jssh_readDB_async "STATS" "${BLOCKEDFILE}"
for MSG in ${!STATS[*]}
do
	[[ ! "${MSG}" =~ ^[0-9-]*$ ]] && continue
	(( BLOCKS++ ))
done
if [ "${BLOCKS}" != "" ]; then
	echo -e "${ORANGE}${BLOCKS} user(s) are blocked:${NC}${GREY}"
	sort -r "${BLOCKEDFILE}.jssh"
	echo -e "${NC}\c"
else
	echo -e "${GREEN}No user is blocked currently ...${NC}"
fi
# show user created bot stats
_exec_if_function my_bashbot_stats "$@"

