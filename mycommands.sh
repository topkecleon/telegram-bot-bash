#!/bin/bash
#########
#
# files: mycommands.sh.dist
#
# this is an out of the box test and example file to show what you can do in mycommands.sh
#
# #### if you start to develop your own bot, use the clean version of this file:
# #### mycommands.clean
#
#### $$VERSION$$ v0.96-dev-7-g0153928
#

# uncomment the following lines to overwrite info and help messages
# export bashbot_info='This is bashbot, the Telegram bot written entirely in bash.
#'
# export bashbot_help='*Available commands*:
#'
export res=""

# Set INLINE to 1 in order to receive inline queries.
# To enable this option in your bot, send the /setinline command to @BotFather.
export INLINE="0"
# Set to .* to allow sending files from all locations
# NOTE: this is a regex, not shell globbing! you must use a valid egex,
# '.' matches any charater and '.*' matches all remaining charatcers!
# additionally you must escape special charaters with '\', e.g. '\. \? \[ \*" to match them literally  
export FILE_REGEX="${BASHBOT_ETC}/.*"
# example: run bashbot over TOR
# export BASHBOT_CURL_ARGS="--socks5-hostname 127.0.0.1:9050"

# set to "yes" and give your bot admin privilegs to remove service messaes from groups
export SILENCER="no"

# messages for admin only commands
NOTADMIN="Sorry, this command is allowed for admin or owner only"
NOTBOTADMIN="Sorry, this command is allowed for bot owner only"

if [ "$1" = "startbot" ];then
    ###################
    # this function is run once after startup when the first message is recieved
    my_startup(){
	# send message ito first user on startup
	send_normal_message "${CHAT[ID]}" "Hi, you was the first one after startup!"
    }
    # reminde bot that it was started
    touch .mystartup
else
    # here we call the function above when the mesage arrives
    # things to do only at soure, eg. after startup
    [ -f .mystartup ] && rm -f .mystartup && _exec_if_function my_startup

    #############################
    # your own bashbot commands
    # NOTE: command can have @botname attached, you must add * in case tests... 
    mycommands() {

	##############
	# a service Message was recieved
	# add your own stuff here
	if [ -n "${SERVICE}" ]; then

		# example: delete every service message
		if [ "${SILENCER}" = "yes" ]; then
			delete_message "${CHAT[ID]}" "${MESSAGE[ID]}"
		fi
	fi

	# pre-check admin only commands  
	case "${MESSAGE}" in
		# must be private, group admin, or botadmin
		'/run_'*|'stop_'*)
			send_action "${CHAT[ID]}" "typing"
			if ! user_is_admin "${CHAT[ID]}" "${USER[ID]}" ; then
			    send_normal_message "${CHAT[ID]}" "${NOTADMIN}"; return 1
			fi
			# ok, now lets process the real command 
			;;
		# must be botadmin
		'/echo'*) 
			send_action "${CHAT[ID]}" "typing"
			if ! user_is_botadmin "${USER[ID]}" ; then
			    send_markdown_message "${CHAT[ID]}" "*${NOTBOTADMIN}*"; return 1
			fi
			;;
	esac

	case "${MESSAGE}" in
		##################
		# example commands, replace thm by your own
		'/echo'*) # example echo command
			send_normal_message "${CHAT[ID]}" "$MESSAGE"
			;;
		'/question'*) # start interactive questions
			checkproc 
			if [ "$res" -gt 0 ] ; then
				startproc "examples/question.sh" || _message "Can't start question."
			else
				send_normal_message "${CHAT[ID]}" "$MESSAGE already running ..."
			fi
			;;

		'/cancel'*) # cancel interactive command
			checkproc
			if [ "$res" -gt 0 ] ;then killproc && _message "Command canceled.";else _message "No command is currently running.";fi
			;;
		'/run_notify'*) # start notify background job
			myback="notify"; checkback "$myback"
			if [ "$res" -gt 0 ] ; then
				background "examples/notify.sh 60" "$myback" || _message "Can't start notify."
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

		##########
		# command overwrite examples
		'/info'*) # output date in front of regular info
			send_normal_message "${CHAT[ID]}" "$(date)"
			return 0
			;;
		'/kickme'*) # this will replace the /kickme command
			send_markdown_mesage "${CHAT[ID]}" "*This bot will not kick you!*"
			return 1
			;;
	esac
     }

     myinlines() {
	#######################
	# Inline query examples, do not use them in production (exept image search ;-)
	# shellcheck disable=SC2128
	iQUERY="${iQUERY,,}" # all lowercase
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
set +x
     }

    # place your processing functions here

    # $1 search parameter
    my_image_search(){
	local image result sep="" count="1"
	result="$(wget --user-agent 'Mozilla/5.0' -qO - "https://images.search.yahoo.com/search/images?p=$1" |  sed 's/</\n</g' | grep "<img src=")"
	while read -r image; do
		[ "$count" -gt "20" ] && break
		image="${image#* src=\'}"; image="${image%%&pid=*}"
		[[ "${image}" = *"src="* ]] && continue
		echo "${sep}"; inline_query_compose "$RANDOM" "photo" "${image}"; sep=","
		count=$(( count + 1 ))
	done <<<"${result}"
    }

fi
