#!/bin/bash
#===============================================================================
#
#          FILE: bashbor_env.inc.sh
# 
#   DESCRIPTION: set bashbot environment for all scripts in this directory
# 
#
#	LICENSE: WTFPLv2 http://www.wtfpl.net/txt/copying/
#        AUTHOR: KayM (gnadelwartz), kay@rrr.de
#       CREATED: 18.12.2020 12:27
#
#### $$VERSION$$ v1.2-dev2-38-g0db0215
#===============================================================================

# set where your bashbot lives
# default: one dir up 
BASHBOT_HOME="$(cd "${BASH_SOURCE[0]%/*}" >/dev/null 2>&1 && pwd)/../"

#####
# if files are not readable, eviroment is wrong or bashbot is not initialized

# check for botconfig.jssh readable
if [ ! -r "${BASHBOT_HOME}/botconfig.jssh" ]; then
	echo "Bashbot config file in \"${BASHBOT_HOME}\" does not exist or is not readable."
	exit 3
fi
# check for count.jssh readable
if [ ! -r "${BASHBOT_HOME}/count.jssh" ]; then
	echo "Bashbot count file in \"${BASHBOT_HOME}\" does not exist or is not readable"
	exit 3
fi

