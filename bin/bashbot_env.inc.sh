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
#### $$VERSION$$ v1.2-dev2-74-g0b7cd8a
#===============================================================================

############
# set where your bashbot lives
# default: one dir up 
BASHBOT_HOME="$(cd "${BASH_SOURCE[0]%/*}" >/dev/null 2>&1 && pwd)/../"
[ "${BASHBOT_HOME}" = "/../" ] && BASHBOT_HOME="../"

# set you own BASHBOT_HOME if different, e.g.
# BASHBOT_HOME="/usr/local/telegram-bot-bash"
BASHBOT_ETC="${BASHBOT_HOME}"
BASHBOT_VAR="${BASHBOT_HOME}"

#####
# if files are not readable, eviroment is wrong or bashbot is not initialized

# source bashbot
if [ ! -r "${BASHBOT_HOME}/bashbot.sh" ]; then
	echo "Bashbot.sh not found in \"${BASHBOT_HOME}\""
	exit 4
else
	# shellcheck disable=SC1090
	source "${BASHBOT_HOME}/bashbot.sh" source "$1"
fi

# check for botconfig.jssh readable
if [ ! -r "${BASHBOT_ETC}/botconfig.jssh" ]; then
	echo "Bashbot config file in \"${BASHBOT_ETC}\" does not exist or is not readable."
	exit 3
fi
# check for count.jssh readable
if [ ! -r "${BASHBOT_VAR}/count.jssh" ]; then
	echo "Bashbot count file in \"${BASHBOT_VAR}\" does not exist or is not readable. Did you run bashbot init?"
	exit 3
fi

# get and check ADMIN and NAME
BOT_ADMIN="$(getConfigKey "botadmin")"
BOT_NAME="$(getConfigKey "botname")"
[[ -z "${BOT_ADMIN}" || "${BOT_ADMIN}" == "?" ]] && echo -e "${ORANGE}Warning: Botadmin not set, did you forget to sent command${NC} /start"
[[ -z "${BOT_NAME}"  ]] && echo -e "${ORANGE}Warning: Botname not set, did you ever run bashbot?"

