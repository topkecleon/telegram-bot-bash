#!/bin/bash
# file: addons/example.sh.dist
#
# Addons can register to bashbot events at statup
# by providing their name and a callback per event
#
# If an event occours each registered event function is called.
#
# Events run in the same context as the main bashbot event loop
# so variables set here are persistent as long bashbot is running.
#
# Note: For the same reason event function MUST return imideatly!
# compute intensive tasks must be run in a nonblocking subshell,
# e.g. "(long running) &"
#  

# Availible events:
# on events startbot and init, this file is sourced
#
# BASBOT_EVENT_INLINE	inline query received
# BASBOT_EVENT_MESSAGE	any type of message received
# BASBOT_EVENT_REPLYTO	reply to message received
# BASBOT_EVENT_FORWARD	forwarded message received
# BASBOT_EVENT_CONTACT	contact received
# BASBOT_EVENT_LOCATION	location or venue received
# BASBOT_EVENT_FILE	file received
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

# any global variable defined by addons MUST be prefixed by addon name
EXAMPLE_ME="example"

# initialize after installation or update
if [[ "$1" = "init"* ]]; then 
	: # notihung to do
fi


# register on startbot
if [[ "$1" = "start"* ]]; then 
    # register to inline
    export BASBOT_EVENT_INLINE["${EXAMPLE_ME}"]="${EXAMPLE_ME}_inline"

    # any function defined by addons MUST be prefixed by addon name
    # function local variables can have any name, but must be LOCAL
    example_inline(){
	local msg="${MESSAGE}"
	send_normal_message "${CHAT[ID]}" "Inline query received: ${msg}"
    }

    # register to reply
    export BASBOT_EVENT_REPLY["${EXAMPLE_ME}"]="${EXAMPLE_ME}_reply"

    # any function defined by addons MUST be prefixed by addon name
    # function local variables can have any name, but must be LOCAL
    example_reply(){
	local msg="message"
	send_markdown_message "${CHAT[ID]}" "User *${USER[USERNAME]}* replied to ${msg} from *${REPLYTO[USERNAME]}*"
    }
fi
