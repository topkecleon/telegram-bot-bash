#!/bin/bash
# file: modules/message.sh
# do not edit, this file will be overwritten on update

# This file is public domain in the USA and all free countries.
# Elsewhere, consider it to be WTFPLv2. (wtfpl.net/txt/copying)
#
# shellcheck disable=SC1117
#### $$VERSION$$ v1.30-dev-6-g87f618f

# will be automatically sourced from bashbot

# source once magic, function named like file
eval "$(basename "${BASH_SOURCE[0]}")(){ :; }"

# source from commands.sh to use the sendMessage functions

MSG_URL=${URL}'/sendMessage'
EDIT_URL=${URL}'/editMessageText'

#
# send/edit message variants ------------------
#

# $1 CHAT $2 message
send_normal_message() {
	local len text; text="$(JsonEscape "$2")"
	text="${text//$'\n'/\\n}"
	until [ -z "${text}" ]; do
		if [ "${#text}" -le 4096 ]; then
			sendJson "$1" '"text":"'"${text}"'"' "${MSG_URL}"
			break
		else
			len=4095
			[ "${text:4095:2}" != "\n" ] &&\
				len="${text:0:4096}" && len="${len%\\n*}" && len="${#len}"
			sendJson "$1" '"text":"'"${text:0:${len}}"'"' "${MSG_URL}"
			text="${text:$((len+2))}"
		fi
	done
}

# $1 CHAT $2 message
send_markdown_message() {
	_format_message_url "$1" "$2" ',"parse_mode":"markdown"' "${MSG_URL}"
}

# $1 CHAT $2 message
send_markdownv2_message() {
	_markdownv2_message_url "$1" "$2" ',"parse_mode":"markdownv2"' "${MSG_URL}"
}

# $1 CHAT $2 message
send_html_message() {
	_format_message_url "$1" "$2" ',"parse_mode":"html"' "${MSG_URL}"
}

# $1 CHAT $2 msg-id $3 message
edit_normal_message() {
	_format_message_url "$1" "$3" ',"message_id":'"$2"'' "${EDIT_URL}"
}

# $1 CHAT $2 msg-id $3 message
edit_markdown_message() {
	_format_message_url "$1" "$3" ',"message_id":'"$2"',"parse_mode":"markdown"' "${EDIT_URL}"
}

# $1 CHAT $2 msg-id $3 message
edit_markdownv2_message() {
	_markdownv2_message_url "$1" "$3" ',"message_id":'"$2"',"parse_mode":"markdownv2"' "${EDIT_URL}"
}

# $1 CHAT $2 msg-id $3 message
edit_html_message() {
	_format_message_url "$1" "$3" ',"message_id":'"$2"',"parse_mode":"html"' "${EDIT_URL}"
}


# internal function, send/edit formatted message with parse_mode and URL
# $1 CHAT $2 message $3 action $4 URL
_format_message_url(){
	local text; text="$(JsonEscape "$2")"
	text="${text//$'\n'/\\n}"
	[ "${#text}" -ge 4096 ] && log_error "Warning: html/markdown message longer than 4096 characters, message is rejected if formatting crosses 4096 border."
	until [ -z "${text}" ]; do
		sendJson "$1" '"text":"'"${text:0:4096}"'"'"$3"'' "$4"
		text="${text:4096}"
	done
}

# internal function, send/edit markdownv2 message with URL
# $1 CHAT $2 message $3 action $4 URL
_markdownv2_message_url() {
	local text; text="$(JsonEscape "$2")"
	text="${text//$'\n'/\\n}"
	[ "${#text}" -ge 4096 ] && log_error "Warning: markdownv2 message longer than 4096 characters, message is rejected if formatting crosses 4096 border."
	# markdown v2 needs additional double escaping!
	text="$(sed -E -e 's|([_|~`>+=#{}()!.-])|\\\1|g' <<< "${text}")"
	until [ -z "${text}" ]; do
		sendJson "$1" '"text":"'"${text:0:4096}"'"'"$3"'' "$4"
		text="${text:4096}"
	done
}

#
# send keyboard, buttons, files ---------------
#

# $1 CHAT $2 message $3 keyboard
send_keyboard() {
	if [[ "$3" != *'['* ]]; then old_send_keyboard "${@}"; return; fi
	local text='"text":"'"Keyboard:"'"'
	if [ -n "$2" ]; then
		text="$(JsonEscape "$2")"
		text='"text":"'"${text//$'\n'/\\n}"'"'
	fi
	local one_time=', "one_time_keyboard":true' && [ -n "$4" ] && one_time=""
	sendJson "$1" "${text}"', "reply_markup": {"keyboard": [ '"$3"' ] '"${one_time}"'}' "${MSG_URL}"
	# '"text":"$2", "reply_markup": {"keyboard": [ $3 ], "one_time_keyboard": true}'
}

# $1 CHAT $2 message $3 remove
remove_keyboard() {
	local text='"text":"'"remove custom keyboard ..."'"'
	if [ -n "$2" ]; then
		text="$(JsonEscape "$2")"
		text='"text":"'"${text//$'\n'/\\n}"'"'
	fi
	sendJson "$1" "${text}"', "reply_markup": {"remove_keyboard":true}' "${MSG_URL}"
	# delete message if no message or $3 not empty
	[[ -z "$2" || -n "$3" ]] && delete_message "$1" "${BOTSENT[ID]}" "nolog"
	#JSON='"text":"$2", "reply_markup": {"remove_keyboard":true}'
}

# $1 CHAT $2 message $3 keyboard
send_inline_keyboard() {
	local text; text='"text":"'$(JsonEscape "$2")'"'; [ -z "$2" ] && text='"text":"'"Keyboard:"'"'
	sendJson "$1" "${text}"', "reply_markup": {"inline_keyboard": [ '"$3"' ]}' "${MSG_URL}"
	# JSON='"text":"$2", "reply_markup": {"inline_keyboard": [ $3->[{"text":"text", "url":"url"}]<- ]}'
}
# $1 CHAT $2 message $3 button text $4 URL
send_button() {
	send_inline_keyboard "$1" "$2" '[ {"text":"'"$(JsonEscape "$3")"'", "url":"'"$4"'"}]' 
}

# $1 chat, $2 file_id on telegram server 
send_sticker() {
	sendJson "$1" '"sticker": "'"$2"'"' "${URL}/setChatDescription"
}


# only curl can send files ... 
if detect_curl ; then
  # there are no checks if URL or ID exists
  # $1 chat $3 ... $n URL or ID
  send_album(){
	[ -z "$1" ] && return 1
	[ -z "$3" ] && return 2 # minimum 2 files
	local CHAT JSON IMAGE; CHAT="$1"; shift 
	for IMAGE in "$@"
	do
		[ -n "${JSON}" ] && JSON+=","
		JSON+='{"type":"photo","media":"'${IMAGE}'"}'
	done
	# shellcheck disable=SC2086
	res="$("${BASHBOT_CURL}" -s -k ${BASHBOT_CURL_ARGS} "${URL}/sendMediaGroup" -F "chat_id=${CHAT}"\
			-F "media=[${JSON}]" | "${JSONSHFILE}" -s -b -n 2>/dev/null )"
	sendJsonResult "${res}" "send_album (curl)" "${CHAT}" "$@"
	[[ -z "${SOURCE}" && -n "${BASHBOT_EVENT_SEND[*]}" ]] && event_send "album" "$@" &
  }
else
  send_album(){
	log_error "Sorry, wget Album upload not implemented"
	BOTSENT[OK]="false"
	[[ -z "${SOURCE}" && -n "${BASHBOT_EVENT_SEND[*]}" ]] && event_send "album" "$@" &
  }
fi

UPLOADDIR="${BASHBOT_UPLOAD:-${DATADIR}/upload}"

# supports local file, URL and file_id
# $1 chat, $2 file https::// file_id:// , $3 caption, $4 extension (optional)
send_file(){
	local url what stat err media capt file="$2" ext="$4"
	capt="$(JsonEscape "$3")"
	if [[ "${file}" =~ ^https*:// ]]; then
		media="URL"
	elif [[ "${file}" == file_id://* ]]; then
		media="ID"
		file="${file#file_id://}"
	else
		# we have a file, check file location ...
		media="FILE"
		[[ "${file}" = *'..'* || "${file}" = '.'* ]] && err=1  # no directory traversal
		if [[ "${file}" = '/'* ]] ; then
			[[ ! "${file}" =~ ${FILE_REGEX} ]] && err=2 # absolute must match REGEX
		else
			file="${UPLOADDIR:-NOUPLOADDIR}/${file}" # others must be in UPLOADDIR
		fi
		[ ! -r "${file}" ] && err=3 # and file must exits of course
		# file path error, generate error response
		if [ -n "${err}" ]; then
		    BOTSENT=(); BOTSENT[OK]="false"
		    case "${err}" in
			1) BOTSENT[ERROR]="Path to file $2 contains to much '../' or starts with '.'";;
			2) BOTSENT[ERROR]="Path to file $2 does not match regex: ${FILE_REGEX} ";;
			3) if [[ "$2" == "/"* ]];then
				BOTSENT[ERROR]="File not found: $2"
			   else
				BOTSENT[ERROR]="File not found: ${UPLOADDIR}/$2"
			   fi;;
		    esac
		    [ -n "${BASHBOTDEBUG}" ] && log_message "Error in upload_file: ${BOTSENT[ERROR]}"
		    return
		fi
		# file OK, let's continue
	fi

	# no type given, use file ext, if no ext type photo
	if [ -z "${ext}" ]; then
		ext="${file##*.}"
		[ "${ext}" = "${file}" ] && ext="photo"
	fi
	# select upload URL
	case "${ext}" in
		photo|png|jpg|jpeg|gif|pic)
			url="${URL}/sendPhoto"; what="photo"; stat="upload_photo"
			;;
        	audio|mp3|flac)
			url="${URL}/sendAudio"; what="audio"; stat="upload_audio"
			;;
		sticker|webp)
			url="${URL}/sendSticker"; what="sticker"; stat="upload_photo"
			;;
		video|mp4)
			url="${URL}/sendVideo"; what="video"; stat="upload_video"
			;;
		voice|ogg)
			url="${URL}/sendVoice"; what="voice"; stat="record_audio"
			;;
		*)	url="${URL}/sendDocument"; what="document"; stat="upload_document"
			;;
	esac

	# show file upload to user
	send_action "$1" "${stat}"
	# select method to send
	case "${media}" in
		FILE)	# send local file ...
			sendUpload "$1" "${what}" "${file}" "${url}" "${capt//\\n/$'\n'}";;

		URL|ID)	# send URL, file_id ...
			sendJson "$1" '"'"${what}"'":"'"${file}"'","caption":"'"${capt//\\n/$'\n'}"'"' "${url}"
	esac
	# get file_id and file_type
	if [ "${BOTSENT[OK]}" = "true" ]; then
		 BOTSENT[FILE_ID]="$(JsonGetString '.*,"file_id"' <<< "${res}")"
		 BOTSENT[FILE_TYPE]="${what}"
	fi
	return 0
}

# $1 typing upload_photo record_video upload_video record_audio upload_audio upload_document find_location
send_action() {
	[ -z "$2" ] && return
	sendJson "$1" '"action": "'"$2"'"' "${URL}/sendChatAction" &
}

# $1 CHAT $2 lat $3 long
send_location() {
	[ -z "$3" ] && return
	sendJson "$1" '"latitude": '"$2"', "longitude": '"$3"'' "${URL}/sendLocation"
}

# $1 CHAT $2 lat $3 long $4 title $5 address $6 foursquard id
send_venue() {
	local add=""
	[ -z "$5" ] && return
	[ -n "$6" ] && add=', "foursquare_id": '"$6"''
	sendJson "$1" '"latitude": '"$2"', "longitude": '"$3"', "address": "'"$5"'", "title": "'"$4"'"'"${add}" "${URL}/sendVenue"
}


#
# other send message variants ---------------------------------
#

# $1 CHAT $2 from chat  $3 from msg id
forward_message() {
	[ -z "$3" ] && return
	sendJson "$1" '"from_chat_id": '"$2"', "message_id": '"$3"'' "${URL}/forwardMessage"
}
forward() { # backward compatibility
	forward_message "$@" || return
}

# $1 CHAT $2 bashbot formatted message, see manual advanced usage
send_message() {
	[ -z "$2" ] && return
	local text keyboard btext burl no_keyboard file lat long title address sent
	text="$(sed <<< "$2" 's/ mykeyboardend.*//;s/ *my[kfltab][a-z]\{2,13\}startshere.*//')$(sed <<< "$2" -n '/mytextstartshere/ s/.*mytextstartshere//p')"
	#shellcheck disable=SC2001
	text="$(sed <<< "${text}" 's/ *mynewlinestartshere */\n/g')"
	text="${text//$'\n'/\\n}"
	[ "$3" != "safe" ] && {
		no_keyboard="$(sed <<< "$2" '/mykeyboardendshere/!d;s/.*mykeyboardendshere.*/mykeyboardendshere/')"
		keyboard="$(sed <<< "$2" '/mykeyboardstartshere /!d;s/.*mykeyboardstartshere *//;s/ *my[nkfltab][a-z]\{2,13\}startshere.*//;s/ *mykeyboardendshere.*//')"
		btext="$(sed <<< "$2" '/mybtextstartshere /!d;s/.*mybtextstartshere //;s/ *my[nkfltab][a-z]\{2,13\}startshere.*//;s/ *mykeyboardendshere.*//')"
		burl="$(sed <<< "$2" '/myburlstartshere /!d;s/.*myburlstartshere //;s/ *my[nkfltab][a-z]\{2,13\}startshere.*//g;s/ *mykeyboardendshere.*//g')"
		file="$(sed <<< "$2" '/myfile[^s]*startshere /!d;s/.*myfile[^s]*startshere //;s/ *my[nkfltab][a-z]\{2,13\}startshere.*//;s/ *mykeyboardendshere.*//')"
		lat="$(sed <<< "$2" '/mylatstartshere /!d;s/.*mylatstartshere //;s/ *my[nkfltab][a-z]\{2,13\}startshere.*//;s/ *mykeyboardendshere.*//')"
		long="$(sed <<< "$2" '/mylongstartshere /!d;s/.*mylongstartshere //;s/ *my[nkfltab][a-z]\{2,13\}startshere.*//;s/ *mykeyboardendshere.*//')"
		title="$(sed <<< "$2" '/mytitlestartshere /!d;s/.*mytitlestartshere //;s/ *my[kfltab][a-z]\{2,13\}startshere.*//;s/ *mykeyboardendshere.*//')"
		address="$(sed <<< "$2" '/myaddressstartshere /!d;s/.*myaddressstartshere //;s/ *my[nkfltab][a-z]\{2,13\}startshere.*//;s/ *mykeyboardendshere.*//')"
	}
	if [ -n "${no_keyboard}" ]; then
		remove_keyboard "$1" "${text}"
		sent=y
	fi
	if [ -n "${keyboard}" ]; then
		if [[ "${keyboard}" != *"["* ]]; then # pre 0.60 style
			keyboard="[ ${keyboard//\" \"/\" \] , \[ \"} ]"
		fi
		send_keyboard "$1" "${text}" "${keyboard}"
		sent=y
	fi
	if [ -n "${btext}" ] && [ -n "${burl}" ]; then
		send_button "$1" "${text}" "${btext}" "${burl}"
		sent=y
	fi
	if [ -n "${file}" ]; then
		send_file "$1" "${file}" "${text}"
		sent=y
	fi
	if [ -n "${lat}" ] && [ -n "${long}" ]; then
		if [ -n "${address}" ] && [ -n "${title}" ]; then
			send_venue "$1" "${lat}" "${long}" "${title}" "${address}"
		else
			send_location "$1" "${lat}" "${long}"
		fi
		sent=y
	fi
	if [ "${sent}" != "y" ];then
		send_text_mode "$1" "${text}"
	fi

}

# $1 CHAT $2 message starting possibly with html_parse_mode or markdown_parse_mode
# not working, fix or remove after 1.0!!
send_text_mode() {
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

