#!/bin/bash
#===============================================================================
#
#          FILE: bashbot_env.inc.sh
# 
#         USAGE: source bashbot_env.inc.sh [debug]
#
#   DESCRIPTION: set bashbot environment for all scripts in this directory
# 
#       OPTIONS: $1 - will be forwarded ro bashbot, e.g. debug
#
#	LICENSE: WTFPLv2 http://www.wtfpl.net/txt/copying/
#        AUTHOR: KayM (gnadelwartz), kay@rrr.de
#       CREATED: 18.12.2020 12:27
#
#### $$VERSION$$ v1.51-0-g6e66a28
#===============================================================================

############
# set where your bashbot lives
export BASHBOT_HOME BASHBOT_ETC BASHBOT_VAR FILE_REGEX ME

# default: one dir up 
BASHBOT_HOME="$(cd "${BASH_SOURCE[0]%/*}/../" >/dev/null 2>&1 && pwd)"
[ "${BASHBOT_HOME}" = "" ] && BASHBOT_HOME="../"

# set you own BASHBOT_HOME if different, e.g.
# BASHBOT_HOME="/usr/local/telegram-bot-bash"
BASHBOT_VAR="${BASHBOT_HOME}"
BASHBOT_ETC="${BASHBOT_HOME}"

#####
# if files are not readable, eviroment is wrong or bashbot is not initialized

# check for bashbot
if [ ! -r "${BASHBOT_HOME}/bashbot.sh" ]; then
	printf "%s\n" "Bashbot.sh not found in \"${BASHBOT_HOME}\""
	exit 4
fi

dev=" Are we in dev or did you forget to run init?"
# check for botconfig.jssh readable
if [ ! -r "${BASHBOT_ETC}/botconfig.jssh" ]; then
	printf "%s\n" "Bashbot config file in \"${BASHBOT_ETC}\" does not exist or is not readable. ${dev}"
	exit 3
fi
# check for count.jssh readable
if [ ! -r "${BASHBOT_VAR}/count.jssh" ]; then
	printf "%s\n" "Bashbot count file in \"${BASHBOT_VAR}\" does not exist or is not readable.  ${dev}"
	exit 3
fi

# shellcheck disable=SC1090
source "${BASHBOT_HOME}/bashbot.sh" source "$1"

# overwrite bot FILE regex to BASHBOT_VAR
# change this to the location you want to allow file uploads from
UPLOADDIR="${BASHBOT_VAR%/bin*}"
FILE_REGEX="${UPLOADDIR}/.*"

# get and check ADMIN and NAME
BOTNAME="$(getConfigKey "botname")"
ME="${BOTNAME}"
[[ -z "${BOTADMIN}" || "${BOTADMIN}" == "?" ]] && printf "%s\n" "${ORANGE}Warning: Botadmin not set, send bot command${NC} /start"
[[ -z "${BOTNAME}"  ]] && printf "%s\n" "${ORANGE}Warning: Botname not set, run bashbot.sh botname"

# default webhook pipe
export WEBHOOK="${DATADIR}/webhook-fifo-${ME}"


# output command result or Telegram response
print_result() { jssh_printDB "BOTSENT" | sort -r; }
print_response() { jssh_printDB "UPD"; }

# check and output help
print_help() {
 case "$1" in
	'')
		printf "missing arguments\n"
		;&
	"-h"*)
		printf 'usage: %s\n' "${USAGE}"
		exit 1
		;;
	'--h'*)
		sed -n '/^#====/,/^#====/p' <"$0"
		exit 1
		;;
 esac
}

