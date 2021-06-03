#!/bin/bash
##################################################################
#
# File: processUpdates.sh 
# Note: DO NOT EDIT! this file will be overwritten on update
#
#### $$VERSION$$ v1.51-0-g6e66a28
##################################################################

##############
# manage webhooks

# $1 URL to sed updates to: https://host.dom[:port][/path], port and path are optional
#      port must be 443, 80, 88 8443, TOKEN will be added to URL for security
#      e.g. https://myhost.com -> https://myhost.com/12345678:azndfhbgdfbbbdsfg
# $2 max connections 1-100 default 1 (because of bash ;-)
set_webhook() {
	local  url='"url": "'"$1/${BOTTOKEN}/"'"'
	local  max=',"max_connections": 1'
	[[ "$2" =~ ^[0-9]+$ ]] && max=',"max_connections": '"$2"''
	# shellcheck disable=SC2153
	sendJson "" "${url}${max}" "${URL}/setWebhook"
	unset "BOTSENT[ID]" "BOTSENT[CHAT]"

}

get_webhook_info() {
	sendJson "" "" "${URL}/getWebhookInfo"
	if [ "${BOTSENT[OK]}" = "true" ]; then
		BOTSENT[URL]="${UPD[result,url]}"
		BOTSENT[COUNT]="${UPD[result,pending_update_count]}"
		BOTSENT[CERT]="${UPD[result,has_custom_certificate]}"
		BOTSENT[LASTERR]="${UPD[result,last_error_message]}"
		unset "BOTSENT[ID]" "BOTSENT[CHAT]"
	fi
}

# $1 drop pending updates true/false, default false
delete_webhook() {
	local drop; [ "$1" = "true" ] && drop='"drop_pending_updates": true'
	sendJson "" "${drop}" "${URL}/deleteWebhook"
	unset "BOTSENT[ID]" "BOTSENT[CHAT]"
}

################
# processing of array of updates starts here
process_multi_updates() {
	local max num debug="$1"
	# get num array elements
	max="$(grep -F ',"update_id"]'  <<< "${UPDATE}" | tail -1 | cut -d , -f 2 )"
	# escape bash $ expansion bug
	UPDATE="${UPDATE//$/\\$}"
	# convert updates to bash array
	Json2Array 'UPD' <<<"${UPDATE}"
	# iterate over array
	for ((num=0; num<=max; num++)); do
		process_update "${num}" "${debug}"
	done
}

################
# processing of a single array item of update
# $1 array index
process_update() {
	local chatuser="Chat" num="$1" debug="$2" 
	pre_process_message "${num}"
	# log message on debug
	[[ -n "${debug}" ]] && log_message "New Message ==========\n$(grep -F '["result",'"${num}" <<<"${UPDATE}")"

	# check for users / groups to ignore, inform them ...
	jssh_updateArray_async "BASHBOTBLOCKED" "${BLOCKEDFILE}"
	if [ -n "${USER[ID]}" ] && [[ -n "${BASHBOTBLOCKED[${USER[ID]}]}" || -n "${BASHBOTBLOCKED[${CHAT[ID]}]}" ]];then
		[  -n "${BASHBOTBLOCKED[${USER[ID]}]}" ] && chatuser="User"
		[ "${NOTIFY_BLOCKED_USERS}" == "yes" ] &&\
			send_normal_message "${CHAT[ID]}" "${chatuser} blocked because: ${BASHBOTBLOCKED[${USER[ID]}]} ${BASHBOTBLOCKED[${CHAT[ID]}]}" &
		return
	fi

	# process per message type
	if [ -n "${iQUERY[ID]}" ]; then
		process_inline_query "${num}" "${debug}"
	        printf "%(%c)T: Inline Query update received FROM=%s iQUERY=%s\n" -1\
			"${iQUERY[USERNAME]:0:20} (${iQUERY[USER_ID]})" "${iQUERY[0]}" >>"${UPDATELOG}"
	elif [ -n "${iBUTTON[ID]}" ]; then
		process_inline_button "${num}" "${debug}"
	        printf "%(%c)T: Inline Button update received FROM=%s CHAT=%s CALLBACK=%s DATA:%s \n" -1\
			"${iBUTTON[USERNAME]:0:20} (${iBUTTON[USER_ID]})" "${iBUTTON[CHAT_ID]}" "${iBUTTON[ID]}" "${iBUTTON[DATA]}" >>"${UPDATELOG}"
	else
		if grep -qs -e '\["result",'"${num}"',"edited_message"' <<<"${UPDATE}"; then
			# edited message
			UPDATE="${UPDATE//,${num},\"edited_message\",/,${num},\"message\",}"
			Json2Array 'UPD' <<<"${UPDATE}"
			MESSAGE[0]="/_edited_message "
		fi
		process_message "${num}" "${debug}"
	        printf "%(%c)T: update received FROM=%s CHAT=%s CMD=%s\n" -1 "${USER[USERNAME]:0:20} (${USER[ID]})"\
			"${CHAT[USERNAME]:0:20}${CHAT[TITLE]:0:30} (${CHAT[ID]})"\
			"${MESSAGE:0:30}${CAPTION:0:30}${URLS[*]}" >>"${UPDATELOG}"
		if [[ -z "${USER[ID]}" || -z "${CHAT[ID]}" ]]; then
			printf "%(%c)T: IGNORE unknown update type: %s\n" -1 "$(grep '\["result",'"${num}"'.*,"id"\]' <<<"${UPDATE}")" >>"${UPDATELOG}"
			return 1
		fi
	fi
	#####
	# process inline and message events
	# first classic command dispatcher
	# shellcheck disable=SC2153,SC1090
	{ source "${COMMANDS}" "${debug}"; } &

	# then all registered addons
	if [ -z "${iQUERY[ID]}" ]; then
		event_message "${debug}"
	else
		event_inline "${debug}"
	fi

	# last count users
	jssh_countKeyDB_async "${CHAT[ID]}" "${COUNTFILE}"
}

pre_process_message(){
	local num="$1"
	# unset everything to not have old values
	CMD=( ); iQUERY=( ); iBUTTON=(); MESSAGE=(); CHAT=(); USER=(); CONTACT=(); LOCATION=(); unset CAPTION
	REPLYTO=( ); FORWARD=( ); URLS=(); VENUE=( ); SERVICE=( ); NEWMEMBER=( ); LEFTMEMBER=( ); PINNED=( ); MIGRATE=( )
	iQUERY[ID]="${UPD["result,${num},inline_query,id"]}"
	iBUTTON[ID]="${UPD["result,${num},callback_query,id"]}"
	CHAT[ID]="${UPD["result,${num},message,chat,id"]}"
	USER[ID]="${UPD["result,${num},message,from,id"]}"
	[ -z "${CHAT[ID]}" ] && CHAT[ID]="${UPD["result,${num},edited_message,chat,id"]}"
	[ -z "${USER[ID]}" ] && USER[ID]="${UPD["result,${num},edited_message,from,id"]}"
	# always true
	return 0
}

process_inline_query() {
	local num="$1"
	iQUERY[0]="$(JsonDecode "${UPD["result,${num},inline_query,query"]}")"
	iQUERY[USER_ID]="${UPD["result,${num},inline_query,from,id"]}"
	iQUERY[FIRST_NAME]="$(JsonDecode "${UPD["result,${num},inline_query,from,first_name"]}")"
	iQUERY[LAST_NAME]="$(JsonDecode "${UPD["result,${num},inline_query,from,last_name"]}")"
	iQUERY[USERNAME]="$(JsonDecode "${UPD["result,${num},inline_query,from,username"]}")"
	# always true
	return 0
}

process_inline_button() {
	local num="$1"
	iBUTTON[DATA]="${UPD["result,${num},callback_query,data"]}"
	iBUTTON[CHAT_ID]="${UPD["result,${num},callback_query,message,chat,id"]}"
	iBUTTON[MESSAGE_ID]="${UPD["result,${num},callback_query,message,message_id"]}"
	iBUTTON[MESSAGE]="$(JsonDecode "${UPD["result,${num},callback_query,message,text"]}")"
# XXX should we give back pressed button, all buttons or nothing?
	iBUTTON[USER_ID]="${UPD["result,${num},callback_query,from,id"]}"
	iBUTTON[FIRST_NAME]="$(JsonDecode "${UPD["result,${num},callback_query,from,first_name"]}")"
	iBUTTON[LAST_NAME]="$(JsonDecode "${UPD["result,${num},callback_query,from,last_name"]}")"
	iBUTTON[USERNAME]="$(JsonDecode "${UPD["result,${num},callback_query,from,username"]}")"
	# always true
	return 0
}

process_message() {
	local num="$1"
	# Message
	MESSAGE[0]+="$(JsonDecode "${UPD["result,${num},message,text"]}" | sed 's|\\/|/|g')"
	MESSAGE[ID]="${UPD["result,${num},message,message_id"]}"
	MESSAGE[CAPTION]="$(JsonDecode "${UPD["result,${num},message,caption"]}")"
	CAPTION="${MESSAGE[CAPTION]}"	# backward compatibility 
	# dice received
	MESSAGE[DICE]="${UPD["result,${num},message,dice,emoji"]}"
	if [ -n "${MESSAGE[DICE]}" ]; then
		MESSAGE[RESULT]="${UPD["result,${num},message,dice,value"]}"
		MESSAGE[0]="/_dice_received ${MESSAGE[DICE]} ${MESSAGE[RESULT]}"
	fi
	# Chat ID is now parsed when update is received
	CHAT[LAST_NAME]="$(JsonDecode "${UPD["result,${num},message,chat,last_name"]}")"
	CHAT[FIRST_NAME]="$(JsonDecode "${UPD["result,${num},message,chat,first_name"]}")"
	CHAT[USERNAME]="$(JsonDecode "${UPD["result,${num},message,chat,username"]}")"
	# set real name as username if empty
	[ -z "${CHAT[USERNAME]}" ] && CHAT[USERNAME]="${CHAT[FIRST_NAME]} ${CHAT[LAST_NAME]}"
	CHAT[TITLE]="$(JsonDecode "${UPD["result,${num},message,chat,title"]}")"
	CHAT[TYPE]="$(JsonDecode "${UPD["result,${num},message,chat,type"]}")"
	CHAT[ALL_ADMIN]="${UPD["result,${num},message,chat,all_members_are_administrators"]}"

	# user ID is now parsed when update is received
	USER[FIRST_NAME]="$(JsonDecode "${UPD["result,${num},message,from,first_name"]}")"
	USER[LAST_NAME]="$(JsonDecode "${UPD["result,${num},message,from,last_name"]}")"
	USER[USERNAME]="$(JsonDecode "${UPD["result,${num},message,from,username"]}")"
	# set real name as username if empty
	[ -z "${USER[USERNAME]}" ] && USER[USERNAME]="${USER[FIRST_NAME]} ${USER[LAST_NAME]}"

	# in reply to message from
	if [ -n "${UPD["result,${num},message,reply_to_message,from,id"]}" ]; then
	   REPLYTO[UID]="${UPD["result,${num},message,reply_to_message,from,id"]}"
	   REPLYTO[0]="$(JsonDecode "${UPD["result,${num},message,reply_to_message,text"]}")"
	   REPLYTO[ID]="${UPD["result,${num},message,reply_to_message,message_id"]}"
	   REPLYTO[FIRST_NAME]="$(JsonDecode "${UPD["result,${num},message,reply_to_message,from,first_name"]}")"
	   REPLYTO[LAST_NAME]="$(JsonDecode "${UPD["result,${num},message,reply_to_message,from,last_name"]}")"
	   REPLYTO[USERNAME]="$(JsonDecode "${UPD["result,${num},message,reply_to_message,from,username"]}")"
	fi

	# forwarded message from
	if [ -n "${UPD["result,${num},message,forward_from,id"]}" ]; then
	   FORWARD[UID]="${UPD["result,${num},message,forward_from,id"]}"
	   FORWARD[ID]="${MESSAGE[ID]}"	# same as message ID
	   FORWARD[FIRST_NAME]="$(JsonDecode "${UPD["result,${num},message,forward_from,first_name"]}")"
	   FORWARD[LAST_NAME]="$(JsonDecode "${UPD["result,${num},message,forward_from,last_name"]}")"
	   FORWARD[USERNAME]="$(JsonDecode "${UPD["result,${num},message,forward_from,username"]}")"
	fi

	# get file URL from telegram, check for any of them!
	if grep -qs -e '\["result",'"${num}"',"message","[avpsd].*,"file_id"\]' <<<"${UPDATE}"; then
	    URLS[AUDIO]="$(get_file "${UPD["result,${num},message,audio,file_id"]}")"
	    URLS[DOCUMENT]="$(get_file "${UPD["result,${num},message,document,file_id"]}")"
	    URLS[PHOTO]="$(get_file "${UPD["result,${num},message,photo,0,file_id"]}")"
	    URLS[STICKER]="$(get_file "${UPD["result,${num},message,sticker,file_id"]}")"
	    URLS[VIDEO]="$(get_file "${UPD["result,${num},message,video,file_id"]}")"
	    URLS[VOICE]="$(get_file "${UPD["result,${num},message,voice,file_id"]}")"
	fi
	# Contact, must have phone_number
	if [ -n "${UPD["result,${num},message,contact,phone_number"]}" ]; then
		CONTACT[USER_ID]="$(JsonDecode  "${UPD["result,${num},message,contact,user_id"]}")"
		CONTACT[FIRST_NAME]="$(JsonDecode "${UPD["result,${num},message,contact,first_name"]}")"
		CONTACT[LAST_NAME]="$(JsonDecode "${UPD["result,${num},message,contact,last_name"]}")"
		CONTACT[NUMBER]="${UPD["result,${num},message,contact,phone_number"]}"
		CONTACT[VCARD]="${UPD["result,${num},message,contact,vcard"]}"
	fi

	# venue, must have a position
	if [ -n "${UPD["result,${num},message,venue,location,longitude"]}" ]; then
		VENUE[TITLE]="$(JsonDecode "${UPD["result,${num},message,venue,title"]}")"
		VENUE[ADDRESS]="$(JsonDecode "${UPD["result,${num},message,venue,address"]}")"
		VENUE[LONGITUDE]="${UPD["result,${num},message,venue,location,longitude"]}"
		VENUE[LATITUDE]="${UPD["result,${num},message,venue,location,latitude"]}"
		VENUE[FOURSQUARE]="${UPD["result,${num},message,venue,foursquare_id"]}"
	fi

	# Location
	LOCATION[LONGITUDE]="${UPD["result,${num},message,location,longitude"]}"
	LOCATION[LATITUDE]="${UPD["result,${num},message,location,latitude"]}"

	# service messages, group or channel only!
	if [[ "${CHAT[ID]}" == "-"* ]] ; then
	    # new chat member
	    if [ -n "${UPD["result,${num},message,new_chat_member,id"]}" ]; then
		SERVICE[NEWMEMBER]="${UPD["result,${num},message,new_chat_member,id"]}"
		NEWMEMBER[ID]="${SERVICE[NEWMEMBER]}"
		NEWMEMBER[FIRST_NAME]="$(JsonDecode "${UPD["result,${num},message,new_chat_member,first_name"]}")"
		NEWMEMBER[LAST_NAME]="$(JsonDecode "${UPD["result,${num},message,new_chat_member,last_name"]}")"
		NEWMEMBER[USERNAME]="$(JsonDecode "${UPD["result,${num},message,new_chat_member,username"]}")"
		NEWMEMBER[ISBOT]="${UPD["result,${num},message,new_chat_member,is_bot"]}"
		MESSAGE[0]="/_new_chat_member ${NEWMEMBER[ID]} ${NEWMEMBER[USERNAME]:=${NEWMEMBER[FIRST_NAME]} ${NEWMEMBER[LAST_NAME]}}"
	    fi
	    # left chat member
	    if [ -n "${UPD["result,${num},message,left_chat_member,id"]}" ]; then
		SERVICE[LEFTMEMBER]="${UPD["result,${num},message,left_chat_member,id"]}"
		LEFTMEMBER[ID]="${SERVICE[LEFTMEBER]}"
		LEFTMEMBER[FIRST_NAME]="$(JsonDecode "${UPD["result,${num},message,left_chat_member,first_name"]}")"
		LEFTMEMBER[LAST_NAME]="$(JsonDecode "${UPD["result,${num},message,left_chat_member,last_name"]}")"
		LEFTMEBER[USERNAME]="$(JsonDecode "${UPD["result,${num},message,left_chat_member,username"]}")"
		LEFTMEMBER[ISBOT]="${UPD["result,${num},message,left_chat_member,is_bot"]}"
		MESSAGE[0]="/_left_chat_member ${LEFTMEMBER[ID]} ${LEFTMEMBER[USERNAME]:=${LEFTMEMBER[FIRST_NAME]} ${LEFTMEMBER[LAST_NAME]}}"
	    fi
	    # chat title / photo, check for any of them!
	    if grep -qs -e '\["result",'"${num}"',"message","new_chat_[tp]' <<<"${UPDATE}"; then
		SERVICE[NEWTITLE]="$(JsonDecode "${UPD["result,${num},message,new_chat_title"]}")"
		[ -n "${SERVICE[NEWTITLE]}" ] &&\
			MESSAGE[0]="/_new_chat_title ${USER[ID]} ${SERVICE[NEWTITLE]}"
		SERVICE[NEWPHOTO]="$(get_file "${UPD["result,${num},message,new_chat_photo,0,file_id"]}")"
		[ -n "${SERVICE[NEWPHOTO]}" ] &&\
			 MESSAGE[0]="/_new_chat_photo ${USER[ID]} ${SERVICE[NEWPHOTO]}"
	    fi
	    # pinned message
	    if [ -n "${UPD["result,${num},message,pinned_message,message_id"]}" ]; then
		SERVICE[PINNED]="${UPD["result,${num},message,pinned_message,message_id"]}"
		PINNED[ID]="${SERVICE[PINNED]}"
		PINNED[MESSAGE]="$(JsonDecode "${UPD["result,${num},message,pinned_message,text"]}")"
		MESSAGE[0]="/_new_pinned_message ${USER[ID]} ${PINNED[ID]} ${PINNED[MESSAGE]}"
	    fi
	    # migrate to super group
	    if [ -n "${UPD["result,${num},message,migrate_to_chat_id"]}" ]; then
		MIGRATE[TO]="${UPD["result,${num},message,migrate_to_chat_id"]}"
		MIGRATE[FROM]="${UPD["result,${num},message,migrate_from_chat_id"]}"
		# CHAT is already migrated, so set new chat id
		[ "${CHAT[ID]}" = "${MIGRATE[FROM]}" ] && CHAT[ID]="${MIGRATE[FROM]}"
		SERVICE[MIGRATE]="${MIGRATE[FROM]} ${MIGRATE[TO]}"
		MESSAGE[0]="/_migrate_group ${SERVICE[MIGRATE]}"
	    fi
	    # set SERVICE to yes if a service message was received
	    [[ "${SERVICE[*]}" =~  ^[[:blank:]]*$ ]] || SERVICE[0]="yes"
	fi

	# split message in command and args
	[[ "${MESSAGE[0]}" == "/"* ]] && read -r CMD <<<"${MESSAGE[0]}" &&  CMD[0]="${CMD[0]%%@*}"
	# everything went well
	return 0
}

#########################
# bot startup actions, call before start polling or webhook loop
declare -A BASHBOTBLOCKED
start_bot() {
	local DEBUGMSG
	# startup message
	DEBUGMSG="BASHBOT startup actions, mode set to \"${1:-normal}\" =========="
	log_update "${DEBUGMSG}"
	# redirect to Debug.log
	if [[ "$1" == *"debug" ]]; then
		# shellcheck disable=SC2153
		exec &>>"${DEBUGLOG}"
		log_debug "${DEBUGMSG}";
	fi
	DEBUGMSG="$1"
	[[ "${DEBUGMSG}" == "xdebug"* ]] && set -x
	# cleaup old pipes and empty logfiles
	find "${DATADIR}" -type p -not -name "webhook-fifo-*" -delete
	find "${DATADIR}" -size 0 -name "*.log" -delete
	# load addons on startup
	for addons in "${ADDONDIR:-.}"/*.sh ; do
		# shellcheck disable=SC1090
		[ -r "${addons}" ] && source "${addons}" "startbot" "${DEBUGMSG}"
	done
	# shellcheck disable=SC1090
	source "${COMMANDS}" "startbot"
	# start timer events
	if [ -n "${BASHBOT_START_TIMER}" ] ; then
		# shellcheck disable=SC2064
		trap "event_timer ${DEBUGMSG}" ALRM
		start_timer &
		# shellcheck disable=SC2064
		trap "kill -9 $!; exit" EXIT INT HUP TERM QUIT 
	fi
	# cleanup on start
	bot_cleanup "startup"
	# read blocked users
	jssh_readDB_async "BASHBOTBLOCKED" "${BLOCKEDFILE}"
	# inform botadmin about start
	send_normal_message "$(getConfigKey "botadmin")" "Bot ${ME} $2 started ..." &
}

# main polling updates loop, should never terminate
get_updates(){
	local errsleep="200" DEBUG="$1" OFFSET=0
	# adaptive sleep defaults
	local nextsleep="100"
	local stepsleep="${BASHBOT_SLEEP_STEP:-100}"
	local maxsleep="${BASHBOT_SLEEP:-5000}"
	printf "%(%c)T: %b\n" -1 "Bot startup actions done, start polling updates ..."
	while true; do
		# adaptive sleep in ms rounded to next 0.1 s
		sleep "$(_round_float "${nextsleep}e-3" "1")"
		# get next update
		# shellcheck disable=SC2153
		UPDATE="$(getJson "${URL}/getUpdates?offset=${OFFSET}" 2>/dev/null | "${JSONSHFILE}" -b -n 2>/dev/null | iconv -f utf-8 -t utf-8 -c)"
		# did we get an response?
		if [ -n "${UPDATE}" ]; then
			# we got something, do processing
			[ "${OFFSET}" = "-999" ] && [ "${nextsleep}" -gt "$((maxsleep*2))" ] &&\
				log_error "Recovered from timeout/broken/no connection, continue with telegram updates"
			# calculate next sleep interval
			((nextsleep+= stepsleep , nextsleep= nextsleep>maxsleep ?maxsleep:nextsleep))
			# warn if webhook is set
			if grep -q '^\["error_code"\]	409' <<<"${UPDATE}"; then
				[ "${OFFSET}" != "-999" ] && nextsleep="${stepsleep}"
				OFFSET="-999"; errsleep="$(_round_float "$(( errsleep= 300*nextsleep ))e-3")"
				log_error "Warning conflicting webhook set, can't get updates until your run delete_webhook! Sleep $((errsleep/60)) min ..."
				sleep "${errsleep}"
				continue
			fi
			# Offset
			OFFSET="$(grep <<<"${UPDATE}" '\["result",[0-9]*,"update_id"\]' | tail -1 | cut -f 2)"
			((OFFSET++))

			if [ "${OFFSET}" != "1" ]; then
				nextsleep="100"
				process_multi_updates "${DEBUG}"
			fi
		else
			# oops, something bad happened, wait maxsleep*10
			(( nextsleep=nextsleep*2 , nextsleep= nextsleep>maxsleep*10 ?maxsleep*10:nextsleep ))
			# second time, report problem
			if [ "${OFFSET}" = "-999" ]; then
			    log_error "Repeated timeout/broken/no connection on telegram update, sleep $(_round_float "${nextsleep}e-3")s"
			    # try to recover
			    if _is_function bashbotBlockRecover && [ -z "$(getJson "${ME_URL}")" ]; then
				log_error "Try to recover, calling bashbotBlockRecover ..."
				bashbotBlockRecover >>"${ERRORLOG}"
			    fi
			fi
			OFFSET="-999"
		fi
	done
}



declare -Ax BASHBOT_EVENT_INLINE BASHBOT_EVENT_MESSAGE BASHBOT_EVENT_CMD BASHBOT_EVENT_REPLYTO BASHBOT_EVENT_FORWARD BASHBOT_EVENT_SEND
declare -Ax BASHBOT_EVENT_CONTACT BASHBOT_EVENT_LOCATION BASHBOT_EVENT_FILE BASHBOT_EVENT_TEXT BASHBOT_EVENT_TIMER BASHBOT_BLOCKED

start_timer(){
	# send alarm every ~60 s
	while :; do
		sleep 59.5
    		kill -ALRM $$
	done;
}

EVENT_TIMER="0"
event_timer() {
	local key timer debug="$1"
	(( EVENT_TIMER++ ))
	# shellcheck disable=SC2153
	for key in "${!BASHBOT_EVENT_TIMER[@]}"
	do
		timer="${key##*,}"
		[[ ! "${timer}" =~ ^-*[1-9][0-9]*$ ]] && continue
		if [ "$(( EVENT_TIMER % timer ))" = "0" ]; then
			_exec_if_function "${BASHBOT_EVENT_TIMER[${key}]}" "timer" "${key}" "${debug}"
			[ "$(( EVENT_TIMER % timer ))" -lt "0" ] && \
				unset BASHBOT_EVENT_TIMER["${key}"]
		fi
	done
}

event_inline() {
	local key debug="$1"
	# shellcheck disable=SC2153
	for key in "${!BASHBOT_EVENT_INLINE[@]}"
	do
		_exec_if_function "${BASHBOT_EVENT_INLINE[${key}]}" "inline" "${key}" "${debug}"
	done
}
event_message() {
	local key debug="$1"
	# ${MESSAEG[*]} event_message
	# shellcheck disable=SC2153
	for key in "${!BASHBOT_EVENT_MESSAGE[@]}"
	do
		 _exec_if_function "${BASHBOT_EVENT_MESSAGE[${key}]}" "message" "${key}" "${debug}"
	done
	
	# ${TEXT[*]} event_text
	if [ -n "${MESSAGE[0]}" ]; then
		# shellcheck disable=SC2153
		for key in "${!BASHBOT_EVENT_TEXT[@]}"
		do
			_exec_if_function "${BASHBOT_EVENT_TEXT[${key}]}" "text" "${key}" "${debug}"
		done

		# ${CMD[*]} event_cmd
		if [ -n "${CMD[0]}" ]; then
			# shellcheck disable=SC2153
			for key in "${!BASHBOT_EVENT_CMD[@]}"
			do
				_exec_if_function "${BASHBOT_EVENT_CMD[${key}]}" "command" "${key}" "${debug}"
			done
		fi
	fi
	# ${REPLYTO[*]} event_replyto
	if [ -n "${REPLYTO[UID]}" ]; then
		# shellcheck disable=SC2153
		for key in "${!BASHBOT_EVENT_REPLYTO[@]}"
		do
			_exec_if_function "${BASHBOT_EVENT_REPLYTO[${key}]}" "replyto" "${key}" "${debug}"
		done
	fi

	# ${FORWARD[*]} event_forward
	if [ -n "${FORWARD[UID]}" ]; then
		# shellcheck disable=SC2153
		for key in "${!BASHBOT_EVENT_FORWARD[@]}"
		do
			 _exec_if_function && "${BASHBOT_EVENT_FORWARD[${key}]}" "forward" "${key}" "${debug}"
		done
	fi

	# ${CONTACT[*]} event_contact
	if [ -n "${CONTACT[FIRST_NAME]}" ]; then
		# shellcheck disable=SC2153
		for key in "${!BASHBOT_EVENT_CONTACT[@]}"
		do
			_exec_if_function "${BASHBOT_EVENT_CONTACT[${key}]}" "contact" "${key}" "${debug}"
		done
	fi

	# ${VENUE[*]} event_location
	# ${LOCATION[*]} event_location
	if [ -n "${LOCATION[LONGITUDE]}" ] || [ -n "${VENUE[TITLE]}" ]; then
		# shellcheck disable=SC2153
		for key in "${!BASHBOT_EVENT_LOCATION[@]}"
		do
			_exec_if_function "${BASHBOT_EVENT_LOCATION[${key}]}" "location" "${key}" "${debug}"
		done
	fi

	# ${URLS[*]} event_file
	# NOTE: compare again #URLS -1 blanks!
	if [[ "${URLS[*]}" != "     " ]]; then
		# shellcheck disable=SC2153
		for key in "${!BASHBOT_EVENT_FILE[@]}"
		do
			_exec_if_function "${BASHBOT_EVENT_FILE[${key}]}" "file" "${key}" "${debug}"
		done
	fi

}

