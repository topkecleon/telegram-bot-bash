#!/bin/bash
# file: addons/example.sh.dist
#
# Addons can register to bashbot events at statup
# by providing their name and a callback per event
#
# If an event occours a subprocess is spawned and call
# all registered event functions.

# Availible events:
#
# BASBOT_EVENT_INLINE	inline query received
# BASBOT_EVENT_MESSAGE	any type of message received
# BASBOT_EVENT_REPLY	reply to message received
# BASBOT_EVENT_FORWARD	forwarded message received
# BASBOT_EVENT_CONTACT	contact received
# BASBOT_EVENT_LOCATION	location or venue received
# BASBOT_EVENT_FILE	file received
#
# all global variables and functions can be used.

# any global variable defined by addons MUST be prefixed by addon name
# funtion local varibales can have an name
EXAMPLE_ME="example"

# register to inline
export BASBOT_EVENT_INLINE["${EXAMPLE_ME}"]="${EXAMPLE_ME}_inline"

# any function defined by addons MUST be prefixed by addon name
example_inline(){
	send_normal_message "${CHAT[ID]}" "Inline query received: ${MESSAGE}"
}

# register to reply
export BASBOT_EVENT_REPLY["${EXAMPLE_ME}"]="${EXAMPLE_ME}_reply"

# any function defined by addons MUST be prefixed by addon name
example_reply(){
	send_markdown_message "${CHAT[ID]}" "User *${USER[USERNAME]}* replied to message from *${REPLYTO[USERNAME]}*"
}

