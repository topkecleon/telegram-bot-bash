# bashbot, the Telegram bot written in bash.
# Written by @topkecleon.
# http://github.com/topkecleon/bashbot

# Depends on JSON.sh (http://github.com/dominictarr/JSON.sh),
# which is MIT/Apache-licensed.

# This file is public domain in the USA and all free countries.
# If you're in Europe, and public domain does not exist, then haha.

#!/bin/bash

TOKEN=''
URL='https://api.telegram.org/bot'$TOKEN
MSG_URL=$URL'/sendMessage?chat_id='
UPD_URL=$URL'/getUpdates?offset='
OFFSET=0

function send_message {
	res=$(curl --data-urlencode "text=$2" "$MSG_URL$1&")
}

while true; do {

	res=$(curl $UPD_URL$OFFSET)

	TARGET=$(echo $res | ./JSON.sh | egrep '\["result",0,"message","chat","id"\]' | cut -f 2)
	OFFSET=$(echo $res | ./JSON.sh | egrep '\["result",0,"update_id"\]' | cut -f 2)
	MESSAGE=$(echo $res | ./JSON.sh -s | egrep '\["result",0,"message","text"\]' | cut -f 2 | cut -d '"' -f 2)

	OFFSET=$((OFFSET+1))

	if [ $OFFSET != 1 ]; then
		case $MESSAGE in
			'/info') msg="This is bashbot, the Telegram bot written entirely in bash.";;
			*) msg="$MESSAGE";;
		esac
		send_message "$TARGET" "$msg"
	fi

} &>/dev/null; done
