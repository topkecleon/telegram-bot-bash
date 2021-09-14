#!/bin/bash
# file:  run_filename
# background job to display content of all new files in WATCHDIR
#
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

# watch for new files created by a trusted program
WATCHDIR="/my_trusted/dir_to_watch"

# shellcheck source=examples/background-scripts/mycommands.sh
source "./mycommands.sh"

# test your script and the remove ...
WATCHDIR="/tmp/bottest"

NEWLINE='mynewlinestartshere'

# this is called by watch dir loop
# $1 is name of the new file
loop_callback() {
	# output content of file, you must trust creator because content is sent as message!
	output_telegram "Contents of ${1}: ${NEWLINE} $(cat "${1}")"
}

watch_dir_loop "${WATCHDIR}"
