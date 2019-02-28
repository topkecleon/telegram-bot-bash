#!/bin/bash

# bashbot, the Telegram bot written in bash.
# Written by Drew (@topkecleon) and Daniil Gentili (@danogentili).
# Also contributed: JuanPotato, BigNerd95, TiagoDanin, iicc1.
# https://github.com/topkecleon/telegram-bot-bash

# Depends on JSON.sh (http://github.com/dominictarr/JSON.sh) (MIT/Apache),
# and on tmux (http://github.com/tmux/tmux) (BSD).
# This file is public domain in the USA and all free countries.
# Elsewhere, consider it to be WTFPLv2. (wtfpl.net/txt/copying)

if [ ! -f "JSON.sh/JSON.sh" ]; then
	echo "You did not clone recursively! Downloading JSON.sh..."
	git clone http://github.com/dominictarr/JSON.sh
	echo "JSON.sh has been downloaded. Proceeding."
fi

if [ ! -f "token" ]; then
	clear
	echo -e '\e[0;31mTOKEN MISSING.\e[0m'
	echo "PLEASE WRITE YOUR TOKEN HERE"
	read token
	echo "$token" >> token
fi

source commands.sh source
URL='https://api.telegram.org/bot'$TOKEN


SCRIPT="$0"
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
ME=$(curl -s $ME_URL | ./JSON.sh/JSON.sh -s | egrep '\["result","username"\]' | cut -f 2 | cut -d '"' -f 2)


FILE_URL='https://api.telegram.org/file/bot'$TOKEN'/'
UPD_URL=$URL'/getUpdates?offset='
GET_URL=$URL'/getFile'
OFFSET=0
declare -A USER MESSAGE URLS CONTACT LOCATION CHAT

urlencode() {
	echo "$*" | sed 's:%:%25:g;s: :%20:g;s:<:%3C:g;s:>:%3E:g;s:#:%23:g;s:{:%7B:g;s:}:%7D:g;s:|:%7C:g;s:\\:%5C:g;s:\^:%5E:g;s:~:%7E:g;s:\[:%5B:g;s:\]:%5D:g;s:`:%60:g;s:;:%3B:g;s:/:%2F:g;s:?:%3F:g;s^:^%3A^g;s:@:%40:g;s:=:%3D:g;s:&:%26:g;s:\$:%24:g;s:\!:%21:g;s:\*:%2A:g'
}


send_message() {
	[ "$2" = "" ] && return 1
	local chat="$1"
	local text="$(echo "$2" | sed 's/ mykeyboardstartshere.*//g;s/ myfilelocationstartshere.*//g;s/ mylatstartshere.*//g;s/ mylongstartshere.*//g;s/ mytitlestartshere.*//g;s/ myaddressstartshere.*//g;s/ mykeyboardendshere.*//g')"
	local arg="$3"
	[ "$3" != "safe" ] && {
		local no_keyboard="$(echo $2 | sed '/mykeyboardendshere/!d;s/.*mykeyboardendshere.*/mykeyboardendshere/')"

		local keyboard="$(echo "$2" | sed '/mykeyboardstartshere /!d;s/.*mykeyboardstartshere //g;s/ myfilelocationstartshere.*//g;s/ mylatstartshere.*//g;s/ mylongstartshere.*//g;s/ mytitlestartshere.*//g;s/ myaddressstartshere.*//g;s/ mykeyboardendshere.*//g')"

		local file="$(echo "$2" | sed '/myfilelocationstartshere /!d;s/.*myfilelocationstartshere //g;s/ mykeyboardstartshere.*//g;s/ mylatstartshere.*//g;s/ mylongstartshere.*//g;s/ mytitlestartshere.*//g;s/ myaddressstartshere.*//g;s/ mykeyboardendshere.*//g')"

		local lat="$(echo "$2" | sed '/mylatstartshere /!d;s/.*mylatstartshere //g;s/ mykeyboardstartshere.*//g;s/ myfilelocationstartshere.*//g;s/ mylongstartshere.*//g;s/ mytitlestartshere.*//g;s/ myaddressstartshere.*//g;s/ mykeyboardendshere.*//g')"

		local long="$(echo "$2" | sed '/mylongstartshere /!d;s/.*mylongstartshere //g;s/ mykeyboardstartshere.*//g;s/ myfilelocationstartshere.*//g;s/ mylatstartshere.*//g;s/ mytitlestartshere.*//g;s/ myaddressstartshere.*//g;s/ mykeyboardendshere.*//g')"

		local title="$(echo "$2" | sed '/mytitlestartshere /!d;s/.*mylongstartshere //g;s/ mykeyboardstartshere.*//g;s/ myfilelocationstartshere.*//g;s/ mylatstartshere.*//g;s/ myaddressstartshere.*//g;s/ mykeyboardendshere.*//g')"

		local address="$(echo "$2" | sed '/myaddressstartshere /!d;s/.*mylongstartshere //g;s/ mykeyboardstartshere.*//g;s/ myfilelocationstartshere.*//g;s/ mylatstartshere.*//g;s/ mytitlestartshere.*//g;s/ mykeyboardendshere.*//g')"

	}
	if [ "$no_keyboard" != "" ]; then
		echo "remove_keyboard $chat $text" > /tmp/prova
		remove_keyboard "$chat" "$text"
		local sent=y
	fi
	if [ "$keyboard" != "" ]; then
		send_keyboard "$chat" "$text" "$keyboard"
		local sent=y
	fi
	if [ "$file" != "" ]; then
		send_file "$chat" "$file" "$text"
		local sent=y
	fi
	if [ "$lat" != "" -a "$long" != "" -a "$address" = "" -a "$title" = "" ]; then
		send_location "$chat" "$lat" "$long"
		local sent=y
	fi
	if [ "$lat" != "" -a "$long" != "" -a "$address" != "" -a "$title" != "" ]; then
		send_venue "$chat" "$lat" "$long" "$title" "$address"
		local sent=y
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
	until [ $(echo -n "$text" | wc -m) -eq 0 ]; do
		res=$(curl -s "$MSG_URL" -d "chat_id=$1" --data-urlencode "text=${text:0:4096}")
		text="${text:4096}"
	done
}

send_markdown_message() {
	text="$2"
	until [ $(echo -n "$text" | wc -m) -eq 0 ]; do
		res=$(curl -s "$MSG_URL" -d "chat_id=$1" --data-urlencode "text=${text:0:4096}" -d "parse_mode=markdown" -d "disable_web_page_preview=true")
		text="${text:4096}"
	done
}

send_html_message() {
	text="$2"
	until [ $(echo -n "$text" | wc -m) -eq 0 ]; do
		res=$(curl -s "$MSG_URL" -F "chat_id=$1" --data-urlencode "text=${text:0:4096}" -F "parse_mode=html")
		text="${text:4096}"
	done
}

kick_chat_member() {
	res=$(curl -s "$KICK_URL" -F "chat_id=$1" -F "user_id=$2")
}

unban_chat_member() {
	res=$(curl -s "$UNBAN_URL" -F "chat_id=$1" -F "user_id=$2")
}

leave_chat() {
	res=$(curl -s "$LEAVE_URL" -F "chat_id=$1")
}

answer_inline_query() {
	case $2 in
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

	res=$(curl -s "$INLINE_QUERY" -F "inline_query_id=$1" -F "results=$InlineQueryResult")

}

send_keyboard() {
	local chat="$1"
	local text="$2"
	shift 2
	local keyboard=init
	OLDIFS=$IFS
	IFS=$(echo -en "\"")
	for f in $*;do [ "$f" != " " ] && local keyboard="$keyboard, [\"$f\"]";done
	IFS=$OLDIFS
	local keyboard=${keyboard/init, /}
	res=$(curl -s "$MSG_URL" --header "content-type: multipart/form-data" -F "chat_id=$chat" -F "text=$text" -F "reply_markup={\"keyboard\": [$keyboard],\"one_time_keyboard\": true}")
}

remove_keyboard() {
	local chat="$1"
	local text="$2"
	shift 2
	res=$(curl -s "$MSG_URL" --header "content-type: multipart/form-data" -F "chat_id=$chat"  -F "text=$text" -F "reply_markup={\"remove_keyboard\": true}")
}

get_file() {
	[ "$1" != "" ] && echo $FILE_URL$(curl -s "$GET_URL" -F "file_id=$1" | ./JSON.sh/JSON.sh -s | egrep '\["result","file_path"\]' | cut -f 2 | cut -d '"' -f 2)
}

send_file() {
	[ "$2" = "" ] && return
	local chat_id=$1
	local file=$2
	echo "$file" | grep -qE $FILE_REGEX || return
	local ext="${file##*.}"
	case $ext in
        	mp3|flac)
			CUR_URL=$AUDIO_URL
			WHAT=audio
			STATUS=upload_audio
			local CAPTION="$3"
			;;
		png|jpg|jpeg|gif)
			CUR_URL=$PHO_URL
			WHAT=photo
			STATUS=upload_photo
			local CAPTION="$3"
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
			local CAPTION="$3"
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
			local CAPTION="$3"
			;;
	esac
	send_action $chat_id $STATUS
	res=$(curl -s "$CUR_URL" -F "chat_id=$chat_id" -F "$WHAT=@$file" -F "caption=$CAPTION")
}

# typing for text messages, upload_photo for photos, record_video or upload_video for videos, record_audio or upload_audio for audio files, upload_document for general files, find_location for location

send_action() {
	[ "$2" = "" ] && return
	res=$(curl -s "$ACTION_URL" -F "chat_id=$1" -F "action=$2")
}

send_location() {
	[ "$3" = "" ] && return
	res=$(curl -s "$LOCATION_URL" -F "chat_id=$1" -F "latitude=$2" -F "longitude=$3")
}

send_venue() {
	[ "$5" = "" ] && return
	[ "$6" != "" ] add="-F \"foursquare_id=$6\""
	res=$(curl -s "$VENUE_URL" -F "chat_id=$1" -F "latitude=$2" -F "longitude=$3" -F "title=$4" -F "address=$5" $add)
}


forward() {
	[ "$3" = "" ] && return
	res=$(curl -s "$FORWARD_URL" -F "chat_id=$1" -F "from_chat_id=$2" -F "message_id=$3")
}

startproc() {
	killproc
	mkfifo /tmp/$copname
	TMUX= tmux new-session -d -s $copname "$* &>/tmp/$copname; echo imprettydarnsuredatdisisdaendofdacmd>/tmp/$copname"
	TMUX= tmux new-session -d -s sendprocess_$copname "bash $SCRIPT outproc ${CHAT[ID]} $copname"
}

killproc() {
	(tmux kill-session -t $copname; echo imprettydarnsuredatdisisdaendofdacmd>/tmp/$copname; tmux kill-session -t sendprocess_$copname; rm -r /tmp/$copname)2>/dev/null
}

inproc() {
	tmux send-keys -t $copname "$MESSAGE ${URLS[*]}
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
	# Message
	MESSAGE[0]="$(echo -e "$(echo "$UPDATE" | egrep '\["result",'$PROCESS_NUMBER',"message","text"\]' | cut -f 2 | cut -d '"' -f 2)" | sed 's#\\/#/#g')"
	MESSAGE[ID]="$(echo "$UPDATE" | egrep '\["result",'$PROCESS_NUMBER',"message","message_id"\]' | cut -f 2 | cut -d '"' -f 2)"

	# Chat
	CHAT[ID]="$(echo "$UPDATE" | egrep '\["result",'$PROCESS_NUMBER',"message","chat","id"\]' | cut -f 2)"
	CHAT[FIRST_NAME]="$(echo "$UPDATE" | egrep '\["result",'$PROCESS_NUMBER',"message","chat","first_name"\]' | cut -f 2 | cut -d '"' -f 2)"
	CHAT[LAST_NAME]="$(echo "$UPDATE" | egrep '\["result",'$PROCESS_NUMBER',"message","chat","last_name"\]' | cut -f 2 | cut -d '"' -f 2)"
	CHAT[USERNAME]="$(echo "$UPDATE" | egrep '\["result",'$PROCESS_NUMBER',"message","chat","username"\]' | cut -f 2 | cut -d '"' -f 2)"
	CHAT[TITLE]="$(echo "$UPDATE" | egrep '\["result",'$PROCESS_NUMBER',"message","chat","title"\]' | cut -f 2 | cut -d '"' -f 2)"
	CHAT[TYPE]="$(echo "$UPDATE" | egrep '\["result",'$PROCESS_NUMBER',"message","chat","type"\]' | cut -f 2 | cut -d '"' -f 2)"
	CHAT[ALL_MEMBERS_ARE_ADMINISTRATORS]="$(echo "$UPDATE" | egrep '\["result",'$PROCESS_NUMBER',"message","chat","all_members_are_administrators"\]' | cut -f 2 | cut -d '"' -f 2)"

	# User
	USER[ID]="$(echo "$UPDATE" | egrep '\["result",'$PROCESS_NUMBER',"message","from","id"\]' | cut -f 2)"
	USER[FIRST_NAME]="$(echo "$UPDATE" | egrep '\["result",'$PROCESS_NUMBER',"message","from","first_name"\]' | cut -f 2 | cut -d '"' -f 2)"
	USER[LAST_NAME]="$(echo "$UPDATE" | egrep '\["result",'$PROCESS_NUMBER',"message","from","last_name"\]' | cut -f 2 | cut -d '"' -f 2)"
	USER[USERNAME]="$(echo "$UPDATE" | egrep '\["result",'$PROCESS_NUMBER',"message","from","username"\]' | cut -f 2 | cut -d '"' -f 2)"

	# Audio
	URLS[AUDIO]="$(get_file $(echo "$UPDATE" | egrep '\["result",'$PROCESS_NUMBER',"message","audio","file_id"\]' | cut -f 2 | cut -d '"' -f 2))"
	# Document
	URLS[DOCUMENT]="$(get_file $(echo "$UPDATE" | egrep '\["result",'$PROCESS_NUMBER',"message","document","file_id"\]' | cut -f 2 | cut -d '"' -f 2))"
	# Photo
	URLS[PHOTO]="$(get_file $(echo "$UPDATE" | egrep '\["result",'$PROCESS_NUMBER',"message","photo",.*,"file_id"\]' | cut -f 2 | cut -d '"' -f 2 | sed -n '$p'))"
	# Sticker
	URLS[STICKER]="$(get_file $(echo "$UPDATE" | egrep '\["result",'$PROCESS_NUMBER',"message","sticker","file_id"\]' | cut -f 2 | cut -d '"' -f 2))"
	# Video
	URLS[VIDEO]="$(get_file $(echo "$UPDATE" | egrep '\["result",'$PROCESS_NUMBER',"message","video","file_id"\]' | cut -f 2 | cut -d '"' -f 2))"
	# Voice
	URLS[VOICE]="$(get_file $(echo "$UPDATE" | egrep '\["result",'$PROCESS_NUMBER',"message","voice","file_id"\]' | cut -f 2 | cut -d '"' -f 2))"

	# Contact
	CONTACT[NUMBER]="$(echo "$UPDATE" | egrep '\["result",'$PROCESS_NUMBER',"message","contact","phone_number"\]' | cut -f 2 | cut -d '"' -f 2)"
	CONTACT[FIRST_NAME]="$(echo "$UPDATE" | egrep '\["result",'$PROCESS_NUMBER',"message","contact","first_name"\]' | cut -f 2 | cut -d '"' -f 2)"
	CONTACT[LAST_NAME]="$(echo "$UPDATE" | egrep '\["result",'$PROCESS_NUMBER',"message","contact","last_name"\]' | cut -f 2 | cut -d '"' -f 2)"
	CONTACT[USER_ID]="$(echo "$UPDATE" | egrep '\["result",'$PROCESS_NUMBER',"message","contact","user_id"\]' | cut -f 2 | cut -d '"' -f 2)"

	# Caption
	CAPTION="$(echo "$UPDATE" | egrep '\["result",'$PROCESS_NUMBER',"message","caption"\]' | cut -f 2 | cut -d '"' -f 2)"

	# Location
	LOCATION[LONGITUDE]="$(echo "$UPDATE" | egrep '\["result",'$PROCESS_NUMBER',"message","location","longitude"\]' | cut -f 2 | cut -d '"' -f 2)"
	LOCATION[LATITUDE]="$(echo "$UPDATE" | egrep '\["result",'$PROCESS_NUMBER',"message","location","latitude"\]' | cut -f 2 | cut -d '"' -f 2)"
	NAME="$(echo ${URLS[*]} | sed 's/.*\///g')"

	# Tmux
	copname="$ME"_"${CHAT[ID]}"

	source commands.sh

	tmpcount="COUNT${CHAT[ID]}"
	cat count | grep -q "$tmpcount" || echo "$tmpcount">>count
	# To get user count execute bash bashbot.sh count
}

# source the script with source as param to use functions in other scripts
while [ "$1" == "startbot" ]; do {

	UPDATE=$(curl -s $UPD_URL$OFFSET | ./JSON.sh/JSON.sh)

	# Offset
	OFFSET=$(echo "$UPDATE" | egrep '\["result",[0-9]*,"update_id"\]' | tail -1 | cut -f 2)
	OFFSET=$((OFFSET+1))

	if [ $OFFSET != 1 ]; then
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
			line=
			read -t 10 line
			[ "$line" != "" -a "$line" != "imprettydarnsuredatdisisdaendofdacmd" ] && send_message "$2" "$line"
		done </tmp/$3
		rm -r /tmp/$3
		;;
	"count")
		echo "A total of $(wc -l count | sed 's/count//g')users used me."
		;;
	"broadcast")
		echo "Sending the broadcast $* to $(wc -l count | sed 's/count//g')users."
		[ $(wc -l count | sed 's/ count//g') -gt 300 ] && sleep="sleep 0.5"
		shift
		for f in $(cat count);do send_message ${f//COUNT} "$*"; $sleep;done
		;;
	"start")
		clear
		tmux kill-session -t $ME&>/dev/null
		tmux new-session -d -s $ME "bash $SCRIPT startbot" && echo -e '\e[0;32mBot started successfully.\e[0m'
		echo "Tmux session name $ME" || echo -e '\e[0;31mAn error occurred while starting the bot. \e[0m'
		send_markdown_message "${CHAT[ID]}" "*Bot started*"
		;;
	"kill")
		clear
		tmux kill-session -t $ME &>/dev/null
		send_markdown_message "${CHAT[ID]}" "*Bot stopped*"
		echo -e '\e[0;32mOK. Bot stopped successfully.\e[0m'
		;;
	"help")
		clear
		less README.md
		;;
	"attach")
		tmux attach -t $ME
		;;
	"source")
		echo "OK"
		;;
	*)
		echo -e '\e[0;31mBAD REQUEST\e[0m'
		echo -e '\e[0;31mAvailable arguments: outproc, count, broadcast, start, kill, help, attach\e[0m'
		;;
esac

