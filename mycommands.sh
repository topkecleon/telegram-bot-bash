#!/bin/bash
#######################################################
#
#        File: mycommands.sh.dist
#
# this is an out of the box test and example file to show what's possible in mycommands.sh
#
# #### if you start to develop your own bot, use the clean version of this file:
# #### mycommands.clean
#
#       Usage: will be executed when a bot command is received 
#
#     License: WTFPLv2 http://www.wtfpl.net/txt/copying/
#      Author: KayM (gnadelwartz), kay@rrr.de
#
#### $$VERSION$$ v1.51-0-g6e66a28
#######################################################
# shellcheck disable=SC1117

####################
# Config has moved to bashbot.conf
# shellcheck source=./commands.sh
[ -r "${BASHBOT_ETC:-.}/mycommands.conf" ] && source "${BASHBOT_ETC:-.}/mycommands.conf"  "$1"


##################
# let's go ...
if [ "$1" = "startbot" ];then
    ###################
    # this section is processed on startup

    # mark startup, triggers action on first message
    setConfigKey "startupaction" "await"
else

    #############################
    # your own bashbot commands
    # NOTE: command can have @botname attached, you must add * to case tests...
        mycommands() {

	#############
	# action triggered on first message after startup
	if [[ "$(getConfigKey "startupaction")" != "done"* ]]; then
	# send message to first user on startup
	send_normal_message "${CHAT[ID]}" "Hi, you are the first user after startup!"
	# mark as done and when
	setConfigKey "startupaction" "done $(date)"
	fi

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
		'USERID1+'*) # do something for all messages from USER
			printf "%s: U=%s C=%s M=%s\n" "$(date)" "${USER[ID]}" "${CHAT[ID]}" "${MESSAGE}" >>"${DATADIR}/${USER[ID]}.log"
			;;&
		*'+CHATID1') # do something for all messages from CHAT
			printf "%s: U=%s C=%s M=%s\n" "$(date)" "${USER[ID]}" "${CHAT[ID]}" "${MESSAGE}" >>"${DATADIR}/${CHAT[ID]}.log"
			;;&
		'USERID2+CHATID2') # do something only for messages form USER in CHAT
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
			    send_markdownv2_message "${CHAT[ID]}" "*${NOTBOTADMIN}*"; return 1
			fi
			;;
		# will we process edited messages also?
		'/_edited_message'*)
			return 1 # no
			# but if we do, remove /edited_message
			MESSAGE="${MESSAGE#/* }"
			;;
		'/_new_chat_member'*)
			if [[ -n "${WELCOME_NEWMEMBER}" && "${NEWMEMBER[ISBOT]}" != "true" ]] && bot_is_admin "${CHAT[ID]}"; then
			    send_normal_message "${CHAT[ID]}"\
				"${WELCOME_MSG} ${NEWMEMBER[FIRST_NAME]} ${NEWMEMBER[LAST_NAME]} (@${NEWMEMBER[USERNAME]})"
			    MYSENTID="${BOTSENT[ID]}"
			    { sleep 5; delete_message  "${CHAT[ID]}" "${MYSENTID}"; } &
			[ -n "${REPORT_NEWMEMBER}" ] && send_normal_message "${BOTADMIN}"\
			    "New member: ${CHAT[TITLE]} (${CHAT[ID]}): ${NEWMEMBER[FIRST_NAME]} ${NEWMEMBER[LAST_NAME]} (@${NEWMEMBER[USERNAME]})"
			fi
			;;
		'/_left_chat_member'*)
			[ -n "${REPORT_LEFTMEMBER}" ] && send_normal_message "${BOTADMIN}"\
			    "Left member: ${CHAT[TITLE]} (${CHAT[ID]}): ${LEFTMEMBER[FIRST_NAME]} ${LEFTMEMBER[LAST_NAME]} (@${LEFTMEMBER[USERNAME]})"
			;;
		'/_migrate_group'*)
			# call group migration function if provided
			_exec_if_function my_migrate_group "${MIGRATE[FROM]}" "${MIGRATE[TO]}"
			;;
		
	esac

	case "${MESSAGE}" in
		##################
		# example commands, replace them by your own
		'/_dice_re'*) # dice from user received
			sleep 5
			local gameresult="*Congratulation ${USER[FIRST_NAME]} ${USER[LAST_NAME]}* you got *${MESSAGE[RESULT]} Points*."
			[ -z "${FORWARD[UID]}" ] && send_markdownv2_message "${CHAT[ID]}" "${gameresult}"
			;;
		'/game'*) # send random dice, edit list to fit your needs
			send_dice "${CHAT[ID]}" ":$(printf "slot_machine\ngame_die\ndart\nbasketball\nsoccer\nslot_machine"|sort -R|shuf -n 1shuf -n 1):"
			if [ "${BOTSENT[OK]}" = "true" ]; then
				local gameresult="*Congratulation ${USER[FIRST_NAME]}* ${USER[LAST_NAME]} you got *${BOTSENT[RESULT]} Points*."
				sleep 5
				case "${BOTSENT[RESULT]}" in
				  1)	gameresult="*Sorry* only *one Point* ...";;
				  2)	gameresult="*Hey*, 2 Points are *more then one!*";;
				  5|6)	[[ "${BOTSENT[EMOJI]}" =~ fb0$ ]] || gameresult="*Super! ${BOTSENT[RESULT]} Points!*";;
				  6*)	gameresult="*JACKPOT! ${BOTSENT[RESULT]} Points!*";;
				esac
				send_markdownv2_message "${CHAT[ID]}" "${gameresult}"
			fi
			;;
		'/unpin'*) # unpin all messages if (bot)admin or allowed for user
			 user_is_allowed "${USER[ID]}" "unpin" "${CHAT[ID]}" &&\
				unpinall_chat_messages "${CHAT[ID]}"
			;;
		'/echo'*) # example echo command
			send_normal_message "${CHAT[ID]}" "${MESSAGE}"
			;;
		'/button'*)# inline button, set CALLBACK=1 for processing callbacks
			send_inline_buttons "${CHAT[ID]}" "Press Button ..." "   Button   |RANDOM-BUTTON"
			;;
		'/question'*) # start interactive questions
			checkproc 
			if [ "${res}" -gt 0 ] ; then
				startproc "examples/question.sh" || send_normal_message "${CHAT[ID]}" "Can't start question."
			else
				send_normal_message "${CHAT[ID]}" "${MESSAGE} already running ..."
			fi
			;;

		'/cancel'*) # cancel interactive command
			checkproc
			if [ "${res}" -gt 0 ] ;then 
				killproc && send_normal_message "${CHAT[ID]}" "Command canceled."
			else
				send_normal_message "${CHAT[ID]}" "No command is currently running."
			fi
			;;
		'/run_notify'*) # start notify background job
			myback="notify"; checkback "${myback}"
			if [ "${res}" -gt 0 ] ; then
				background "examples/notify.sh 60" "${myback}" || send_normal_message "${CHAT[ID]}" "Can't start notify."
			else
				send_normal_message "${CHAT[ID]}" "Background command ${myback} already running ..."
			fi
			;;
		'/stop_notify'*) # kill notify background job
			myback="notify"; checkback "${myback}"
			if [ "${res}" -eq 0 ] ; then
				killback "${myback}"
				send_normal_message "${CHAT[ID]}" "Background command ${myback} canceled."
			else
				send_normal_message "${CHAT[ID]}" "No background command ${myback} is currently running.."
			fi
			;;

		##########
		# command overwrite examples
		'/info'*) # output date in front of regular info
			send_normal_message "${CHAT[ID]}" "$(date)"
			return 0
			;;
		'/kickme'*) # this will replace the /kickme command
			send_markdownv2_mesage "${CHAT[ID]}" "This bot will *not* kick you!"
			return 1
			;;
	esac
     }

     mycallbacks() {
	#######################
	# callbacks from buttons attached to messages will be  processed here
	# no standard use case for processing callbacks, let's log them for some users and chats
	case "${iBUTTON[USER_ID]}+${iBUTTON[CHAT_ID]}" in
	    'USERID1+'*) # do something for all callbacks from USER
		printf "%s: U=%s C=%s D=%s\n" "$(date)" "${iBUTTON[USER_ID]}" "${iBUTTON[CHAT_ID]}" "${iBUTTON[DATA]}"\
				>>"${DATADIR}/${iBUTTON[USER_ID]}.log"
		answer_callback_query "${iBUTTON[ID]}" "Request has been logged in your user log..."
		return
		;;
	    *'+CHATID1') # do something for all callbacks from CHAT
		printf "%s: U=%s C=%s D=%s\n" "$(date)" "${iBUTTON[USER_ID]}" "${iBUTTON[CHAT_ID]}" "${iBUTTON[DATA]}"\
				>>"${DATADIR}/${iBUTTON[CHAT_ID]}.log"
		answer_callback_query "${iBUTTON[ID]}" "Request has been logged in chat log..."
		return
		;;
	    'USERID2+CHATID2') # do something only for callbacks form USER in CHAT
		printf "%s: U=%s C=%s D=%s\n" "$(date)" "${iBUTTON[USER_ID]}" "${iBUTTON[CHAT_ID]}" "${iBUTTON[DATA]}"\
				>>"${DATADIR}/${iBUTTON[USER_ID]}-${iBUTTON[CHAT_ID]}.log"
		answer_callback_query "${iBUTTON[ID]}" "Request has been logged in user-chat log..."
		return
		;;
	    *)	# all other callbacks are processed here
		local callback_answer
		# your processing here ...
		# message available?
		if [[ -n "${iBUTTON[CHAT_ID]}" && -n "${iBUTTON[MESSAGE_ID]}" ]]; then
			if [ "${iBUTTON[DATA]}" = "RANDOM-BUTTON" ]; then
			    callback_answer="Button pressed"
			    edit_inline_buttons "${iBUTTON[CHAT_ID]}" "${iBUTTON[MESSAGE_ID]}" "Button ${RANDOM}|RANDOM-BUTTON"
			fi
		else
			    callback_answer="Button to old, sorry."
		fi
		# Telegram needs an ack each callback query, default empty
		answer_callback_query "${iBUTTON[ID]}" "${callback_answer}"
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
			    $(inline_query_compose "${RANDOM}" "photo" "https://avatars.githubusercontent.com/u/13046303"), 
			    $(inline_query_compose "${RANDOM}" "photo" "https://avatars.githubusercontent.com/u/4593242")
			    "
			;;
		"3"*) # three photos
			answer_inline_multi "${iQUERY[ID]}" "
			    $(inline_query_compose "${RANDOM}" "photo" "https://avatars.githubusercontent.com/u/13046303"), 
			    $(inline_query_compose "${RANDOM}" "photo" "https://avatars.githubusercontent.com/u/4593242")
			    $(inline_query_compose "${RANDOM}" "photo" "https://avatars.githubusercontent.com/u/102707")
			    "
			;;

		"4") # four photos from array
			local sep=""
			local avatar=("https://avatars.githubusercontent.com/u/13046303" "https://avatars.githubusercontent.com/u/4593242" "https://avatars.githubusercontent.com/u/102707" "https://avatars.githubusercontent.com/u/6460407")
			answer_inline_multi "${iQUERY[ID]}" "
				$(for photo in  ${avatar[*]} ; do
					printf "%s\n" "${sep}"; inline_query_compose "${RANDOM}" "photo" "${photo}" "${photo}"; sep=","
				done)
				"
			;;

		"sticker") # example cached telegram sticker
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
	[ -f ".jssh" ] && printf "%s: %s\n" "$1" "Ups, found file \"${PWD:-.}/.jssh\"! =========="
    }

    ###########################
    # example recover from telegram block function
    # called when bashbot send_xxx command failed because we can not connect to telegram
    # return 0 to retry, return non 0 to give up
    bashbotBlockRecover() {
	# place your commands to unblock here, e.g. change IP or simply wait
	sleep 60 # may be temporary
	# check connection working
	[ -n "$(getJson "${ME_URL}")" ] && return 0
	return 1 
    }

    ###########################
    # example error processing
    # called when delete Message failed
    # func="$1" err="$2" chat="$3" user="$4" emsg="$5" remaining args
    bashbotError_delete_message() {
	log_debug "custom errorProcessing delete_message: ERR=$2 CHAT=$3 MSGID=$6 ERTXT=$5"
    }

    # called when error 403 is returned (and no func processing)
    # func="$1" err="$2" chat="$3" user="$4" emsg="$5" remaining args
    bashbotError_403() {
	log_debug "custom errorProcessing error 403: FUNC=$1 CHAT=$3 USER=${4:-no-user} MSGID=$6 ERTXT=$5"
	local user="$4"; [[ -z "$4" && -n "$3" ]] && user="$3"
	if [ -n "${user}" ]; then
		# block chat/user
		case "$6" in
		    *"blocked"*)
			jssh_insertKeyDB "${user}" "User blocked bot on (LANG=C date)" "${BLOCKEDFILE}";;
		    *"kicked"*)
			jssh_insertKeyDB "${user}" "Bot kicked from chat on (LANG=C date)" "${BLOCKEDFILE}";;
		    *)
			jssh_insertKeyDB "${user}" "Reason: $6 on (LANG=C date)" "${BLOCKEDFILE}";;
		esac
	fi
    }


    ###########################
    # place your processing functions here --------------

    # $1 search parameter
    my_image_search(){
	local image result sep="" count="1"
	result="$(wget --user-agent 'Mozilla/5.0' -qO - "https://images.search.yahoo.com/search/images?p=$1" |  sed 's/</\n</g' | grep "<img src=")"
	while read -r image; do
		[ "${count}" -gt "20" ] && break
		image="${image#* src=\'}"; image="${image%%&pid=*}"
		[[ "${image}" = *"src="* ]] && continue
		printf "%s\n" "${sep}"; inline_query_compose "${RANDOM}" "photo" "${image}"; sep=","
		count=$(( count + 1 ))
	done <<<"${result}"
    }

fi

