#!/bin/bash
# file: modules/message.sh
# do not edit, this file will be overwritten on update

# This file is public domain in the USA and all free countries.
# Elsewhere, consider it to be WTFPLv2. (wtfpl.net/txt/copying)
#
# shellcheck disable=SC1117
#### $$VERSION$$ v1.2-0-gc50499c

# will be automatically sourced from bashbot

# source once magic, function named like file
eval "$(basename "${BASH_SOURCE[0]}")(){ :; }"

# source from commands.sh to use the sendMessage functions

MSG_URL=$URL'/sendMessage'
PHO_URL=$URL'/sendPhoto'
AUDIO_URL=$URL'/sendAudio'
DOCUMENT_URL=$URL'/sendDocument'
STICKER_URL=$URL'/sendSticker'
VIDEO_URL=$URL'/sendVideo'
VOICE_URL=$URL'/sendVoice'
LOCATION_URL=$URL'/sendLocation'
VENUE_URL=$URL'/sendVenue'
ACTION_URL=$URL'/sendChatAction'
FORWARD_URL=$URL'/forwardMessage'
ALBUM_URL=$URL'/sendMediaGroup'

# $1 CHAT $2 message
send_normal_message() {
	local len text; text="$(JsonEscape "${2}")"
	text="${text//$'\n'/\\n}"
	until [ -z "${text}" ]; do
		if [ "${#text}" -le 4096 ]; then
			sendJson "${1}" '"text":"'"${text}"'"' "${MSG_URL}"
			break
		else
			len=4095
			[ "${text:4095:2}" != "\n" ] &&\
				len="${text:0:4096}" && len="${len%\\n*}" && len="${#len}"
			sendJson "${1}" '"text":"'"${text:0:${len}}"'"' "${MSG_URL}"
			text="${text:$((len+2))}"
		fi
	done
}

# $1 CHAT $2 message
send_markdown_message() {
	local text; text="$(JsonEscape "${2}")"
	text="${text//$'\n'/\\n}"
	[ "${#text}" -ge 4096 ] && log_error "Warning: markdown message longer than 4096 characters, message is rejected if formatting crosses 4096 border."
	until [ -z "${text}" ]; do
		sendJson "${1}" '"text":"'"${text:0:4096}"'","parse_mode":"markdown"' "${MSG_URL}"
		text="${text:4096}"
	done
}

# $1 CHAT $2 message
send_markdownv2_message() {
	local text; text="$(JsonEscape "${2}")"
	text="${text//$'\n'/\\n}"
	[ "${#text}" -ge 4096 ] && log_error "Warning: markdown message longer than 4096 characters, message is rejected if formatting crosses 4096 border."
	# markdown v2 needs additional double escaping!
	text="$(sed -E -e 's|([#{}()!.-])|\\\1|g' <<< "$text")"
	until [ -z "${text}" ]; do
		sendJson "${1}" '"text":"'"${text:0:4096}"'","parse_mode":"markdownv2"' "${MSG_URL}"
		text="${text:4096}"
	done
}

# $1 CHAT $2 message
send_html_message() {
	local text; text="$(JsonEscape "${2}")"
	text="${text//$'\n'/\\n}"
	[ "${#text}" -ge 4096 ] && log_error "Warning: html message longer than 4096 characters, message is rejected if formatting crosses 4096 border."
	until [ -z "${text}" ]; do
		sendJson "${1}" '"text":"'"${text:0:4096}"'","parse_mode":"html"' "${MSG_URL}"
		text="${text:4096}"
	done
}

# obsolote, will be removed after 1.0!!
# $1 CHAT $2 message $3 keyboard
old_send_keyboard() {
	local text; text='"text":"'$(JsonEscape "${2}")'"'
	shift 2
	local keyboard="init"
	OLDIFS="$IFS"
	IFS="\""
	for f in "$@" ;do [ "$f" != " " ] && keyboard="$keyboard, [\"$f\"]";done
	IFS="$OLDIFS"
	keyboard="${keyboard/init, /}"
	sendJson "${1}" "${text}"', "reply_markup": {"keyboard": [ '"${keyboard}"' ],"one_time_keyboard": true}' "$MSG_URL"
	send_normal_message "$(getConfigKey "botadmin")" "Warning: old 'send_keyboard' format is deprecated since version 0.6 and will be removed after 1.0 release!"
}

# $1 CHAT $2 message $3 keyboard
send_keyboard() {
	if [[ "$3" != *'['* ]]; then old_send_keyboard "${@}"; return; fi
	local text='"text":"'"Keyboard:"'"'
	if [ -n "${2}" ]; then
		text="$(JsonEscape "${2}")"
		text='"text":"'"${text//$'\n'/\\n}"'"'
	fi
	local one_time=', "one_time_keyboard":true' && [ -n "$4" ] && one_time=""
	sendJson "${1}" "${text}"', "reply_markup": {"keyboard": [ '"${3}"' ] '"${one_time}"'}' "$MSG_URL"
	# '"text":"$2", "reply_markup": {"keyboard": [ ${3} ], "one_time_keyboard": true}'
}

# $1 CHAT $2 message $3 remove
remove_keyboard() {
	local text='"text":"'"remove custom keyboard ..."'"'
	if [ -n "${2}" ]; then
		text="$(JsonEscape "${2}")"
		text='"text":"'"${text//$'\n'/\\n}"'"'
	fi
	sendJson "${1}" "${text}"', "reply_markup": {"remove_keyboard":true}' "$MSG_URL"
	# delete message if no message or $3 not empty
	[[ -z "${2}" || -n "${3}" ]] && delete_message "${1}" "${BOTSENT[ID]}" "nolog"
	#JSON='"text":"$2", "reply_markup": {"remove_keyboard":true}'
}

# $1 CHAT $2 message $3 keyboard
send_inline_keyboard() {
	local text; text='"text":"'$(JsonEscape "${2}")'"'; [ -z "${2}" ] && text='"text":"'"Keyboard:"'"'
	sendJson "${1}" "${text}"', "reply_markup": {"inline_keyboard": [ '"${3}"' ]}' "$MSG_URL"
	# JSON='"text":"$2", "reply_markup": {"inline_keyboard": [ $3->[{"text":"text", "url":"url"}]<- ]}'
}
# $1 CHAT $2 message $3 button text $4 URL
send_button() {
	send_inline_keyboard "${1}" "${2}" '[ {"text":"'"$(JsonEscape "${3}")"'", "url":"'"${4}"'"}]' 
}


UPLOADDIR="${BASHBOT_UPLOAD:-${DATADIR}/upload}"

# for now this can only send local files with curl!
# extend to allow send files by URL or telegram ID
send_file() {
	upload_file "${@}"
}

if [ -z "${BASHBOT_WGET}" ] && _exists curl ; then
# there are no checks if URL or ID exists
# $1 chat $3 ... $n URL or ID
  send_album(){
	[ -z "${1}" ] && return 1
	[ -z "${3}" ] && return 2 # minimum 2 files
	local CHAT JSON IMAGE; CHAT="${1}"; shift 
	for IMAGE in "$@"
	do
		[ -n "${JSON}" ] && JSON+=","
		JSON+='{"type":"photo","media":"'${IMAGE}'"}'
	done
	# shellcheck disable=SC2086
	res="$("${BASHBOT_CURL}" -s -k ${BASHBOT_CURL_ARGS} "${ALBUM_URL}" -F "chat_id=${CHAT}"\
			-F "media=[${JSON}]" | "${JSONSHFILE}" -s -b -n 2>/dev/null )"
	sendJsonResult "${res}" "send_album (curl)" "${CHAT}" "$@"
	[[ -z "${SOURCE}" && -n "${BASHBOT_EVENT_SEND[*]}" ]] && event_send "album" "$@" &
  }
else
  send_album(){
	log_error "Sorry, wget Album upload not yet implemented"
	BOTSENT[OK]="false"
	[[ -z "${SOURCE}" && -n "${BASHBOT_EVENT_SEND[*]}" ]] && event_send "album" "$@" &
  }
fi

upload_file(){
	local CUR_URL WHAT STATUS file="$2"
	# file access checks ...
	[[ "$file" = *'..'* ]] && return  # no directory traversal
	[[ "$file" = '.'* ]] && return	 # no hidden or relative files
	if [[ "$file" = '/'* ]] ; then
		[[ ! "$file" =~ $FILE_REGEX ]] && return # absolute must match REGEX
	else
		file="${UPLOADDIR:-NOUPLOADDIR}/${file}" # othiers must be in UPLOADDIR
	fi
	[ ! -r "$file" ] && return # and file must exits of course
 
	local ext="${file##*.}"
	case $ext in
        	mp3|flac)
			CUR_URL="$AUDIO_URL"
			WHAT="audio"
			STATUS="upload_audio"
			;;
		png|jpg|jpeg|gif|pic)
			CUR_URL="$PHO_URL"
			WHAT="photo"
			STATUS="upload_photo"
			;;
		webp)
			CUR_URL="$STICKER_URL"
			WHAT="sticker"
			STATUS="upload_photo"
			;;
		mp4)
			CUR_URL="$VIDEO_URL"
			WHAT="video"
			STATUS="upload_video"
			;;

		ogg)
			CUR_URL="$VOICE_URL"
			WHAT="voice"
			STATUS="upload_audio"
			;;
		*)
			CUR_URL="$DOCUMENT_URL"
			WHAT="document"
			STATUS="upload_document"
			;;
	esac
	send_action "${1}" "$STATUS"
	sendUpload "$1" "${WHAT}" "${file}" "${CUR_URL}" "$3"
}

# typing for text messages, upload_photo for photos, record_video or upload_video for videos, record_audio or upload_audio for audio files, upload_document for general files, find_location for location
send_action() {
	[ -z "$2" ] && return
	sendJson "${1}" '"action": "'"${2}"'"' "$ACTION_URL" &
}

# $1 CHAT $2 lat $3 long
send_location() {
	[ -z "$3" ] && return
	sendJson "${1}" '"latitude": '"${2}"', "longitude": '"${3}"'' "$LOCATION_URL"
}

# $1 CHAT $2 lat $3 long $4 title $5 address $6 foursquard id
send_venue() {
	local add=""
	[ -z "$5" ] && return
	[ -n "$6" ] && add=', "foursquare_id": '"$6"''
	sendJson "${1}" '"latitude": '"${2}"', "longitude": '"${3}"', "address": "'"${5}"'", "title": "'"${4}"'"'"${add}" "$VENUE_URL"
}


# $1 CHAT $2 from chat  $3 from msg id
forward_message() {
	[ -z "$3" ] && return
	sendJson "${1}" '"from_chat_id": '"${2}"', "message_id": '"${3}"'' "$FORWARD_URL"
}
forward() { # backward compatibility
	forward_message "$@" || return
}

# $1 CHAT $2 bashbot formatted message, see manual advanced usage
send_message() {
	[ -z "$2" ] && return
	local text keyboard btext burl no_keyboard file lat long title address sent
	text="$(sed <<< "${2}" 's/ mykeyboardend.*//;s/ *my[kfltab][a-z]\{2,13\}startshere.*//')$(sed <<< "${2}" -n '/mytextstartshere/ s/.*mytextstartshere//p')"
	#shellcheck disable=SC2001
	text="$(sed <<< "${text}" 's/ *mynewlinestartshere */\\n/g')"
	text="${text//$'\n'/\\n}"
	[ "$3" != "safe" ] && {
		no_keyboard="$(sed <<< "${2}" '/mykeyboardendshere/!d;s/.*mykeyboardendshere.*/mykeyboardendshere/')"
		keyboard="$(sed <<< "${2}" '/mykeyboardstartshere /!d;s/.*mykeyboardstartshere *//;s/ *my[nkfltab][a-z]\{2,13\}startshere.*//;s/ *mykeyboardendshere.*//')"
		btext="$(sed <<< "${2}" '/mybtextstartshere /!d;s/.*mybtextstartshere //;s/ *my[nkfltab][a-z]\{2,13\}startshere.*//;s/ *mykeyboardendshere.*//')"
		burl="$(sed <<< "${2}" '/myburlstartshere /!d;s/.*myburlstartshere //;s/ *my[nkfltab][a-z]\{2,13\}startshere.*//g;s/ *mykeyboardendshere.*//g')"
		file="$(sed <<< "${2}" '/myfilelocationstartshere /!d;s/.*myfilelocationstartshere //;s/ *my[nkfltab][a-z]\{2,13\}startshere.*//;s/ *mykeyboardendshere.*//')"
		lat="$(sed <<< "${2}" '/mylatstartshere /!d;s/.*mylatstartshere //;s/ *my[nkfltab][a-z]\{2,13\}startshere.*//;s/ *mykeyboardendshere.*//')"
		long="$(sed <<< "${2}" '/mylongstartshere /!d;s/.*mylongstartshere //;s/ *my[nkfltab][a-z]\{2,13\}startshere.*//;s/ *mykeyboardendshere.*//')"
		title="$(sed <<< "${2}" '/mytitlestartshere /!d;s/.*mytitlestartshere //;s/ *my[kfltab][a-z]\{2,13\}startshere.*//;s/ *mykeyboardendshere.*//')"
		address="$(sed <<< "${2}" '/myaddressstartshere /!d;s/.*myaddressstartshere //;s/ *my[nkfltab][a-z]\{2,13\}startshere.*//;s/ *mykeyboardendshere.*//')"
	}
	if [ -n "$no_keyboard" ]; then
		remove_keyboard "$1" "$text"
		sent=y
	fi
	if [ -n "$keyboard" ]; then
		if [[ "$keyboard" != *"["* ]]; then # pre 0.60 style
			keyboard="[ ${keyboard//\" \"/\" \] , \[ \"} ]"
		fi
		send_keyboard "$1" "$text" "$keyboard"
		sent=y
	fi
	if [ -n "$btext" ] && [ -n "$burl" ]; then
		send_button "$1" "$text" "$btext" "$burl"
		sent=y
	fi
	if [ -n "$file" ]; then
		send_file "$1" "$file" "$text"
		sent=y
	fi
	if [ -n "$lat" ] && [ -n "$long" ]; then
		if [ -n "$address" ] && [ -n "$title" ]; then
			send_venue "$1" "$lat" "$long" "$title" "$address"
		else
			send_location "$1" "$lat" "$long"
		fi
		sent=y
	fi
	if [ "$sent" != "y" ];then
		send_text "$1" "$text"
	fi

}

# $1 CHAT $2 message starting possibly with html_parse_mode or markdown_parse_mode
# not working, fix or remove after 1.0!!
send_text() {
	case "$2" in
		'html_parse_mode'*)
			send_html_message "$1" "${2//html_parse_mode}"
			;;
		'markdown_parse_mode'*)
			send_markdown_message "$1" "${2//markdown_parse_mode}"
			;;
		*)
			send_normal_message "$1" "$2"
			;;
	esac
}

