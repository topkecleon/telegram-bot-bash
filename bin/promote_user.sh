#!/bin/bash
# shellcheck disable=SC1090,SC2034
#===============================================================================
#
#          FILE: bin/promote_user.sh
# 
USAGE='promote_user.sh [-h|--help] "CHAT[ID]" "USER[ID]" "right[:true|false]" ..'
# 
#   DESCRIPTION: promote / denote user rights in given group
# 
#       OPTIONS: CHAT[ID] - ID number of CHAT or BOTADMIN to send to yourself
#                USER[ID] - user to (un)ban
#                rights[:true|false] - rights to grant in long or short form,
#                        followed by :true to grant or :false to renove
#                  long: is_anonymous can_change_info can_post_messages can_edit_messages
#                        can_delete_messages can_invite_users can_restrict_members
#                        can_pin_messages can_promote_member`
#                  short: anon change post edit delete invite restrict pin promote
#
#                -h - display short help
#                --help - this help
#
#
#	LICENSE: WTFPLv2 http://www.wtfpl.net/txt/copying/
#        AUTHOR: KayM (gnadelwartz), kay@rrr.de
#       CREATED: 25.01.2021 22:34
#
#### $$VERSION$$ v1.51-0-g6e66a28
#===============================================================================

####
# parse args
PROMOTE="promote_chat_member"

# set bashbot environment
source "${0%/*}/bashbot_env.inc.sh" "debug" # debug
print_help "$1"

####
# ready, do stuff here -----

# send message in selected format
"${PROMOTE}" "$@"

# output send message result
print_result
