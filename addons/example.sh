#!/bin/bash
# file: addons/example.sh.dist
#
# Addons can register to bashbot events at startup
# by providing their name and a callback per event
#
#### $$VERSION$$ v1.51-0-g6e66a28
#
# If an event occurs each registered event function is called.
#
# Events run in the same context as the main bashbot event loop
# so variables set here are persistent as long bashbot is running.
#
# Note: For the same reason event function MUST return imideatly!
# compute intensive tasks must be run in a nonblocking subshell,
# e.g. "(long running) &"
#  

# Available events:
# on events startbot and init, this file is sourced
#
# BASHBOT_EVENT_INLINE	inline query received
# BASHBOT_EVENT_MESSAGE	any type of message received
# BASHBOT_EVENT_TEXT	message containing message text received
# BASHBOT_EVENT_CMD	a command is received
# BASHBOT_EVENT_REPLYTO	reply to message received
# BASHBOT_EVENT_FORWARD	forwarded message received
# BASHBOT_EVENT_CONTACT	contact received
# BASHBOT_EVENT_LOCATION	location or venue received
# BASHBOT_EVENT_FILE	file received
#
# BASHBOT_EVENT_TIMER	this event is a bit special as it fires every Minute
#			and has 3 meanings: oneshot, every time, every X minutes.
#
# all global variables and functions can be used in registered functions.
#
# parameters when loaded
# $1 event: init, startbot ...
# $2 debug: use "[[ "$2" = *"debug"* ]]" if you want to output extra diagnostic
#
# parameters on events
# $1 event: inline, message, ..., file
# $2 key: key of array BASHBOT_EVENT_xxx 
# $3 debug: use "[[ "$2" = *"debug"* ]]" if you want to output extra diagnostic
#

# export used events
export BASHBOT_EVENT_INLINE BASHBOT_EVENT_CMD BASHBOT_EVENT_REPLY BASHBOT_EVENT_TIMER BASHBOT_EVENT_SEND

# any global variable defined by addons MUST be prefixed by addon name
EXAMPLE_ME="example"

# initialize after installation or update
if [[ "$1" = "init"* ]]; then 
	: # nothing to do
fi


# register on startbot
if [[ "$1" = "start"* ]]; then 
    # register to reply
    BASHBOT_EVENT_REPLY["${EXAMPLE_ME}"]="${EXAMPLE_ME}_reply"
    EXAMPLE_ADMIN="$(getConfigKey "botadmin")"

    # any function defined by addons MUST be prefixed by addon name
    # function local variables can have any name, but must be LOCAL
    example_reply(){
	local msg="message" event="$1" key="$2"
	send_markdown_message "${CHAT[ID]}" "User *${USER[USERNAME]}* replied to ${msg} from *${REPLYTO[USERNAME]}* (Event: ${event} Key:{${key})" &
    }

    # register to inline and command
    BASHBOT_EVENT_INLINE["${EXAMPLE_ME}"]="${EXAMPLE_ME}_multievent"
    BASHBOT_EVENT_CMD["${EXAMPLE_ME}"]="${EXAMPLE_ME}_multievent"

    # any function defined by addons MUST be prefixed by addon name
    # function local variables can have any name, but must be LOCAL
    example_multievent(){
	local event="$1" key="$2"
	local msg="${MESSAGE[0]}"
	# shellcheck disable=SC2154
	[ "${type}" = "inline" ] && msg="${iQUERY[0]}"
	send_normal_message "${CHAT[ID]}" "${event} from ${key} received: ${msg}" &
    }

    BASHBOT_EVENT_TIMER["${EXAMPLE_ME}after5min","-5"]="${EXAMPLE_ME}_after5min"

    # any function defined by addons MUST be prefixed by addon name
    # function local variables can have any name, but must be LOCAL
    example_after5min(){
	send_markdown_message "${EXAMPLE_ADMIN}" "This is a one time event after 5 Minutes!" &
    }

    BASHBOT_EVENT_TIMER["${EXAMPLE_ME}every2min","2"]="${EXAMPLE_ME}_every2min"

    # any function defined by addons MUST be prefixed by addon name
    # function local variables can have any name, but must be LOCAL
    example_every2min(){
	send_markdown_message "${EXAMPLE_ADMIN}" "This a a every 2 minute event ..." &
    }

    # register to send
    BASHBOT_EVENT_SEND["${EXAMPLE_ME}"]="${EXAMPLE_ME}_log"
    EXAMPLE_LOG="${BASHBOT_ETC:-.}/addons/${EXAMPLE_ME}.log"

    # any function defined by addons MUST be prefixed by addon name
    # function local variables can have any name, but must be LOCAL
    # $1 = send / upload
    # $* remaining args are from sendJson and sendUpload
    # Note: do not call any send message functions from EVENT_SEND!
    example_log(){
	local send="$1"; shift
	printf "%s: Type: %s Args: %s\n" "$(date)" "${send}" "$*" >>"${EXAMPLE_LOG}"
    }
fi
