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
#### $$VERSION$$ v0.52-0-gdb7b19f
#
# Exit Codes:
# - 0 sucess (hopefully)
# - 1 can't change to dir
# - 2 can't write to tmp, count or token 
# - 3 user not found
# - 4 unkown command

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

if ! cd "${SCRIPTDIR}" ; then
	echo -e "${RED}ERROR: Can't change to ${SCRIPTDIR} ...${NC}"
	exit 1
fi

if [ ! -w "." ]; then
	echo -e "${ORANGE}WARNING: ${SCRIPTDIR} is not writeable!${NC}"
	ls -ld .
fi

if [ ! -f "JSON.sh/JSON.sh" ]; then
	echo "You did not clone recursively! Downloading JSON.sh..."
	git clone http://github.com/dominictarr/JSON.sh
	echo "JSON.sh has been downloaded. Proceeding."
fi

TOKEN="./token"
if [ ! -f "${TOKEN}" ]; then
   if [ "${CLEAR}" == "" ]; then
	echo "Running headless, run ${SCRIPT} init first!"
	exit 2 
   else
	${CLEAR}
	echo -e "${RED}TOKEN MISSING.${NC}"
	echo -e "${ORANGE}PLEASE WRITE YOUR TOKEN HERE${NC}"
	read -r token
	echo "${token}" > "${TOKEN}"
   fi
fi

BOTADMIN="./botadmin"
if [ ! -f "${BOTADMIN}" ]; then
   if [ "${CLEAR}" == "" ]; then
	echo "Running headless, set botadmin to AUTO MODE!"
	echo "?" > "${BOTADMIN}"
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
	touch "${BOTACL}"
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

COUNT="./count"
if [ ! -f "${COUNT}" ]; then
	touch "${COUNT}"
elif [ ! -w "${COUNT}" ]; then
	${CLEAR}
	echo -e "${RED}ERROR: Can't write to ${COUNT}!.${NC}"
	ls -l "${COUNT}"
	exit 2
fi


source "commands.sh" "source"
URL='https://api.telegram.org/bot'$TOKEN


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
ME="$(curl -s "$ME_URL" | ./JSON.sh/JSON.sh -s | grep '\["result","username"\]' | cut -f 2 | cut -d '"' -f 2)"


FILE_URL='https://api.telegram.org/file/bot'$TOKEN'/'
UPD_URL=$URL'/getUpdates?offset='
GET_URL=$URL'/getFile'
OFFSET=0
declare -A USER MESSAGE URLS CONTACT LOCATION CHAT FORWARD REPLYTO

urlencode() {
	echo "$*" | sed 's:%:%25:g;s: :%20:g;s:<:%3C:g;s:>:%3E:g;s:#:%23:g;s:{:%7B:g;s:}:%7D:g;s:|:%7C:g;s:\\:%5C:g;s:\^:%5E:g;s:~:%7E:g;s:\[:%5B:g;s:\]:%5D:g;s:`:%60:g;s:;:%3B:g;s:/:%2F:g;s:?:%3F:g;s^:^%3A^g;s:@:%40:g;s:=:%3D:g;s:&:%26:g;s:\$:%24:g;s:\!:%21:g;s:\*:%2A:g'
}


send_message() {
	local text arg keyboard file lat long title address sent
	[ "$2" = "" ] && return 1
	local chat="$1"
	text="$(echo "$2" | sed 's/ mykeyboardstartshere.*//g;s/ myfilelocationstartshere.*//g;s/ mylatstartshere.*//g;s/ mylongstartshere.*//g;s/ mytitlestartshere.*//g;s/ myaddressstartshere.*//g;s/ mykeyboardendshere.*//g')"
	arg="$3"
	[ "$arg" != "safe" ] && {
		#text="$(echo "$text" | sed 's/ mynewlinestartshere /\r\n/g')" # hack for linebreaks in startproc scripts
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
	curl -s "$GETMEMBER_URL" -F "chat_id=$1" -F "user_id=$2" | ./JSON.sh/JSON.sh -s | sed -n -e '/\["result","status"\]/  s/.*\][ \t]"\(.*\)"$/\1/p'
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
	if [ "${1:--}" == "${2:-+}" ] || [ "$(get_chat_member_status "$1" "$2")" == "creator" ]; then return 0; fi
	return 1 
}

user_is_admin() {
	local me; me="$(get_chat_member_status "$1" "$2")"
	if [ "${me}" == "creator" ] || [ "${me}" == "administrator" ]; then return 0; fi
	return 1 
}

user_is_botadmin() {
	local admin; admin="$(head -n 1 "${BOTADMIN}")"
	[ "${admin}" == "${1}" ] && return 0
	[[ "${admin}" == "@*" ]] && [[ "${admin}" == "${2}" ]] && return 0
	if [ "${admin}" == "?" ]; then echo "${1:-?}" >"${BOTADMIN}"; return 0; fi
	return 1
}

user_is_allowed() {
	local acl; acl="$1"
	[ "$1" == "" ] && return 1
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

send_keyboard() {
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

remove_keyboard() {
	local chat="$1"
	local text="$2"
	shift 2
	res="$(curl -s "$MSG_URL" --header "content-type: multipart/form-data" -F "chat_id=$chat"  -F "text=$text" -F "reply_markup={\"remove_keyboard\": true}")"
}

get_file() {
	[ "$1" != "" ] && echo "$FILE_URL$(curl -s "$GET_URL" -F "file_id=$1" | ./JSON.sh/JSON.sh -s | grep '\["result","file_path"\]' | cut -f 2 | cut -d '"' -f 2)"
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


forward() {
	[ "$3" = "" ] && return
	res="$(curl -s "$FORWARD_URL" -F "chat_id=$1" -F "from_chat_id=$2" -F "message_id=$3")"
}


background() {
	echo "${CHAT[ID]}:$2:$1" >"${TMPDIR:-.}/${copname}$2-back.cmd"
	startproc "$1" "back-$2-"
}

startproc() {
	killproc "$2"
	local fifo="$2${copname}" # add $1 to copname, so we can have more than one running script per chat
	mkfifo "${TMPDIR:-.}/${fifo}"
	tmux new-session -d -s "${fifo}" "$1 &>${TMPDIR:-.}/${fifo}; echo imprettydarnsuredatdisisdaendofdacmd>${TMPDIR:-.}/${fifo}"
	tmux new-session -d -s "sendprocess_${fifo}" "bash $SCRIPT outproc ${CHAT[ID]} ${fifo}"
}


checkback() {
	checkproc "back-$1-"
}

checkproc() {
	tmux ls | grep -q "$1${copname}"; res=$?
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
		if [ "$1" == "test" ]; then
			process_client "$1"
		else
			process_client "$1" &
		fi
	done
}
process_client() {
	local TMP="${TMPDIR:-.}/$RANDOM$RANDOM-MESSAGE"
	echo "$UPDATE" >"$TMP"
	# Message
	MESSAGE[0]="$(echo -e "$(sed -n -e '/\["result",'$PROCESS_NUMBER',"message","text"\]/  s/.*\][ \t]"\(.*\)"$/\1/p' <"$TMP")" | sed 's#\\/#/#g')"
	MESSAGE[ID]="$(sed -n -e '/\["result",'$PROCESS_NUMBER',"message","message_id"\]/ s/.*\][ \t]//p' <"$TMP" )"

	# Chat
	CHAT[ID]="$(sed -n -e  '/\["result",'$PROCESS_NUMBER',"message","chat","id"\]/ s/.*\][ \t]//p' <"$TMP" )"
	CHAT[FIRST_NAME]="$(sed -n -e '/\["result",'$PROCESS_NUMBER',"message","chat","first_name"\]/  s/.*\][ \t]"\(.*\)"$/\1/p' <"$TMP")"
	CHAT[LAST_NAME]="$(sed -n -e '/\["result",'$PROCESS_NUMBER',"message","chat","last_name"\]/  s/.*\][ \t]"\(.*\)"$/\1/p' <"$TMP")"
	CHAT[USERNAME]="$(sed -n -e '/\["result",'$PROCESS_NUMBER',"message","chat","username"\]/  s/.*\][ \t]"\(.*\)"$/\1/p' <"$TMP")"
	CHAT[TITLE]="$(sed -n -e '/\["result",'$PROCESS_NUMBER',"message","chat","title"\]/  s/.*\][ \t]"\(.*\)"$/\1/p' <"$TMP")"
	CHAT[TYPE]="$(sed -n -e '/\["result",'$PROCESS_NUMBER',"message","chat","type"\]/  s/.*\][ \t]"\(.*\)"$/\1/p' <"$TMP")"
	CHAT[ALL_MEMBERS_ARE_ADMINISTRATORS]="$(sed -n -e '/\["result",'$PROCESS_NUMBER',"message","chat","all_members_are_administrators"\]/  s/.*\][ \t]"\(.*\)"$/\1/p' <"$TMP")"

	# User
	USER[ID]="$(sed -n -e '/\["result",'$PROCESS_NUMBER',"message","from","id"\]/ s/.*\][ \t]//p' <"$TMP" )"
	USER[FIRST_NAME]="$(sed -n -e '/\["result",'$PROCESS_NUMBER',"message","from","first_name"\]/  s/.*\][ \t]"\(.*\)"$/\1/p' <"$TMP")"
	USER[LAST_NAME]="$(sed -n -e '/\["result",'$PROCESS_NUMBER',"message","from","last_name"\]/  s/.*\][ \t]"\(.*\)"$/\1/p' <"$TMP")"
	USER[USERNAME]="$(sed -n -e '/\["result",'$PROCESS_NUMBER',"message","from","username"\]/  s/.*\][ \t]"\(.*\)"$/\1/p' <"$TMP")"

	# in reply to message from
	REPLYTO[UID]="$(sed -n -e '/\["result",'$PROCESS_NUMBER',"message","reply_to_message","from","id"\]/ s/.*\][ \t]//p' <"$TMP" )"
	if [ "${REPLYTO[UID]}" != "" ]; then
	   REPLYTO[0]="$(sed -n -e '/\["result",'$PROCESS_NUMBER',"message","reply_to_message","text"\]/  s/.*\][ \t]"\(.*\)"$/\1/p' <"$TMP")"
	   REPLYTO[ID]="$(sed -n -e '/\["result",'$PROCESS_NUMBER',"message","reply_to_message","message_id"\/  s/.*\][ \t]"\(.*\)"$/\1/p' <"$TMP")"
	   REPLYTO[FIRST_NAME]="$(sed -n -e '/\["result",'$PROCESS_NUMBER',"message","reply_to_message","from","first_name"\]/  s/.*\][ \t]"\(.*\)"$/\1/p' <"$TMP")"
	   REPLYTO[LAST_NAME]="$(sed -n -e '/\["result",'$PROCESS_NUMBER',"message","reply_to_message","from","last_name"\]/  s/.*\][ \t]"\(.*\)"$/\1/p' <"$TMP")"
	   REPLYTO[USERNAME]="$(sed -n -e '/\["result",'$PROCESS_NUMBER',"message","reply_to_message","from","username"\]/  s/.*\][ \t]"\(.*\)"$/\1/p' <"$TMP")"
	fi

	# forwarded message from
	FORWARD[UID]="$(sed -n -e '/\["result",'$PROCESS_NUMBER',"message","forward_from","id"\]/ s/.*\][ \t]//p' <"$TMP" )"
	if [ "${FORWARD[UID]}" != "" ]; then
	   FORWARD[ID]="${MESSAGE[ID]}" # same as message ID
	   FORWARD[FIRST_NAME]="$(sed -n -e '/\["result",'$PROCESS_NUMBER',"message","forward_from","first_name"\]/  s/.*\][ \t]"\(.*\)"$/\1/p' <"$TMP")"
	   FORWARD[LAST_NAME]="$(sed -n -e '/\["result",'$PROCESS_NUMBER',"message","forward_from","last_name"\]/  s/.*\][ \t]"\(.*\)"$/\1/p' <"$TMP")"
	   FORWARD[USERNAME]="$(sed -n -e '/\["result",'$PROCESS_NUMBER',"message","forward_from","username"\]/  s/.*\][ \t]"\(.*\)"$/\1/p' <"$TMP")"
	fi

	# Audio
	URLS[AUDIO]="$(get_file "$(sed -n -e '/\["result",'$PROCESS_NUMBER',"message","audio","file_id"\]/  s/.*\][ \t]"\(.*\)"$/\1/p' <"$TMP")")"
	# Document
	URLS[DOCUMENT]="$(get_file "$(sed -n -e '/\["result",'$PROCESS_NUMBER',"message","document","file_id"\]/  s/.*\][ \t]"\(.*\)"$/\1/p' <"$TMP")")"
	# Photo
	URLS[PHOTO]="$(get_file "$(sed -n -e '/\["result",'$PROCESS_NUMBER',"message","photo",.*,"file_id"\]/  s/.*\][ \t]"\(.*\)"$/\1/p' <"$TMP")")"
	# Sticker
	URLS[STICKER]="$(get_file "$(sed -n -e '/\["result",'$PROCESS_NUMBER',"message","sticker","file_id"\]/  s/.*\][ \t]"\(.*\)"$/\1/p' <"$TMP")")"
	# Video
	URLS[VIDEO]="$(get_file "$(sed -n -e '/\["result",'$PROCESS_NUMBER',"message","video","file_id"\]/  s/.*\][ \t]"\(.*\)"$/\1/p' <"$TMP")")"
	# Voice
	URLS[VOICE]="$(get_file "$(sed -n -e '/\["result",'$PROCESS_NUMBER',"message","voice","file_id"\]/  s/.*\][ \t]"\(.*\)"$/\1/p' <"$TMP")")"

	# Contact
	CONTACT[NUMBER]="$(sed -n -e '/\["result",'$PROCESS_NUMBER',"message","contact","phone_number"\]/  s/.*\][ \t]"\(.*\)"$/\1/p' <"$TMP")"
	CONTACT[FIRST_NAME]="$(sed -n -e '/\["result",'$PROCESS_NUMBER',"message","contact","first_name"\]/  s/.*\][ \t]"\(.*\)"$/\1/p' <"$TMP")"
	CONTACT[LAST_NAME]="$(sed -n -e '/\["result",'$PROCESS_NUMBER',"message","contact","last_name"\]/  s/.*\][ \t]"\(.*\)"$/\1/p' <"$TMP")"
	CONTACT[USER_ID]="$(sed -n -e '/\["result",'$PROCESS_NUMBER',"message","contact","user_id"\]/  s/.*\][ \t]"\(.*\)"$/\1/p' <"$TMP")"

	# Caption
	CAPTION="$(sed -n -e '/\["result",'$PROCESS_NUMBER',"message","caption"\]/  s/.*\][ \t]"\(.*\)"$/\1/p' <"$TMP")"

	# Location
	LOCATION[LONGITUDE]="$(sed -n -e '/\["result",'$PROCESS_NUMBER',"message","location","longitude"\]/  s/.*\][ \t]"\(.*\)"$/\1/p' <"$TMP")"
	LOCATION[LATITUDE]="$(sed -n -e '/\["result",'$PROCESS_NUMBER',"message","location","latitude"\]/  s/.*\][ \t]"\(.*\)"$/\1/p' <"$TMP")"
	NAME="$(echo "${URLS[*]}" | sed 's/.*\///g')"
	rm "$TMP"

	# Tmux
	copname="$ME"_"${CHAT[ID]}"

	source commands.sh

	tmpcount="COUNT${CHAT[ID]}"
	grep -q "$tmpcount" <"${COUNT}" >/dev/null 2>&1 || echo "$tmpcount">>${COUNT}
	# To get user count execute bash bashbot.sh count
}

# source the script with source as param to use functions in other scripts
while [ "$1" == "startbot" ]; do {

	UPDATE="$(curl -s "$UPD_URL$OFFSET" | ./JSON.sh/JSON.sh)"

	# Offset
	OFFSET="$(echo "$UPDATE" | grep '\["result",[0-9]*,"update_id"\]' | tail -1 | cut -f 2)"
	OFFSET=$((OFFSET+1))

	if [ "$OFFSET" != "1" ]; then
		if [ "$2" == "test" ]; then
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
		echo "A total of $(wc -l <"${COUNT}") users used me."
		exit
		;;
	"broadcast")
		NUMCOUNT="$(wc -l <"${COUNT}")"
		echo "Sending the broadcast $* to $NUMCOUNT users."
		[ "$NUMCOUNT" -gt "300" ] && sleep="sleep 0.5"
		shift
		while read -r f; do send_message "${f//COUNT}" "$*"; $sleep; done <"${COUNT}"
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
			echo "Adjusting user in bashbot.rc ..."
			sed -i '/^[# ]*runas=/ s/runas=.*$/runas="'$TOUSER'"/' bashbot.rc
			echo "Adjusting Owner and Permissions ..."
			chown -R "$TOUSER" . ./*
			chmod 711 .
			chmod -R a-w ./*
			chmod -R u+w "${COUNT}" "${TMPDIR}" "${BOTADMIN}" ./*.log 2>/dev/null
			chmod -R o-r,o-w "${COUNT}" "${TMPDIR}" "${TOKEN}" "${BOTADMIN}" "${BOTACL}" 2>/dev/null
			ls -la
			exit			
		fi
		;;
	"background" | "resumeback")
		${CLEAR}
		echo -e "${GREEN}Restart background processes ...${NC}"
		for FILE in "${TMPDIR:-.}/"*-back.cmd; do
		    if [ "${FILE}" == "${TMPDIR:-.}/*-back.cmd" ]; then
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
		    if [ "${FILE}" == "${TMPDIR:-.}/*-back.cmd" ]; then
			echo -e "${RED}No background processes.${NC}"; break
		    else
			REMOVE="$(< "${FILE}")"
			JOB="${REMOVE#*:}"
			fifo="back-${JOB%:*}-${ME}_${REMOVE%%:*}"
			echo "killbackground  ${fifo}"
			[ "$1" == "killback" ] && rm -f "${FILE}" # remove job
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
		echo "OK"
		exit
		;;
	*)
		echo -e "${RED}BAD REQUEST${NC}"
		echo -e "${RED}Available arguments: outproc, count, broadcast, start, suspendback, resumeback, kill, killback, help, attach${NC}"
		exit 4
		;;
esac

# warn if root
if [[ "$(id -u)" -eq "0" ]] ; then
	echo -e "\\n${ORANGE}WARNING: ${SCRIPT} was started as ROOT (UID 0)!${NC}"
	echo -e "${ORANGE}You are at HIGH RISK when processing user input with root privilegs!${NC}"
fi

