#!/bin/bash
# files: mycommands.sh.dist
# copy to mycommands.sh and add all your commands and functions here ...
#
#### $$VERSION$$ v0.72-dev-3-g65b32aa
#
# shellcheck disable=SC2154
# shellcheck disable=SC2034


# uncomment the following lines to overwrite info and help messages
# bashbot_info='This is bashbot, the Telegram bot written entirely in bash.
#'
# bashbot_help='*Available commands*:
#'

if [ "$1" = "source" ];then
    # Set INLINE to 1 in order to receive inline queries.
    # To enable this option in your bot, send the /setinline command to @BotFather.
    INLINE="1"
    # Set to .* to allow sending files from all locations
    FILE_REGEX='/home/user/allowed/.*'

else
    # your additional bahsbot commands
    # NOTE: command can have @botname attached, you must add * in case tests... 
    mycommands() {

	case "$MESSAGE" in
		'/echo'*) # example echo command
			send_normal_message "${CHAT[ID]}" "$MESSAGE"
			;;
		'/question'*) # start interactive questions
			checkproc 
			if [ "$res" -gt 0 ] ; then
				startproc "example/question"
			else
				send_normal_message "${CHAT[ID]}" "$MESSAGE already running ..."
			fi
			;;

		'/run_notify'*) # start notify background job
			myback="notify"; checkback "$myback"
			if [ "$res" -gt 0 ] ; then
				background "example/notify 60" "$myback" # notify every 60 seconds
			else
				send_normal_message "${CHAT[ID]}" "Background command $myback already running ..."
			fi
			;;
		'/stop_notify'*) # kill notify background job
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

     myinlines() {
	#######################
	# Inline query examples
	# shellcheck disable=SC2128
	case "${iQUERY}" in
		"google "*) # search in google images
			local search="${iQUERY#* }"
			answer_inline_multi "${iQUERY[ID]}" "$(my_image_search "${search}")"
			;;
		"photo")
			answer_inline_multi "${iQUERY[ID]}" "
			    $(inline_query_compose "$RANDOM" "photo" "https://avatars0.githubusercontent.com/u/13046303"), 
			    $(inline_query_compose "$RANDOM" "photo" "https://avatars1.githubusercontent.com/u/4593242")
			    "
			;;

		"sticker")
			answer_inline_query "${iQUERY[ID]}" "cached_sticker" "BQADBAAD_QEAAiSFLwABWSYyiuj-g4AC"
			;;
		"gif")
			answer_inline_query "${iQUERY[ID]}" "cached_gif" "BQADBAADIwYAAmwsDAABlIia56QGP0YC"
			;;
		"web")
			answer_inline_query "${iQUERY[ID]}" "article" "GitHub" "http://github.com/topkecleon/telegram-bot-bash"
			;;
	esac
     }

    # place your processing functions here

    # $1 search parameter
    my_image_search(){
	local image result
	result="$(wget --user-agent 'Mozilla/5.0' -qO - "https://www.google.com/search?q=$1&tbm=isch" |  sed 's/</\n</g' | grep '<img')"

	while read -r image; do
		image="${image#* src=\"}"; image="${image%%\" width=\"*}"
		echo "$(inline_query_compose "$RANDOM" "photo" "${image}"),"
	done <<<"${result}"
    }

fi
