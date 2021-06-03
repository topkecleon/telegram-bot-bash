#!/bin/bash
# file: addons/antiFlood.sh.dist
#
# this addon counts how many files, e.g. stickers, are sent to
# a chat and takes actions if threshold is reached
#  
#### $$VERSION$$ v1.51-0-g6e66a28

# used events:
#
# BASHBOT_EVENT_TEXT	message containing message text received
# BASHBOT_EVENT_CMD	a command is received
# BASHBOT_EVENT_FILE	file received
#
# all global variables and functions can be used in registered functions.
#
# parameters when loaded
# $1 event: init, startbot ...
# $2 debug: use "[[ "$2" = *"debug"* ]]" if you want to output extra diagnostic
#
# parameters on events
# $1 event: inline, message, ..., file
# $2 debug: use "[[ "$2" = *"debug"* ]]" if you want to output extra diagnostic
#
# shellcheck disable=SC2140

# export used events
export BASHBOT_EVENT_TEXT BASHBOT_EVENT_CMD BASHBOT_EVENT_FILE BASHBOT_EVENT_TIMER

# any global variable defined by addons MUST be prefixed by addon name
ANTIFL_ME="antiFlood"

declare -Ax ANTIFL_CHATS ANTIFL_ACTUALS

ANTIFL_DEFAULT="5"	# 5 files per minute
ANTIFL_BAN="5"	# 5 minutes

# initialize after installation or update
if [[ "$1" = "init"* ]]; then 
	jssh_newDB "addons/${ANTIFL_ME}"
fi



# register on startbot
if [[ "$1" = "start"* ]]; then 
    ANTIFL_ADMIN="$(getConfigKey "botadmin")"
    #load existing chat settings on start
    jssh_readDB "ANTIFL_CHATS" "addons/${ANTIFL_ME}"

    # register to CMD
    BASHBOT_EVENT_CMD["${ANTIFL_ME}"]="${ANTIFL_ME}_cmd"

    antiFlood_cmd(){
	# shellcheck disable=SC2153
	local chat="${CHAT[ID]}"

	case "${CMD[0]}" in
		# command /afstart starts detection, $1 floodlevel
		"/afstart")
			# allow bot admin to activate for other chats
			[[ "${CMD[3]}"  =~ ^[-0-9]+$  ]] && user_is_botadmin "${USER[ID]}" && chat="$3"
			[[ "${CMD[1]}"  =~ ^[0-9]+$  ]] && ANTIFL_CHATS["${chat}","level"]="${CMD[1]}" \
				|| ANTIFL_CHATS["${chat}","level"]="${ANTIFL_DEFAULT}"
			[[ "${CMD[2]}"  =~ ^[0-9]+$  ]] && ANTIFL_CHATS["${chat}","ban"]="${CMD[2]}" \
				|| ANTIFL_CHATS["${chat}","ban"]="${ANTIFL_BAN}"
			antiFlood_timer
			send_normal_message "${USER[ID]}" "Antiflood set for chat ${chat}" &
		;;
		# command /afactive starts counter meausares
		"/afdo" | "/afactive")
			[[ "${CMD[1]}"  =~ ^[-0-9]+$  ]] && user_is_botadmin "${USER[ID]}" && chat="$3"
			ANTIFL_CHATS["${chat}","active"]="yes"
			jssh_writeDB "ANTIFL_CHATS" "addons/${ANTIFL_ME}" &
			send_normal_message "${USER[ID]}" "Antiflood activated for chat ${chat}" &
		;;
		# command /afactive starts counter meausares
		"/afstop")
			[[ "${CMD[1]}"  =~ ^[-0-9]+$  ]] && user_is_botadmin "${USER[ID]}" && chat="$3"
			ANTIFL_CHATS["${chat}","active"]="no"
			jssh_writeDB "ANTIFL_CHATS" "addons/${ANTIFL_ME}" &
			send_normal_message "${USER[ID]}" "Antiflood stopped for chat ${chat}" &
		;;
	esac
    }

    # register to timer
    BASHBOT_EVENT_TIMER["${ANTIFL_ME}","${ANTIFL_BAN}"]="antiFlood_timer"

    # save settings and reset flood level every BAN Min
    antiFlood_timer(){
	ANTIFL_ACTUALS=( ) 
	jssh_writeDB "ANTIFL_CHATS" "addons/${ANTIFL_ME}" &
    }

    # register to inline and command
    BASHBOT_EVENT_TEXT["${ANTIFL_ME}"]="${ANTIFL_ME}_multievent"
    BASHBOT_EVENT_FILE["${ANTIFL_ME}"]="${ANTIFL_ME}_multievent"

    antiFlood_multievent(){
	# not started
	[ -z "${ANTIFL_CHATS["${CHAT[ID]}","level"]}" ] && return
	# count user flood text
	if [ "$1" = "text" ]; then
		if [ "${#MESSAGE[0]}" -gt "${ANTIFL_CHATS["${CHAT[ID]}","level"]}" ]; then
			(( ANTIFL_ACTUALS["${CHAT[ID]}","${USER[ID]}"]-- ))
			# shellcheck disable=SC2154
			(( ANTIFL_ACTUALS["${CHAT[ID]}","${USER[ID]}","file"]-- ))
		else
			# shellcheck disable=SC2154
			(( ANTIFL_ACTUALS["${CHAT[ID]}","${USER[ID]}"]++ ))
		fi
	fi
	# count user chat flood 
	if [ "$1" = "file" ]; then
		# shellcheck disable=SC2154
		(( ANTIFL_ACTUALS["${CHAT[ID]}","${USER[ID]}","file"]++ ))
		# shellcheck disable=SC2154
		(( ANTIFL_ACTUALS["${CHAT[ID]}","file"]++ ))
		antiFlood_action & # do actions in subshell
	fi
    }

    # check and handle actions
    antiFlood_action() {
	# check flood level of user
	if [ "$(( ANTIFL_ACTUALS["${CHAT[ID]}","${USER[ID]}","file"] +1))" -gt "${ANTIFL_CHATS["${CHAT[ID]}","level"]}" ]; then
		if [ "${ANTIFL_CHATS["${CHAT[ID]}","active"]}" = "yes" ]; then
			# remove message
			delete_message "${CHAT[ID]}" "${MESSAGE[ID]}"
		else
			# inform admin
			send_markdown_message "${ANTIFL_ADMIN}" "User ${USER[USERNAME]} reached flood level in chat ${CHAT[USERNAME]}!"
		fi
	fi
	# check flood level of chat
	if [ "$(( ANTIFL_ACTUALS["${CHAT[ID]}","file"] +1))" -gt "$(( ANTIFL_CHATS["${CHAT[ID]}","level"] * ANTIFL_BAN ))" ]; then
		if [ "${ANTIFL_CHATS["${CHAT[ID]}","active"]}" = "yes" ]; then
			# remove message
			delete_message "${CHAT[ID]}" "${MESSAGE[ID]}"
		else
			# inform admin
			send_markdown_message "${ANTIFL_ADMIN}" "Chat ${CHAT[USERNAME]} reached max flood level!"
		fi
	fi
    }
fi
