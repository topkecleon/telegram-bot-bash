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
	[ "$2" != "" ] && res=$(curl "$MSG_URL" -F "chat_id=$1" -F "text=$2")
}
send_keyboard() {
	for f in ${@/1\|2/};do keyboard="$keyboard, [\"$f\"]";done
	keyboard=${keyboard/^, /}
	res=$(curl "$MSG_URL" -F "chat_id=$1" -F "text=$2" -F "reply_markup={\"keyboard\": $keyboard, \"one_time_keyboard\": true}")
}

send_photo() {
	res=$(curl "$PHO_URL" -F "chat_id=$1" -F "photo=@$2")
}

question() {
	TARGET="$1'
	echo "Why hello there.
Would you like some tea (y/n)?"
	read answer
	[[ $answer =~ ^([yY][eE][sS]|[yY])$ ]] && echo "OK then, here you go: http://www.rivertea.com/blog/wp-content/uploads/2013/12/Green-Tea.jpg" || echo "OK then."
	until [ "$SUCCESS" = "y" ] ;do
		send_keyboard "$TARGET" "Do you like Music?" "Yass!" "No"
		read answer
		case $answer in
			'Yass!') echo "Goody!";SUCCESS=y;;
			'No') echo "Well that's weird";SUCCESS=y;;
			*) SUCCESS=n;;
		esac
	done
}

inproc() {
	copname="$1"
	msg="${@/1/}"
	echo "$msg" >&${$1["0"]}
}

outproc() {
	copname="$1"
	TARGET="$2"
	while true; do read msg <&${$copname["0"]}; [ "$?" != "0" ] && return || send_message "$TARGET" "$msg";done
}


process_client() {
	local MESSAGE=$1
	local TARGET=$2
	local msg=""
	local copname="coproc$TARGET"
	local copidname="$copname"_PID
	local copid="${$copid}"
	[ "$copid" = "" ] {
		case $MESSAGE in
			'/info') send_message "$TARGET" "This is bashbot, the Telegram bot written entirely in bash.";;
			'/question') coproc "$copname" { question "$TARGET"; } &>&1; outproc "$copname" "$TARGET"; return;;
			*) send_message "$TARGET" "$MESSAGE";;
		esac
	} || {
		
		case $MESSAGE in
			'/cancel') kill $copid;;
			*) inproc "$copname" "$MESSAGE";;
		esac
	}
}

while true; do {

	res=$(curl $UPD_URL$OFFSET)

	TARGET=$(echo $res | ./JSON.sh | egrep '\["result",0,"message","chat","id"\]' | cut -f 2)
	OFFSET=$(echo $res | ./JSON.sh | egrep '\["result",0,"update_id"\]' | cut -f 2)
	MESSAGE=$(echo $res | ./JSON.sh -s | egrep '\["result",0,"message","text"\]' | cut -f 2 | cut -d '"' -f 2)

	OFFSET=$((OFFSET+1))

	if [ $OFFSET != 1 ]; then
		process_client "$MESSAGE" "$TARGET"&
	fi

} &>/dev/null; done
