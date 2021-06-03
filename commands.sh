#!/bin/bash
# file: commands.sh

#  _____                               _______    _ _      _ 
# (____ \                      _      (_______)  | (_)_   | |
#  _   \ \ ___     ____   ___ | |_     _____   _ | |_| |_ | |
# | |   | / _ \   |  _ \ / _ \|  _)   |  ___) / || | |  _)|_|
# | |__/ / |_| |  | | | | |_| | |__   | |____( (_| | | |__ _ 
# |_____/ \___/   |_| |_|\___/ \___)  |_______)____|_|\___)_|
#
# this file *MUST* not edited! place your config in the file "mycommands.conf"
# and commands in "mycommands.sh", a clean version is provided as "mycommands.sh.clean"
#

# This file is public domain in the USA and all free countries.
# Elsewhere, consider it to be WTFPLv2. (wtfpl.net/txt/copying)
#
#### $$VERSION$$ v1.51-0-g6e66a28
#

# bashbot locale defaults to c.UTF-8, adjust locale in mycommands.sh if needed
export 'LC_ALL=C.UTF-8'
export 'LANG=C.UTF-8'
export 'LANGUAGE=C.UTF-8'

unset IFS
# set -f # if you are paranoid use set -f to disable globbing

#-----------------------------
# this file *MUST* not edited!
# copy "mycommands.sh.dist" to "mycommands.sh" and change the strings there
bashbot_info='This is bashbot, the Telegram bot written entirely in bash.
It features background tasks and interactive chats, and can serve as an interface for CLI programs.
It currently can send, receive and forward messages, custom keyboards, photos, audio, voice, documents, locations and video files.
'

#-----------------------------
# this file *MUST* not edited!
# copy "mycommands.sh.dist" to "mycommands.sh" and change the strings there
bashbot_help='
*Available commands*:
*• /start*: _Start bot and get this message_.
*• /help*: _Get this message_.
*• /info*: _Get shorter info message about this bot_.
*• /kickme*: _You will be autokicked from the group_.
*• /leavechat*: _The bot will leave the group with this command _.
Additional commands from mycommands.dist ...
*• /game*: _throw a die_.
*• /question*: _Start interactive chat_.
*• /cancel*: _Cancel any currently running interactive chat_.
*• /run_notify*: _Start background job_.
*• /stop_notify*: _Stop notify background job_.
Written by Drew (@topkecleon) and KayM (@gnadelwartz).
Get the code on [GitHub](http://github.com/topkecleon/telegram-bot-bash)
'

# load modules on startup and always on on debug
if [ -n "$1" ]; then
    # load all readable modules
    for modules in "${MODULEDIR:-.}"/*.sh ; do
	if [[ "$1" == *"debug"* ]] || ! _is_function "$(basename "${modules}")"; then
		# shellcheck source=./modules/aliases.sh
		[ -r "${modules}" ] && source "${modules}" "$1"
	fi
    done
fi

#----------------------------
# this file *MUST* not edited!
# copy "mycommands.sh.dist" to "mycommands.sh" and change the values there
# defaults to no inline, all commands  and nonsense home dir
export INLINE="0"
export CALLBACK="0"
export MEONLY="0"
export FILE_REGEX="${BASHBOT_ETC}/.*"


# load mycommands
# shellcheck source=./commands.sh
[ -r "${BASHBOT_ETC:-.}/mycommands.sh" ] && source "${BASHBOT_ETC:-.}/mycommands.sh"  "$1"


if [ -z "$1" ] || [[ "$1" == *"debug"* ]];then
    #################
    # detect inline and callback query
    if [ -n "${iQUERY[ID]}" ]; then
    	# forward inline query to optional dispatcher
	[ "${INLINE:-0}" != "0" ] &&  _exec_if_function myinlines

    elif [ -n "${iBUTTON[ID]}" ]; then
    	# forward inline query to optional dispatcher
	[ "${CALLBACK:-0}" != "0" ] && _exec_if_function mycallbacks

    #################
    # regular command
    else
	
	###################
	# if is bashbot is group admin it get commands sent to other bots
	# set MEONLY=1 to ignore commands for other bots
	if [[ "${MEONLY}" != "0" && "${MESSAGE}" == "/"*"@"* ]]; then
		# here we have a command with @xyz_bot added, check if it's our bot
		[ "${MESSAGE%%@*}" != "${MESSAGE%%@${ME}}" ] && return
	fi 

	###################
	# user defined commands must placed in mycommands
	! _is_function mycommands || mycommands

	# run commands if true (0) is returned or if mycommands dose not exist
	# shellcheck disable=SC2181
	if [ "$?" = "0" ]; then
	    case "${MESSAGE}" in
		################################################
		# this file *MUST* not edited!
		# copy "mycommands.sh.dist" to "mycommands.sh" and change the values and add your commands there
		#
		# GLOBAL commands start here, edit messages only
		'/info'*)
			send_markdown_message "${CHAT[ID]}" "${bashbot_info}"
			;;
		'/start'*)
			send_action "${CHAT[ID]}" "typing"
			MYCOMMANDS="*Note*: MISSING mycommands.sh:  copy _mycommands.dist_ or _mycommands.clean_."
			[ -r "${BASHBOT_ETC:-.}/mycommands.sh" ] && MYCOMMANDS="Place your commands and messages in _mycommands.sh_"
			user_is_botadmin "${USER[ID]}" &&\
				send_markdownv2_message "${CHAT[ID]}" "You are *BOTADMIN*.\n${MYCOMMANDS}"
			if user_is_admin "${CHAT[ID]}" "${USER[ID]}" || user_is_allowed  "${USER[ID]}" "start" ; then
				send_markdown_message "${CHAT[ID]}" "${bashbot_help}"
			else
				send_normal_message "${CHAT[ID]}" "You are not allowed to start Bot."
			fi
			;;
			
		'/help'*)
			send_markdown_message "${CHAT[ID]}" "${bashbot_help}"
			;;
		'/leavechat'*)	# bot leave chat if user is admin in chat
			if user_is_admin "${CHAT[ID]}" "${USER[ID]}" || user_is_allowed  "${USER[ID]}" "leave" ; then
				send_markdown_message "${CHAT[ID]}" "*LEAVING CHAT...*"
   				leave_chat "${CHAT[ID]}"
			fi
     			;;
     			
     		'/kickme'*)
     			kick_chat_member "${CHAT[ID]}" "${USER[ID]}"
     			unban_chat_member "${CHAT[ID]}" "${USER[ID]}"
     			;;
     			
		'/'*)	# discard all unknown commands
			: ;;
		*)	# forward message to interactive chats 
			_exec_if_function send_interactive "${CHAT[ID]}" "${MESSAGE}"
			;;
	     esac
	fi
    fi 
fi
