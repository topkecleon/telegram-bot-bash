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
#### $$VERSION$$ v0.99-dev2-10-g3a658ea
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
# '.' matches any character and '.*' matches all remaining charatcers!
# additionally you must escape special characters with '\', e.g. '\. \? \[ \*" to match them literally  
export FILE_REGEX="${BASHBOT_ETC}/.*"
# example: run bashbot over TOR
# export BASHBOT_CURL_ARGS="--socks5-hostname 127.0.0.1:9050"

# set BASHBOT_RETRY to enable retry in case of recoverable errors, e.g.  throtteling
# problems with send_,´message etc are looged to  logs/ERROR.log 
unset BASHBOT_RETRY
#export BASHBOT_RETRY="yes"

# set value for adaptive sleeping while waitingnfor uodates in millisconds
# max slepp between polling updates 10s (default 5s)
export BASHBOT_SLEEP="10000"
# add 0.2s if no update available, up to BASHBOT_SLEEP (default 0.1s)
export BASHBOT_SLEEP_STEP="200"

# if you want to use timer functions, set BASHBOT_START_TImer to not empty value
# default is to nit start timer
unset BASHBOT_START_TIMER
#export BASHBOT_START_TIMER="yes"

# set to "yes" and give your bot admin privilegs to remove service messaes from groups
export SILENCER="no"

# uncomment if you use keyboards in your commands
# export REMOVEKEYBOARD="yes"
# export REMOVEKEYBOARD_PRIVATE="yes"

# uncomment if you want to say welcome to new chat members
# export WELCOME_NEWMEMBER="yes"
WELCOME_MSG="Welcome"

# uncomment if you want to be informed about new/left chat members
# export REPORT_NEWMEMBER="yes"
# export REPORT_LEFTMEMBER="yes"

# messages for admin only commands
NOTADMIN="Sorry, this command is allowed for admin or owner only"
NOTBOTADMIN="Sorry, this command is allowed for bot owner only"

if [ "$1" = "startbot" ];then
    ###################
    # this function is run once after startup when the first message is received
    my_startup(){
	# send message ito first user on startup
	send_normal_message "${CHAT[ID]}" "Hi, you was the first one after startup!"
    }
    # reminde bot that it was started
    touch .mystartup
else
    # here we call the function above when the message arrives
    # things to do only at source, eg. after startup
    [ -f .mystartup ] && rm -f .mystartup && _exec_if_function my_startup

    #############################
    # your own bashbot commands
    # NOTE: command can have @botname attached, you must add * in case tests... 
    mycommands() {

	##############
	# a service Message was received
	# add your own stuff here
	if [ -n "${SERVICE}" ]; then

		# example: delete every service message
		if [ "${SILENCER}" = "yes" ]; then
			delete_message "${CHAT[ID]}" "${MESSAGE[ID]}"
		fi
	fi

	# remove keyboard if you use keyboards
	[ -n "${REMOVEKEYBOARD}" ] && remove_keyboard "${CHAT[ID]}" &
	[[ -n "${REMOVEKEYBOARD_PRIVATE}" &&  "${CHAT[ID]}" == "${USER[ID]}" ]] && remove_keyboard "${CHAT[ID]}" &

	# example for actions based on chat or sender
	case "${USER[ID]}+${CHAT[ID]}" in
		'USERID+'*) # do something for all messages from USER
			printf "%s: U=%s C=%s M=%s\n" "$(date)" "${USER[ID]}" "${CHAT[ID]}" "${MESSAGE}" >>"${DATADIR}/${USER[ID]}.log"
			;;&
		*'+CHATID') # do something for all messages from CHAT
			printf "%s: U=%s C=%s M=%s\n" "$(date)" "${USER[ID]}" "${CHAT[ID]}" "${MESSAGE}" >>"${DATADIR}/${CHAT[ID]}.log"
			;;&
		'USERID+CHATID') # do something only for messages form USER in CHAT
			printf "%s: U=%s C=%s M=%s\n" "$(date)" "${USER[ID]}" "${CHAT[ID]}" "${MESSAGE}" >>"${DATADIR}/${CHAT[ID]}+${USER[ID]}.log"
			;;&
	esac

	# fix first letter upper case because of smartphone auto correction
	[[ "${MESSAGE}" =~  ^/[[:upper:]] ]] && MESSAGE="${MESSAGE:0:1}$(tr '[:upper:]' '[:lower:]' <<<"${MESSAGE:1:1}")${MESSAGE:2}"
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
		# will we process edited messages also?
		'/_edited_message'*)
			return 1 # no
			# but if we do, remove /edited_message
			MESSAGE="${MESSAGE#/* }"
			;;
		'/_new_chat_member'*)
			if [[ -n "${WELCOME_NEWMEMBER}" && "${NEWMEMBER[ISBOT]}" != "true" ]]; then
			    send_normal_message "${CHAT[ID]}"\
				"${WELCOME_MSG} ${NEWMEMBER[FIRST_NAME]} ${NEWMEMBER[LAST_NAME]} (@${NEWMEMBER[USERNAME]})"
			    MYSENTID="${BOTSENT[ID]}"
			    { sleep 5; delete_message  "${CHAT[ID]}" "${MYSENTID}"; } &
			[ -n "${REPORT_NEWMEMBER}" ] && send_normal_message "$(getConfigKey "botadmin")"\
			    "New member: ${CHAT[TITLE]} (${CHAT[ID]}): ${NEWMEMBER[FIRST_NAME]} ${NEWMEMBER[LAST_NAME]} (@${NEWMEMBER[USERNAME]})"
			fi
			;;
		'/_left_chat_member'*)
			[ -n "${REPORT_LEFTMEMBER}" ] && send_normal_message "$(getConfigKey "botadmin")"\
			    "Left member: ${CHAT[TITLE]} (${CHAT[ID]}): ${NEWMEMBER[FIRST_NAME]} ${NEWMEMBER[LAST_NAME]} (@${NEWMEMBER[USERNAME]})"
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
	# Inline query examples, do not use them in production (except image search ;-)
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
		"gif") # example cached gif
			answer_inline_query "${iQUERY[ID]}" "cached_gif" "BQADBAADIwYAAmwsDAABlIia56QGP0YC"
			;;
	esac
     }

    # debug function called on start, stop of bot, interactive and  background processes
    # if your bot was started with debug as second argument
    # $1 current date, $2 from where the function was called, $3 ... $n optional information
    my_debug_checks() {
	# example check because my bot created a wrong file
	[ -f ".jssh" ] && printf "%s: %s\n" "${1}" "Ups, found file \"${PWD:-.}/.jssh\"! =========="
    }

    # called when bashbot sedn command failed because we can not connect to telegram
    # return 0 to retry, return non 0 to give up
    bashbotBlockRecover() {
	# place your commands to unblock here, e.g. change IP or simply wait
	sleep 60 && return 0 # may be temporary
	return 1 
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
