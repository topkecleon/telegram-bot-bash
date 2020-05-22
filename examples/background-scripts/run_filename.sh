#!/bin/bash
# file:  run_filename
# background job to display all new files in WATCHDIR
#
#### $$VERSION$$ v0.96-dev-7-g0153928

# adjust your language setting here
# https://github.com/topkecleon/telegram-bot-bash#setting-up-your-environment
export 'LC_ALL=C.UTF-8'
export 'LANG=C.UTF-8'
export 'LANGUAGE=C.UTF-8'

unset IFS
# set -f # if you are paranoid use set -f to disable globbing

# discard STDIN for background jobs!
cat >/dev/null & 

# watch for new logfiles
WATCHDIR="/var/log"
source "./mycommands.sh"

# test your script and the remove ...
WATCHDIR="/tmp/bottest"

# this is called by watch dir loop
# $1 is name of the new file
loop_callback() {
	# output one simple line ...
	echo "New file ${1} created in ${WATCHDIR}!"
}

watch_dir_loop "$WATCHDIR"
