#!/bin/bash
# bashbot, the Telegram bot written in bash.
# Written by @topkecleon, Juan Potato (@awkward_potato), Lorenzo Santina (BigNerd95) and Daniil Gentili (danog)
# https://github.com/topkecleon/telegram-bot-bash

# Depends on ./JSON.sh (http://github.com/dominictarr/./JSON.sh),
# which is MIT/Apache-licensed
# And on tmux (https://github.com/tmux/tmux),
# which is BSD-licensed


# This file is public domain in the USA and all free countries.
# If you're in Europe, and public domain does not exist, then haha.

TOKEN='tokenhere'
URL='https://api.telegram.org/bot'$TOKEN

FORWARD_URL=$URL'/forwardMessage'

MSG_URL=$URL'/sendMessage'
PHO_URL=$URL'/sendPhoto'
AUDIO_URL=$URL'/sendAudio'
DOCUMENT_URL=$URL'/sendDocument'
STICKER_URL=$URL'/sendSticker'
VIDEO_URL=$URL'/sendVideo'
VOICE_URL=$URL'/sendVoice'
LOCATION_URL=$URL'/sendLocation'
ACTION_URL=$URL'/sendChatAction'


FILE_URL='https://api.telegram.org/file/bot'$TOKEN'/'
UPD_URL=$URL'/getUpdates?offset='
GET_URL=$URL'/getFile'
OFFSET=0
declare -A USER URLS CONTACT LOCATION

send_message() {
	local chat="$1"
	local text="$(echo "$2" | sed 's/ mykeyboardstartshere.*//g;s/ myimagelocationstartshere.*//g')"
	local keyboard="$(echo "$2" | sed '/mykeyboardstartshere /!d;s/.*mykeyboardstartshere //g;s/ myimagelocationstartshere.*//g')"
	local image="$(echo "$2" | sed '/myimagelocationstartshere /!d;s/.*myimagelocationstartshere //g;s/ mykeyboardstartshere.*//g;')"
	if [ "$keyboard" != "" ]; then
		send_keyboard "$chat" "$text" "$keyboard"
		local sent=y
	fi
	if [ "$image" != "" ]; then
		send_photo "$chat" "$image"
		local sent=y
	fi
	if [ "$sent" != "y" ];then
		res=$(curl -s "$MSG_URL" -F "chat_id=$chat" -F "text=$text")
	fi
}

send_keyboard() {
	local chat="$1"
	local text="$2"
	shift 2
	local keyboard=init
	for f in $*;do local keyboard="$keyboard, [\"$f\"]";done
	local keyboard=${keyboard/init, /}
	res=$(curl -s "$MSG_URL" --header "content-type: multipart/form-data" -F "chat_id=$chat" -F "text=$text" -F "reply_markup={\"keyboard\": [$keyboard],\"one_time_keyboard\": true}")
}

send_photo() {
	res=$(curl -s "$PHO_URL" -F "chat_id=$1" -F "photo=@$2")
}

send_audio() {
}

get_file() {
	[ "$1" != "" ] && echo $FILE_URL$(curl -s "$GET_URL" -F "file_id=$1" | ./JSON.sh -s | egrep '\["result","file_path"\]' | cut -f 2 | cut -d '"' -f 2)

}

send_file() {
	
}

startproc() {
	local copname="$1"
	local USER="$2"
	mkdir -p "$copname"
	mkfifo $copname/out
	tmux new-session -d -s $copname "./question 2>&1>$copname/out"
	local pid=$(ps aux | sed '/tmux/!d;/'$copname'/!d;/sed/d;s/'$USER'\s*//g;s/\s.*//g')
	echo $pid>$copname/pid
	while ps aux | grep -v grep | grep -q $pid;do
		read -t 10 line
		[ "$line" != "" ] && send_message "${USER[ID]}" "$line"
		line=
	done <$copname/out
}

inproc() {
	local copname="$1"
	local copid="$2"
	local MESSAGE="$3"
	shift 2
	tmux send-keys -t $copname "$MESSAGE
"
	ps aux | grep -v grep | grep -q "$copid" || { rm -r $copname; };
}

process_client() {
	local copname="CO${USER[ID]}"
	local copidname="$copname/pid"
	local copid="$(cat $copidname 2>/dev/null)"
	if [ "$copid" = "" ]; then
		case $MESSAGE in
			'/question')
				startproc "$copname" "${USER[ID]}"&
				;;
			'/info')
				send_message "${USER[ID]}" "This is bashbot, the Telegram bot written entirely in bash."
				;;
			'/start')
				send_message "${USER[ID]}" "This is bashbot, the Telegram bot written entirely in bash.
Features background tasks and interactive chats.
Can serve as an interface for cli programs.
Currently can send messages, custom keyboards and photos.

Available commands:
/start: Start bot and get this message.
/info: Get shorter info message about this bot.
/question: Start interactive chat.
/cancel: Cancel any currently running interactive chats.

Written by @topkecleon, Juan Potato (@awkward_potato), Lorenzo Santina (BigNerd95) and Daniil Gentili (danog)
https://github.com/topkecleon/telegram-bot-bash
"
				;;
			*)
				send_message "${USER[ID]}" "$MESSAGE"
		esac
	else
		case $MESSAGE in
			'/cancel')
				kill $copid
				rm -r $copname
				send_message "${USER[ID]}" "Command canceled."
				;;
			*) inproc "$copname" "$copid" "$MESSAGE";;
		esac
	fi
}

while true; do {

	res=$(curl -s $UPD_URL$OFFSET | ./JSON.sh -s)

	# Target
	USER[ID]=$(echo "$res" | egrep '\["result",0,"message","chat","id"\]' | cut -f 2)
	# Offset
	OFFSET=$(echo "$res" | egrep '\["result",0,"update_id"\]' | cut -f 2)
	# Message
	MESSAGE=$(echo "$res" | egrep '\["result",0,"message","text"\]' | cut -f 2 | cut -d '"' -f 2)
	
	OFFSET=$((OFFSET+1))

	if [ $OFFSET != 1 ]; then
		# User
		USER[FIRST_NAME]=$(echo "$res" | egrep '\["result",0,"message","chat","first_name"\]' | cut -f 2 | cut -d '"' -f 2)
		USER[LAST_NAME]=$(echo "$res" | egrep '\["result",0,"message","chat","last_name"\]' | cut -f 2 | cut -d '"' -f 2)
		USER[USERNAME]=$(echo "$res" | egrep '\["result",0,"message","chat","username"\]' | cut -f 2 | cut -d '"' -f 2)

		# Audio
		AUDIO_ID=$(echo "$res" | egrep '\["result",0,"message","audio","file_id"\]' | cut -f 2 | cut -d '"' -f 2)
		URLS[AUDIO]=$(get_file "$AUDIO_ID")
		# Document
		DOCUMENT_ID=$(echo "$res" | egrep '\["result",0,"message","document","file_id"\]' | cut -f 2 | cut -d '"' -f 2)
		URLS[DOCUMENT]=$(get_file "$DOCUMENT_ID")
		# Photo
		PHOTO_ID=$(echo "$res" | egrep '\["result",0,"message","photo",.*,"file_id"\]' | cut -f 2 | cut -d '"' -f 2 | sed -n '$p')
		URLS[PHOTO]=$(get_file "$PHOTO_ID")
		# Sticker
		STICKER_ID=$(echo "$res" | egrep '\["result",0,"message","sticker","file_id"\]' | cut -f 2 | cut -d '"' -f 2)
		URLS[STICKER]=$(get_file "$STICKER_ID")
		# Video
		VIDEO_ID=$(echo "$res" | egrep '\["result",0,"message","video","file_id"\]' | cut -f 2 | cut -d '"' -f 2)
		URLS[VIDEO]=$(get_file "$VIDEO_ID")
		# Voice
		VOICE_ID=$(echo "$res" | egrep '\["result",0,"message","voice","file_id"\]' | cut -f 2 | cut -d '"' -f 2)
		URLS[VOICE]=$(get_file "$VOICE_ID")

		# Contact
		CONTACT[NUMBER]=$(echo "$res" | egrep '\["result",0,"message","contact","phone_number"\]' | cut -f 2 | cut -d '"' -f 2)
		CONTACT[FIRST_NAME]=$(echo "$res" | egrep '\["result",0,"message","contact","first_name"\]' | cut -f 2 | cut -d '"' -f 2)
		CONTACT[LAST_NAME]=$(echo "$res" | egrep '\["result",0,"message","contact","last_name"\]' | cut -f 2 | cut -d '"' -f 2)
		CONTACT[USER_ID]=$(echo "$res" | egrep '\["result",0,"message","contact","user_id"\]' | cut -f 2 | cut -d '"' -f 2)

		# Caption
		CAPTION=$(echo "$res" | egrep '\["result",0,"message","caption"\]' | cut -f 2 | cut -d '"' -f 2)

		# Location
		LOCATION[LONGITUDE]=$(echo "$res" | egrep '\["result",0,"message","location","longitude"\]' | cut -f 2 | cut -d '"' -f 2)
		LOCATION[LATITUDE]=$(echo "$res" | egrep '\["result",0,"message","location","latitude"\]' | cut -f 2 | cut -d '"' -f 2)

		process_client&

	fi

}; done


