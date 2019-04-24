#!/bin/bash
# files: mycommands.sh.dist
# copy to mycommands.sh and add all your commands and functions here ...
#
#### $$VERSION$$ v0.70-dev2-21-g0cfb9f0
#
# shellcheck disable=SC2154
# shellcheck disable=SC2034


# uncomment the following lines to overwrite info and help messages
# bashbot_info='This is bashbot, the Telegram bot written entirely in bash.
#'
# bashbot_help='*Available commands*:
#'


# your additional bahsbot commands
mycommands() {

	case "$MESSAGE" in
		'/echo'*) # example echo command
			send_normal_message "${CHAT[ID]}" "$MESSAGE"
			;;
		'/question') # start interactive questions
			checkproc 
			if [ "$res" -gt 0 ] ; then
				startproc "example/question"
			else
				send_normal_message "${CHAT[ID]}" "$MESSAGE already running ..."
			fi
			;;

		'/run-notify') # start notify background job
			myback="notify"; checkback "$myback"
			if [ "$res" -gt 0 ] ; then
				background "example/notify 60" "$myback" # notify every 60 seconds
			else
				send_normal_message "${CHAT[ID]}" "Background command $myback already running ..."
			fi
			;;
		'/stop-notify') # kill notify background job
			myback="notify"; checkback "$myback"
			if [ "$res" -eq 0 ] ; then
				killback "$myback"
				send_normal_message "${CHAT[ID]}" "Background command $myback canceled."
			else
				send_normal_message "${CHAT[ID]}" "No background command $myback is currently running.."
			fi
			;;

	esac
}

# place your processing functions here
