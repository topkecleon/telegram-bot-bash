#!/bin/bash
# file: commands.sh

#  _____                               _______    _ _      _ 
# (____ \                      _      (_______)  | (_)_   | |
#  _   \ \ ___     ____   ___ | |_     _____   _ | |_| |_ | |
# | |   | / _ \   |  _ \ / _ \|  _)   |  ___) / || | |  _)|_|
# | |__/ / |_| |  | | | | |_| | |__   | |____( (_| | | |__ _ 
# |_____/ \___/   |_| |_|\___/ \___)  |_______)____|_|\___)_|
#
# this file *MUST* not be edited! palce your config and commands in
# the file "mycommnds.sh". a clean version is provided as "mycommands.clean"
#

# This file is public domain in the USA and all free countries.
# Elsewhere, consider it to be WTFPLv2. (wtfpl.net/txt/copying)
#
#### $$VERSION$$ v0.96-dev-7-g0153928
#

# adjust your language setting here, e.g.when run from other user or cron.
# https://github.com/topkecleon/telegram-bot-bash#setting-up-your-environment
export 'LC_ALL=C.UTF-8'
export 'LANG=C.UTF-8'
export 'LANGUAGE=C.UTF-8'

unset IFS
# set -f # if you are paranoid use set -f to disable globbing

#                                                            
# this file *MUST* not edited!
# copy "mycommands.sh.dist" to "mycommnds.sh" and change the strings there
bashbot_info='This is bashbot, the Telegram bot written entirely in bash.
It features background tasks and interactive chats, and can serve as an interface for CLI programs.
It currently can send, recieve and forward messages, custom keyboards, photos, audio, voice, documents, locations and video files.
'

#                                                            
# this file *MUST* not edited!
# copy "mycommands.sh.dist" to "mycommnds.sh" and change the strings there
bashbot_help='*Available commands*:
*• /start*: _Start bot and get this message_.
*• /help*: _Get this message_.
*• /info*: _Get shorter info message about this bot_.
*• /question*: _Start interactive chat_.
*• /cancel*: _Cancel any currently running interactive chats_.
*• /kickme*: _You will be autokicked from the chat_.
*• /leavechat*: _The bot will leave the group with this command _.
Written by Drew (@topkecleon), Daniil Gentili (@danogentili) and KayM(@gnadelwartz).
Get the code in my [GitHub](http://github.com/topkecleon/telegram-bot-bash)
'

# load modues on startup and always on on debug
if [ -n "${1}" ]; then
    # load all readable modules
    for modules in "${MODULEDIR:-.}"/*.sh ; do
	if [[ "${1}" == *"debug"* ]] || ! _is_function "$(basename "${modules}")"; then
		# shellcheck source=./modules/aliases.sh
		[ -r "${modules}" ] && source "${modules}" "${1}"
	fi
    done
fi

#                                                            
# this file *MUST* not edited!
# copy "mycommands.sh.dist" to "mycommnds.sh" and change the values there
# defaults to no inline and nonsense home dir
export INLINE="0"
export FILE_REGEX="${BASHBOT_ETC}/.*"


# load mycommands
# shellcheck source=./commands.sh
[ -r "${BASHBOT_ETC:-.}/mycommands.sh" ] && source "${BASHBOT_ETC:-.}/mycommands.sh"  "${1}"


if [ -z "${1}" ] || [[ "${1}" == *"debug"* ]];then
    # detect inline commands....
    # no default commands, all processing is done in myinlines()
    if [ "$INLINE" != "0" ] && [ -n "${iQUERY[ID]}" ]; then
    	# forward iinline query to optional dispatcher
	_exec_if_function myinlines

    # regular (gobal) commands ...
    # your commands are in mycommands() 
    else

	###################
	# user defined commands must placed in mycommands
	_exec_if_function mycommands

	# run commands if true (0) is returned or if mycommands dose not exist
	# shellcheck disable=SC2181
	if [ "$?" = "0" ]; then
	    case "${MESSAGE}" in
		################################################
		# this file *MUST* not edited!
		# copy "mycommands.sh.dist" to "mycommnds.sh" and change the values and add your commands there
		#
		# GLOBAL commands start here, edit messages only
		'/info'*)
			send_markdown_message "${CHAT[ID]}" "${bashbot_info}"
			;;
		'/start'*)
			send_action "${CHAT[ID]}" "typing"
			user_is_botadmin "${USER[ID]}" && send_markdown_message "${CHAT[ID]}" "You are *BOTADMIN*."
			if user_is_admin "${CHAT[ID]}" "${USER[ID]}" || user_is_allowed  "${USER[ID]}" "start" ; then
				send_markdown_message "${CHAT[ID]}" "${bashbot_help}"
			else
				send_normal_message "${CHAT[ID]}" "You are not allowed to start Bot."
			fi
			;;
			
		'/help'*)
			send_markdown_message "${CHAT[ID]}" "${bashbot_help}"
			;;
		'/leavechat'*) # bot leave chat if user is admin in chat
			if user_is_admin "${CHAT[ID]}" "${USER[ID]}" || user_is_allowed  "${USER[ID]}" "leave" ; then
				send_markdown_message "${CHAT[ID]}" "*LEAVING CHAT...*"
   				leave_chat "${CHAT[ID]}"
			fi
     			;;
     			
     		'/kickme'*)
     			kick_chat_member "${CHAT[ID]}" "${USER[ID]}"
     			unban_chat_member "${CHAT[ID]}" "${USER[ID]}"
     			;;
     			
		*)	# forward messages to optional dispatcher
			_exec_if_function send_interactive "${CHAT[ID]}" "${MESSAGE}"
			;;
	     esac
	fi
    fi 
fi
