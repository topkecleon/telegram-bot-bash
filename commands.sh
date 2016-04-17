#!/bin/bash
# Edit your commands in this file.

if ! tmux ls | grep -v send | grep -q $copname; then
	[ ! -z ${URLS[*]} ] && {
		curl -s ${URLS[*]} -o $NAME
		send_file "${USER[ID]}" "$NAME" "$CAPTION"
		rm "$NAME"
	}
	[ ! -z ${LOCATION[*]} ] && send_location "${USER[ID]}" "${LOCATION[LATITUDE]}" "${LOCATION[LONGITUDE]}"
		
	# Inline 
	if [ $INLINE == 1 ]; then
			# inline query data
			iUSER[FIRST_NAME]=$(echo "$res" | sed 's/^.*\(first_name.*\)/\1/g' | cut -d '"' -f3 | tail -1)
			iUSER[LAST_NAME]=$(echo "$res" | sed 's/^.*\(last_name.*\)/\1/g' | cut -d '"' -f3)
			iUSER[USERNAME]=$(echo "$res" | sed 's/^.*\(username.*\)/\1/g' | cut -d '"' -f3 | tail -1)
			iQUERY_ID=$(echo "$res" | sed 's/^.*\(inline_query.*\)/\1/g' | cut -d '"' -f5 | tail -1)
			iQUERY_MSG=$(echo "$res" | sed 's/^.*\(inline_query.*\)/\1/g' | cut -d '"' -f5 | tail -6 | head -1)
		
			# Inline examples
			if [[ $iQUERY_MSG == photo ]]; then
				answer_inline_query "$iQUERY_ID" "photo" "http://blog.techhysahil.com/wp-content/uploads/2016/01/Bash_Scripting.jpeg" "http://blog.techhysahil.com/wp-content/uploads/2016/01/Bash_Scripting.jpeg"
			fi
		
			if [[ $iQUERY_MSG == sticker ]]; then
				answer_inline_query "$iQUERY_ID" "cached_sticker" "BQADBAAD_QEAAiSFLwABWSYyiuj-g4AC"
			fi
		
			if [[ $iQUERY_MSG == gif ]]; then
				answer_inline_query "$iQUERY_ID" "cached_gif" "BQADBAADIwYAAmwsDAABlIia56QGP0YC"
			fi
			if [[ $iQUERY_MSG == web ]]; then
				answer_inline_query "$iQUERY_ID" "article" "Telegram" "https://telegram.org/"
			fi
		fi
fi
case $MESSAGE in
		'/question')
			startproc "./question"
			;;
		'/info')
			send_message "${USER[ID]}" "This is bashbot, the Telegram bot written entirely in bash."
			;;
		'/start')
			send_message "${USER[ID]}" "This is bashbot, the Telegram bot written entirely in bash.
Features background tasks and interactive chats.
Can serve as an interface for cli programs.
Currently can send, recieve and forward messages, custom keyboards, photos, audio, voice, documents, locations and video files.
Available commands:
/start: Start bot and get this message.
/info: Get shorter info message about this bot.
/question: Start interactive chat.
/cancel: Cancel any currently running interactive chats.
Written by @topkecleon, Juan Potato (@awkward_potato), Lorenzo Santina (BigNerd95) and Daniil Gentili (@danogentili)
Contribute to the project: https://github.com/topkecleon/telegram-bot-bash
"
			;;
		'/cancel')
			if tmux ls | grep -q $copname; then killproc && send_message "${USER[ID]}" "Command canceled.";else send_message "${USER[ID]}" "No command is currently running.";fi
			;;
		*)
			if tmux ls | grep -v send | grep -q $copname;then inproc; else send_message "${USER[ID]}" "$MESSAGE" "safe";fi
			;;
esac