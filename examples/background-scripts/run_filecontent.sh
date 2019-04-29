#!/bin/bash
# file:  run_filename
# background job to display content of all new files in WATCHDIR
#

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
WATCHDIR="/my_special/dir_to_watch"
source "./mycommands.sh"

# test your script and the remove ...
WATCHDIR="/tmp"

# this is calles by watch loop
# $1 is name of the new file
loop_callback() {
	# output content of file, you MUST trust creator of the file because it contest are sent as message to you!
	output_telegram "Contents of ${1}: mynewlinestartshere $(cat "${1}")"
}

watch_dir_loop "$WATCHDIR"
