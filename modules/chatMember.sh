#!/bin/bash
# file: modules/chatMember.sh
# do not edit, this file will be overwritten on update

# This file is public domain in the USA and all free countries.
# Elsewhere, consider it to be WTFPLv2. (wtfpl.net/txt/copying)
#
#### $$VERSION$$ v1.30-dev-0-gd521d35

# will be automatically sourced from bashbot

# source once magic, function named like file
eval "$(basename "${BASH_SOURCE[0]}")(){ :; }"

LEAVE_URL="${URL}"'/leaveChat'
KICK_URL="${URL}"'/kickChatMember'
UNBAN_URL="${URL}"'/unbanChatMember'
GETMEMBER_URL=${URL}'/getChatMember'

# manage chat functions -------
# $1 chat, $2 title 
set_chat_title() {
	sendJson "$1" '"title": "'"$2"'"' "${URL}/setChatTitle"
}

# $1 chat, $2 title 
set_chat_description() {
	sendJson "$1" '"description": "'"$2"'"' "${URL}/setChatDescription"
}


# manage chat member functions -------
kick_chat_member() {
	sendJson "$1" 'user_id: '"$2"'' "${KICK_URL}"
}

unban_chat_member() {
	sendJson "$1" 'user_id: '"$2"'' "${UNBAN_URL}"
}

leave_chat() {
	sendJson "$1" "" "${LEAVE_URL}"
}


# bashbot specific functions ---------

# usage: status="$(get_chat_member_status "chat" "user")"
# $1 chat # $2 user
get_chat_member_status() {
	sendJson "$1" '"user_id":'"$2"'' "${GETMEMBER_URL}"
	# shellcheck disable=SC2154
	JsonGetString '"result","status"' <<< "${res}"
}

user_is_creator() {
	# empty is false ...
	[[ "${1:--}" == "${2:-+}" || "$(get_chat_member_status "$1" "$2")" == "creator" ]] && return 0
	return 1 
}

# $1 chat
bot_is_admin() {
	user_is_admin "$1" "$(getConfigKey "botid")"
}

# $1 chat # $2 user
user_is_admin() {
	[[ -z "$1" || -z "$2" ]] && return 1
	[ "${1:--}" == "${2:-+}" ] && return 0
	user_is_botadmin "$2" && return 0
	local me; me="$(get_chat_member_status "$1" "$2")"
	[[ "${me}" =~ ^creator$|^administrator$ ]] && return 0
	return 1 
}

# $1 user
user_is_botadmin() {
	[ -z "$1" ] && return 1
	local admin; admin="$(getConfigKey "botadmin")"; [ -z "${admin}" ] && return 1
	[[ "${admin}" == "$1" || "${admin}" == "$2" ]] && return 0
	#[[ "${admin}" = "@*" ]] && [[ "${admin}" = "$2" ]] && return 0
	if [ "${admin}" = "?" ]; then setConfigKey "botadmin" "${1:-?}"; return 0; fi
	return 1
}

# $1 user # $2 key # $3 chat
user_is_allowed() {
	[ -z "$1" ] && return 1
	# user can do everything
	grep -F -xq "$1:*:*" <"${BOTACL}" && return 0
	[ -z "$2" ] && return 1
	# user is allowed todo one action in every chat
	grep -F -xq "$1:$2:*" <"${BOTACL}" && return 0
	# all users are allowed to do one action in every chat
	grep -F -xq "ALL:$2:*" <"${BOTACL}" && return 0
	[ -z "$3" ] && return 1
	# user is allowed to do one action in one chat
	grep -F -xq "$1:$2:$3" <"${BOTACL}" && return 0
	# all users are allowed to do one action in one chat
	grep -F -xq "ALL:$2:$3" <"${BOTACL}" && return 0
	return 1
}
