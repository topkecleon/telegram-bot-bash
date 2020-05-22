#!/bin/bash
# file: modules/chatMember.sh
# do not edit, this file will be overwritten on update

# This file is public domain in the USA and all free countries.
# Elsewhere, consider it to be WTFPLv2. (wtfpl.net/txt/copying)
#
#### $$VERSION$$ v0.96-dev-7-g0153928

# source once magic, function named like file
eval "$(basename "${BASH_SOURCE[0]}")(){ :; }"

# source from commands.sh to use the member functions

LEAVE_URL=$URL'/leaveChat'
KICK_URL=$URL'/kickChatMember'
UNBAN_URL=$URL'/unbanChatMember'
GETMEMBER_URL=$URL'/getChatMember'

# usage: status="$(get_chat_member_status "chat" "user")"
get_chat_member_status() {
	sendJson "$1" '"user_id":'"$2"'' "$GETMEMBER_URL"
	# shellcheck disable=SC2154
	JsonGetString '"result","status"' <<< "$res"
}

kick_chat_member() {
	sendJson "$1" 'user_id: '"$2"'' "$KICK_URL"
}

unban_chat_member() {
	sendJson "$1" 'user_id: '"$2"'' "$UNBAN_URL"
}

leave_chat() {
	sendJson "$1" "" "$LEAVE_URL"
}

user_is_creator() {
	if [ "${1:--}" = "${2:-+}" ] || [ "$(get_chat_member_status "$1" "$2")" = "creator" ]; then return 0; fi
	return 1 
}

user_is_admin() {
	[ "$1" = "$2" ] && return 0
	local me; me="$(get_chat_member_status "$1" "$2")"
	if [ "${me}" = "creator" ] || [ "${me}" = "administrator" ]; then return 0; fi
	user_is_botadmin "$2" && return 0
	return 1 
}

user_is_botadmin() {
	local admin; admin="$(head -n 1 "${BOTADMIN}")"
	[ "${admin}" = "${1}" ] && return 0
	[ "${admin}" = "${2}" ] && return 0
	[[ "${admin}" = "@*" ]] && [[ "${admin}" = "${2}" ]] && return 0
	if [ "${admin}" = "?" ]; then printf '%s\n' "${1:-?}" >"${BOTADMIN}"; return 0; fi
	return 1
}

user_is_allowed() {
	local acl="$1"
	[ -z "$1" ] && return 1
	grep -F -xq "${acl}:*:*" <"${BOTACL}" && return 0
	[ -n "$2" ] && acl="${acl}:$2"
	grep -F -xq "${acl}:*" <"${BOTACL}" && return 0
	[ -n "$3" ] && acl="${acl}:$3"
	grep -F -xq "${acl}" <"${BOTACL}"
}
