#!/bin/bash
# file: modules/aliases.sh
# do not edit, this file will be overwritten on update

# This file is public domain in the USA and all free countries.
# Elsewhere, consider it to be WTFPLv2. (wtfpl.net/txt/copying)
#
#### $$VERSION$$ v1.51-0-g6e66a28
#
# will be automatically sourced from bashbot

# source once magic, function named like file
eval "$(basename "${BASH_SOURCE[0]}")(){ :; }"

# easy handling of users:
_is_botadmin() {
	user_is_botadmin "${USER[ID]}"
}
_is_admin() {
	user_is_admin "${CHAT[ID]}" "${USER[ID]}"
}
_is_creator() {
	user_is_creator "${CHAT[ID]}" "${USER[ID]}"
}
_is_allowed() {
	user_is_allowed "${USER[ID]}" "$1" "${CHAT[ID]}"
}
_leave() {
	leave_chat "${CHAT[ID]}"
}
_kick_user() {
	kick_chat_member "${CHAT[ID]}" "$1"
}
_unban_user() {
	unban_chat_member "${CHAT[ID]}" "$1"
}
# easy sending of messages of messages
_message() {
	send_normal_message "${CHAT[ID]}" "$1"
}
_normal_message() {
	send_normal_message "${CHAT[ID]}" "$1"
}
_html_message() {
	send_html_message "${CHAT[ID]}" "$1"
}
_markdown_message() {
	send_markdown_message "${CHAT[ID]}" "$1"
}
# easy handling of keyboards
_inline_button() {
	send_inline_button "${CHAT[ID]}" "" "$1" "$2" 
}
_inline_keyboard() {
	send_inline_keyboard "${CHAT[ID]}" "" "$1"
}
_keyboard_numpad() {
	send_keyboard "${CHAT[ID]}" "" '["1","2","3"],["4","5","6"],["7","8","9"],["-","0","."]' "yes"
}
_keyboard_yesno() {
	send_keyboard "${CHAT[ID]}" "" '["yes","no"]'
}
_del_keyboard() {
	remove_keyboard "${CHAT[ID]}" ""
}
