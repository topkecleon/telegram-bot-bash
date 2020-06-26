#!/bin/bash
# file: bashbot.sh 
# do not edit, this file will be overwritten on update

# bashbot, the Telegram bot written in bash.
# Written by Drew (@topkecleon) and Daniil Gentili (@danogentili), KayM (@gnadelwartz).
# Also contributed: JuanPotato, BigNerd95, TiagoDanin, iicc1.
# https://github.com/topkecleon/telegram-bot-bash

# Depends on JSON.sh (http://github.com/dominictarr/JSON.sh) (MIT/Apache),
# This file is public domain in the USA and all free countries.
# Elsewhere, consider it to be WTFPLv2. (wtfpl.net/txt/copying)
#
#### $$VERSION$$ v0.98-pre2-0-ga597303
#
# Exit Codes:
# - 0 success (hopefully)
# - 1 can't change to dir
# - 2 can't write to tmp, count or token 
# - 3 user / command / file not found
# - 4 unknown command
# - 5 cannot connect to telegram bot
# - 6 mandatory module not found
# - 6 can't get bottoken
# shellcheck disable=SC2140,SC2031,SC2120,SC1091

# are we running in a terminal?
if [ -t 1 ] && [ -n "$TERM" ];  then
    CLEAR='clear'
    RED='\e[31m'
    GREEN='\e[32m'
    ORANGE='\e[35m'
    GREY='\e[1;30m'
    NC='\e[0m'
fi

# some important helper functions
# returns true if command exist
_exists() {
	[ "$(LC_ALL=C type -t "${1}")" = "file" ]
}

# execute function if exists
_exec_if_function() {
	[ "$(LC_ALL=C type -t "${1}")" != "function" ] && return 1
	"$@"
}
# returns true if function exist
_is_function() {
	[ "$(LC_ALL=C type -t "${1}")" = "function" ]
}
# round $1 in international notation! , returns float with $2 decimal digits
# if $2 is not fiven or is not a positive number, it's set to zero
_round_float() {
	local digit="${2}"; [[ "${2}" =~ ^[0-9]+$ ]] || digit="0"
	LC_ALL=C printf "%.${digit}f" "${1}"
}
setConfigKey() {
	[[ "$1" =~ ^[-a-zA-Z0-9,._]+$ ]] || return 3
	[ -z "${BOTCONFIG}" ] && return 1
	printf '["%s"]\t"%s"\n' "${1//,/\",\"}" "${2//\"/\\\"}" >>"${BOTCONFIG}.jssh"
}
getConfigKey() {
	[[ "$1" =~ ^[-a-zA-Z0-9,._]+$ ]] || return 3
	[ -r "${BOTCONFIG}.jssh" ] && sed -n 's/\["'"$1"'"\]\t*"\(.*\)"/\1/p' <"${BOTCONFIG}.jssh" | tail -n 1
}

# get location and name of bashbot.sh
SCRIPT="$0"
REALME="${BASH_SOURCE[0]}"
SCRIPTDIR="$(dirname "${REALME}")"
RUNDIR="$(dirname "$0")"

MODULEDIR="${SCRIPTDIR}/modules"

# adjust locations based on source and real name
if [ "${SCRIPT}" != "${REALME}" ] || [ "$1" = "source" ]; then
	SOURCE="yes"
fi

BOTCOMMANDS="start, stop, status, help, init, stats, broadcast, suspendback, resumeback, killback"
[[ -z "$1" && -z "${SOURCE}" ]] &&  echo -e "${ORANGE}Available commands: ${GREY}${BOTCOMMANDS}${NC}" && exit
if [ "$1" = "help" ]; then
		HELP="README"
		if [ -n "${CLEAR}" ];then
			_exists w3m && w3m "$HELP.html" && exit
			_exists lynx && lynx "$HELP.html" && exit
			_exists less && less "$HELP.txt" && exit
		fi
		cat "$HELP.txt"
		exit
fi

if [ -n "$BASHBOT_HOME" ]; then
	SCRIPTDIR="$BASHBOT_HOME"
 else
	BASHBOT_HOME="${SCRIPTDIR}"
fi
[ -z "${BASHBOT_ETC}" ] && BASHBOT_ETC="$BASHBOT_HOME"
[ -z "${BASHBOT_VAR}" ] && BASHBOT_VAR="$BASHBOT_HOME"

ADDONDIR="${BASHBOT_ETC:-.}/addons"
RUNUSER="${USER}" # USER is overwritten by bashbot array

# OK everything setup, lest start
if [[ -z "${SOURCE}" && -z "$BASHBOT_HOME" ]] && ! cd "${RUNDIR}" ; then
	echo -e "${RED}ERROR: Can't change to ${RUNDIR} ...${NC}"
	exit 1
else
	RUNDIR="."
fi

if [ ! -w "." ]; then
	echo -e "${ORANGE}WARNING: ${RUNDIR} is not writeable!${NC}"
	ls -ld .
fi

# Setup and check environment if BOTTOKEN is NOT set
BOTCONFIG="${BASHBOT_ETC:-.}/botconfig"
TOKENFILE="${BASHBOT_ETC:-.}/token"
BOTADMIN="${BASHBOT_ETC:-.}/botadmin"
BOTACL="${BASHBOT_ETC:-.}/botacl"
DATADIR="${BASHBOT_VAR:-.}/data-bot-bash"
BLOCKEDFILE="${BASHBOT_VAR:-.}/blocked"
COUNTFILE="${BASHBOT_VAR:-.}/count"

LOGDIR="${RUNDIR:-.}/logs"
if [ ! -d "${LOGDIR}" ] || [ ! -w "${LOGDIR}" ]; then
	LOGDIR="${RUNDIR:-.}"
fi
DEBUGLOG="${LOGDIR}/DEBUG.log"
ERRORLOG="${LOGDIR}/ERROR.log"
UPDATELOG="${LOGDIR}/BASHBOT.log"

# we assume everything is already set up correctly if we have TOKEN
if [ -z "${BOTTOKEN}" ]; then
  # BOTCONFIG does not exist, create
  [ ! -f "${BOTCONFIG}.jssh" ] &&
		printf '["bot_config_key"]\t"config_key_value"\n' >>"${BOTCONFIG}.jssh"
  # BOTTOKEN empty read ask user
  if [ -z "$(getConfigKey "bottoken")" ]; then
     # convert old token
     if [ -r "${TOKENFILE}" ]; then
		token="$(< "${TOKENFILE}")"
     # no old token available ask user
     elif [ -z "${CLEAR}" ] && [ "$1" != "init" ]; then
	echo "Running headless, set BOTTOKEN or run ${SCRIPT} init first!"
	exit 2 
     else
	${CLEAR}
	echo -e "${RED}TOKEN MISSING.${NC}"
	echo -e "${ORANGE}PLEASE WRITE YOUR TOKEN HERE OR PRESS CTRL+C TO ABORT${NC}"
	read -r token
     fi
     [ -n "${token}" ] && printf '["bottoken"]\t"%s"\n'  "${token}" >> "${BOTCONFIG}.jssh"
  fi

  # setup botadmin file
  if [ -z "$(getConfigKey "botadmin")" ]; then
     # convert old admin
     if [ -r "${BOTADMIN}" ]; then
		admin="$(< "${BOTADMIN}")"
     elif [ -z "${CLEAR}" ]; then
	echo "Running headless, set botadmin to AUTO MODE!"
     else
	${CLEAR}
	echo -e "${RED}BOTADMIN MISSING.${NC}"
	echo -e "${ORANGE}PLEASE WRITE YOUR TELEGRAM ID HERE OR ENTER '?'${NC}"
	echo -e "${ORANGE}TO MAKE FIRST USER TYPING '/start' TO BOTADMIN${NC}"
	read -r admin
     fi
     [ -z "${admin}" ] && admin='?'
     printf '["botadmin"]\t"%s"\n'  "${admin}" >> "${BOTCONFIG}.jssh"
  fi
  # setup botacl file
  if [ ! -f "${BOTACL}" ]; then
	echo -e "${ORANGE}Create empty ${BOTACL} file.${NC}"
	printf '\n' >"${BOTACL}"
  fi
  # setup data dir file
  if [ ! -d "${DATADIR}" ]; then
	mkdir "${DATADIR}"
  elif [ ! -w "${DATADIR}" ]; then
	echo -e "${RED}ERROR: Can't write to ${DATADIR}!.${NC}"
	ls -ld "${DATADIR}"
	exit 2
  fi
  # setup count file 
  if [ ! -f "${COUNTFILE}.jssh" ]; then
	printf '["counted_user_chat_id"]\t"num_messages_seen"\n' >> "${COUNTFILE}.jssh"
	# convert old file on creation
	if [ -r  "${COUNTFILE}" ];then
		sed 's/COUNT/\[\"/;s/$/\"\]\t\"1\"/' < "${COUNTFILE}" >> "${COUNTFILE}.jssh"
	fi
  elif [ ! -w "${COUNTFILE}.jssh" ]; then
	echo -e "${RED}ERROR: Can't write to ${COUNTFILE}!.${NC}"
	ls -l "${COUNTFILE}.jssh"
	exit 2
  fi
  # setup blocked file 
  if [ ! -f "${BLOCKEDFILE}.jssh" ]; then
	printf '["blocked_user_or_chat_id"]\t"name and reason"\n' >>"${BLOCKEDFILE}.jssh"
  fi
fi

# read BOTTOKEN from bot database if not set
if [ -z "${BOTTOKEN}" ]; then
    BOTTOKEN="$(getConfigKey "bottoken")"
    if [ -z "${BOTTOKEN}" ]; then
   	echo -e "${ORANGE}Warning: can't get bot token, try to recover working config.${NC}"
	if [ -r "${BOTCONFIG}.jssh.ok" ]; then
		cp "${BOTCONFIG}.jssh.ok" "${BOTCONFIG}.jssh"
		BOTTOKEN="$(getConfigKey "bottoken")"
	else
   		echo -e "${RED}Error: Missing bot token! remove ${BOTCONFIG}.jssh and run \"bashbot.sh init\" may fix it.${NC}"
		exit 7
	fi
    fi
fi


# BOTTOKEN format checks
if [[ ! "${BOTTOKEN}" =~ ^[0-9]{8,10}:[a-zA-Z0-9_-]{35}$ ]]; then
	echo -e "${ORANGE}Warning: your bottoken may incorrect. it should have the following format:${NC}"
	echo -e "${GREY}123456789${RED}:${GREY}Aa-Zz_0Aa-Zz_1Aa-Zz_2Aa-Zz_3Aa-Zz_4${ORANGE} => ${NC}\c"
	echo -e "${GREY}8-10 digits${RED}:${GREY}35 alnum characters + '_-'${NC}"
	echo -e "${ORANGE}Your current token is: '${GREY}^$(cat -ve <<<"${BOTTOKEN//:/${RED}:${GREY}}")${ORANGE}'${NC}"
	[[ ! "${BOTTOKEN}" =~ ^[0-9]{8,10}: ]] &&\
		echo -e "${ORANGE}Possible problem in the digits part, len is $(($(wc -c <<<"${BOTTOKEN%:*}")-1))${NC}"
	[[ ! "${BOTTOKEN}" =~ :[a-zA-Z0-9_-]{35}$ ]] &&\
		echo -e "${ORANGE}Posilbe problem in the charatcers part, len is $(($(wc -c <<<"${BOTTOKEN#*:}")-1))${NC}"
fi


##################
# here we start with the real stuff
BASHBOT_RETRY="" # retry by default

URL="${BASHBOT_URL:-https://api.telegram.org/bot}${BOTTOKEN}"
ME_URL=$URL'/getMe'

UPD_URL=$URL'/getUpdates?offset='
GETFILE_URL=$URL'/getFile'

#################
# BASHBOT COMMON functions

declare -rx SCRIPT SCRIPTDIR MODULEDIR RUNDIR ADDONDIR TOKENFILE BOTADMIN BOTACL DATADIR COUNTFILE
declare -rx BOTTOKEN URL ME_URL UPD_URL GETFILE_URL

declare -ax CMD
declare -Ax UPD BOTSENT USER MESSAGE URLS CONTACT LOCATION CHAT FORWARD REPLYTO VENUE iQUERY SERVICE NEWMEMBER
export res CAPTION


##################
# read commamds file if we are not sourced
COMMANDS="${BASHBOT_ETC:-.}/commands.sh"
if [ -z "${SOURCE}" ]; then
	if [ ! -f "${COMMANDS}" ] || [ ! -r "${COMMANDS}" ]; then
		echo -e "${RED}ERROR: ${COMMANDS} does not exist or is not readable!.${NC}"
		ls -l "${COMMANDS}"
		exit 3
	fi
fi
# shellcheck source=./commands.sh
[  -r "${COMMANDS}" ] && source "${COMMANDS}" "source"

###############
# load modules
for modules in "${MODULEDIR:-.}"/*.sh ; do
	# shellcheck source=./modules/aliases.sh
	if ! _is_function "$(basename "${modules}")" && [ -r "${modules}" ]; then source "${modules}" "source"; fi
done

#####################
# BASHBOT INTERNAL functions
#

# do we have BSD sed
if ! sed '1ia' </dev/null 2>/dev/null; then
	echo -e "${ORANGE}Warning: You may run on a BSD style system without gnu utils ...${NC}"
fi
#jsonDB is now mandatory
if ! _is_function jssh_newDB ; then
	echo -e "${RED}ERROR: Mandatory module jsonDB is missing or not readable!"
	exit 6
fi


# $1 URL, $2 filename in DATADIR
# outputs final filename
download() {
	local empty="no.file" file="${2:-${empty}}"
	if [[ "$file" = *"/"* ]] || [[ "$file" = "."* ]]; then file="${empty}"; fi
	while [ -f "${DATADIR:-.}/${file}" ] ; do file="$RAMDOM-${file}"; done
	getJson "$1" >"${DATADIR:-.}/${file}" || return
	printf '%s\n' "${DATADIR:-.}/${file}"
}

# $1 postfix, e.g. chatid
# $2 prefix, back- or startbot-
procname(){
	printf '%s\n' "$2${ME}_$1"
}

# $1 string to search for proramm incl. parameters
# returns a list of PIDs of all current bot proceeses matching $1
proclist() {
	# shellcheck disable=SC2009
	ps -fu "${UID}" | grep -F "$1" | grep -v ' grep'| grep -F "${ME}" | sed 's/\s\+/\t/g' | cut -f 2
}

# $1 string to search for proramm to kill
killallproc() {
	local procid; procid="$(proclist "$1")"
	if [ -n "${procid}" ] ; then
		# shellcheck disable=SC2046
		kill $(proclist "$1")
		sleep 1
		procid="$(proclist "$1")"
		# shellcheck disable=SC2046
		[ -n "${procid}" ] && kill $(proclist -9 "$1")
	fi
}


# $ chat $2 mesgid $3 nolog
declare -xr DELETE_URL=$URL'/deleteMessage'
delete_message() {
	[ -z "$3" ] && printf "%s: Delete Message CHAT=%s MSG_ID=%s\n" "$(date)" "${1}" "${2}" >>"${UPDATELOG}"
	sendJson "${1}" '"message_id": '"${2}"'' "${DELETE_URL}"
}

get_file() {
	[ -z "$1" ] && return
	sendJson ""  '"file_id": "'"${1}"'"' "${GETFILE_URL}"
	printf '%s\n' "${URL}"/"$(JsonGetString <<< "${res}" '"result","file_path"')"
}

# curl is preferred, but may not available on embedded systems
TIMEOUT="${BASHBOT_TIMEOUT}"
[[ "$TIMEOUT" =~ ^[0-9]+$ ]] || TIMEOUT="20"

if [ -z "${BASHBOT_WGET}" ] && _exists curl ; then
  [ -z "${BASHBOT_CURL}" ] && BASHBOT_CURL="curl"
  # simple curl or wget call, output to stdout
  getJson(){
	[[ -n "${BASHBOTDEBUG}" && -n "${3}" ]] && printf "%s: getJson (curl) URL=%s\n" "$(date)" "${1##*/}" 1>&2
	# shellcheck disable=SC2086
	"${BASHBOT_CURL}" -sL -k ${BASHBOT_CURL_ARGS} -m "${TIMEOUT}" "$1"
  }
  # usage: sendJson "chat" "JSON" "URL"
  sendJson(){
	local chat="";
	[ -n "${1}" ] && chat='"chat_id":'"${1}"','
	[ -n "${BASHBOTDEBUG}" ] && printf "%s: sendJson (curl) CHAT=%s JSON=%s URL=%s\n" "$(date)" "${1}" "${2:0:100}" "${3##*/}" 1>&2
	# shellcheck disable=SC2086
	res="$("${BASHBOT_CURL}" -s -k ${BASHBOT_CURL_ARGS} -m "${TIMEOUT}"\
		-d '{'"${chat} $(iconv -f utf-8 -t utf-8 -c <<<$2)"'}' -X POST "${3}" \
		-H "Content-Type: application/json" | "${JSONSHFILE}" -s -b -n 2>/dev/null )"
	sendJsonResult "${res}" "sendJson (curl)" "$@"
	[ -n "${BASHBOT_EVENT_SEND[*]}" ] && event_send "send" "${@}" &
  }
  #$1 Chat, $2 what , $3 file, $4 URL, $5 caption
  sendUpload() {
	[ "$#" -lt 4  ] && return
	if [ -n "$5" ]; then
	[ -n "${BASHBOTDEBUG}" ] && printf "%s: sendUpload CHAT=%s WHAT=%s  FILE=%s CAPT=%s\n" "$(date)" "${1}" "${2}" "${3}" "${4}" 1>&2
	# shellcheck disable=SC2086
		res="$("${BASHBOT_CURL}" -s -k ${BASHBOT_CURL_ARGS} "$4" -F "chat_id=$1"\
			-F "$2=@$3;${3##*/}" -F "caption=$5" | "${JSONSHFILE}" -s -b -n 2>/dev/null )"
	else
	# shellcheck disable=SC2086
		res="$("${BASHBOT_CURL}" -s -k ${BASHBOT_CURL_ARGS} "$4" -F "chat_id=$1"\
			-F "$2=@$3;${3##*/}" | "${JSONSHFILE}" -s -b -n 2>/dev/null )"
	fi
	sendJsonResult "${res}" "sendUpload (curl)" "$@"
	[ -n "${BASHBOT_EVENT_SEND[*]}" ] && event_send "upload" "$@" &
  }
else
  # simple curl or wget call outputs result to stdout
  getJson(){
	[[ -n "${BASHBOTDEBUG}" && -z "${3}" ]] && printf "%s: getJson (wget) URL=%s\n" "$(date)" "${1##*/}" 1>&2
	# shellcheck disable=SC2086
	wget --no-check-certificate -t 2 -T "${TIMEOUT}" ${BASHBOT_WGET_ARGS} -qO - "$1"
  }
  # usage: sendJson "chat" "JSON" "URL"
  sendJson(){
	local chat="";
	[ -n "${1}" ] && chat='"chat_id":'"${1}"','
	[ -n "${BASHBOTDEBUG}" ] && printf "%s: sendJson (wget) CHAT=%s JSON=%s URL=%s\n" "$(date)" "${1}" "${2:0:100}" "${3##*/}" 1>&2
	# shellcheck disable=SC2086
	res="$(wget --no-check-certificate -t 2 -T "${TIMEOUT}" ${BASHBOT_WGET_ARGS} -qO - --post-data='{'"${chat} $(iconv -f utf-8 -t utf-8 -c <<<$2)"'}' \
		--header='Content-Type:application/json' "${3}" | "${JSONSHFILE}" -s -b -n 2>/dev/null )"
	sendJsonResult "${res}" "sendJson (wget)" "$@"
	[ -n "${BASHBOT_EVENT_SEND[*]}" ] && event_send "send" "${@}" & 
  }
  sendUpload() {
	printf "%s: %s\n" "$(date)" "Sorry, wget does not support file upload\n" >>"${ERRORLOG}"
	BOTSENT[OK]="false"
	[ -n "${BASHBOT_EVENT_SEND[*]}" ] && event_send "upload" "$@" &
  }
fi 

# retry sendJson
# $1 function $2 sleep $3 ... $n arguments
sendJsonRetry(){
	local retry="${1}"; shift
	[[ "${1}" =~ ^\ *[0-9.]+\ *$ ]] && sleep "${1}"; shift
	printf "%s: RETRY %s %s %s\n" "$(date)" "${retry}" "${1}" "${2:0:60}"
	case "${retry}" in
		'sendJson'*)
			sendJson "$@"	
			;;
		'sendUpload'*)
			sendUpload "$@"	
			;;
		'send_album'*)
			send_album "$@"	
			;;
		*)
			printf "%s: Error: unknown function %s, cannot retry\n" "$(date)" "${retry}"
			return
			;;
	esac
	[ "${BOTSENT[OK]}" = "true" ] && printf "%s: Retry OK: %s %s %s\n" "$(date)" "${retry}" "${1}" "${2:0:60}"
} >>"${ERRORLOG}"

# process sendJson result
# stdout is written to ERROR.log
# $1 result $2 function $3 .. $n original arguments, $3 is Chat_id
sendJsonResult(){
	local offset=0
	BOTSENT=( )
	[ -n "${BASHBOTDEBUG}" ] && printf "\n%s: New Result ==========\n%s\n" "$(date)" "$1" >>"${LOGDIR}/MESSAGE.log"
	BOTSENT[OK]="$(JsonGetLine '"ok"' <<< "${1}")"
	if [ "${BOTSENT[OK]}" = "true" ]; then
		BOTSENT[ID]="$(JsonGetValue '"result","message_id"' <<< "${1}")"
		return
		# hot path everything OK!
	else
	    # oops something went wrong!
	    if [ "${res}" != "" ]; then
		BOTSENT[ERROR]="$(JsonGetValue '"error_code"' <<< "${1}")"
		BOTSENT[DESCRIPTION]="$(JsonGetString '"description"' <<< "${1}")"
		BOTSENT[RETRY]="$(JsonGetValue '"parameters","retry_after"' <<< "${1}")"
	    else
		BOTSENT[OK]="false"
		BOTSENT[ERROR]="999"
		BOTSENT[DESCRIPTION]="Send to telegram not possible, timeout/broken/no connection"
	    fi
	    # log error
	    [[ "${BOTSENT[ERROR]}" = "400" && "${BOTSENT[DESCRIPTION]}" == *"starting at byte offset"* ]] &&\
			 offset="${BOTSENT[DESCRIPTION]%* }"
	    printf "%s: RESULT=%s FUNC=%s CHAT[ID]=%s ERROR=%s DESC=%s ACTION=%s\n" "$(date)"\
			"${BOTSENT[OK]}"  "${2}" "${3}" "${BOTSENT[ERROR]}" "${BOTSENT[DESCRIPTION]}" "${4:${offset}:100}"
	    # warm path, do not retry on error, also if we use wegt
	    [ -n "${BASHBOT_RETRY}${BASHBOT_WGET}" ] && return

	    # OK, we can retry sendJson, let's see what's failed
	    # throttled, telegram say we send to much messages
	    if [ -n "${BOTSENT[RETRY]}" ]; then
		BASHBOT_RETRY="$(( BOTSENT[RETRY]++ ))"
		printf "Retry %s in %s seconds ...\n" "${2}" "${BASHBOT_RETRY}"
		sendJsonRetry "${2}" "${BASHBOT_RETRY}" "${@:3}"
		unset BASHBOT_RETRY
		return
	    fi
	    # timeout, failed connection or blocked
	    if [ "${BOTSENT[ERROR]}" == "999" ];then
		# check if default curl and args are OK
		if ! curl -sL -k -m 2 "${URL}" >/dev/null 2>&1 ; then
		    printf "%s: BASHBOT IP Address is blocked!\n" "$(date)"
		    # user provided function to recover or notify block
		    if _exec_if_function bashbotBlockRecover; then
			BASHBOT_RETRY="2"
			printf "bashbotBlockRecover returned true, retry %s ...\n" "${2}"
			sendJsonRetry "${2}" "${BASHBOT_RETRY}" "${@:3}"
			unset BASHBOT_RETRY
		    fi
		    return
		fi
	        # are not blocked, default curl and args are working
		if [ -n "${BASHBOT_CURL_ARGS}" ] || [ "${BASHBOT_CURL}" != "curl" ]; then
		    printf "Problem with \"%s %s\"? retry %s with default config ...\n"\
				"${BASHBOT_CURL}" "${BASHBOT_CURL_ARGS}" "${2}"
		    BASHBOT_RETRY="2"; BASHBOT_CURL="curl"; BASHBOT_CURL_ARGS=""
		    sendJsonRetry "${2}" "${BASHBOT_RETRY}" "${@:3}"
		    unset BASHBOT_RETRY
		fi
	    fi
	fi
} >>"${ERRORLOG}"

# escape / remove text characters for json strings, eg. " -> \" 
# $1 string
# output escaped string
JsonEscape(){
	sed 's/\([-"`´,§$%&/(){}#@!?*.\t]\)/\\\1/g' <<< "$1"
}

# convert common telegram entities to JSON
# title caption description markup inlinekeyboard
title2Json(){
	local title caption desc markup keyboard
	[ -n "$1" ] && title=',"title":"'$(JsonEscape "$1")'"'
	[ -n "$2" ] && caption=',"caption":"'$(JsonEscape "$2")'"'
	[ -n "$3" ] && desc=',"description":"'$(JsonEscape "$3")'"'
	[ -n "$4" ] && markup=',"parse_mode":"'"$4"'"'
	[ -n "$5" ] && keyboard=',"reply_markup":"'$(JsonEscape "$5")'"'
	printf '%s\n' "${title}${caption}${desc}${markup}${keyboard}"
}

# get bot name
getBotName() {
	getJson "$ME_URL"  | "${JSONSHFILE}" -s -b -n 2>/dev/null | JsonGetString '"result","username"'
}

# pure bash implementation, done by KayM (@gnadelwartz)
# see https://stackoverflow.com/a/55666449/9381171
JsonDecode() {
        local out="$1" remain="" U=""
	local regexp='(.*)\\u[dD]([0-9a-fA-F]{3})\\u[dD]([0-9a-fA-F]{3})(.*)'
        while [[ "${out}" =~ $regexp ]] ; do
		U=$(( ( (0xd${BASH_REMATCH[2]} & 0x3ff) <<10 ) | ( 0xd${BASH_REMATCH[3]} & 0x3ff ) + 0x10000 ))
                remain="$(printf '\\U%8.8x' "${U}")${BASH_REMATCH[4]}${remain}"
                out="${BASH_REMATCH[1]}"
        done
	# this echo must stay for correct decoding!
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
	Json2Array 'UPD' <<<"${UPDATE}"
	for ((num=0; num<=max; num++)); do
		process_client "$num" "${debug}"
	done
}
process_client() {
	local num="$1" debug="$2" 
	CMD=( ); iQUERY=( ); MESSAGE=()
	iQUERY[ID]="${UPD["result",${num},"inline_query","id"]}"
	CHAT[ID]="${UPD["result",${num},"message","chat","id"]}"
	USER[ID]="${UPD["result",${num},"message","from","id"]}"
	[ -z "${CHAT[ID]}" ] && CHAT[ID]="${UPD["result",${num},"edited_message","chat","id"]}"
	[ -z "${USER[ID]}" ] && USER[ID]="${UPD["result",${num},"edited_message","from","id"]}"
	# log message on debug
	[[ -n "${debug}" ]] && printf "\n%s: New Message ==========\n%s\n" "$(date)" "$UPDATE" >>"${LOGDIR}/MESSAGE.log"

	# check for uers / groups to ignore
	jssh_updateArray_async "BASHBOTBLOCKED" "${BLOCKEDFILE}"
	[ -n "${USER[ID]}" ] && [[ -n "${BASHBOTBLOCKED[${USER[ID]}]}" || -n "${BASHBOTBLOCKED[${CHAT[ID]}]}" ]] && return

	# process per message type
	if [ -z "${iQUERY[ID]}" ]; then
		if grep -qs -e '\["result",'"${num}"',"edited_message"' <<<"${UPDATE}"; then
			# edited message
			UPDATE="${UPDATE//,${num},\"edited_message\",/,${num},\"message\",}"
			Json2Array 'UPD' <<<"${UPDATE}"
			MESSAGE[0]="/edited_message "
		fi
		process_message "${num}" "${debug}"
	        printf "%s: update received FROM=%s CHAT=%s CMD=%s\n" "$(date)" "${USER[USERNAME]:0:20} (${USER[ID]})"\
			"${CHAT[USERNAME]:0:20}${CHAT[TITLE]:0:30} (${CHAT[ID]})"\
			"${MESSAGE:0:30}${CAPTION:0:30}${URLS[*]:0:30}" >>"${UPDATELOG}"
	else
		process_inline "${num}" "${debug}"
	        printf "%s: iQuery received FROM=%s iQUERY=%s\n" "$(date)"\
			"${iQUERY[USERNAME]:0:20} (${iQUERY[USER_ID]})" "${iQUERY[0]}" >>"${UPDATELOG}"
	fi
	#####
	# process inline and message events
	# first classic command dispatcher
	# shellcheck source=./commands.sh
	source "${COMMANDS}" "${debug}" &

	# then all registered addons
	if [ -z "${iQUERY[ID]}" ]; then
		event_message "${debug}"
	else
		event_inline "${debug}"
	fi

	# last count users
	jssh_countKeyDB_async "${CHAT[ID]}" "${COUNTFILE}"
}

declare -Ax BASBOT_EVENT_INLINE BASBOT_EVENT_MESSAGE BASHBOT_EVENT_CMD BASBOT_EVENT_REPLY BASBOT_EVENT_FORWARD BASHBOT_EVENT_SEND
declare -Ax BASBOT_EVENT_CONTACT BASBOT_EVENT_LOCATION BASBOT_EVENT_FILE BASHBOT_EVENT_TEXT BASHBOT_EVENT_TIMER BASHBOT_BLOCKED

start_timer(){
	# send alarm every ~60 s
	while :; do
		sleep 59.5
    		kill -ALRM $$
	done;
}

EVENT_SEND="0"
event_send() {
	# max recursion level 5 to avoid fork bombs
	(( EVENT_SEND++ )); [ "$EVENT_SEND" -gt "5" ] && return
	# shellcheck disable=SC2153
	for key in "${!BASHBOT_EVENT_SEND[@]}"
	do
		_exec_if_function "${BASHBOT_EVENT_SEND[${key}]}" "$@"
	done
}

EVENT_TIMER="0"
event_timer() {
	local key timer debug="$1"
	(( EVENT_TIMER++ ))
	# shellcheck disable=SC2153
	for key in "${!BASHBOT_EVENT_TIMER[@]}"
	do
		timer="${key##*,}"
		[[ ! "$timer" =~ ^-*[1-9][0-9]*$ ]] && continue
		if [ "$(( EVENT_TIMER % timer ))" = "0" ]; then
			_exec_if_function "${BASHBOT_EVENT_TIMER[${key}]}" "timer" "${key}" "${debug}"
			[ "$(( EVENT_TIMER % timer ))" -lt "0" ] && \
				unset BASHBOT_EVENT_TIMER["${key}"]
		fi
	done
}

event_inline() {
	local key debug="$1"
	# shellcheck disable=SC2153
	for key in "${!BASHBOT_EVENT_INLINE[@]}"
	do
		_exec_if_function "${BASHBOT_EVENT_INLINE[${key}]}" "inline" "${key}" "${debug}"
	done
}
event_message() {
	local key debug="$1"
	# ${MESSAEG[*]} event_message
	# shellcheck disable=SC2153
	for key in "${!BASHBOT_EVENT_MESSAGE[@]}"
	do
		 _exec_if_function "${BASHBOT_EVENT_MESSAGE[${key}]}" "message" "${key}" "${debug}"
	done
	
	# ${TEXT[*]} event_text
	if [ -n "${MESSAGE[0]}" ]; then
		# shellcheck disable=SC2153
		for key in "${!BASHBOT_EVENT_TEXT[@]}"
		do
			_exec_if_function "${BASHBOT_EVENT_TEXT[${key}]}" "text" "${key}" "${debug}"
		done

		# ${CMD[*]} event_cmd
		if [ -n "${CMD[0]}" ]; then
			# shellcheck disable=SC2153
			for key in "${!BASHBOT_EVENT_CMD[@]}"
			do
				_exec_if_function "${BASHBOT_EVENT_CMD[${key}]}" "command" "${key}" "${debug}"
			done
		fi
	fi
	# ${REPLYTO[*]} event_replyto
	if [ -n "${REPLYTO[UID]}" ]; then
		# shellcheck disable=SC2153
		for key in "${!BASHBOT_EVENT_REPLYTO[@]}"
		do
			_exec_if_function "${BASHBOT_EVENT_REPLYTO[${key}]}" "replyto" "${key}" "${debug}"
		done
	fi

	# ${FORWARD[*]} event_forward
	if [ -n "${FORWARD[UID]}" ]; then
		# shellcheck disable=SC2153
		for key in "${!BASHBOT_EVENT_FORWARD[@]}"
		do
			 _exec_if_function && "${BASHBOT_EVENT_FORWARD[${key}]}" "forward" "${key}" "${debug}"
		done
	fi

	# ${CONTACT[*]} event_contact
	if [ -n "${CONTACT[FIRST_NAME]}" ]; then
		# shellcheck disable=SC2153
		for key in "${!BASHBOT_EVENT_CONTACT[@]}"
		do
			_exec_if_function "${BASHBOT_EVENT_CONTACT[${key}]}" "contact" "${key}" "${debug}"
		done
	fi

	# ${VENUE[*]} event_location
	# ${LOCATION[*]} event_location
	if [ -n "${LOCATION[LONGITUDE]}" ] || [ -n "${VENUE[TITLE]}" ]; then
		# shellcheck disable=SC2153
		for key in "${!BASHBOT_EVENT_LOCATION[@]}"
		do
			_exec_if_function "${BASHBOT_EVENT_LOCATION[${key}]}" "location" "${key}" "${debug}"
		done
	fi

	# ${URLS[*]} event_file
	# NOTE: compare again #URLS -1 blanks!
	if [[ "${URLS[*]}" != "     " ]]; then
		# shellcheck disable=SC2153
		for key in "${!BASHBOT_EVENT_FILE[@]}"
		do
			_exec_if_function "${BASHBOT_EVENT_FILE[${key}]}" "file" "${key}" "${debug}"
		done
	fi

}
process_inline() {
	local num="${1}"
	iQUERY[0]="$(JsonDecode "${UPD["result",${num},"inline_query","query"]}")"
	iQUERY[USER_ID]="${UPD["result",${num},"inline_query","from","id"]}"
	iQUERY[FIRST_NAME]="$(JsonDecode "${UPD["result",${num},"inline_query","from","first_name"]}")"
	iQUERY[LAST_NAME]="$(JsonDecode "${UPD["result",${num},"inline_query","from","last_name"]}")"
	iQUERY[USERNAME]="$(JsonDecode "${UPD["result",${num},"inline_query","from","username"]}")"
}
process_message() {
	local num="$1"
	# Message
	MESSAGE[0]+="$(JsonDecode "${UPD["result",${num},"message","text"]}" | sed 's#\\/#/#g')"
	MESSAGE[ID]="${UPD["result",${num},"message","message_id"]}"

	# Chat ID is now parsed when update isreceived
	#CHAT[ID]="${UPD["result",${num},"message","chat","id"]}"
	CHAT[LAST_NAME]="$(JsonDecode "${UPD["result",${num},"message","chat","last_name"]}")"
	CHAT[FIRST_NAME]="$(JsonDecode "${UPD["result",${num},"message","chat","first_name"]}")"
	CHAT[USERNAME]="$(JsonDecode "${UPD["result",${num},"message","chat","username"]}")"
	# set real name as username if empty
	[ -z "${CHAT[USERNAME]}" ] && CHAT[USERNAME]="${CHAT[FIRST_NAME]} ${CHAT[LAST_NAME]}"
	CHAT[TITLE]="$(JsonDecode "${UPD["result",${num},"message","chat","title"]}")"
	CHAT[TYPE]="$(JsonDecode "${UPD["result",${num},"message","chat","type"]}")"
	CHAT[ALL_ADMIN]="${UPD["result",${num},"message","chat","all_members_are_administrators"]}"

	# user ID is now parsed when update isreceived
	#USER[ID]="${UPD["result",${num},"message","from","id"]}"
	USER[FIRST_NAME]="$(JsonDecode "${UPD["result",${num},"message","from","first_name"]}")"
	USER[LAST_NAME]="$(JsonDecode "${UPD["result",${num},"message","from","last_name"]}")"
	USER[USERNAME]="$(JsonDecode "${UPD["result",${num},"message","from","username"]}")"
	# set real name as username if empty
	[ -z "${USER[USERNAME]}" ] && USER[USERNAME]="${USER[FIRST_NAME]} ${USER[LAST_NAME]}"

	# in reply to message from
	REPLYTO=( )
	if grep -qs -e '\["result",'"${num}"',"message","reply_to_message"' <<<"${UPDATE}"; then
	   REPLYTO[UID]="${UPD["result",${num},"message","reply_to_message","from","id"]}"
	   REPLYTO[0]="$(JsonDecode "${UPD["result",${num},"message","reply_to_message","text"]}")"
	   REPLYTO[ID]="${UPD["result",${num},"message","reply_to_message","message_id"]}"
	   REPLYTO[FIRST_NAME]="$(JsonDecode "${UPD["result",${num},"message","reply_to_message","from","first_name"]}")"
	   REPLYTO[LAST_NAME]="$(JsonDecode "${UPD["result",${num},"message","reply_to_message","from","last_name"]}")"
	   REPLYTO[USERNAME]="$(JsonDecode "${UPD["result",${num},"message","reply_to_message","from","username"]}")"
	fi

	# forwarded message from
	FORWARD=( )
	if grep -qs -e '\["result",'"${num}"',"message","forward_from"' <<<"${UPDATE}"; then
	   FORWARD[UID]="${UPD["result",${num},"message","forward_from","id"]}"
	   FORWARD[ID]="${MESSAGE[ID]}" # same as message ID
	   FORWARD[FIRST_NAME]="$(JsonDecode "${UPD["result",${num},"message","forward_from","first_name"]}")"
	   FORWARD[LAST_NAME]="$(JsonDecode "${UPD["result",${num},"message","forward_from","last_name"]}")"
	   FORWARD[USERNAME]="$(JsonDecode "${UPD["result",${num},"message","forward_from","username"]}")"
	fi

	# get file URL from telegram
	URLS=()
	if grep -qs -e '\["result",'"${num}"',"message",".*,"file_id"\]' <<<"${UPDATE}"; then
	    URLS[AUDIO]="$(get_file "${UPD["result",${num},"message","audio","file_id"]}")"
	    URLS[DOCUMENT]="$(get_file "${UPD["result",${num},"message","document","file_id"]}")"
	    URLS[PHOTO]="$(get_file "${UPD["result",${num},"message","photo",0,"file_id"]}")"
	    URLS[STICKER]="$(get_file "${UPD["result",${num},"message","sticker","file_id"]}")"
	    URLS[VIDEO]="$(get_file "${UPD["result",${num},"message","video","file_id"]}")"
	    URLS[VOICE]="$(get_file "${UPD["result",${num},"message","voice","file_id"]}")"
	fi
	# Contact
	CONTACT=( )
	if grep -qs -e '\["result",'"${num}"',"message","contact"' <<<"${UPDATE}"; then
		CONTACT[FIRST_NAME]="$(JsonDecode "${UPD["result",${num},"message","contact","first_name"]}")"
		CONTACT[USER_ID]="$(JsonDecode  "${UPD["result",${num},"message","contact","user_id"]}")"
		CONTACT[LAST_NAME]="$(JsonDecode "${UPD["result",${num},"message","contact","last_name"]}")"
		CONTACT[NUMBER]="${UPD["result",${num},"message","contact","phone_number"]}"
		CONTACT[VCARD]="$(JsonGetString '"result",'"${num}"',"message","contact","vcard"' <<<"${UPDATE}")"
	fi

	# vunue
	VENUE=( )
	if grep -qs -e '\["result",'"${num}"',"message","venue"' <<<"${UPDATE}"; then
		VENUE[TITLE]="$(JsonDecode "${UPD["result",${num},"message","venue","title"]}")"
		VENUE[ADDRESS]="$(JsonDecode "${UPD["result",${num},"message","venue","address"]}")"
		VENUE[LONGITUDE]="${UPD["result",${num},"message","venue","location","longitude"]}"
		VENUE[LATITUDE]="${UPD["result",${num},"message","venue","location","latitude"]}"
		VENUE[FOURSQUARE]="${UPD["result",${num},"message","venue","foursquare_id"]}"
	fi

	# Caption
	CAPTION="$(JsonDecode "${UPD["result",${num},"message","caption"]}")"

	# Location
	LOCATION[LONGITUDE]="${UPD["result",${num},"message","location","longitude"]}"
	LOCATION[LATITUDE]="${UPD["result",${num},"message","location","latitude"]}"

	# service messages
	SERVICE=( ); NEWMEMBER=( ); LEFTMEMBER=( )
	if grep -qs -e '\["result",'"${num}"',"message","new_chat_member' <<<"${UPDATE}"; then
		SERVICE[NEWMEMBER]="${UPD["result",${num},"message","new_chat_member","id"]}"
		NEWMEMBER[ID]="${SERVICE[NEWMEMBER]}"
		NEWMEMBER[FIRST_NAME]="$(JsonDecode "${UPD["result",${num},"message","new_chat_member","first_name"]}")"
		NEWMEMBER[LAST_NAME]="$(JsonDecode "${UPD["result",${num},"message","new_chat_member","last_name"]}")"
		NEWMEMBER[USERNAME]="$(JsonDecode "${UPD["result",${num},"message","new_chat_member","username"]}")"
		NEWMEMBER[ISBOT]="${UPD["result",${num},"message","new_chat_member","is_bot"]}"
		MESSAGE[0]="/new_chat_member ${NEWMEMBER[USERNAME]:=${NEWMEMBER[FIRST_NAME]} ${NEWMEMBER[LAST_NAME]}}"
	fi
	if grep -qs -e '\["result",'"${num}"',"message","left_chat_member' <<<"${UPDATE}"; then
		SERVICE[LEFTMEMBER]="${UPD["result",${num},"message","left_chat_member","id"]}"
		LEFTMEMBER[ID]="${SERVICE[LEFTMEBER]}"
		LEFTMEMBER[FIRST_NAME]="$(JsonDecode "${UPD["result",${num},"message","left_chat_member","first_name"]}")"
		LEFTMEMBER[LAST_NAME]="$(JsonDecode "${UPD["result",${num},"message","left_chat_member","last_name"]}")"
		LEFTMEBER[USERNAME]="$(JsonDecode "${UPD["result",${num},"message","left_chat_member","username"]}")"
		LEFTMEMBER[ISBOT]="${UPD["result",${num},"message","left_chat_member","is_bot"]}"
		MESSAGE[0]="/left_chat_member ${LEFTMEMBER[USERNAME]:=${LEFTMEMBER[FIRST_NAME]} ${LEFTMEMBER[LAST_NAME]}}"
	fi
	if grep -qs -e '\["result",'"${num}"',"message","\(new_chat_[tp]\)\|\(pinned_message\)' <<<"${UPDATE}"; then
		SERVICE[NEWTITLE]="$(JsonDecode "${UPD["result",${num},"message","new_chat_title"]}")"
		[ -n "${SERVICE[NEWTITLE]}" ] && MESSAGE[0]="/new_chat_title ${SERVICE[NEWTITLE]}"
		SERVICE[NEWPHOTO]="$(get_file "${UPD["result",${num},"message","new_chat_photo",0,"file_id"]}")"
		[ -n "${SERVICE[NEWPHOTO]}" ] && MESSAGE[0]="/new_chat_photo ${SERVICE[NEWPHOTO]}"
		SERVICE[PINNED]="$(JsonDecode "${UPD["result",${num},"message","pinned_message"]}")"
		[ -n "${SERVICE[PINNED]}" ] && MESSAGE[0]="/new_pinned_message ${SERVICE[PINNED]}"
	fi
	# set SSERVICE to yes if a service message was received
	[[ "${SERVICE[*]}" =~  ^[[:blank:]]*$ ]] || SERVICE[0]="yes"

	# split message in command and args
	[ "${MESSAGE[0]:0:1}" = "/" ] && read -r CMD <<<"${MESSAGE[0]}" &&  CMD[0]="${CMD[0]%%@*}"
}

#########################
# main get updates loop, should never terminate
declare -A BASHBOTBLOCKED
export BASHBOTDEBUG
start_bot() {
	local ADMIN OFFSET=0
	# adaptive sleep defaults
	local nextsleep="100"
	local stepsleep="${BASHBOT_SLEEP_STEP:-100}"
	local maxsleep="${BASHBOT_SLEEP:-5000}"
	# startup message
	BASHBOTDEBUG="$(date): Start BASHBOT updates in Mode \"${1:-normal}\" =========="
	printf  "%s\n" "${BASHBOTDEBUG}" >>"${UPDATELOG}"
	# redirect to Debug.log
	[[ "${1}" == *"debug" ]] && exec &>>"${DEBUGLOG}"
	printf  "%s\n" "${BASHBOTDEBUG}"; BASHBOTDEBUG="${1}"
	[[ "${BASHBOTDEBUG}" == "xdebug"* ]] && set -x
	#cleaup old pipes and empty logfiles
	find "${DATADIR}" -type p -delete
	find "${DATADIR}" -size 0 -name "*.log" -delete
	# load addons on startup
	for addons in "${ADDONDIR:-.}"/*.sh ; do
		# shellcheck source=./modules/aliases.sh
		[ -r "${addons}" ] && source "${addons}" "startbot" "${BASHBOTDEBUG}"
	done
	# shellcheck source=./commands.sh
	source "${COMMANDS}" "startbot"
	# start timer events
	if [ -n "${BASHBOT_START_TIMER}" ] ; then
		# shellcheck disable=SC2064
		trap "event_timer $BASHBOTDEBUG" ALRM
		start_timer &
		# shellcheck disable=SC2064
		trap "kill -9 $!; exit" EXIT INT HUP TERM QUIT 
	fi
	# cleanup countfile on startup
	jssh_deleteKeyDB "CLEAN_COUNTER_DATABASE_ON_STARTUP" "${COUNTFILE}"
        [ -f "${COUNTFILE}.jssh.flock" ] && rm -f "${COUNTFILE}.jssh.flock"
	jssh_deleteKeyDB "CLEAN_BOT_BOTCONFIG_ON_STARTUP" "${BOTCONFIG}"
        [ -f "${BOTCONFIG}.jssh.flock" ] && rm -f "${BOTCONFIG}.jssh.flock"
	jssh_readDB_async "BASHBOTBLOCKED" "${BLOCKEDFILE}"
	# inform botadmin about start
	ADMIN="$(getConfigKey "botadmin")"
	[ -n "${ADMIN}" ] && send_normal_message "${ADMIN}" "Bot $(getConfigKey "botname") started ..." &
	##########
	# bot is ready, start processing updates ...
	while true; do
		# adaptive sleep in ms rounded to next 0.1 s
		sleep "$(_round_float "${nextsleep}e-3" "1")"
		# get next update
		UPDATE="$(getJson "$UPD_URL$OFFSET" "nolog" 2>/dev/null | "${JSONSHFILE}" -s -b -n 2>/dev/null | iconv -f utf-8 -t utf-8 -c)"
		# did we ge an responsn0r
		if [ -n "${UPDATE}" ]; then
			# we got something, do processing
			[ "${OFFSET}" = "-999" ] && [ "${nextsleep}" -gt "$((maxsleep*2))" ] &&\
				printf "%s: Recovered from timeout/broken/no connection, continue with telegram updates\n"\
					"$(date)"  >>"${ERRORLOG}"
			# escape bash $ expansion bug
			((nextsleep+= stepsleep , nextsleep= nextsleep>maxsleep ?maxsleep:nextsleep))
			UPDATE="${UPDATE//$/\\$}"
			# Offset
			OFFSET="$(grep <<< "${UPDATE}" '\["result",[0-9]*,"update_id"\]' | tail -1 | cut -f 2)"
			((OFFSET++))

			if [ "$OFFSET" != "1" ]; then
				nextsleep="100"
				process_updates "${BASHBOTDEBUG}"
			fi
		else
			# ups, something bad happened, wait maxsleep*10
			(( nextsleep=nextsleep*2 , nextsleep= nextsleep>maxsleep*10 ?maxsleep*10:nextsleep ))
			[ "${OFFSET}" = "-999" ] &&\
				printf "%s: Repeated timeout/broken/no connection on telegram update, sleep %ds\n"\
					"$(date)"  "$(_round_float "${nextsleep}e-3")" >>"${ERRORLOG}"
			OFFSET="-999"
		fi
	done
}

# initialize bot environment, user and permissions
bot_init() {
	[ -n "${BASHBOT_HOME}" ] && cd "${BASHBOT_HOME}" || exit 1
	local DEBUG="$1"
	# upgrade from old version
	echo "Check for Update actions ..."
	local OLDTMP="${BASHBOT_VAR:-.}/tmp-bot-bash"
	[ -d "${OLDTMP}" ] && { mv -n "${OLDTMP}/"* "${DATADIR}"; rmdir "${OLDTMP}"; }
	# no more existing modules
	[ -f "modules/inline.sh" ] && rm -f "modules/inline.sh"
	# load addons on startup
	echo "Initialize modules and addons ..."
	for addons in "${ADDONDIR:-.}"/*.sh ; do
		# shellcheck source=./modules/aliases.sh
		[ -r "${addons}" ] && source "${addons}" "init" "${DEBUG}"
	done
	#setup bashbot
	[[ "${UID}" -eq "0" ]] && RUNUSER="nobody"
	echo -n "Enter User to run basbot [$RUNUSER]: "
	read -r TOUSER
	[ -z "$TOUSER" ] && TOUSER="$RUNUSER"
	if ! id "$TOUSER" &>/dev/null; then
		echo -e "${RED}User \"$TOUSER\" not found!${NC}"
		exit 3
	else
		# shellcheck disable=SC2009
		oldbot="$(ps -fu "$TOUSER" | grep startbot | grep -v -e 'grep' -e '\-startbot' )"
		[ -n "${oldbot}" ] && \
			echo -e "${ORANGE}Warning: At least one not upgraded TMUX bot is running! You must stop it with kill command:${NC}\\n${oldbot}"
		echo "Adjusting files and permissions for user \"${TOUSER}\" ..."
		[ -w "bashbot.rc" ] && sed -i '/^[# ]*runas=/ s/runas=.*$/runas="'$TOUSER'"/' "bashbot.rc"
		chown -R "$TOUSER" . ./*
		chmod 711 .
		chmod -R o-w ./*
		chmod -R u+w "${COUNTFILE}"* "${BLOCKEDFILE}"* "${DATADIR}" "${BOTADMIN}" "${LOGDIR}/"*.log 2>/dev/null
	chmod -R o-r,o-w "${COUNTFILE}"* "${BLOCKEDFILE}"* "${DATADIR}" "${TOKENFILE}" "${BOTADMIN}" "${BOTACL}" 2>/dev/null
		# jsshDB must writeable by owner
		find . -name '*.jssh*' -exec chmod u+w \{\} +
	fi
	# check if botconf if seems valid
	echo -e "${GREEN}This is your bot config:${NC}"
	sed 's/^/\t/' "${BOTCONFIG}.jssh" | grep -vF '["bot_config_key"]'
	if [[ "$(getConfigKey "bottoken")" =~ ^[0-9]{8,10}:[a-zA-Z0-9_-]{35}$ && "$(getConfigKey "botadmin")" =~ ^[0-9]+$ ]]; then
		echo -e "Bot config seems to be valid. Should I make a backup copy? (Y/n) Y\b\c"
		read -r ANSWER
		if [[ -z "${ANSWER}" || "${ANSWER}" =~ ^[^Nn] ]]; then
			echo "Copy bot config to ${BOTCONFIG}.jssh.ok ..."
		fi 
	else
		echo -e "${ORANGE}Bot config may not complete, pls check.${NC}"
	fi
	# show result
	ls -ld "${DATADIR}" "${LOGDIR}" ./*.jssh* ./*.sh 
}

if ! _is_function send_message ; then
	echo -e "${RED}ERROR: send_message is not available, did you deactivate ${MODULEDIR}/sendMessage.sh?${NC}"
	exit 1
fi

JSONSHFILE="${BASHBOT_JSONSH:-${SCRIPTDIR}/JSON.sh/JSON.sh}"
[[ "${JSONSHFILE}" != *"/JSON.sh" ]] && echo -e "${RED}ERROR: \"${JSONSHFILE}\" ends not with \"JSONS.sh\".${NC}" && exit 3

if [ ! -f "${JSONSHFILE}" ]; then
	echo "Seems to be first run, Downloading ${JSONSHFILE}..."
	[ "${SCRIPTDIR}/JSON.sh/JSON.sh" = "${JSONSHFILE}" ] &&\
		 mkdir "${SCRIPTDIR}/JSON.sh" 2>/dev/null && chmod +w "${SCRIPTDIR}/JSON.sh"
	getJson "https://cdn.jsdelivr.net/gh/dominictarr/JSON.sh/JSON.sh" >"${JSONSHFILE}"
	chmod +x "${JSONSHFILE}" 
fi

# source the script with source as param to use functions in other scripts
# do not execute if read from other scripts

if [ -z "${SOURCE}" ]; then

  ##############
  # internal options only for use from bashbot and developers
  case "$1" in
	# update botname botname when starting only
	"botname"|"start"*)
		ME="$(getBotName)"
		if [ -n "${ME}" ]; then
			# ok we have a connection an got botname, save it
			[ -n "${CLEAR}" ] && echo -e "${GREY}Bottoken is valid ...${NC}"
			jssh_updateKeyDB "botname" "${ME}" "${BOTCONFIG}"
			rm -f "${BOTCONFIG}.jssh.flock"
		else
			echo -e "${GREY}Info: Can't get Botname from Telegram, try cached one ...${NC}"
			ME="$(getConfigKey "botname")"
			if [ -z "$ME" ]; then
			    echo -e "${RED}ERROR: No cached botname, can't continue! ...${NC}"
			    exit 1
			fi
		fi
		[ -n "${CLEAR}" ] && printf "Bot Name: %s\n" "${ME}"
		[ "$1" = "botname" ] && exit
		;;&
	# used to send output of background and interactive to chats
	"outproc") # $2 chat_id $3 identifier of job, internal use only!
		[ -z "$3" ] && echo "No job identifier" && exit 3
		[ -z "$2"  ] && echo "No chat to send to" && exit 3
		ME="$(getConfigKey "botname")"
		# read until terminated
		while read -r line ;do
			[ -n "$line" ] && send_message "$2" "$line"
		done 
		# cleanup datadir, keep logfile if not empty
		rm -f -r "${DATADIR:-.}/$3"
		[ -s "${DATADIR:-.}/$3.log" ] || rm -f "${DATADIR:-.}/$3.log"
		exit
		;;
	# finally starts  the read update loop, internal use only1
	"startbot" )
		start_bot "$2"
		exit
		;;
	# run after every update to update files and adjust permissions
	"init") 
		bot_init "$2"
		exit
		;;
	# print usage sats
	"count") echo -e "${RED}Command ${GREY}count${RED} is deprecated, use ${GREY}stats{$RED}instead.${NC}";&
	"stats")
		ME="$(getConfigKey "botname")"
		declare -A STATS
		jssh_readDB_async "STATS" "${COUNTFILE}"
		for MSG in ${!STATS[*]}
		do
			[[ ! "${MSG}" =~ ^[0-9-]*$ ]] && continue
			(( USERS++ ))
		done
		for MSG in ${STATS[*]}
		do
			(( MESSAGES+=MSG ))
		done
		echo "A total of ${MESSAGES} messages from ${USERS} users are processed."
		exit
		;;
	# sedn message to all users
	'broadcast')
		ME="$(getConfigKey "botname")"
		declare -A SENDALL
		shift
		jssh_readDB_async "SENDALL" "${COUNTFILE}"
		echo -e "Sending broadcast message to all users of ${ME} \c"
		for MSG in ${!SENDALL[*]}
		do
			[[ ! "${MSG}" =~ ^[0-9-]*$ ]] && continue
			(( USERS++ ))
			if [ -n "$*" ]; then
				send_message "${MSG}" "$*"
				echo -e ".\c"
				sleep 0.1
			fi
		done
		echo -e "\nMessage \"$*\" sent to ${USERS} users."
		exit
		;;
	# does what is says
	"status")
		ME="$(getConfigKey "botname")"
		SESSION="${ME:-_bot}-startbot"
		BOTPID="$(proclist "${SESSION}")"
		if [ -n "${BOTPID}" ]; then
			echo -e "${GREEN}Bot is running with UID ${RUNUSER}.${NC}"
			exit
		else
			echo -e "${ORANGE}No Bot running with UID ${RUNUSER}.${NC}"
			exit 5
		fi
		;;
		 
	# start bot as background jod and check if bot is running
	"start")
		# shellcheck disable=SC2086
		SESSION="${ME:-_bot}-startbot"
		BOTPID="$(proclist "${SESSION}")"
		# shellcheck disable=SC2086
		[ -n "${BOTPID}" ] && kill ${BOTPID}
		nohup "$SCRIPT" "startbot" "$2" "${SESSION}" &>/dev/null &
		printf "Session Name: %s\n" "${SESSION}"
		sleep 1
		if [ -n "$(proclist "${SESSION}")" ]; then
		 	echo -e "${GREEN}Bot started successfully.${NC}"
		else
			echo -e "${RED}An error occurred while starting the bot.${NC}"
			exit 5
		fi
		;;
	# does what it says
	"kill") echo -e "${RED}Command ${GREY}kill${RED} is deprecated, use ${GREY}stop{$RED}instead.${NC}";&
	"stop")
		ME="$(getConfigKey "botname")"
		SESSION="${ME:-_bot}-startbot"
		BOTPID="$(proclist "${SESSION}")"
		if [ -n "${BOTPID}" ]; then
			# shellcheck disable=SC2086
			if kill ${BOTPID}; then
				# inform botadmin about stop
				ADMIN="$(getConfigKey "botadmin")"
				[ -n "${ADMIN}" ] && send_normal_message "${ADMIN}" "Bot ${ME} stopped ..." &
				echo -e "${GREEN}OK. Bot stopped successfully.${NC}"
			else
				echo -e "${RED}An error occurred while stopping bot.${NC}"
				exit 5
			fi
		else
			echo -e "${ORANGE}No Bot running with UID ${RUNUSER}.${NC}"
		fi
		exit
		;;
	# suspend, resume or kill background jobs
	"suspendb"*|"resumeb"*|"killb"*)
  		_is_function job_control || { echo -e "${RED}Module background is not available!${NC}"; exit 3; }
		ME="$(getConfigKey "botname")"
		job_control "$1"
		;;
	*)
		echo -e "${RED}${REALME##*/}: unknown command${NC}"
		echo -e "${RED}Available commands: ${GREY}${BOTCOMMANDS}${NC}" && exit
		exit 4
		;;
  esac

  # warn if root
  if [[ "${UID}" -eq "0" ]] ; then
	echo -e "\\n${ORANGE}WARNING: ${SCRIPT} was started as ROOT (UID 0)!${NC}"
	echo -e "${ORANGE}You are at HIGH RISK when running a Telegram BOT with root privilegs!${NC}"
  fi
fi # end source
