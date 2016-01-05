#!/bin/bash
# bashbot, the Telegram bot written in bash.
# Written by @topkecleon, Juan Potato (@awkward_potato), Lorenzo Santina (BigNerd95) and Daniil Gentili (danog)
# http://github.com/topkecleon/bashbot

# Depends on JSON.sh (http://github.com/dominictarr/JSON.sh),
# which is MIT/Apache-licensed.

# This file is public domain in the USA and all free countries.
# If you're in Europe, and public domain does not exist, then haha.

TOKEN=''
URL='https://api.telegram.org/bot'$TOKEN
MSG_URL=$URL'/sendMessage'
PHO_URL=$URL'/sendPhoto'
UPD_URL=$URL'/getUpdates?offset='
OFFSET=0

send_message() {
	local chat="$1"
	local text="$(echo "$2" | sed 's/ mykeyboardstartshere.*//g')"
	local keyboard="$(echo "$2" | sed '/mykeyboardstartshere /!d;s/.*mykeyboardstartshere //g')"
	if [ "$keyboard" = "" ]; then
		res=$(curl -s "$MSG_URL" -F "chat_id=$chat" -F "text=$text")
	else
		send_keyboard "$chat" "$text" "$keyboard"
	fi
}

send_keyboard() {
	local chat="$1"
	local text="$2"
	shift 2
	keyboard=init
	for f in $*;do keyboard="$keyboard, [\"$f\"]";done
	keyboard=${keyboard/init, /}
	res=$(curl -s "$MSG_URL" --header "content-type: multipart/form-data" -F "chat_id=$chat" -F "text=$text" -F "reply_markup={\"keyboard\": [$keyboard],\"one_time_keyboard\": true}")
}

send_photo() {
	res=$(curl -s "$PHO_URL" -F "chat_id=$1" -F "photo=@$2")
}

startproc() {
	local copname="$1"
	local TARGET="$2"
	mkdir -p "$copname"
	mkfifo $copname/out
	tmux new-session -d -n $copname "./question $TARGET 2>&1>$copname/out"
	local pid=$(ps aux | sed '/tmux/!d;/'$copname'/!d;/sed/d;s/'$USER'\s*//g;s/\s.*//g')
	echo $pid>$copname/pid
	while ps aux | grep -v grep | grep -q $pid;do
		read -t 10 line
		[ "$line" != "" ] && send_message "$TARGET" "$line"
		line=
	done <$copname/out
}
inproc() {
	local copname="$1"
	local copid="$2"
	shift 2
	tmux send-keys -t $copname "$@
"
	ps aux | grep -v grep | grep -q "$copid" || { rm -r $copname; };
}

process_client() {
	local MESSAGE=$1
	local TARGET=$2
	local msg=""
	local copname="CO$TARGET"
	local copidname="$copname/pid"
	local copid="$(cat $copidname 2>/dev/null)"
	if [ "$copid" = "" ]; then
		case $MESSAGE in
			'/question')
				startproc "$copname" "$TARGET"&
				;;
			'/info')
				send_message "$TARGET" "This is bashbot, the Telegram bot written entirely in bash."
				;;
			*)
				send_message "$TARGET" "$MESSAGE"
		esac
	else
		case $MESSAGE in
			'/cancel')
				kill $copid
				rm -r $copname
				send_message "$TARGET" "Command canceled."
				;;
			*) inproc "$copname" "$copid" "$MESSAGE";;
		esac
	fi
}

while true; do {

	res=$(curl -s $UPD_URL$OFFSET)

	TARGET=$(echo $res | JSON.sh | egrep '\["result",0,"message","chat","id"\]' | cut -f 2)
	OFFSET=$(echo $res | JSON.sh | egrep '\["result",0,"update_id"\]' | cut -f 2)
	MESSAGE=$(echo $res | JSON.sh -s | egrep '\["result",0,"message","text"\]' | cut -f 2 | cut -d '"' -f 2)

	OFFSET=$((OFFSET+1))

	if [ $OFFSET != 1 ]; then
		process_client "$MESSAGE" "$TARGET"&
	fi

}; done

