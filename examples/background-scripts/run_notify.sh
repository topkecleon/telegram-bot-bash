#!/bin/bash
# file: notify.sh
# example for an background job, run with startback notify.sh
#
# This file is public domain in the USA and all free countries.
# Elsewhere, consider it to be WTFPLv2. (wtfpl.net/txt/copying)
#### $$VERSION$$ v1.51-0-g6e66a28

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

# check if $1 is a number
regex='^[0-9]+$'
if [[ "$1" =~ ${regex} ]] ; then
	SLEEP="$1"
else
	SLEEP=10 # time between time notifications
fi

# output current time every $1 seconds
while sleep "${SLEEP}"
do
	date "+* It's %k:%M:%S o' clock ..."
done

