#!/bin/bash
# file: bashbot.sh 
# do not edit, this file will be overwritten on update

# bashbot, the Telegram bot written in bash.
# Written by Drew (@topkecleon) and Daniil Gentili (@danogentili), KayM (@gnadelwartz).
# Also contributed: JuanPotato, BigNerd95, TiagoDanin, iicc1.
# https://github.com/topkecleon/telegram-bot-bash

# Depends on JSON.sh (http://github.com/dominictarr/JSON.sh) (MIT/Apache),
# and on tmux (http://github.com/tmux/tmux) (BSD).
# This file is public domain in the USA and all free countries.
# Elsewhere, consider it to be WTFPLv2. (wtfpl.net/txt/copying)
#
#### $$VERSION$$ v0.80-dev3-2-ga1a823b
#
# Exit Codes:
# - 0 sucess (hopefully)
# - 1 can't change to dir
# - 2 can't write to tmp, count or token 
# - 3 user / command / file not found
# - 4 unkown command
# - 5 cannot connect to telegram bot

# are we runnig in a terminal?
if [ -t 1 ] && [ "$TERM" != "" ];  then
    CLEAR='clear'
    RED='\e[31m'
    GREEN='\e[32m'
    ORANGE='\e[35m'
    NC='\e[0m'
fi

# get location and name of bashbot.sh
export SCRIPT SCRIPTDIR MODULEDIR RUNDIR RUNUSER
SCRIPT="$0"
SCRIPTDIR="$(dirname "$0")"
MODULEDIR="${SCRIPTDIR}/modules"

RUNDIR="${SCRIPTDIR}"
[ "${RUNDIR}" = "${SCRIPTDIR}" ] && SCRIPT="./$(basename "${SCRIPT}")"

RUNUSER="${USER}" # USER is overwritten by bashbot array

if [ "$1" != "source" ] && ! cd "${RUNDIR}" ; then
	echo -e "${RED}ERROR: Can't change to ${RUNDIR} ...${NC}"
	exit 1
fi

if [ ! -w "." ]; then
	echo -e "${ORANGE}WARNING: ${RUNDIR} is not writeable!${NC}"
	ls -ld .
fi

TOKENFILE="${BASHBOT_ETC:-.}/token"
if [ ! -f "${TOKENFILE}" ]; then
   if [ "${CLEAR}" = "" ] && [ "$1" != "init" ]; then
	echo "Running headless, run ${SCRIPT} init first!"
	exit 2 
   else
	${CLEAR}
	echo -e "${RED}TOKEN MISSING.${NC}"
	echo -e "${ORANGE}PLEASE WRITE YOUR TOKEN HERE OR PRESS CTRL+C TO ABORT${NC}"
	read -r token
	echo "${token}" > "${TOKENFILE}"
   fi
fi

BOTADMIN="${BASHBOT_ETC:-.}/botadmin"
if [ ! -f "${BOTADMIN}" ]; then
   if [ "${CLEAR}" = "" ]; then
	echo "Running headless, set botadmin to AUTO MODE!"
	echo '?' > "${BOTADMIN}"
   else
	${CLEAR}
	echo -e "${RED}BOTADMIN MISSING.${NC}"
	echo -e "${ORANGE}PLEASE WRITE YOUR TELEGRAM ID HERE OR ENTER '?'${NC}"
	echo -e "${ORANGE}TO MAKE FIRST USER TYPING '/start' TO BOTADMIN${NC}"
	read -r token
	echo "${token}" > "${BOTADMIN}"
	[ "${token}" = "" ] && echo '?' > "${BOTADMIN}"
   fi
fi

BOTACL="${BASHBOT_ETC:-.}/botacl"
if [ ! -f "${BOTACL}" ]; then
	echo -e "${ORANGE}Create empty ${BOTACL} file.${NC}"
	echo "" >"${BOTACL}"
fi

TMPDIR="${BASHBOT_VAR:-.}/data-bot-bash"
if [ ! -d "${TMPDIR}" ]; then
	mkdir "${TMPDIR}"
elif [ ! -w "${TMPDIR}" ]; then
	echo -e "${RED}ERROR: Can't write to ${TMPDIR}!.${NC}"
	ls -ld "${TMPDIR}"
	exit 2
fi

COUNTFILE="${BASHBOT_VAR:-.}/count"
if [ ! -f "${COUNTFILE}" ]; then
	echo "" >"${COUNTFILE}"
elif [ ! -w "${COUNTFILE}" ]; then
	echo -e "${RED}ERROR: Can't write to ${COUNTFILE}!.${NC}"
	ls -l "${COUNTFILE}"
	exit 2
fi


BOTTOKEN="$(< "${TOKENFILE}")"
URL="${BASHBOT_URL:-https://api.telegram.org/bot}${BOTTOKEN}"

ME_URL=$URL'/getMe'

UPD_URL=$URL'/getUpdates?offset='
GETFILE_URL=$URL'/getFile'

unset USER
declare -A BOTSENT USER MESSAGE URLS CONTACT LOCATION CHAT FORWARD REPLYTO VENUE iQUERY
export res BOTSENT USER MESSAGE URLS CONTACT LOCATION CHAT FORWARD REPLYTO VENUE iQUERY CAPTION NAME

COMMANDS="${BASHBOT_ETC:-.}/commands.sh"
if [ "$1" != "source" ]; then
	if [ ! -f "${COMMANDS}" ] || [ ! -r "${COMMANDS}" ]; then
		echo -e "${RED}ERROR: ${COMMANDS} does not exist or is not readable!.${NC}"
		ls -l "${COMMANDS}"
		exit 3
	fi
	# shellcheck source=./commands.sh
	source "${COMMANDS}" "source"
fi


# internal functions
# $1 postfix, e.g. chatid
# $2 prefix, back- or startbot-
procname(){
	echo "$2${ME}_$1"
}

# $1 proc name
proclist() {
	# shellcheck disable=SC2009
	ps -ef | grep -v grep| grep "$1" | sed 's/\s\+/\t/g' | cut -f 2
}

# returns true if command exist
_exists()
{
	[ "$(LC_ALL=C type -t "$1")" = "file" ]
}

# returns true if function exist
_is_function()
{
	[ "$(LC_ALL=C type -t "$1")" = "function" ]
}

DELETE_URL=$URL'/deleteMessage'
delete_message() {
	sendJson "${1}" 'message_id: '"${2}"'' "${DELETE_URL}"
}

get_file() {
	[ "$1" = "" ] && return
	local JSON='"file_id": '"${1}"
	sendJson "" "${JSON}" "${GETFILE_URL}"
	jsonGetString <<< "${URL}/""${res}" '"result","file_path"'
}

# curl is preffered, but may not availible on ebedded systems
if [ "${BASHBOT_WGET}" = "" ] && _exists curl ; then
  # simple curl or wget call, output to stdout
  getJson(){
	curl -sL "$1"
  }
  # usage: sendJson "chat" "JSON" "URL"
  sendJson(){
	local chat="";
	[ "${1}" != "" ] && chat='"chat_id":'"${1}"','
	res="$(curl -s -d '{'"${chat} $2"'}' -X POST "${3}" \
		-H "Content-Type: application/json" | "${JSONSHFILE}" -s -b -n )"
	BOTSENT[OK]="$(JsonGetLine '"ok"' <<< "$res")"
	BOTSENT[ID]="$(JsonGetValue '"result","message_id"' <<< "$res")"
  }
else
  # simple curl or wget call outputs result to stdout
  getJson(){
	wget -qO - "$1"
  }
  # usage: sendJson "chat" "JSON" "URL"
  sendJson(){
	local chat="";
	[ "${1}" != "" ] && chat='"chat_id":'"${1}"','
	res="$(wget -qO - --post-data='{'"${chat} $2"'}' \
		--header='Content-Type:application/json' "${3}" | "${JSONSHFILE}" -s -b -n )"
	BOTSENT[OK]="$(JsonGetLine '"ok"' <<< "$res")"
	BOTSENT[ID]="$(JsonGetValue '"result","message_id"' <<< "$res")"
  }
fi 

# convert common telegram entities to JSON
# title caption description markup inlinekeyboard
title2Json(){
	local title caption desc markup keyboard
	[ "$1" != "" ] && title=',"title":"'$1'"'
	[ "$2" != "" ] && caption=',"caption":"'$2'"'
	[ "$3" != "" ] && desc=',"description":"'$3'"'
	[ "$4" != "" ] && markup=',"parse_mode":"'$4'"'
	[ "$5" != "" ] && keyboard=',"reply_markup":"'$5'"'
	echo "${title}${caption}${desc}${markup}${keyboard}"
}

# get bot name
getBotName() {
	sendJson "" "" "$ME_URL"
	JsonGetString '"result","username"' <<< "$res"
}

# pure bash implementaion, done by KayM (@gnadelwartz)
# see https://stackoverflow.com/a/55666449/9381171
JsonDecode() {
        local out="$1" remain="" U=""
	local regexp='(.*)\\u[dD]([0-9a-fA-F]{3})\\u[dD]([0-9a-fA-F]{3})(.*)'
        while [[ "${out}" =~ $regexp ]] ; do
		U=$(( ( (0xd${BASH_REMATCH[2]} & 0x3ff) <<10 ) | ( 0xd${BASH_REMATCH[3]} & 0x3ff ) + 0x10000 ))
                remain="$(printf '\\U%8.8x' "${U}")${BASH_REMATCH[4]}${remain}"
                out="${BASH_REMATCH[1]}"
        done
        echo -e "${out}${remain}"
}

JsonGetString() {
	sed -n -e '0,/\['"$1"'\]/ s/\['"$1"'\][ \t]"\(.*\)"$/\1/p'
}
JsonGetLine() {
	sed -n -e '0,/\['"$1"'\]/ s/\['"$1"'\][ \t]//p'
}
JsonGetValue() {
	sed -n -e '0,/\['"$1"'\]/ s/\['"$1"'\][ \t]\([0-9.,]*\).*/\1/p'
}

################
# processing of updates starts here
process_updates() {
	local max num debug="$1"
	max="$(sed <<< "${UPDATE}" '/\["result",[0-9]*\]/!d' | tail -1 | sed 's/\["result",//g;s/\].*//g')"
	for ((num=0; num<=max; num++)); do
		process_client "$num" "${debug}"
	done
}
process_client() {
	local num="$1" debug="$2" 
	iQUERY[ID]="$(JsonGetString <<<"${UPDATE}" '"result",'"${num}"',"inline_query","id"')"
	if [ "${iQUERY[ID]}" = "" ]; then
		[[ "${debug}" = *"debug"* ]] && cat <<< "$UPDATE$'\\n'" >>"MESSAGE.log"
		process_message "${num}" "${debug}"
	else
		[[ "${debug}" = *"debug"* ]] && cat <<< "$UPDATE$'\\n'" >>"INLINE.log"
		[ "$INLINE" != "0" ] && _is_function process_inline && process_inline "${num}" "${debug}"
	fi
	# shellcheck source=./commands.sh
	source "${COMMANDS}" "${debug}"
	tmpcount="COUNT${CHAT[ID]}"
	grep -q "$tmpcount" <"${COUNTFILE}" >/dev/null 2>&1 || cat <<< "$tmpcount$'\\n'" >>"${COUNTFILE}"
	# To get user count execute bash bashbot.sh count
}
process_inline() {
	local num="${1}"
	iQUERY[0]="$(JsonDecode "$(JsonGetString <<<"${UPDATE}" '"result",0,"inline_query","query"')")"
	iQUERY[USER_ID]="$(JsonGetValue <<<"${UPDATE}" '"result",'"${num}"',"inline_query","from","id"')"
	iQUERY[FIRST_NAME]="$(JsonDecode "$(JsonGetString <<<"${UPDATE}" '"result",'"${num}"',"inline_query","from","first_name"')")"
	iQUERY[LAST_NAME]="$(JsonDecode "$(JsonGetString <<<"${UPDATE}" '"result",'"${num}"',"inline_query","from","last_name"')")"
	iQUERY[USERNAME]="$(JsonDecode "$(JsonGetString <<<"${UPDATE}" '"result",'"${num}"',"inline_query","from","username"')")"
}
process_message() {
	local num="$1"
	local TMP="${TMPDIR:-.}/$RANDOM$RANDOM-MESSAGE"
	cat <<< "$UPDATE$'\\n'" >"$TMP"
	# Message
	MESSAGE[0]="$(JsonDecode "$(JsonGetString '"result",'"${num}"',"message","text"' <"$TMP")" | sed 's#\\/#/#g')"
	MESSAGE[ID]="$(JsonGetValue '"result",'"${num}"',"message","message_id"' <"$TMP" )"

	# Chat
	CHAT[ID]="$(JsonGetValue '"result",'"${num}"',"message","chat","id"' <"$TMP" )"
	CHAT[FIRST_NAME]="$(JsonDecode "$(JsonGetString '"result",'"${num}"',"message","chat","first_name"' <"$TMP")")"
	CHAT[LAST_NAME]="$(JsonDecode "$(JsonGetString '"result",'"${num}"',"message","chat","last_name"' <"$TMP")")"
	CHAT[USERNAME]="$(JsonDecode "$(JsonGetString '"result",'"${num}"',"message","chat","username"' <"$TMP")")"
	CHAT[TITLE]="$(JsonDecode "$(JsonGetString '"result",'"${num}"',"message","chat","title"' <"$TMP")")"
	CHAT[TYPE]="$(JsonDecode "$(JsonGetString '"result",'"${num}"',"message","chat","type"' <"$TMP")")"
	CHAT[ALL_MEMBERS_ARE_ADMINISTRATORS]="$(JsonDecode "$(JsonGetString '"result",'"${num}"',"message","chat","all_members_are_administrators"' <"$TMP")")"

	# User
	USER[ID]="$(JsonGetValue '"result",'"${num}"',"message","from","id"' <"$TMP" )"
	USER[FIRST_NAME]="$(JsonDecode "$(JsonGetString '"result",'"${num}"',"message","from","first_name"' <"$TMP")")"
	USER[LAST_NAME]="$(JsonDecode "$(JsonGetString '"result",'"${num}"',"message","from","last_name"' <"$TMP")")"
	USER[USERNAME]="$(JsonDecode "$(JsonGetString '"result",'"${num}"',"message","from","username"' <"$TMP")")"

	# in reply to message from
	REPLYTO[UID]="$(JsonGetValue '"result",'"${num}"',"message","reply_to_message","from","id"' <"$TMP" )"
	if [ "${REPLYTO[UID]}" != "" ]; then
	   REPLYTO[0]="$(JsonDecode "$(JsonGetString '"result",'"${num}"',"message","reply_to_message","text"' <"$TMP")")"
	   REPLYTO[ID]="$(JsonGetValue '"result",'"${num}"',"message","reply_to_message","message_id"' <"$TMP")"
	   REPLYTO[FIRST_NAME]="$(JsonDecode "$(JsonGetString '"result",'"${num}"',"message","reply_to_message","from","first_name"' <"$TMP")")"
	   REPLYTO[LAST_NAME]="$(JsonDecode "$(JsonGetString '"result",'"${num}"',"message","reply_to_message","from","last_name"' <"$TMP")")"
	   REPLYTO[USERNAME]="$(JsonDecode "$(JsonGetString '"result",'"${num}"',"message","reply_to_message","from","username"' <"$TMP")")"
	fi

	# forwarded message from
	FORWARD[UID]="$(JsonGetValue '"result",'"${num}"',"message","forward_from","id"' <"$TMP" )"
	if [ "${FORWARD[UID]}" != "" ]; then
	   FORWARD[ID]="${MESSAGE[ID]}" # same as message ID
	   FORWARD[FIRST_NAME]="$(JsonDecode "$(JsonGetString '"result",'"${num}"',"message","forward_from","first_name"' <"$TMP")")"
	   FORWARD[LAST_NAME]="$(JsonDecode "$(JsonGetString '"result",'"${num}"',"message","forward_from","last_name"' <"$TMP")")"
	   FORWARD[USERNAME]="$(JsonDecode "$(JsonGetString '"result",'"${num}"',"message","forward_from","username"' <"$TMP")")"
	fi

	# Audio
	URLS[AUDIO]="$(get_file "$(JsonGetString '"result",'"${num}"',"message","audio","file_id"' <"$TMP")")"
	# Document
	URLS[DOCUMENT]="$(get_file "$(JsonGetString '"result",'"${num}"',"message","document","file_id"' <"$TMP")")"
	# Photo
	URLS[PHOTO]="$(get_file "$(JsonGetString '"result",'"${num}"',"message","photo",0,"file_id"' <"$TMP")")"
	# Sticker
	URLS[STICKER]="$(get_file "$(JsonGetString '"result",'"${num}"',"message","sticker","file_id"' <"$TMP")")"
	# Video
	URLS[VIDEO]="$(get_file "$(JsonGetString '"result",'"${num}"',"message","video","file_id"' <"$TMP")")"
	# Voice
	URLS[VOICE]="$(get_file "$(JsonGetString '"result",'"${num}"',"message","voice","file_id"' <"$TMP")")"

	# Contact
	CONTACT[USER_ID]="$(JsonDecode "$(JsonGetString '"result",'"${num}"',"message","contact","user_id"' <"$TMP")")"
	CONTACT[FIRST_NAME]="$(JsonDecode "$(JsonGetString '"result",'"${num}"',"message","contact","first_name"' <"$TMP")")"
	CONTACT[LAST_NAME]="$(JsonDecode "$(JsonGetString '"result",'"${num}"',"message","contact","last_name"' <"$TMP")")"
	CONTACT[NUMBER]="$(JsonGetString '"result",'"${num}"',"message","contact","phone_number"' <"$TMP")"
	CONTACT[VCARD]="$(JsonGetString '"result",'"${num}"',"message","contact","vcard"' <"$TMP")"

	# vunue
	VENUE[TITLE]="$(JsonDecode "$(JsonGetString '"result",'"${num}"',"message","venue","title"' <"$TMP")")"
	VENUE[ADDRESS]="$(JsonDecode "$(JsonGetString '"result",'"${num}"',"message","venue","address"' <"$TMP")")"
	VENUE[LONGITUDE]="$(JsonGetValue '"result",'"${num}"',"message","venue","location","longitude"' <"$TMP")"
	VENUE[LATITUDE]="$(JsonGetValue '"result",'"${num}"',"message","venue","location","latitude"' <"$TMP")"
	VENUE[FOURSQUARE]="$(JsonGetString '"result",'"${num}"',"message","venue","foursquare_id"' <"$TMP")"

	# Caption
	CAPTION="$(JsonDecode "$(JsonGetString '"result",'"${num}"',"message","caption"' <"$TMP")")"

	# Location
	LOCATION[LONGITUDE]="$(JsonGetValue '"result",'"${num}"',"message","location","longitude"' <"$TMP")"
	LOCATION[LATITUDE]="$(JsonGetValue '"result",'"${num}"',"message","location","latitude"' <"$TMP")"
	NAME="$(sed 's/.*\///g' <<< "${URLS[*]}")"
	rm "$TMP"
}


#########################
# main get updates loop, should never terminate
start_bot() {
	local DEBUG="$1"
	local OFFSET=0
	local mysleep="100" # ms
	local addsleep="100"
	local maxsleep="$(( ${BASHBOT_SLEEP:-5000} + 100 ))"
	[[ "${DEBUG}" = *"debug" ]] && exec &>>"DEBUG.log"
	[ "${DEBUG}" != "" ] && date && echo "Start BASHBOT in Mode \"${DEBUG}\""
	[[ "${DEBUG}" = "xdebug"* ]] && set -x 
	while true; do
		UPDATE="$(getJson "$UPD_URL$OFFSET" | "${JSONSHFILE}" -s -b -n)"

		# Offset
		OFFSET="$(grep <<< "${UPDATE}" '\["result",[0-9]*,"update_id"\]' | tail -1 | cut -f 2)"
		((OFFSET++))

		if [ "$OFFSET" != "1" ]; then
			mysleep="100"
			process_updates "${DEBUG}" &
		fi
		# adaptive sleep in ms rounded to next lower second
		[ "${mysleep}" -gt "999" ] && sleep "${mysleep%???}"
		# bash aritmetic
		((mysleep+= addsleep , mysleep= mysleep>maxsleep ?maxsleep:mysleep))
	done
}

# initialize bot environment, user and permissions
bot_init() {
	# upgrade from old version
	local OLDTMP="${BASHBOT_VAR:-.}/tmp-bot-bash"
	[ -d "${OLDTMP}" ] && { mv -n "${OLDTMP}/"* "${TMPDIR}"; rmdir "${OLDTMP}"; }
	[ -f "modules/inline.sh" ] && rm -f "modules/inline.sh"
	#setup bashbot
	[[ "$(id -u)" -eq "0" ]] && RUNUSER="nobody"
	echo -n "Enter User to run basbot [$RUNUSER]: "
	read -r TOUSER
	[ "$TOUSER" = "" ] && TOUSER="$RUNUSER"
	if ! id "$TOUSER" >/dev/null 2>&1; then
		echo -e "${RED}User \"$TOUSER\" not found!${NC}"
		exit 3
	else
		echo "Adjusting user \"${TOUSER}\" files and permissions ..."
		[ -w "bashbot.rc" ] && sed -i '/^[# ]*runas=/ s/runas=.*$/runas="'$TOUSER'"/' "bashbot.rc"
		chown -R "$TOUSER" . ./*
		chmod 711 .
		chmod -R a-w ./*
		chmod -R u+w "${COUNTFILE}" "${TMPDIR}" "${BOTADMIN}" ./*.log 2>/dev/null
		chmod -R o-r,o-w "${COUNTFILE}" "${TMPDIR}" "${TOKENFILE}" "${BOTADMIN}" "${BOTACL}" 2>/dev/null
		ls -la
	fi
}

JSONSHFILE="${BASHBOT_JSONSH:-${RUNDIR}/JSON.sh/JSON.sh}"
[[ "${JSONSHFILE}" != *"/JSON.sh" ]] && echo -e "${RED}ERROR: \"${JSONSHFILE}\" ends not with \"JSONS.sh\".${NC}" && exit 3

if [ ! -f "${JSONSHFILE}" ]; then
	echo "Seems to be first run, Downloading ${JSONSHFILE}..."
	[[ "${JSONSHFILE}" = "${RUNDIR}/JSON.sh/JSON.sh" ]] && mkdir "JSON.sh" 2>/dev/null && chmod +w "JSON.sh"
	getJson "https://cdn.jsdelivr.net/gh/dominictarr/JSON.sh/JSON.sh" >"${JSONSHFILE}"
	chmod +x "${JSONSHFILE}" 
fi

ME="$(getBotName)"
if [ "$ME" = "" ]; then
   if [ "$(< "${TOKENFILE}")" = "bashbottestscript" ]; then
	ME="bashbottestscript"
   else
	echo -e "${RED}ERROR: Can't connect to Telegram Bot! May be your TOKEN is invalid ...${NC}"
	exit 1
   fi
fi

# source the script with source as param to use functions in other scripts
# do not execute if read from other scripts

if [ "$1" != "source" ]; then

  ##############
  # internal options only for use from bashbot and developers
  case "$1" in
	"outproc") # forward output from interactive and jobs to chat
		[ "$3" = "" ] && echo "No file to read from" && exit 3
		[ "$2" = "" ] && echo "No chat to send to" && exit 3
		while read -r -t 10 line ;do
			[ "$line" != "" ] && send_message "$2" "$line"
		done 
		rm -f -r "${TMPDIR:-.}/$3"
		[ -s "${TMPDIR:-.}/$3.log" ] || rm -f "${TMPDIR:-.}/$3.log"
		exit
		;;
	"startbot" )
		start_bot "$2"
		exit
		;;
	"source") # this should never arrive here
		exit
		;;
	"init") # adjust users and permissions
		bot_init
		exit
		;;
	"attach")
		tmux attach -t "$ME"
		exit
		;;
  esac


  ###############
  # "official" arguments as shown to users
  case "$1" in
	"count")
		echo "A total of $(wc -l <"${COUNTFILE}") users used me."
		exit
		;;
	"broadcast")
		NUMCOUNT="$(wc -l <"${COUNTFILE}")"
		echo "Sending the broadcast $* to $NUMCOUNT users."
		[ "$NUMCOUNT" -gt "300" ] && sleep="sleep 0.5"
		shift
		while read -r f; do send_markdown_message "${f//COUNT}" "$*"; $sleep; done <"${COUNTFILE}"
		;;
	"start")
		tmux kill-session -t "$ME" &>/dev/null
		tmux new-session -d -s "$ME" "bash $SCRIPT startbot" && echo -e "${GREEN}Bot started successfully.${NC}"
		echo "Tmux session name $ME" || echo -e "${RED}An error occurred while starting the bot. ${NC}"
		;;
	"kill")
		tmux kill-session -t "$ME" &>/dev/null
		echo -e "${GREEN}OK. Bot stopped successfully.${NC}"
		;;
	"background" | "resumeback")
		echo -e "${GREEN}Restart background processes ...${NC}"
		for FILE in "${TMPDIR:-.}/"*-back.cmd; do
		    if [ "${FILE}" = "${TMPDIR:-.}/*-back.cmd" ]; then
			echo -e "${RED}No background processes to start.${NC}"; break
		    else
			RESTART="$(< "${FILE}")"
			CHAT[ID]="${RESTART%%:*}"
			JOB="${RESTART#*:}"
			PROG="${JOB#*:}"
			JOB="${JOB%:*}"
			fifo="$(fifoname "${CHAT[ID]}" "back-${JOB}")" 
			echo "restartbackground  ${PROG}  ${fifo}"
			start_back "${CHAT[ID]}" "${PROG}" "${JOB}"
		    fi
		done
		;;
	"killback" | "suspendback")
		echo -e "${GREEN}Stopping background processes ...${NC}"
		for FILE in "${TMPDIR:-.}/"*-back.cmd; do
		    if [ "${FILE}" = "${TMPDIR:-.}/*-back.cmd" ]; then
			echo -e "${RED}No background processes.${NC}"; break
		    else
			REMOVE="$(< "${FILE}")"
			CHAT[ID]="${RESTART%%:*}"
			JOB="${REMOVE#*:}"
			JOB="${JOB%:*}"
			fifo="$(fifoname "${CHAT[ID]}" "back-${JOB}")"
			echo "killbackground  ${fifo}"
			[ "$1" = "killback" ] && rm -f "${FILE}" # remove job
			kill_proc "${CHAT[ID]}" "back-${JOB}"
		    fi
		done
		;;
	"help")
		less "README.txt"
		exit
		;;
	*)
		echo -e "${RED}${ME}: BAD REQUEST${NC}"
		echo -e "${RED}Available arguments: start, kill, count, broadcast, help, suspendback, resumeback, killback${NC}"
		exit 4
		;;
  esac

  # warn if root
  if [[ "$(id -u)" -eq "0" ]] ; then
	echo -e "\\n${ORANGE}WARNING: ${SCRIPT} was started as ROOT (UID 0)!${NC}"
	echo -e "${ORANGE}You are at HIGH RISK when processing user input with root privilegs!${NC}"
  fi
fi # end source
