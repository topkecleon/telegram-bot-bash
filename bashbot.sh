#!/bin/bash
# file: bashbot.sh 
# do not edit, this file will be overwritten on update

# bashbot, the Telegram bot written in bash.
# Written by Drew (@topkecleon) and Daniil Gentili (@danogentili), KayM (@gnadelwartz).
# Also contributed: JuanPotato, BigNerd95, TiagoDanin, iicc1.
# https://github.com/topkecleon/telegram-bot-bash

# Depends on JSON.sh (http://github.com/dominictarr/JSON.sh) (MIT/Apache),
# and on tmux (http://github.com/tmux/tmux) (BSD).
# This file is public domain in the USA and all free countries.
# Elsewhere, consider it to be WTFPLv2. (wtfpl.net/txt/copying)
#
#### $$VERSION$$ v0.72-0-ge899420
#
# Exit Codes:
# - 0 sucess (hopefully)
# - 1 can't change to dir
# - 2 can't write to tmp, count or token 
# - 3 user / command / file not found
# - 4 unkown command
# - 5 cannot connect to telegram bot

# are we runnig in a terminal?
if [ -t 1 ] && [ "$TERM" != "" ];  then
    CLEAR='clear'
    RED='\e[31m'
    GREEN='\e[32m'
    ORANGE='\e[35m'
    NC='\e[0m'
fi

# get location and name of bashbot.sh
SCRIPT="$0"
SCRIPTDIR="$(dirname "$0")"
MODULEDIR="${SCRIPTDIR}/modules"

RUNDIR="${SCRIPTDIR}"
[ "${RUNDIR}" = "${SCRIPTDIR}" ] && SCRIPT="./$(basename "${SCRIPT}")"

RUNUSER="${USER}" # USER is overwritten by bashbot array

if [ "$1" != "source" ] && ! cd "${RUNDIR}" ; then
	echo -e "${RED}ERROR: Can't change to ${RUNDIR} ...${NC}"
	exit 1
fi

if [ ! -w "." ]; then
	echo -e "${ORANGE}WARNING: ${RUNDIR} is not writeable!${NC}"
	ls -ld .
fi

TOKENFILE="${BASHBOT_ETC:-.}/token"
if [ ! -f "${TOKENFILE}" ]; then
   if [ "${CLEAR}" = "" ] && [ "$1" != "init" ]; then
	echo "Running headless, run ${SCRIPT} init first!"
	exit 2 
   else
	${CLEAR}
	echo -e "${RED}TOKEN MISSING.${NC}"
	echo -e "${ORANGE}PLEASE WRITE YOUR TOKEN HERE OR PRESS CTRL+C TO ABORT${NC}"
	read -r token
	echo "${token}" > "${TOKENFILE}"
   fi
fi

JSONSHFILE="${BASHBOT_JSONSH:-${RUNDIR}/JSON.sh/JSON.sh}"
[[ "${JSONSHFILE}" != *"/JSON.sh" ]] && echo -e "${RED}ERROR: \"${JSONSHFILE}\" ends not with \"JSONS.sh\".${NC}" && exit 3

if [ ! -f "${JSONSHFILE}" ]; then
	echo "Seems to be first run, Downloading ${JSONSHFILE}..."
	[[ "${JSONSHFILE}" = "${RUNDIR}/JSON.sh/JSON.sh" ]] && mkdir "JSON.sh" 2>/dev/null;
	curl -sL -o "${JSONSHFILE}" "https://cdn.jsdelivr.net/gh/dominictarr/JSON.sh/JSON.sh"
	chmod +x "${JSONSHFILE}" 
fi

BOTADMIN="${BASHBOT_ETC:-.}/botadmin"
if [ ! -f "${BOTADMIN}" ]; then
   if [ "${CLEAR}" = "" ]; then
	echo "Running headless, set botadmin to AUTO MODE!"
	echo '?' > "${BOTADMIN}"
   else
	${CLEAR}
	echo -e "${RED}BOTADMIN MISSING.${NC}"
	echo -e "${ORANGE}PLEASE WRITE YOUR TELEGRAM ID HERE OR ENTER '?'${NC}"
	echo -e "${ORANGE}TO MAKE FIRST USER TYPING '/start' TO BOTADMIN${NC}"
	read -r token
	echo "${token}" > "${BOTADMIN}"
	[ "${token}" = "" ] && echo '?' > "${BOTADMIN}"
   fi
fi

BOTACL="${BASHBOT_ETC:-.}/botacl"
if [ ! -f "${BOTACL}" ]; then
	echo -e "${ORANGE}Create empty ${BOTACL} file.${NC}"
	echo "" >"${BOTACL}"
fi

TMPDIR="${BASHBOT_VAR:-.}/data-bot-bash"
if [ ! -d "${TMPDIR}" ]; then
	mkdir "${TMPDIR}"
elif [ ! -w "${TMPDIR}" ]; then
	${CLEAR}
	echo -e "${RED}ERROR: Can't write to ${TMPDIR}!.${NC}"
	ls -ld "${TMPDIR}"
	exit 2
fi

COUNTFILE="${BASHBOT_VAR:-.}/count"
if [ ! -f "${COUNTFILE}" ]; then
	echo "" >"${COUNTFILE}"
elif [ ! -w "${COUNTFILE}" ]; then
	${CLEAR}
	echo -e "${RED}ERROR: Can't write to ${COUNTFILE}!.${NC}"
	ls -l "${COUNTFILE}"
	exit 2
fi


BOTTOKEN="$(cat "${TOKENFILE}")"
URL='https://api.telegram.org/bot'$BOTTOKEN

MSG_URL=$URL'/sendMessage'
LEAVE_URL=$URL'/leaveChat'
KICK_URL=$URL'/kickChatMember'
UNBAN_URL=$URL'/unbanChatMember'
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
ME_URL=$URL'/getMe'
DELETE_URL=$URL'/deleteMessage'
GETMEMBER_URL=$URL'/getChatMember'

UPD_URL=$URL'/getUpdates?offset='
GETFILE_URL=$URL'/getFile'

unset USER
declare -A BOTSENT USER MESSAGE URLS CONTACT LOCATION CHAT FORWARD REPLYTO VENUE
export BOTSENT USER MESSAGE URLS CONTACT LOCATION CHAT FORWARD REPLYTO VENUE

COMMANDS="${BASHBOT_ETC:-.}/commands.sh"
if [ "$1" != "source" ]; then
	if [ ! -f "${COMMANDS}" ] || [ ! -r "${COMMANDS}" ]; then
		${CLEAR}
		echo -e "${RED}ERROR: ${COMMANDS} does not exist or is not readable!.${NC}"
		ls -l "${COMMANDS}"
		exit 3
	fi
	# shellcheck source=./commands.sh
	source "${COMMANDS}" "source"
fi


send_normal_message() {
	local text="${2}"
	until [ -z "${text}" ]; do
		sendJson "${1}" '"text":"'"${text:0:4096}"'"' "${MSG_URL}"
		text="${text:4096}"
	done
}

send_markdown_message() {
	local text="${2}"
	until [ -z "${text}" ]; do
		sendJson "${1}" '"text":"'"${text:0:4096}"'","parse_mode":"markdown"' "${MSG_URL}"
		text="${text:4096}"
	done
}

send_html_message() {
	local text="${2}"
	until [ -z "${text}" ]; do
		sendJson "${1}" '"text":"'"${text:0:4096}"'","parse_mode":"html"' "${MSG_URL}"
		text="${text:4096}"
	done
}

delete_message() {
	sendJson "${1}" 'message_id: '"${2}"'' "${DELETE_URL}"
}

# usage: status="$(get_chat_member_status "chat" "user")"
get_chat_member_status() {
	sendJson "$1" 'user_id: '"$2"'' "$GETMEMBER_URL"
	JsonGetString '"result","status"' <<< "$res"
}

kick_chat_member() {
	sendJson "$1" 'user_id: '"$2"'' "$KICK_URL"
}

unban_chat_member() {
	sendJson "$1" 'user_id: '"$2"'' "$UNBAN_URL"
}

leave_chat() {
	sendJson "$1" "" "$LEAVE_URL"
}

user_is_creator() {
	if [ "${1:--}" = "${2:-+}" ] || [ "$(get_chat_member_status "$1" "$2")" = "creator" ]; then return 0; fi
	return 1 
}

user_is_admin() {
	local me; me="$(get_chat_member_status "$1" "$2")"
	if [ "${me}" = "creator" ] || [ "${me}" = "administrator" ]; then return 0; fi
	return 1 
}

user_is_botadmin() {
	local admin; admin="$(head -n 1 "${BOTADMIN}")"
	[ "${admin}" = "${1}" ] && return 0
	[[ "${admin}" = "@*" ]] && [[ "${admin}" = "${2}" ]] && return 0
	if [ "${admin}" = "?" ]; then echo "${1:-?}" >"${BOTADMIN}"; return 0; fi
	return 1
}

user_is_allowed() {
	local acl="$1"
	[ "$1" = "" ] && return 1
	grep -F -xq "${acl}:*:*" <"${BOTACL}" && return 0
	[ "$2" != "" ] && acl="${acl}:$2"
	grep -F -xq "${acl}:*" <"${BOTACL}" && return 0
	[ "$3" != "" ] && acl="${acl}:$3"
	grep -F -xq "${acl}" <"${BOTACL}"
}

old_send_keyboard() {
	local text='"text":"'"${2}"'"'
	shift 2
	local keyboard=init
	OLDIFS=$IFS
	IFS=$(echo -en "\"")
	for f in "$@" ;do [ "$f" != " " ] && keyboard="$keyboard, [\"$f\"]";done
	IFS=$OLDIFS
	keyboard=${keyboard/init, /}
	sendJson "${1}" "${text}"', "reply_markup": {"keyboard": [ '"${keyboard}"' ],"one_time_keyboard": true}' "$MSG_URL"
}

ISEMPTY="ThisTextIsEmptyAndWillBeDeleted"
send_keyboard() {
	if [[ "$3" != *'['* ]]; then old_send_keyboard "$@"; return; fi
	local text='"text":"'"${2}"'"'; [ "${2}" = "" ] && text='"text":"'"${ISEMPTY}"'"'
	local one_time=', "one_time_keyboard":true' && [ "$4" != "" ] && one_time=""
	sendJson "${1}" "${text}"', "reply_markup": {"keyboard": [ '"${3}"' ] '"${one_time}"'}' "$MSG_URL"
	# '"text":"$2", "reply_markup": {"keyboard": [ ${3} ], "one_time_keyboard": true}'
}

remove_keyboard() {
	local text='"text":"'"${2}"'"'; [ "${2}" = "" ] && text='"text":"'"${ISEMPTY}"'"'
	sendJson "${1}" "${text}"', "reply_markup": {"remove_keyboard":true}' "$MSG_URL"
	#JSON='"text":"$2", "reply_markup": {"remove_keyboard":true}'
}
send_inline_keyboard() {
	local text='"text":"'"${2}"'"'; [ "${2}" = "" ] && text='"text":"'"${ISEMPTY}"'"'
	sendJson "${1}" "${text}"', "reply_markup": {"inline_keyboard": [ '"${3}"' ]}' "$MSG_URL"
	# JSON='"text":"$2", "reply_markup": {"inline_keyboard": [ $3->[{"text":"text", "url":"url"}]<- ]}'
}
send_button() {
	send_inline_keyboard "${1}" "${2}" '[ {"text":"'"${3}"'", "url":"'"${4}"'"}]' 
}

# usage: sendJson "chat" "JSON" "URL"
sendJson(){
	local chat="";
	[ "${1}" != "" ] && chat='"chat_id":'"${1}"','
	res="$(curl -s -d '{'"${chat} $2"'}' -X POST "${3}" \
		-H "Content-Type: application/json" | "${JSONSHFILE}" -s -b -n )"
	BOTSENT[OK]="$(JsonGetLine '"ok"' <<< "$res")"
	BOTSENT[ID]="$(JsonGetValue '"result","message_id"' <<< "$res")"
	[[ "${2}" = *"${ISEMPTY}"* ]] && delete_message "${1}" "${BOTSENT[ID]}"
}

# convert common telegram entities to JSON
# title caption description markup inlinekeyboard
title2Json(){
	local title caption desc markup keyboard
	[ "$1" != "" ] && title=',"title":"'$1'"'
	[ "$2" != "" ] && caption=',"caption":"'$2'"'
	[ "$3" != "" ] && desc=',"description":"'$3'"'
	[ "$4" != "" ] && markup=',"parse_mode":"'$4'"'
	[ "$5" != "" ] && keyboard=',"reply_markup":"'$5'"'
	echo "${title}${caption}${desc}${markup}${keyboard}"
}

get_file() {
	[ "$1" = "" ] && return
	local JSON='"file_id": '"${1}"
	sendJson "" "${JSON}" "${GETFILE_URL}"
	echo "${URL}/$(echo "${res}" | jsonGetString '"result","file_path"')"
}

send_file() {
	[ "$2" = "" ] && return
	local CAPTION
	local chat_id=$1
	local file=$2
	echo "$file" | grep -qE "$FILE_REGEX" || return
	local ext="${file##*.}"
	case $ext in
        	mp3|flac)
			CUR_URL=$AUDIO_URL
			WHAT=audio
			STATUS=upload_audio
			CAPTION="$3"
			;;
		png|jpg|jpeg|gif)
			CUR_URL=$PHO_URL
			WHAT=photo
			STATUS=upload_photo
			CAPTION="$3"
			;;
		webp)
			CUR_URL=$STICKER_URL
			WHAT=sticker
			STATUS=
			;;
		mp4)
			CUR_URL=$VIDEO_URL
			WHAT=video
			STATUS=upload_video
			CAPTION="$3"
			;;

		ogg)
			CUR_URL=$VOICE_URL
			WHAT=voice
			STATUS=
			;;
		*)
			CUR_URL=$DOCUMENT_URL
			WHAT=document
			STATUS=upload_document
			CAPTION="$3"
			;;
	esac
	send_action "$chat_id" "$STATUS"
	res="$(curl -s "$CUR_URL" -F "chat_id=$chat_id" -F "$WHAT=@$file" -F "caption=$CAPTION")"
}

# typing for text messages, upload_photo for photos, record_video or upload_video for videos, record_audio or upload_audio for audio files, upload_document for general files, find_location for location

send_action() {
	[ "$2" = "" ] && return
	sendJson "${1}" '"action": "'"${2}"'"' "$ACTION_URL"
}

send_location() {
	[ "$3" = "" ] && return
	sendJson "${1}" '"latitude": '"${2}"', "longitude": '"${3}"'' "$LOCATION_URL"
}

send_venue() {
	local add=""
	[ "$5" = "" ] && return
	[ "$6" != "" ] && add=', "foursquare_id": '"$6"''
	sendJson "${1}" '"latitude": '"${2}"', "longitude": '"${3}"', "address": "'"${5}"'", "title": "'"${4}"'"'"${add}" "$VENUE_URL"
}


forward_message() {
	[ "$3" = "" ] && return
	sendJson "${1}" '"from_chat_id": '"${2}"', "message_id": '"${3}"'' "$FORWARD_URL"
}
forward() { # backward compatibility
	forward_message "$@" || return
}

# returns true if function exist
_is_function()
{
	[ "$(LC_ALL=C type -t "$1")" = "function" ]
}
process_updates() {
	MAX_PROCESS_NUMBER="$(sed <<< "${UPDATE}" '/\["result",[0-9]*\]/!d' | tail -1 | sed 's/\["result",//g;s/\].*//g')"
	for ((PROCESS_NUMBER=0; PROCESS_NUMBER<=MAX_PROCESS_NUMBER; PROCESS_NUMBER++)); do
		process_client "$1"
	done
}
process_client() {
	iQUERY[ID]="$(JsonGetString <<<"${UPDATE}" '"result",'"${PROCESS_NUMBER}"',"inline_query","id"')"
	if [ "${iQUERY[ID]}" = "" ]; then
		[[ "$1" = *"debug"* ]] && echo "$UPDATE" >>"MESSAGE.log"
		process_message "$PROCESS_NUMBER" "$1"
	else
		[[ "$1" = *"debug"* ]] && echo "$UPDATE" >>"INLINE.log"
		[ "$INLINE" != "0" ] && _is_function process_inline && process_inline "$PROCESS_NUMBER" "$1"
	fi
	# Tmux
	copname="$ME"_"${CHAT[ID]}"
	source commands.sh
	tmpcount="COUNT${CHAT[ID]}"
	grep -q "$tmpcount" <"${COUNTFILE}" >/dev/null 2>&1 || echo "$tmpcount">>"${COUNTFILE}"
	# To get user count execute bash bashbot.sh count
}
JsonGetString() {
	sed -n -e '0,/\['"$1"'\]/ s/\['"$1"'\][ \t]"\(.*\)"$/\1/p'
}
JsonGetLine() {
	sed -n -e '0,/\['"$1"'\]/ s/\['"$1"'\][ \t]//p'
}
JsonGetValue() {
	sed -n -e '0,/\['"$1"'\]/ s/\['"$1"'\][ \t]\([0-9.,]*\).*/\1/p'
}
process_message() {
	local num="$1"
	local TMP="${TMPDIR:-.}/$RANDOM$RANDOM-MESSAGE"
	echo "$UPDATE" >"$TMP"
	# Message
	MESSAGE[0]="$(JsonDecode "$(JsonGetString '"result",'"${num}"',"message","text"' <"$TMP")" | sed 's#\\/#/#g')"
	MESSAGE[ID]="$(JsonGetValue '"result",'"${num}"',"message","message_id"' <"$TMP" )"

	# Chat
	CHAT[ID]="$(JsonGetValue '"result",'"${num}"',"message","chat","id"' <"$TMP" )"
	CHAT[FIRST_NAME]="$(JsonDecode "$(JsonGetString '"result",'"${num}"',"message","chat","first_name"' <"$TMP")")"
	CHAT[LAST_NAME]="$(JsonDecode "$(JsonGetString '"result",'"${num}"',"message","chat","last_name"' <"$TMP")")"
	CHAT[USERNAME]="$(JsonDecode "$(JsonGetString '"result",'"${num}"',"message","chat","username"' <"$TMP")")"
	CHAT[TITLE]="$(JsonDecode "$(JsonGetString '"result",'"${num}"',"message","chat","title"' <"$TMP")")"
	CHAT[TYPE]="$(JsonDecode "$(JsonGetString '"result",'"${num}"',"message","chat","type"' <"$TMP")")"
	CHAT[ALL_MEMBERS_ARE_ADMINISTRATORS]="$(JsonDecode "$(JsonGetString '"result",'"${num}"',"message","chat","all_members_are_administrators"' <"$TMP")")"

	# User
	USER[ID]="$(JsonGetValue '"result",'"${num}"',"message","from","id"' <"$TMP" )"
	USER[FIRST_NAME]="$(JsonDecode "$(JsonGetString '"result",'"${num}"',"message","from","first_name"' <"$TMP")")"
	USER[LAST_NAME]="$(JsonDecode "$(JsonGetString '"result",'"${num}"',"message","from","last_name"' <"$TMP")")"
	USER[USERNAME]="$(JsonDecode "$(JsonGetString '"result",'"${num}"',"message","from","username"' <"$TMP")")"

	# in reply to message from
	REPLYTO[UID]="$(JsonGetValue '"result",'"${num}"',"message","reply_to_message","from","id"' <"$TMP" )"
	if [ "${REPLYTO[UID]}" != "" ]; then
	   REPLYTO[0]="$(JsonDecode "$(JsonGetString '"result",'"${num}"',"message","reply_to_message","text"' <"$TMP")")"
	   REPLYTO[ID]="$(JsonGetValue '"result",'"${num}"',"message","reply_to_message","message_id"' <"$TMP")"
	   REPLYTO[FIRST_NAME]="$(JsonDecode "$(JsonGetString '"result",'"${num}"',"message","reply_to_message","from","first_name"' <"$TMP")")"
	   REPLYTO[LAST_NAME]="$(JsonDecode "$(JsonGetString '"result",'"${num}"',"message","reply_to_message","from","last_name"' <"$TMP")")"
	   REPLYTO[USERNAME]="$(JsonDecode "$(JsonGetString '"result",'"${num}"',"message","reply_to_message","from","username"' <"$TMP")")"
	fi

	# forwarded message from
	FORWARD[UID]="$(JsonGetValue '"result",'"${num}"',"message","forward_from","id"' <"$TMP" )"
	if [ "${FORWARD[UID]}" != "" ]; then
	   FORWARD[ID]="${MESSAGE[ID]}" # same as message ID
	   FORWARD[FIRST_NAME]="$(JsonDecode "$(JsonGetString '"result",'"${num}"',"message","forward_from","first_name"' <"$TMP")")"
	   FORWARD[LAST_NAME]="$(JsonDecode "$(JsonGetString '"result",'"${num}"',"message","forward_from","last_name"' <"$TMP")")"
	   FORWARD[USERNAME]="$(JsonDecode "$(JsonGetString '"result",'"${num}"',"message","forward_from","username"' <"$TMP")")"
	fi

	# Audio
	URLS[AUDIO]="$(get_file "$(JsonGetString '"result",'"${num}"',"message","audio","file_id"' <"$TMP")")"
	# Document
	URLS[DOCUMENT]="$(get_file "$(JsonGetString '"result",'"${num}"',"message","document","file_id"' <"$TMP")")"
	# Photo
	URLS[PHOTO]="$(get_file "$(JsonGetString '"result",'"${num}"',"message","photo",0,"file_id"' <"$TMP")")"
	# Sticker
	URLS[STICKER]="$(get_file "$(JsonGetString '"result",'"${num}"',"message","sticker","file_id"' <"$TMP")")"
	# Video
	URLS[VIDEO]="$(get_file "$(JsonGetString '"result",'"${num}"',"message","video","file_id"' <"$TMP")")"
	# Voice
	URLS[VOICE]="$(get_file "$(JsonGetString '"result",'"${num}"',"message","voice","file_id"' <"$TMP")")"

	# Contact
	CONTACT[USER_ID]="$(JsonDecode "$(JsonGetString '"result",'"${num}"',"message","contact","user_id"' <"$TMP")")"
	CONTACT[FIRST_NAME]="$(JsonDecode "$(JsonGetString '"result",'"${num}"',"message","contact","first_name"' <"$TMP")")"
	CONTACT[LAST_NAME]="$(JsonDecode "$(JsonGetString '"result",'"${num}"',"message","contact","last_name"' <"$TMP")")"
	CONTACT[NUMBER]="$(JsonGetString '"result",'"${num}"',"message","contact","phone_number"' <"$TMP")"
	CONTACT[VCARD]="$(JsonGetString '"result",'"${num}"',"message","contact","vcard"' <"$TMP")"

	# vunue
	VENUE[TITLE]="$(JsonDecode "$(JsonGetString '"result",'"${num}"',"message","venue","title"' <"$TMP")")"
	VENUE[ADDRESS]="$(JsonDecode "$(JsonGetString '"result",'"${num}"',"message","venue","address"' <"$TMP")")"
	VENUE[LONGITUDE]="$(JsonGetValue '"result",'"${num}"',"message","venue","location","longitude"' <"$TMP")"
	VENUE[LATITUDE]="$(JsonGetValue '"result",'"${num}"',"message","venue","location","latitude"' <"$TMP")"
	VENUE[FOURSQUARE]="$(JsonGetString '"result",'"${num}"',"message","venue","foursquare_id"' <"$TMP")"

	# Caption
	CAPTION="$(JsonDecode "$(JsonGetString '"result",'"${num}"',"message","caption"' <"$TMP")")"

	# Location
	LOCATION[LONGITUDE]="$(JsonGetValue '"result",'"${num}"',"message","location","longitude"' <"$TMP")"
	LOCATION[LATITUDE]="$(JsonGetValue '"result",'"${num}"',"message","location","latitude"' <"$TMP")"
	NAME="$(echo "${URLS[*]}" | sed 's/.*\///g')"
	rm "$TMP"
}

# main get updates loop, should never terminate
start_bot() {
	local DEBUG="$1"
	local OFFSET=0
	local mysleep="100" # ms
	local addsleep="100"
	local maxsleep="$(( ${BASHBOT_SLEEP:-5000} + 100 ))"
	[[ "${DEBUG}" = *"debug" ]] && exec &>>"DEBUG.log"
	[ "${DEBUG}" != "" ] && date && echo "Start BASHBOT in Mode \"${DEBUG}\""
	[[ "${DEBUG}" = "xdebug"* ]] && set -x 
	while true; do {

		UPDATE="$(curl -s "$UPD_URL$OFFSET" | "${JSONSHFILE}" -s -b -n)"

		# Offset
		OFFSET="$(grep <<< "${UPDATE}" '\["result",[0-9]*,"update_id"\]' | tail -1 | cut -f 2)"
		OFFSET=$((OFFSET+1))

		if [ "$OFFSET" != "1" ]; then
			mysleep="100"
			process_updates "${DEBUG}" &
		fi
		# adaptive sleep in ms rounded to next lower second
		[ "${mysleep}" -gt "999" ] && sleep "${mysleep%???}"
		mysleep=$((mysleep+addsleep)); [ "${mysleep}" -gt "${maxsleep}" ] && mysleep="${maxsleep}"
  	}
	done
}

# initialize bot environment, user and permissions
bot_init() {
	# move tmpdir to datadir
	local OLDTMP="${BASHBOT_VAR:-.}/tmp-bot-bash"
	[ -d "${OLDTMP}" ] && { mv -n "${OLDTMP}/"* "${TMPDIR}"; rmdir "${OLDTMP}"; }
	[[ "$(id -u)" -eq "0" ]] && RUNUSER="nobody"
	echo -n "Enter User to run basbot [$RUNUSER]: "
	read -r TOUSER
	[ "$TOUSER" = "" ] && TOUSER="$RUNUSER"
	if ! compgen -u "$TOUSER" >/dev/null 2>&1; then
		echo -e "${RED}User \"$TOUSER\" not found!${NC}"
		exit 3
	else
		echo "Adjusting user \"${TOUSER}\" files and permissions ..."
		[ -w "bashbot.rc" ] && sed -i '/^[# ]*runas=/ s/runas=.*$/runas="'$TOUSER'"/' "bashbot.rc"
		chown -R "$TOUSER" . ./*
		chmod 711 .
		chmod -R a-w ./*
		chmod -R u+w "${COUNTFILE}" "${TMPDIR}" "${BOTADMIN}" ./*.log 2>/dev/null
		chmod -R o-r,o-w "${COUNTFILE}" "${TMPDIR}" "${TOKENFILE}" "${BOTADMIN}" "${BOTACL}" 2>/dev/null
		ls -la
	fi
}

# get bot name
getBotName() {
	sendJson "" "" "$ME_URL"
	JsonGetString '"result","username"' <<< "$res"
}

ME="$(getBotName)"
if [ "$ME" = "" ]; then
   if [ "$(cat "${TOKENFILE}")" = "bashbottestscript" ]; then
	ME="bashbottestscript"
   else
	echo -e "${RED}ERROR: Can't connect to Telegram Bot! May be your TOKEN is invalid ...${NC}"
	exit 1
   fi
fi

# use phyton JSON to decode JSON UFT-8, provide bash implementaion as fallback
if [ "${BASHBOT_DECODE}" != "" ] && which python >/dev/null 2>&1 ; then
    JsonDecode() {
	printf '"%s\\n"' "${1//\"/\\\"}" | python -c 'import json, sys; sys.stdout.write(json.load(sys.stdin).encode("utf-8"))'
    }
else
    # pure bash implementaion, done by KayM (@gnadelwartz)
    # see https://stackoverflow.com/a/55666449/9381171
    JsonDecode() {
        local out="$1"
        local remain=""
        local regexp='(.*)\\u[dD]([0-9a-fA-F]{3})\\u[dD]([0-9a-fA-F]{3})(.*)'
        while [[ "${out}" =~ $regexp ]] ; do
		# match 2 \udxxx hex values, calculate new U, then split and replace
                local W1=$(( ( 0xd${BASH_REMATCH[2]} & 0x3ff) <<10 ))
                local W2=$(( 0xd${BASH_REMATCH[3]} & 0x3ff ))
                local U=$(( ( W1 | W2 ) + 0x10000 ))
                remain="$(printf '\\U%8.8x' "${U}")${BASH_REMATCH[4]}${remain}"
                out="${BASH_REMATCH[1]}"
        done
        echo -e "${out}${remain}"
    }
fi

# source the script with source as param to use functions in other scripts
# do not execute if read from other scripts

if [ "$1" != "source" ]; then

  ##############
  # internal options only for use from bashbot and developers
  case "$1" in
	"outproc") # forward output from interactive and jobs to chat
		until [ "$line" = "imprettydarnsuredatdisisdaendofdacmd" ];do
			line=""
			read -r -t 10 line
			[ "$line" != "" ] && [ "$line" != "imprettydarnsuredatdisisdaendofdacmd" ] && send_message "$2" "$line"
		done <"${TMPDIR:-.}/$3"
		rm -f -r "${TMPDIR:-.}/$3"
		exit
		;;
	"startbot" )
		start_bot "$2"
		exit
		;;
	"source") # this should never arrive here
		exit
		;;
	"init") # adjust users and permissions
		bot_init
		exit
		;;
	"attach")
		tmux attach -t "$ME"
		exit
		;;
  esac


  ###############
  # "official" arguments as shown to users
  case "$1" in
	"count")
		echo "A total of $(wc -l <"${COUNTFILE}") users used me."
		exit
		;;
	"broadcast")
		NUMCOUNT="$(wc -l <"${COUNTFILE}")"
		echo "Sending the broadcast $* to $NUMCOUNT users."
		[ "$NUMCOUNT" -gt "300" ] && sleep="sleep 0.5"
		shift
		while read -r f; do send_markdown_message "${f//COUNT}" "$*"; $sleep; done <"${COUNTFILE}"
		;;
	"start")
		${CLEAR}
		tmux kill-session -t "$ME" &>/dev/null
		tmux new-session -d -s "$ME" "bash $SCRIPT startbot" && echo -e "${GREEN}Bot started successfully.${NC}"
		echo "Tmux session name $ME" || echo -e "${RED}An error occurred while starting the bot. ${NC}"
		send_markdown_message "${CHAT[ID]}" "*Bot started*"
		;;
	"kill")
		${CLEAR}
		tmux kill-session -t "$ME" &>/dev/null
		send_markdown_message "${CHAT[ID]}" "*Bot stopped*"
		echo -e "${GREEN}OK. Bot stopped successfully.${NC}"
		;;
	"background" | "resumeback")
		${CLEAR}
		echo -e "${GREEN}Restart background processes ...${NC}"
		for FILE in "${TMPDIR:-.}/"*-back.cmd; do
		    if [ "${FILE}" = "${TMPDIR:-.}/*-back.cmd" ]; then
			echo -e "${RED}No background processes to start.${NC}"; break
		    else
			RESTART="$(< "${FILE}")"
			CHAT[ID]="${RESTART%%:*}"
			JOB="${RESTART#*:}"
			PROG="${JOB#*:}"
			JOB="${JOB%:*}"
			fifo="back-${JOB}-${ME}_${CHAT[ID]}" # compose fifo from jobname, $ME (botname) and CHAT[ID] 
			echo "restartbackground  ${PROG}  ${fifo}"
			( tmux kill-session -t "${fifo}"; tmux kill-session -t "sendprocess_${fifo}"; rm -f -r "${TMPDIR:-.}/${fifo}") 2>/dev/null
			mkfifo "${TMPDIR:-.}/${fifo}"
			tmux new-session -d -s "${fifo}" "${PROG} &>${TMPDIR:-.}/${fifo}; echo imprettydarnsuredatdisisdaendofdacmd>${TMPDIR:-.}/${fifo}"
			tmux new-session -d -s "sendprocess_${fifo}" "bash $SCRIPT outproc ${CHAT[ID]} ${fifo}"
		    fi
		done
		;;
	"killback" | "suspendback")
		${CLEAR}
		echo -e "${GREEN}Stopping background processes ...${NC}"
		for FILE in "${TMPDIR:-.}/"*-back.cmd; do
		    if [ "${FILE}" = "${TMPDIR:-.}/*-back.cmd" ]; then
			echo -e "${RED}No background processes.${NC}"; break
		    else
			REMOVE="$(< "${FILE}")"
			JOB="${REMOVE#*:}"
			fifo="back-${JOB%:*}-${ME}_${REMOVE%%:*}"
			echo "killbackground  ${fifo}"
			[ "$1" = "killback" ] && rm -f "${FILE}" # remove job
			( tmux kill-session -t "${fifo}"; tmux kill-session -t "sendprocess_${fifo}"; rm -f -r "${TMPDIR:-.}/${fifo}") 2>/dev/null
		    fi
		done
		;;
	"help")
		${CLEAR}
		less "README.txt"
		exit
		;;
	*)
		echo -e "${RED}${ME}: BAD REQUEST${NC}"
		echo -e "${RED}Available arguments: start, kill, count, broadcast, help, suspendback, resumeback, killback${NC}"
		exit 4
		;;
  esac

  # warn if root
  if [[ "$(id -u)" -eq "0" ]] ; then
	echo -e "\\n${ORANGE}WARNING: ${SCRIPT} was started as ROOT (UID 0)!${NC}"
	echo -e "${ORANGE}You are at HIGH RISK when processing user input with root privilegs!${NC}"
  fi
fi # end source
