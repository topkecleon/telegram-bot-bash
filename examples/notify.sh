#!/bin/bash
########################################################################
#
# File: notify.sh
#
# Description: example for an background job, see mycommands.sh.dist
#
# Usage: runback notify  example/notify.sh [seconds] - or run in terminal
#        killback notify - to stop background job
#
# Options: seconds - time to sleep between output, default 10
#
# This file is public domain in the USA and all free countries.
# Elsewhere, consider it to be WTFPLv2. (wtfpl.net/txt/copying)
#
#### $$VERSION$$ v1.51-0-g6e66a28
########################################################################

######
# parameters
# $1 $2 args as given to starct_proc chat script arg1 arg2
# $3 path to named pipe/log

# adjust your language setting here
# https://github.com/topkecleon/telegram-bot-bash#setting-up-your-environment
export 'LC_ALL=C.UTF-8'
export 'LANG=C.UTF-8'
export 'LANGUAGE=C.UTF-8'

unset IFS
# set -f # if you are paranoid use set -f to disable globbing

# discard STDIN for background jobs!
cat >/dev/null & 

# $1 = time between time notifications
# check if $1 is a valid number
if [[ "$1" =~ ^[0-9]+$ ]] ; then
	SLEEP="$1"
else
	SLEEP=10
fi

# output current time every $1 seconds
printf "Output time every %s seconds ...\n" "${SLEEP}"

while true 
do
	date "+* It's %k:%M:%S o'clock ..."
	sleep "${SLEEP}"
done

