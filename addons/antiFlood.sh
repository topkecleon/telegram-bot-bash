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
export BASHBOT_EVENT_TEXT BASHBOT_EVENT_CMD BASHBOT_EVENT_FILE

# any global variable defined by addons MUST be prefixed by addon name
ANTIFLOOD_ME="antiflood"

declare -Ax ANTIFLOOD_CHATS ANTIFLOOD_ACTUALS

ANTIFLOOD_DEFAULT="5"	# 5 files per minute
ANTIFLOOD_BAN="5"	# 5 minutes

# initialize after installation or update
if [[ "$1" = "init"* ]]; then 
	: # nothing
fi


# register on startbot
if [[ "$1" = "start"* ]]; then 
    #load existing chat settings on start
    jssh_readDB "ANTIFLOOD_CHATS" "${ADDONDIR:-./addons}/$ANTIFLOOD_ME"

    # register to CMD
    BASHBOT_EVENT_CMD["${ANTIFLOOD_ME}"]="${ANTIFLOOD_ME}_cmd"

	# command /antiflood starts addon, $1 floodlevel $2 bantime
    antiflood_cmd(){
	case "${CMD[0]}" in
		"/antifl"*)
			ANTIFLOOD_CHATS["${CHAT[ID]}","level"]="${ANTIFLOOD_DEFAULT}"
			ANTIFLOOD_CHATS["${CHAT[ID]}","ban"]="${ANTIFLOOD_BAN}"
			[[ "${CMD[1]}"  =~ ^[0-9]+$  ]] && ANTIFLOOD_CHATS["${CHAT[ID]}","level"]="${CMD[1]}"
			[[ "${CMD[2]}"   =~ ^[0-9]+$ ]] && ANTIFLOOD_CHATS["${CHAT[ID]}","ban"]="${CMD[2]}"
			# antiflood_save &
		;;
	esac
    }

    # register to inline and command
    BASHBOT_EVENT_TEXT["${ANTIFLOOD_ME}"]="${ANTIFLOOD_ME}_multievent"
    BASHBOT_EVENT_FILE["${ANTIFLOOD_ME}"]="${ANTIFLOOD_ME}_multievent"

    antiflood_multievent(){
	# not started
	[ "${ANTIFLOOD_CHATS["${CHAT[ID]}","level"]}" = "" ] && return
	# count flood messages
	[ "$1" = "text" ] && [ "${#MESSAGE[0]}" -lt "5" ] && (( ANTIFLOOD_ACTUALS["${CHAT[ID]}","${USER[ID]}"] += 1 ))
	# shellcheck disable=SC2154
	[ "$1" = "file" ] && (( ANTIFLOOD_ACTUALS["${CHAT[ID]}","${USER[ID]}","file"] += 1 ))
	# antiflood_check &
    }
fi
