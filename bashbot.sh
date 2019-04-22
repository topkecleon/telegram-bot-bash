#!/bin/bash

# bashbot, the Telegram bot written in bash.
# Written by Drew (@topkecleon) and Daniil Gentili (@danogentili), KayM (@gnadelwartz).
# Also contributed: JuanPotato, BigNerd95, TiagoDanin, iicc1.
# https://github.com/topkecleon/telegram-bot-bash

# Depends on JSON.sh (http://github.com/dominictarr/JSON.sh) (MIT/Apache),
# and on tmux (http://github.com/tmux/tmux) (BSD).
# This file is public domain in the USA and all free countries.
# Elsewhere, consider it to be WTFPLv2. (wtfpl.net/txt/copying)
#
#### $$VERSION$$ 0.70-dev-26-gbca3e59
#
# Exit Codes:
# - 0 sucess (hopefully)
# - 1 can't change to dir
# - 2 can't write to tmp, count or token 
# - 3 user / command not found
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

# get location of bashbot.sh an change to bashbot dir
SCRIPT="./$(basename "$0")"
SCRIPTDIR="$(dirname "$0")"
RUNUSER="${USER}" # USER is overwritten by bashbot array, $USER may not work later on...

if [ "$1" != "source" ] && ! cd "${SCRIPTDIR}" ; then
	echo -e "${RED}ERROR: Can't change to ${SCRIPTDIR} ...${NC}"
	exit 1
fi

if [ ! -w "." ]; then
	echo -e "${ORANGE}WARNING: ${SCRIPTDIR} is not writeable!${NC}"
	ls -ld .
fi

TOKENFILE="./token"
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

JSONSHFILE="JSON.sh/JSON.sh"
if [ ! -f "${JSONSHFILE}" ]; then
	echo "Seems to be first run, Downloading ${JSONSHFILE}..."
	mkdir "JSON.sh" 2>/dev/null;
	curl -sL -o "${JSONSHFILE}" "https://cdn.jsdelivr.net/gh/dominictarr/JSON.sh/JSON.sh"
	chmod +x "${JSONSHFILE}" 
fi

BOTADMIN="./botadmin"
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
   fi
fi

BOTACL="./botacl"
if [ ! -f "${BOTACL}" ]; then
	echo -e "${ORANGE}Create empty ${BOTACL} file.${NC}"
	echo "" >"${BOTACL}"
fi

TMPDIR="./tmp-bot-bash"
if [ ! -d "${TMPDIR}" ]; then
	mkdir "${TMPDIR}"
elif [ ! -w "${TMPDIR}" ]; then
	${CLEAR}
	echo -e "${RED}ERROR: Can't write to ${TMPDIR}!.${NC}"
	ls -ld "${TMPDIR}"
	exit 2
fi

COUNTFILE="./count"
if [ ! -f "${COUNTFILE}" ]; then
	echo "" >"${COUNTFILE}"
elif [ ! -w "${COUNTFILE}" ]; then
	${CLEAR}
	echo -e "${RED}ERROR: Can't write to ${COUNTFILE}!.${NC}"
	ls -l "${COUNTFILE}"
	exit 2
fi

COMMANDS="./commands.sh"
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
INLINE_QUERY=$URL'/answerInlineQuery'
ME_URL=$URL'/getMe'
DELETE_URL=$URL'/deleteMessage'
GETMEMBER_URL=$URL'/getChatMember'


FILE_URL='https://api.telegram.org/file/bot'$BOTTOKEN'/'
UPD_URL=$URL'/getUpdates?offset='
GET_URL=$URL'/getFile'
OFFSET=0
declare -A USER MESSAGE URLS CONTACT LOCATION CHAT FORWARD REPLYTO



send_message() {
	local text arg keyboard file lat long title address sent
	[ "$2" = "" ] && return 1
	local chat="$1"
	text="$(echo "$2" | sed 's/ mykeyboardstartshere.*//g;s/ myfilelocationstartshere.*//g;s/ mylatstartshere.*//g;s/ mylongstartshere.*//g;s/ mytitlestartshere.*//g;s/ myaddressstartshere.*//g;s/ mykeyboardendshere.*//g')"
	arg="$3"
	[ "$arg" != "safe" ] && {
		text="${text// mynewlinestartshere /$'\r\n'}"
		no_keyboard="$(echo "$2" | sed '/mykeyboardendshere/!d;s/.*mykeyboardendshere.*/mykeyboardendshere/')"

		keyboard="$(echo "$2" | sed '/mykeyboardstartshere /!d;s/.*mykeyboardstartshere //g;s/ myfilelocationstartshere.*//g;s/ mylatstartshere.*//g;s/ mylongstartshere.*//g;s/ mytitlestartshere.*//g;s/ myaddressstartshere.*//g;s/ mykeyboardendshere.*//g')"

		file="$(echo "$2" | sed '/myfilelocationstartshere /!d;s/.*myfilelocationstartshere //g;s/ mykeyboardstartshere.*//g;s/ mylatstartshere.*//g;s/ mylongstartshere.*//g;s/ mytitlestartshere.*//g;s/ myaddressstartshere.*//g;s/ mykeyboardendshere.*//g')"

		lat="$(echo "$2" | sed '/mylatstartshere /!d;s/.*mylatstartshere //g;s/ mykeyboardstartshere.*//g;s/ myfilelocationstartshere.*//g;s/ mylongstartshere.*//g;s/ mytitlestartshere.*//g;s/ myaddressstartshere.*//g;s/ mykeyboardendshere.*//g')"

		long="$(echo "$2" | sed '/mylongstartshere /!d;s/.*mylongstartshere //g;s/ mykeyboardstartshere.*//g;s/ myfilelocationstartshere.*//g;s/ mylatstartshere.*//g;s/ mytitlestartshere.*//g;s/ myaddressstartshere.*//g;s/ mykeyboardendshere.*//g')"

		title="$(echo "$2" | sed '/mytitlestartshere /!d;s/.*mylongstartshere //g;s/ mykeyboardstartshere.*//g;s/ myfilelocationstartshere.*//g;s/ mylatstartshere.*//g;s/ myaddressstartshere.*//g;s/ mykeyboardendshere.*//g')"

		address="$(echo "$2" | sed '/myaddressstartshere /!d;s/.*mylongstartshere //g;s/ mykeyboardstartshere.*//g;s/ myfilelocationstartshere.*//g;s/ mylatstartshere.*//g;s/ mytitlestartshere.*//g;s/ mykeyboardendshere.*//g')"

	}
	if [ "$no_keyboard" != "" ]; then
		echo "remove_keyboard $chat $text" > ${TMPDIR:-.}/prova
		remove_keyboard "$chat" "$text"
		sent=y
	fi
	if [ "$keyboard" != "" ]; then
		if [[ "$keyboard" != *"["* ]]; then # pre 0.60 style
			keyboard="[ ${keyboard//\" \"/\" \] , \[ \"} ]"
		fi
		send_keyboard "$chat" "$text" "$keyboard"
		sent=y
	fi
	if [ "$file" != "" ]; then
		send_file "$chat" "$file" "$text"
		sent=y
	fi
	if [ "$lat" != "" ] && [ "$long" != "" ] && [ "$address" = "" ] && [ "$title" = "" ]; then
		send_location "$chat" "$lat" "$long"
		sent=y
	fi
	if [ "$lat" != "" ] && [ "$long" != "" ] && [ "$address" != "" ] && [ "$title" != "" ]; then
		send_venue "$chat" "$lat" "$long" "$title" "$address"
		sent=y
	fi
	if [ "$sent" != "y" ];then
		send_text "$chat" "$text"
	fi

}

send_text() {
	case "$2" in
		html_parse_mode*)
			send_html_message "$1" "${2//html_parse_mode}"
			;;
		markdown_parse_mode*)
			send_markdown_message "$1" "${2//markdown_parse_mode}"
			;;
		*)
			send_normal_message "$1" "$2"
			;;
	esac
}

send_normal_message() {
	text="$2"
	until [ "$(echo -n "$text" | wc -m)" -eq "0" ]; do
		res="$(curl -s "$MSG_URL" -d "chat_id=$1" --data-urlencode "text=${text:0:4096}")"
		text="${text:4096}"
	done
}

send_markdown_message() {
	text="$2"
	until [ "$(echo -n "$text" | wc -m)" -eq "0" ]; do
		res="$(curl -s "$MSG_URL" -d "chat_id=$1" --data-urlencode "text=${text:0:4096}" -d "parse_mode=markdown" -d "disable_web_page_preview=true")"
		text="${text:4096}"
	done
}

send_html_message() {
	text="$2"
	until [ "$(echo -n "$text" | wc -m)" -eq "0" ]; do
		res="$(curl -s "$MSG_URL" -d "chat_id=$1" --data-urlencode "text=${text:0:4096}" -d "parse_mode=html")"
		text="${text:4096}"
	done
}

delete_message() {
        res="$(curl -s "$DELETE_URL" -F "chat_id=$1" -F "message_id=$2")"
}

# usage: status="$(get_chat_member_status "chat" "user")"
get_chat_member_status() {
	curl -s "$GETMEMBER_URL" -F "chat_id=$1" -F "user_id=$2" | "./${JSONSHFILE}" -s -b -n | sed -n -e '/\["result","status"\]/  s/.*\][ \t]"\(.*\)"$/\1/p'
}

kick_chat_member() {
	res="$(curl -s "$KICK_URL" -F "chat_id=$1" -F "user_id=$2")"
}

unban_chat_member() {
	res="$(curl -s "$UNBAN_URL" -F "chat_id=$1" -F "user_id=$2")"
}

leave_chat() {
	res="$(curl -s "$LEAVE_URL" -F "chat_id=$1")"
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

answer_inline_query() {
	case "$2" in
		"article")
			InlineQueryResult='[{"type":"'$2'","id":"'$RANDOM'","title":"'$3'","message_text":"'$4'"}]'
		;;
		"photo")
			InlineQueryResult='[{"type":"'$2'","id":"'$RANDOM'","photo_url":"'$3'","thumb_url":"'$4'"}]'
		;;
		"gif")
			InlineQueryResult='[{"type":"'$2'","id":"'$RANDOM'","gif_url":"'$3'", "thumb_url":"'$4'"}]'
		;;
		"mpeg4_gif")
			InlineQueryResult='[{"type":"'$2'","id":"'$RANDOM'","mpeg4_url":"'$3'"}]'
		;;
		"video")
			InlineQueryResult='[{"type":"'$2'","id":"'$RANDOM'","video_url":"'$3'","mime_type":"'$4'","thumb_url":"'$5'","title":"'$6'"}]'
		;;
		"audio")
			InlineQueryResult='[{"type":"'$2'","id":"'$RANDOM'","audio_url":"'$3'","title":"'$4'"}]'
		;;
		"voice")
			InlineQueryResult='[{"type":"'$2'","id":"'$RANDOM'","voice_url":"'$3'","title":"'$4'"}]'
		;;
		"document")
			InlineQueryResult='[{"type":"'$2'","id":"'$RANDOM'","title":"'$3'","caption":"'$4'","document_url":"'$5'","mime_type":"'$6'"}]'
		;;
		"location")
			InlineQueryResult='[{"type":"'$2'","id":"'$RANDOM'","latitude":"'$3'","longitude":"'$4'","title":"'$5'"}]'
		;;
		"venue")
			InlineQueryResult='[{"type":"'$2'","id":"'$RANDOM'","latitude":"'$3'","longitude":"'$4'","title":"'$5'","address":"'$6'"}]'
		;;
		"contact")
			InlineQueryResult='[{"type":"'$2'","id":"'$RANDOM'","phone_number":"'$3'","first_name":"'$4'"}]'
		;;

		# Cached media stored in Telegram server

		"cached_photo")
			InlineQueryResult='[{"type":"photo","id":"'$RANDOM'","photo_file_id":"'$3'"}]'
		;;
		"cached_gif")
			InlineQueryResult='[{"type":"gif","id":"'$RANDOM'","gif_file_id":"'$3'"}]'
		;;
		"cached_mpeg4_gif")
			InlineQueryResult='[{"type":"mpeg4_gif","id":"'$RANDOM'","mpeg4_file_id":"'$3'"}]'
		;;
		"cached_sticker")
			InlineQueryResult='[{"type":"sticker","id":"'$RANDOM'","sticker_file_id":"'$3'"}]'
		;;
		"cached_document")
			InlineQueryResult='[{"type":"document","id":"'$RANDOM'","title":"'$3'","document_file_id":"'$4'"}]'
		;;
		"cached_video")
			InlineQueryResult='[{"type":"video","id":"'$RANDOM'","video_file_id":"'$3'","title":"'$4'"}]'
		;;
		"cached_voice")
			InlineQueryResult='[{"type":"voice","id":"'$RANDOM'","voice_file_id":"'$3'","title":"'$4'"}]'
		;;
		"cached_audio")
			InlineQueryResult='[{"type":"audio","id":"'$RANDOM'","audio_file_id":"'$3'"}]'
		;;

	esac

	res="$(curl -s "$INLINE_QUERY" -F "inline_query_id=$1" -F "results=$InlineQueryResult")"

}


old_send_keyboard() {
	local chat="$1"
	local text="$2"
	shift 2
	local keyboard=init
	OLDIFS=$IFS
	IFS=$(echo -en "\"")
	for f in "$@" ;do [ "$f" != " " ] && keyboard="$keyboard, [\"$f\"]";done
	IFS=$OLDIFS
	keyboard=${keyboard/init, /}
	res="$(curl -s "$MSG_URL" --header "content-type: multipart/form-data" -F "chat_id=$chat" -F "text=$text" -F "reply_markup={\"keyboard\": [$keyboard],\"one_time_keyboard\": true}")"
}

send_keyboard() {
	if [[ "$3" != *'['* ]]; then old_send_keyboard "$@"; return; fi
	local chat="$1"
	local text="$2"
	local keyboard="$3"
	res="$(curl -s "$MSG_URL" --header "content-type: multipart/form-data" -F "chat_id=$chat" -F "text=$text" -F "reply_markup={\"keyboard\": [${keyboard}],\"one_time_keyboard\": true}")"
}

remove_keyboard() {
	local chat="$1"
	local text="$2"
	shift 2
	res="$(curl -s "$MSG_URL" --header "content-type: multipart/form-data" -F "chat_id=$chat"  -F "text=$text" -F "reply_markup={\"remove_keyboard\": true}")"
}

get_file() {
	[ "$1" = "" ] && return
	echo "${FILE_URL}$(curl -s "${GET_URL}" -F "file_id=$1" | "./${JSONSHFILE}" -s -b -n | grep '\["result","file_path"\]' | cut -f 2 | cut -d '"' -f 2)"
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
	res="$(curl -s "$ACTION_URL" -F "chat_id=$1" -F "action=$2")"
}

send_location() {
	[ "$3" = "" ] && return
	res="$(curl -s "$LOCATION_URL" -F "chat_id=$1" -F "latitude=$2" -F "longitude=$3")"
}

send_venue() {
	[ "$5" = "" ] && return
	[ "$6" != "" ] add="-F \"foursquare_id=$6\""
	res="$(curl -s "$VENUE_URL" -F "chat_id=$1" -F "latitude=$2" -F "longitude=$3" -F "title=$4" -F "address=$5")"
}


forward_message() {
	[ "$3" = "" ] && return
	res="$(curl -s "$FORWARD_URL" -F "chat_id=$1" -F "from_chat_id=$2" -F "message_id=$3")"
}
forward() { # backward compatibility
	forward_message "$@" || return
}

background() {
	echo "${CHAT[ID]}:$2:$1" >"${TMPDIR:-.}/${copname}$2-back.cmd"
	startproc "$1" "back-$2-"
}

startproc() {
	killproc "$2"
	local fifo="$2${copname}"
	mkfifo "${TMPDIR:-.}/${fifo}"
	tmux new-session -d -s "${fifo}" "$1 &>${TMPDIR:-.}/${fifo}; echo imprettydarnsuredatdisisdaendofdacmd>${TMPDIR:-.}/${fifo}"
	tmux new-session -d -s "sendprocess_${fifo}" "bash $SCRIPT outproc ${CHAT[ID]} ${fifo}"
}


checkback() {
	checkproc "back-$1-"
}

checkproc() {
	tmux ls | grep -q "$1${copname}"; res=$?; return $?
}

killback() {
	killproc "back-$1-"
	rm -f "${TMPDIR:-.}/${copname}$1-back.cmd"
}

killproc() {
	local fifo="$1${copname}"
	(tmux kill-session -t "${fifo}"; echo imprettydarnsuredatdisisdaendofdacmd>"${TMPDIR:-.}/${fifo}"; tmux kill-session -t "sendprocess_${fifo}"; rm -f -r "${TMPDIR:-.}/${fifo}")2>/dev/null
}

inproc() {
	tmux send-keys -t "$copname" "${MESSAGE[0]} ${URLS[*]}
"
}
process_updates() {
	MAX_PROCESS_NUMBER=$(echo "$UPDATE" | sed '/\["result",[0-9]*\]/!d' | tail -1 | sed 's/\["result",//g;s/\].*//g')
	for ((PROCESS_NUMBER=0; PROCESS_NUMBER<=MAX_PROCESS_NUMBER; PROCESS_NUMBER++)); do
		if [ "$1" = "test" ]; then
			process_client "$1"
		else
			process_client "$1" &
		fi
	done
}
process_client() {
	process_message "$PROCESS_NUMBER"
	# Tmux
	copname="$ME"_"${CHAT[ID]}"
	source commands.sh
	tmpcount="COUNT${CHAT[ID]}"
	grep -q "$tmpcount" <"${COUNTFILE}" >/dev/null 2>&1 || echo "$tmpcount">>${COUNTFILE}
	# To get user count execute bash bashbot.sh count
}
JsonGetString() {
	sed -n -e '0,/\['"$1"'\]/ s/\['"$1"'\][ \t]"\(.*\)"$/\1/p'
}
JsonGetLine() {
	sed -n -e '0,/\['"$1"'\]/ s/\['"$1"'\]\][ \t]//p'
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
	CONTACT[NUMBER]="$(JsonDecode "$(JsonGetString '"result",'"${num}"',"message","contact","phone_number"' <"$TMP")")"
	CONTACT[FIRST_NAME]="$(JsonDecode "$(JsonGetString '"result",'"${num}"',"message","contact","first_name"' <"$TMP")")"
	CONTACT[LAST_NAME]="$(JsonDecode "$(JsonGetString '"result",'"${num}"',"message","contact","last_name"' <"$TMP")")"
	CONTACT[USER_ID]="$(JsonDecode "$(JsonGetString '"result",'"${num}"',"message","contact","user_id"' <"$TMP")")"

	# Caption
	CAPTION="$(JsonDecode "$(JsonGetString '"result",'"${num}"',"message","caption"' <"$TMP")")"

	# Location
	LOCATION[LONGITUDE]="$(JsonGetValue '"result",'"${num}"',"message","location","longitude"' <"$TMP")"
	LOCATION[LATITUDE]="$(JsonGetValue '"result",'"${num}"',"message","location","latitude"' <"$TMP")"
	NAME="$(echo "${URLS[*]}" | sed 's/.*\///g')"
	rm "$TMP"
}
# get bot name
getBotName() {
	res="$(curl -s "$ME_URL")"
	echo "$res" | "./${JSONSHFILE}" -s -b -n | JsonGetString '"result","username"'
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
if [ "${BASHDECODE}" != "yes" ] && which python >/dev/null 2>&1 ; then
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
                local W1="$(( ( 0xd${BASH_REMATCH[2]} & 0x3ff) <<10 ))"
                local W2="$(( 0xd${BASH_REMATCH[3]} & 0x3ff ))"
                U="$(( ( W1 | W2 ) + 0x10000 ))"
                remain="$(printf '\\U%8.8x' "${U}")${BASH_REMATCH[4]}${remain}"
                out="${BASH_REMATCH[1]}"
        done
        echo -e "${out}${remain}"
    }
fi

# source the script with source as param to use functions in other scripts
# do not execute if read from other scripts

if [ "$1" != "source" ]; then
  while [ "$1" = "startbot" ]; do {

	UPDATE="$(curl -s "$UPD_URL$OFFSET" | ./${JSONSHFILE})"

	# Offset
	OFFSET="$(echo "$UPDATE" | grep '\["result",[0-9]*,"update_id"\]' | tail -1 | cut -f 2)"
	OFFSET=$((OFFSET+1))

	if [ "$OFFSET" != "1" ]; then
		if [ "$2" = "test" ]; then
			process_updates "$2"
		else
			process_updates "$2" &
		fi
	fi

  }; done


  case "$1" in
	"outproc")
		until [ "$line" = "imprettydarnsuredatdisisdaendofdacmd" ];do
			line=""
			read -r -t 10 line
			[ "$line" != "" ] && [ "$line" != "imprettydarnsuredatdisisdaendofdacmd" ] && send_message "$2" "$line"
		done <"${TMPDIR:-.}/$3"
		rm -f -r "${TMPDIR:-.}/$3"
		;;
	"count")
		echo "A total of $(wc -l <"${COUNTFILE}") users used me."
		exit
		;;
	"broadcast")
		NUMCOUNT="$(wc -l <"${COUNTFILE}")"
		echo "Sending the broadcast $* to $NUMCOUNT users."
		[ "$NUMCOUNT" -gt "300" ] && sleep="sleep 0.5"
		shift
		while read -r f; do send_message "${f//COUNT}" "$*"; $sleep; done <"${COUNTFILE}"
		;;
	"start")
		${CLEAR}
		tmux kill-session -t "$ME" &>/dev/null
		tmux new-session -d -s "$ME" "bash $SCRIPT startbot" && echo -e "${GREEN}Bot started successfully.${NC}"
		echo "Tmux session name $ME" || echo -e "${RED}An error occurred while starting the bot. ${NC}"
		send_markdown_message "${CHAT[ID]}" "*Bot started*"
		;;
	"init") # adjust users and permissions
		[[ "$(id -u)" -eq "0" ]] && RUNUSER="nobody"
		echo -n "Enter User to run basbot [$RUNUSER]: "
		read -r TOUSER
		[ "$TOUSER" = "" ] && TOUSER="$RUNUSER"
		if ! compgen -u "$TOUSER" >/dev/null 2>&1; then
			echo -e "${RED}User \"$TOUSER\" not found!${NC}"
			exit 3
		else
			echo "Adjusting user \"${TOUSER}\" files and permissions ..."
			sed -i '/^[# ]*runas=/ s/runas=.*$/runas="'$TOUSER'"/' bashbot.rc
			chown -R "$TOUSER" . ./*
			chmod 711 .
			chmod -R a-w ./*
			chmod -R u+w "${COUNTFILE}" "${TMPDIR}" "${BOTADMIN}" ./*.log 2>/dev/null
			chmod -R o-r,o-w "${COUNTFILE}" "${TMPDIR}" "${TOKENFILE}" "${BOTADMIN}" "${BOTACL}" 2>/dev/null
			ls -la
			exit			
		fi
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
	"kill")
		${CLEAR}
		tmux kill-session -t "$ME" &>/dev/null
		send_markdown_message "${CHAT[ID]}" "*Bot stopped*"
		echo -e "${GREEN}OK. Bot stopped successfully.${NC}"
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
	"attach")
		tmux attach -t "$ME"
		;;
	"source")
		# this should never happen
		echo "OK" 
		;;
	*)
		echo -e "${RED}${ME}: BAD REQUEST${NC}"
		echo -e "${RED}Available arguments: outproc, count, broadcast, start, suspendback, resumeback, kill, killback, help, attach${NC}"
		exit 4
		;;
  esac

  # warn if root
  if [[ "$(id -u)" -eq "0" ]] ; then
	echo -e "\\n${ORANGE}WARNING: ${SCRIPT} was started as ROOT (UID 0)!${NC}"
	echo -e "${ORANGE}You are at HIGH RISK when processing user input with root privilegs!${NC}"
  fi
fi # end source
