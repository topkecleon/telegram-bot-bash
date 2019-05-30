#!/bin/bash
# file: addons/antiFlood.sh.dist
#
# this addon counts how many files, e.g. stickers, are sent to
# a chat and takes actions if threshold is reached
#  

# used events:
#
# BASHBOT_EVENT_TEXT	message containing message text received
# BASHBOT_EVENT_CMD	a command is recieved
# BASHBOT_EVENT_FILE	file received
#
# all global variables and functions can be used in registered functions.
#
# parameters when loaded
# $1 event: init, startbot ...
# $2 debug: use "[[ "$2" = *"debug"* ]]" if you want to output extra diagnostic
#
# prameters on events
# $1 event: inline, message, ..., file
# $2 debug: use "[[ "$2" = *"debug"* ]]" if you want to output extra diagnostic
#
# shellcheck disable=SC2140

# export used events
export BASHBOT_EVENT_TEXT BASHBOT_EVENT_CMD BASHBOT_EVENT_FILE BASHBOT_EVENT_TIMER

# any global variable defined by addons MUST be prefixed by addon name
ANTIFL_ME="antiflood"

declare -Ax ANTIFL_CHATS ANTIFL_ACTUALS

ANTIFL_DEFAULT="5"	# 5 files per minute
ANTIFL_BAN="5"	# 5 minutes

# initialize after installation or update
if [[ "$1" = "init"* ]]; then 
	ANTIFL_ADMIN="$(< "${BOTADMIN}")"
fi


# register on startbot
if [[ "$1" = "start"* ]]; then 
    #load existing chat settings on start
    jssh_readDB "ANTIFL_CHATS" "${ADDONDIR:-./addons}/$ANTIFL_ME"

    # register to CMD
    BASHBOT_EVENT_CMD["${ANTIFL_ME}"]="${ANTIFL_ME}_cmd"

    antiflood_cmd(){
	case "${CMD[0]}" in
		# command /antiflood starts detection, $1 floodlevel
		"/antifl"*)
			ANTIFL_CHATS["${CHAT[ID]}","level"]="${ANTIFL_DEFAULT}"
			ANTIFL_CHATS["${CHAT[ID]}","ban"]="${ANTIFL_BAN}"
			[[ "${CMD[1]}"  =~ ^[0-9]+$  ]] && ANTIFL_CHATS["${CHAT[ID]}","level"]="${CMD[1]}"
			# antiflood_save &
		;;
		# command /floodapply starts counter meausares
		"/floodap"*)
			ANTIFL_CHATS["${CHAT[ID]}","active"]="yes"
		;;
	esac
    }

    # register to timer
    BASHBOT_EVENT_TIMER["${ANTIFL_ME}","${ANTIFL_BAN}"]="antiflood_timer"

    # save settings and reset flood level every BAN Min
    antiflood_timer(){
	unset ANTIFL_ACTUALS
	jssh_writeBD "ANTIFL_CHATS" "${ADDONDIR:-./addons}/$ANTIFL_ME" &
    }

    # register to inline and command
    BASHBOT_EVENT_TEXT["${ANTIFL_ME}"]="${ANTIFL_ME}_multievent"
    BASHBOT_EVENT_FILE["${ANTIFL_ME}"]="${ANTIFL_ME}_multievent"

    antiflood_multievent(){
	# not started
	[ "${ANTIFL_CHATS["${CHAT[ID]}","level"]}" = "" ] && return
	# check user flood text
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
	# check user flood picture
	# shellcheck disable=SC2154
	[ "$1" = "file" ] && (( ANTIFL_ACTUALS["${CHAT[ID]}","${USER[ID]}","file"]++ ))
	antiflood_action & # do actions in subshell
    }

    # check and handle actions
    antiflood_action() {
	# check flood level of user
	if [ "${ANTIFL_ACTUALS["${CHAT[ID]}","${USER[ID]}","file"]}" -gt "${ANTIFL_CHATS["${CHAT[ID]}","level"]}" ]; then
		if [ "${ANTIFL_CHATS["${CHAT[ID]}","active"]}" = "yes" ]; then
			# remove message
			delete_message "${CHAT[ID]}" "${MESSAGE[ID]}"
		else
			# inform admin
			send_markdown_message "${ANTIFL_ADMIN}" "User ${USER[USERNAME]} reached flood level in chat ${CHAT[USERNAME]}!"
		fi
	fi
    }
fi
