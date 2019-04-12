#!/bin/bash
# Edit your commands in this file.

# This file is public domain in the USA and all free countries.
# Elsewhere, consider it to be WTFPLv2. (wtfpl.net/txt/copying)
#
#### $$VERSION$$ v0.52-1-gdb7b19f
#
# shellcheck disable=SC2154
# shellcheck disable=SC2034
SC2034="$CONTACT" # mute CONTACT not used ;-)

# adjust your language setting here, e.g.when run from other user or cron.
# https://github.com/topkecleon/telegram-bot-bash#setting-up-your-environment
export 'LC_ALL=C.UTF-8'
export 'LANG=C.UTF-8'
export 'LANGUAGE=C.UTF-8'

unset IFS
# set -f # if you are paranoid use set -f to disable globbing


# change Info anf Help to fit your needs
bashbot_info() {
	send_markdown_message "${1}" 'This is bashbot, the Telegram bot written entirely in bash.
It features background tasks and interactive chats, and can serve as an interface for CLI programs.
It currently can send, recieve and forward messages, custom keyboards, photos, audio, voice, documents, locations and video files.
'
}

bashbot_help() {
	send_markdown_message "${1}" '*Available commands*:
*• /start*: _Start bot and get this message_.
*• /info*: _Get shorter info message about this bot_.
*• /question*: _Start interactive chat_.
*• /cancel*: _Cancel any currently running interactive chats_.
*• /kickme*: _You will be autokicked from the chat_.
*• /leavechat*: _The bot will leave the group with this command _.
Written by Drew (@topkecleon), Daniil Gentili (@danogentili) and KayM(@gnadelwartz).
Get the code in my [GitHub](http://github.com/topkecleon/telegram-bot-bash)
'
}

# some handy shortcuts, e.g.:
_is_botadmin() {
	user_is_botadmin "${USER[ID]}"
}
_is_admin() {
	user_is_admin "${CHAT[ID]}" "${USER[ID]}"
}
_is_allowed() { # $1 = resource
	user_is_allowed "${USER[ID]}" "$1" "${CHAT[ID]}"
}


if [ "$1" = "source" ];then
	# Place the token in the token file
	TOKEN="$(cat token)"
	# Set INLINE to 1 in order to receive inline queries.
	# To enable this option in your bot, send the /setinline command to @BotFather.
	INLINE="0"
	# Set to .* to allow sending files from all locations
	FILE_REGEX='/home/user/allowed/.*'
else
	if ! tmux ls | grep -v send | grep -q "$copname"; then
		[ ! -z "${URLS[*]}" ] && {
			curl -s "${URLS[*]}" -o "$NAME"
			send_file "${CHAT[ID]}" "$NAME" "$CAPTION"
			rm -f "$NAME"
		}
		[ ! -z "${LOCATION[*]}" ] && send_location "${CHAT[ID]}" "${LOCATION[LATITUDE]}" "${LOCATION[LONGITUDE]}"

		# Inline
		if [ $INLINE == 1 ]; then
			# inline query data
			iUSER[FIRST_NAME]="$(echo "$res" | sed 's/^.*\(first_name.*\)/\1/g' | cut -d '"' -f3 | tail -1)"
			iUSER[LAST_NAME]="$(echo "$res" | sed 's/^.*\(last_name.*\)/\1/g' | cut -d '"' -f3)"
			iUSER[USERNAME]="$(echo "$res" | sed 's/^.*\(username.*\)/\1/g' | cut -d '"' -f3 | tail -1)"
			iQUERY_ID="$(echo "$res" | sed 's/^.*\(inline_query.*\)/\1/g' | cut -d '"' -f5 | tail -1)"
			iQUERY_MSG="$(echo "$res" | sed 's/^.*\(inline_query.*\)/\1/g' | cut -d '"' -f5 | tail -6 | head -1)"

			# Inline examples
			if [[ "$iQUERY_MSG" == "photo" ]]; then
				answer_inline_query "$iQUERY_ID" "photo" "http://blog.techhysahil.com/wp-content/uploads/2016/01/Bash_Scripting.jpeg" "http://blog.techhysahil.com/wp-content/uploads/2016/01/Bash_Scripting.jpeg"
			fi

			if [[ "$iQUERY_MSG" == "sticker" ]]; then
				answer_inline_query "$iQUERY_ID" "cached_sticker" "BQADBAAD_QEAAiSFLwABWSYyiuj-g4AC"
			fi

			if [[ "$iQUERY_MSG" == "gif" ]]; then
				answer_inline_query "$iQUERY_ID" "cached_gif" "BQADBAADIwYAAmwsDAABlIia56QGP0YC"
			fi
			if [[ "$iQUERY_MSG" == "web" ]]; then
				answer_inline_query "$iQUERY_ID" "article" "GitHub" "http://github.com/topkecleon/telegram-bot-bash"
			fi
		fi &
	fi
	case "$MESSAGE" in
		'/question')
			checkproc 
			if [ "$res" -gt 0 ] ; then
				startproc "./question"
			else
				send_normal_message "${CHAT[ID]}" "$MESSAGE already running ..."
			fi
			;;

		'/run-notify') 
			myback="notify"; checkback "$myback"
			if [ "$res" -gt 0 ] ; then
				background "./notify 60" "$myback" # notify every 60 seconds
			else
				send_normal_message "${CHAT[ID]}" "Background command $myback already running ..."
			fi
			;;
		'/stop-notify')
			myback="notify"; checkback "$myback"
			if [ "$res" -eq 0 ] ; then
				killback "$myback"
				send_normal_message "${CHAT[ID]}" "Background command $myback canceled."
			else
				send_normal_message "${CHAT[ID]}" "No background command $myback is currently running.."
			fi
			;;

		################################################
		# DEFAULT commands start here, edit messages only
		'/info')
			bashbot_info "${CHAT[ID]}"
			;;
		'/start')
			send_action "${CHAT[ID]}" "typing"
			user_is_botadmin "${USER[ID]}" && send_markdown_message "${CHAT[ID]}" "You are *BOTADMIN*."
			if user_is_allowed "${USER[ID]}" "start" "${CHAT[ID]}" ; then
				bot_help "${CHAT[ID]}"
			else
				send_normal_message "${CHAT[ID]}" "You are not allowed to start Bot."
			fi
			;;
			
		'/leavechat') # bot leave chat if user is admin in chat
			if user_is_admin "${CHAT[ID]}" "${USER[ID]}"; then 
				send_markdown_message "${CHAT[ID]}" "*LEAVING CHAT...*"
   				leave_chat "${CHAT[ID]}"
			fi
     			;;
     			
     		'/kickme')
     			kick_chat_member "${CHAT[ID]}" "${USER[ID]}"
     			unban_chat_member "${CHAT[ID]}" "${USER[ID]}"
     			;;
     			
		'/cancel')
			checkprog
			if [ "$res" -eq 0 ] ; then killproc && send_message "${CHAT[ID]}" "Command canceled.";else send_message "${CHAT[ID]}" "No command is currently running.";fi
			;;
		*)
			if tmux ls | grep -v send | grep -q "$copname";then inproc; else send_message "${CHAT[ID]}" "$MESSAGE" "safe";fi
			;;
	esac
fi
