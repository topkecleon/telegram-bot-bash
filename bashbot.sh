#!/bin/bash
# bashbot, the Telegram bot written in bash.
# Written by @topkecleon, Juan Potato (@awkward_potato) and Lorenzo Santina (BigNerd95)
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
	res=$(curl "$MSG_URL" -F "chat_id=$1" -F "text=$2")
}

send_photo() {
	res=$(curl "$PHO_URL" -F "chat_id=$1" -F "photo=@$2")
}

readproc() {
	cur=test
	coproc="coproc$1"
	while [ "$cur" != "" ];do read cur <&${coproc["0"]};echo "$cur";done
}
process_client() {
	local MESSAGE=$1
	local TARGET=$2
	local msg=""
	case $MESSAGE in
		'/info') msg="This is bashbot, the Telegram bot written entirely in bash.";;
		'/question') coproc "coproc$TARGET" { question; }; msg="$(readproc $TARGET)"
		*) msg="$MESSAGE";;
	esac
	send_message "$TARGET" "$msg"&
}

while true; do {

	res=$(curl $UPD_URL$OFFSET)

	TARGET=$(echo $res | ./JSON.sh | egrep '\["result",0,"message","chat","id"\]' | cut -f 2)
	OFFSET=$(echo $res | ./JSON.sh | egrep '\["result",0,"update_id"\]' | cut -f 2)
	MESSAGE=$(echo $res | ./JSON.sh -s | egrep '\["result",0,"message","text"\]' | cut -f 2 | cut -d '"' -f 2)

	OFFSET=$((OFFSET+1))

	if [ $OFFSET != 1 ]; then
		process_client "$MESSAGE" "$TARGET"
		
	fi

} &>/dev/null; done
