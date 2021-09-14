#!/bin/bash
# file: modules/chatMember.sh
# do not edit, this file will be overwritten on update

# This file is public domain in the USA and all free countries.
# Elsewhere, consider it to be WTFPLv2. (wtfpl.net/txt/copying)
#
#### $$VERSION$$ v1.51-0-g6e66a28

# will be automatically sourced from bashbot

# source once magic, function named like file
eval "$(basename "${BASH_SOURCE[0]}")(){ :; }"


# manage chat functions -------
# $1 chat 
new_chat_invite() {
	sendJson "$1" "" "${URL}/exportChatInviteLink"
	[ "${BOTSENT[OK]}" = "true" ] && printf "%s\n" "${BOTSENT[RESULT]}"
}

# $1 chat, $2 user_id, $3 title 
set_chatadmin_title() {
	sendJson "$1" '"user_id":'"$2"',"custom_title": "'"$3"'"' "${URL}/setChatAdministratorCustomTitle"
}
# $1 chat, $2 title 
set_chat_title() {
	sendJson "$1" '"title": "'"$2"'"' "${URL}/setChatTitle"
}

# $1 chat, $2 title 
set_chat_description() {
	sendJson "$1" '"description": "'"$2"'"' "${URL}/setChatDescription"
}

# $1 chat  $2 file
set_chat_photo() {
	local file; file="$(checkUploadFile "$1" "$2" "set_chat_photo")"
	[ -z "${file}" ] && return 1
	sendUpload "$1" "photo" "${file}" "${URL}/setChatPhoto" 
}
# $1 chat 
delete_chat_photo() {
	sendJson "$1" "" "${URL}/deleteChatPhoto"
}

# $1 chat, $2 message_id 
pin_chat_message() {
	sendJson "$1" '"message_id": "'"$2"'"' "${URL}/pinChatMessage"
}

# $1 chat, $2 message_id 
unpin_chat_message() {
	sendJson "$1" '"message_id": "'"$2"'"' "${URL}/unpinChatMessage"
}

# $1 chat 
unpinall_chat_message() {
	sendJson "$1" "" "${URL}/unpinAllChatMessages"
}

# $1 chat 
delete_chat_stickers() {
	sendJson "$1" "" "${URL}/deleteChatStickerSet"
}

# manage chat member functions -------
# $1 chat 
chat_member_count() {
	sendJson "$1" "" "${URL}/getChatMembersCount"
	[ "${BOTSENT[OK]}" = "true" ] && printf "%s\n" "${BOTSENT[RESULT]}"
}

kick_chat_member() {
	sendJson "$1" 'user_id: '"$2"'' "${URL}/kickChatMember"
}

unban_chat_member() {
	sendJson "$1" 'user_id: '"$2"'' "${URL}/unbanChatMember"
}

leave_chat() {
	sendJson "$1" "" "${URL}/leaveChat"
}

# $1 chat, $2 userid, $3 ... "right[:true]" default false
# right:  is_anonymous change_info post_messages edit_messages delete_messages invite_users restrict_members pin_messages promote_member
promote_chat_member() {
	local arg bool json chat="$1" user="$2; shift 2"
	for arg in "$@"
	do
		# default false
		bool=false; [ "${arg##*:}" = "true" ] && bool="true"
		# expand args
		case "${arg}" in
			*"anon"*)	arg="is_anonymous";;
			*"change"*)	arg="can_change_info";;
			*"post"*)	arg="can_post_messages";;
			*"edit"*)	arg="can_edit_messages";;
			*"delete"*)	arg="can_delete_messages";;
			*"pin"*)	arg="can_pin_messages";;
			*"invite"*)	arg="can_invite_users";;
			*"restrict"*)	arg="can_restrict_members";;
			*"promote"*)	arg="can_promote_members";;
			*) 	[ -n "${BASHBOTDEBUG}" ] && log_debug "promote_chat_member: unknown promotion CHAT=${chat} USER=${user} PROM=${arg}"
				continue;; 
		esac
		# compose json
		[ -n "${json}" ] && json+=","
		json+='"'"${arg}"'": "'"${bool}"'"'
	done
	sendJson "${chat}" '"user_id":'"${user}"','"${json}"'' "${URL}/promoteChatMember"
}

# bashbot specific functions ---------

# usage: status="$(get_chat_member_status "chat" "user")"
# $1 chat # $2 user
get_chat_member_status() {
	sendJson "$1" '"user_id":'"$2"'' "${URL}/getChatMember"
	# shellcheck disable=SC2154
	printf "%s\n" "${UPD["result,status"]}"
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
	[ -z "${BOTADMIN}" ] && return 1
	[[ "${BOTADMIN}" == "$1" || "${BOTADMIN}" == "$2" ]] && return 0
	if [ "${BOTADMIN}" = "?" ]; then setConfigKey "botadmin" "${1:-?}"; BOTADMIN="${1:-?}"; return 0; fi
	return 1
}

# $1 user # $2 key # $3 chat
user_is_allowed() {
	[ -z "$1" ] && return 1
	user_is_admin "$1" && return 0
	# user can do everything
	grep -F -xq "$1:*:*" "${BOTACL}" && return 0
	[ -z "$2" ] && return 1
	# user is allowed todo one action in every chat
	grep -F -xq "$1:$2:*" "${BOTACL}" && return 0
	# all users are allowed to do one action in every chat
	grep -F -xq "ALL:$2:*" "${BOTACL}" && return 0
	[ -z "$3" ] && return 1
	# user is allowed to do one action in one chat
	grep -F -xq "$1:$2:$3" "${BOTACL}" && return 0
	# all users are allowed to do one action in one chat
	grep -F -xq "ALL:$2:$3" "${BOTACL}" && return 0
	return 1
}
