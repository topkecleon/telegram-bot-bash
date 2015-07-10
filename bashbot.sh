# bashbot, the Telegram bot written in bash.
# Written by @topkecleon.
# http://github.com/topkecleon/bashbot

# Depends on JSON.sh (http://github.com/dominictarr/JSON.sh),
# which is MIT/Apache-licensed.

# This file is public domain in the USA and all free countries.
# If you're in Europe, and public domain does not exist, then haha.

#!/bin/bash

TOKEN='94209408:AAHkmfpwpTkXQg7GRdRmLgIWdSMt0b3TYqk'
URL='https://api.telegram.org/bot'$TOKEN
MSG_URL=$URL'/sendMessage?chat_id='
UPD_URL=$URL'/getUpdates?offset='
OFFSET=0

while true; do {

	wget $UPD_URL$OFFSET -O bashbot_temp

	TARGET=$(cat bashbot_temp | ./JSON.sh | egrep '\["result",0,"message","chat","id"\]' | cut -f 2)
	OFFSET=$(cat bashbot_temp | ./JSON.sh | egrep '\["result",0,"update_id"\]' | cut -f 2)
	MESSAGE=$(cat bashbot_temp | ./JSON.sh | egrep '\["result",0,"message","text"\]' | cut -f 2 | cut -d '"' -f 2)

	OFFSET=$((OFFSET+1))

	wget "$MSG_URL$TARGET&text=$MESSAGE" -O bashbot_temp

} &>/dev/null; done

rm bashbot_temp
