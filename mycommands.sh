#!/bin/bash
# files: mycommands.sh.dist
# copy to mycommands.sh and add all your commands and functions here ...
#
#### $$VERSION$$ v0.72-0-ge899420
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
    INLINE="0"
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
	# Inline query examples, do not use them in production (exept image search ;-)
	# shellcheck disable=SC2128
	case "${iQUERY}" in
		"image "*) # search images with yahoo
			local search="${iQUERY#* }"
			answer_inline_multi "${iQUERY[ID]}" "$(my_image_search "${search}")"
			;;

		"0"*)	# a single message with title
			answer_inline_query "${iQUERY[ID]}" "message" "Title of the result" "Content of the message to be sent"
			;;
		"1"*)	# a single photo
			answer_inline_query "${iQUERY[ID]}" "photo" "https://avatars.githubusercontent.com/u/13046303" "https://avatars.githubusercontent.com/u/13046303" 
			;;
		"2"*)	# two photos
			answer_inline_multi "${iQUERY[ID]}" "
			    $(inline_query_compose "$RANDOM" "photo" "https://avatars.githubusercontent.com/u/13046303"), 
			    $(inline_query_compose "$RANDOM" "photo" "https://avatars.githubusercontent.com/u/4593242")
			    "
			;;
		"3"*) # three photos
			answer_inline_multi "${iQUERY[ID]}" "
			    $(inline_query_compose "$RANDOM" "photo" "https://avatars.githubusercontent.com/u/13046303"), 
			    $(inline_query_compose "$RANDOM" "photo" "https://avatars.githubusercontent.com/u/4593242")
			    $(inline_query_compose "$RANDOM" "photo" "https://avatars.githubusercontent.com/u/102707")
			    "
			;;

		"4") # four photo from array
			local sep=""
			local avatar=("https://avatars.githubusercontent.com/u/13046303" "https://avatars.githubusercontent.com/u/4593242" "https://avatars.githubusercontent.com/u/102707" "https://avatars.githubusercontent.com/u/6460407")
			answer_inline_multi "${iQUERY[ID]}" "
				$(for photo in  ${avatar[*]} ; do
					echo "${sep}"; inline_query_compose "$RANDOM" "photo" "${photo}" "${photo}"; sep=","
				done)
				"
			;;

		"sticker") # example chaecd telegram sticker
			answer_inline_query "${iQUERY[ID]}" "cached_sticker" "BQADBAAD_QEAAiSFLwABWSYyiuj-g4AC"
			;;
		"gif") # exmaple chaehed gif
			answer_inline_query "${iQUERY[ID]}" "cached_gif" "BQADBAADIwYAAmwsDAABlIia56QGP0YC"
			;;
	esac
exit
     }

    # place your processing functions here

    # $1 search parameter
    my_image_search(){
	local image result sep="" count="1"
	result="$(wget --user-agent 'Mozilla/5.0' -qO - "https://images.search.yahoo.com/search/images?p=$1" |  sed 's/</\n</g' | grep "<img src=")"
	while read -r image; do
		[ "$count" -gt "9" ] && break
		image="${image#* src=\'}"; image="${image%%&pid=*}"
		[[ "${image}" = *"src="* ]] && continue
		echo "${sep}"; inline_query_compose "$RANDOM" "photo" "${image}"; sep=","
		count=$(( count + 1 ))
	done <<<"${result}"
    }

fi
