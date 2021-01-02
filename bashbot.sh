#!/bin/bash
##################################################################
#
# File: bashbot.sh 
# Note: DO NOT EDIT! this file will be overwritten on update
# shellcheck disable=SC2140,SC2031,SC2120,SC1091,SC1117,SC2059
#
# Description: bashbot, the Telegram bot written in bash.
#
#     Written by Drew (@topkecleon) KayM (@gnadelwartz).
#     Also contributed: Daniil Gentili (@danog), JuanPotato, BigNerd95,
#                       TiagoDanin, iicc1, dcoomber
#     https://github.com/topkecleon/telegram-bot-bash
#
#     This file is public domain in the USA and all free countries.
#     Elsewhere, consider it to be WTFPLv2. (wtfpl.net/txt/copying)
#
# Usage: bashbot.sh [-h|--help|BOTCOMMANDS]
         BOTCOMMANDS="start, stop, status, help, init, suspendback, resumeback, killback"
#
# Exit Codes:
#     0 - success (hopefully)
#     1 - can't change to dir
#     2 - can't write to tmp, count or token
#     3 - user / command / file not found
#     4 - unknown command
#     5 - cannot start, stop or get status
#     6 - mandatory module not found
#     7 - can't get bottoken
#     8 - curl/wget missing
#     10 - not bash!
#
#### $$VERSION$$ v1.21-pre-28-g5415f28
##################################################################

# emmbeded system may claim bash but it is not
# check for bash like ARRAY handlung
if ! (unset a; set -A a a; eval "a=(a b)"; eval '[ -n "${a[1]}" ]'; ) > /dev/null 2>&1; then
	printf "Error: Current shell does not support ARRAY's, may be busybox ash shell. pls install a real bash!\n"
	exit 10
fi

# are we running in a terminal?
NN="\n"
if [ -t 1 ] && [ -n "$TERM" ];  then
    INTERACTIVE='yes'
    RED='\e[31m'
    GREEN='\e[32m'
    ORANGE='\e[35m'
    GREY='\e[1;30m'
    NC='\e[0m'
    NN="${NC}\n"
fi

# telegram uses utf-8 characters, check if we have an utf-8 charset
if [ "${LANG}" = "${LANG%[Uu][Tt][Ff]*}" ]; then
	printf "${ORANGE}Warning: Telegram uses utf-8, but looks like you are using non utf-8 locale:${NC} ${LANG}\n"
fi

# we need some bash 4+ features, check for old bash by feature
if [ "$({ LC_ALL=C.utf-8 printf "%b" "\u1111"; } 2>/dev/null)" = "\u1111" ]; then
	printf "${ORANGE}Warning: Missing unicode '\uxxxx' support, missing C.utf-8 locale or to old bash version.${NN}"
fi


# some important helper functions
# returns true if command exist
_exists() {
	[ "$(type -t "${1}")" = "file" ]
}
# execute function if exists
_exec_if_function() {
	[ "$(type -t "${1}")" != "function" ] && return 1
	"$@"
}
# returns true if function exist
_is_function() {
	[ "$(type -t "${1}")" = "function" ]
}
# round $1 in international notation! , returns float with $2 decimal digits
# if $2 is not given or is not a positive number zero is assumed
_round_float() {
	local digit="${2}"; [[ "${2}" =~ ^[0-9]+$ ]] || digit="0"
	{ LC_ALL=C.utf-8 printf "%.${digit}f" "${1}"; } 2>/dev/null
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
# check if $1 seems a valid token
# return true if token seems to be valid
check_token(){
	[[ "${1}" =~ ^[0-9]{8,10}:[a-zA-Z0-9_-]{35}$ ]] && return 0
	return 1
}
# log $1 with date
log_error(){ printf "%s: %s\n" "$(date)" "$*" >>"${ERRORLOG}"; }
log_debug(){ printf "%s: %s\n" "$(date)" "$*" >>"${DEBUGLOG}"; }
log_update(){ printf "%s: %s\n" "$(date)" "$*" >>"${UPDATELOG}"; }
# log $1 with date, special first \n
log_message(){ printf "\n%s: %s\n" "$(date)" "${1/\\n/$'\n'}" >>"${MESSAGELOG}"; }

# additional tests if we run in debug mode
export BASHBOTDEBUG
[[ "${BASH_ARGV[0]}" == *"debug"* ]] && BASHBOTDEBUG="yes"

# $1 where $2 command $3 may debug 
# shellcheck disable=SC2094
debug_checks(){ {
	[  -z "${BASHBOTDEBUG}" ] && return
	local DATE WHERE MYTOKEN; DATE="$(date)"; WHERE="${1}"; shift
	printf "%s: debug_checks: %s: bashbot.sh %s\n" "${DATE}" "${WHERE}" "${@##*/}"
	# shellcheck disable=SC2094
	[ -z "${DEBUGLOG}" ] && printf "%s: %s\n" "${DATE}" "DEBUGLOG not set! =========="
	MYTOKEN="$(getConfigKey "bottoken")"
	[ -z "${MYTOKEN}" ] && printf "%s: %s\n" "${DATE}" "Bot token is missing! =========="
	check_token "${MYTOKEN}" || printf "%s: %s\n" "${DATE}" "Invalid bot token! =========="
	[ -z "$(getConfigKey "botadmin")" ] && printf "%s: %s\n" "${DATE}" "Bot admin is missing! =========="
	# call user defined debug_checks if exists
	_exec_if_function my_debug_checks "${DATE}" "${WHERE}" "$*"
	} >>"${DEBUGLOG}"
}

# some Linux distributions (e.g. Manjaro) doesn't seem to have C locale activated by default
if _exists locale && [ "$(locale -a | grep -c -e "^C$" -e "^C.utf8$")" -lt 2 ]; then
	printf "${ORANGE}Warning: locale ${NC}${GREY}C${NC}${ORANGE} and/or ${NC}${GREY}C.utf8${NC}${ORANGE} seems missing, use \"${NC}${GREY}locale -a${NC}${ORANGE}\" to show what locales are installed on your system.${NN}"
fi

# get location and name of bashbot.sh
SCRIPT="$0"
REALME="${BASH_SOURCE[0]}"
SCRIPTDIR="$(dirname "${REALME}")"
RUNDIR="$(dirname "$0")"

MODULEDIR="${SCRIPTDIR}/modules"

# adjust locations based on source and real name
[[ "${SCRIPT}" != "${REALME}" || "$1" == "source" ]] && SOURCE="yes"

if [ -n "$BASHBOT_HOME" ]; then
	SCRIPTDIR="$BASHBOT_HOME"
 else
	BASHBOT_HOME="${SCRIPTDIR}"
fi
[ -z "${BASHBOT_ETC}" ] && BASHBOT_ETC="$BASHBOT_HOME"
[ -z "${BASHBOT_VAR}" ] && BASHBOT_VAR="$BASHBOT_HOME"

ADDONDIR="${BASHBOT_ETC:-.}/addons"
RUNUSER="${USER}" # USER is overwritten by bashbot array :-(, save original

# provide help
case "$1" in
	""|"-h"*) [ -z "${SOURCE}" ] && printf "${ORANGE}Available commands: ${GREY}${BOTCOMMANDS}${NN}" && exit
		;;
	"--h"*)	sed -nE -e '/(NOT EDIT)|(shellcheck)/d' -e '3,/###/p' <"$0"
		exit;;
	"help") HELP="${BASHBOT_HOME:-.}/README"
		if [ -n "${INTERACTIVE}" ];then
			_exists w3m && w3m "$HELP.html" && exit
			_exists lynx && lynx "$HELP.html" && exit
			_exists less && less "$HELP.txt" && exit
		fi
		cat "$HELP.txt"
		exit;;
esac

# OK, ENVIRONMENT is set up, let's do some additional tests
if [[ -z "${SOURCE}" && -z "$BASHBOT_HOME" ]] && ! cd "${RUNDIR}" ; then
	printf "${RED}ERROR: Can't change to ${RUNDIR} ...${NN}"
	exit 1
fi
RUNDIR="."
[ ! -w "." ] && printf "${ORANGE}WARNING: ${RUNDIR} is not writeable!${NN}"

# check if JSON.sh is available
JSONSHFILE="${BASHBOT_JSONSH:-${SCRIPTDIR}/JSON.sh/JSON.sh}"
[ ! -x "${JSONSHFILE}" ] &&\
	 printf "${RED}ERROR:${NC} ${JSONSHFILE} ${RED}does not exist, are we in dev environment?${NN}${GREY}%s${NN}\n"\
		"\$JSONSHFILE is set wrong or bashbot is not installed correctly, see doc/0_install.md" && exit 3

# file locations based on ENVIRONMENT
BOTCONFIG="${BASHBOT_ETC:-.}/botconfig"
BOTACL="${BASHBOT_ETC:-.}/botacl"
DATADIR="${BASHBOT_VAR:-.}/data-bot-bash"
BLOCKEDFILE="${BASHBOT_VAR:-.}/blocked"
COUNTFILE="${BASHBOT_VAR:-.}/count"

LOGDIR="${RUNDIR:-.}/logs"

# CREATE botconfig if not exist
# assume everything already set up correctly if TOKEN is set
if [ -z "${BOTTOKEN}" ]; then
  # BOTCONFIG does not exist, create
  [ ! -f "${BOTCONFIG}.jssh" ] && printf '["bot_config_key"]\t"config_key_value"\n' >>"${BOTCONFIG}.jssh"
  if [ -z "$(getConfigKey "bottoken")" ]; then
    # ask user for bot token
    if [ -z "${INTERACTIVE}" ] && [ "$1" != "init" ]; then
	printf "Running headless, set BOTTOKEN or run ${SCRIPT} init first!\n"
	exit 2 
    else
	printf "${RED}ENTER BOT TOKEN...${NN}${ORANGE}PLEASE WRITE YOUR TOKEN HERE OR PRESS CTRL+C TO ABORT${NN}"
	read -r token
	printf "\n"
    fi
    [ -n "${token}" ] && printf '["bottoken"]\t"%s"\n'  "${token}" >> "${BOTCONFIG}.jssh"
  fi
  # no botadmin, setup botadmin
  if [ -z "$(getConfigKey "botadmin")" ]; then
     # ask user for bot admin
     if [ -z "${INTERACTIVE}" ]; then
	printf "Running headless, set botadmin to AUTO MODE!\n"
     else
	printf "${RED}ENTER BOT ADMIN...${NN}${ORANGE}PLEASE WRITE YOUR TELEGRAM ID HERE OR PRESS ENTER\nTO MAKE FIRST USER TYPING '/start' BOT ADMIN${NN}?\b"
	read -r admin
     fi
     [ -z "${admin}" ] && admin='?'
     printf '["botadmin"]\t"%s"\n'  "${admin}" >> "${BOTCONFIG}.jssh"
  fi
  # setup botacl file
  if [ ! -f "${BOTACL}" ]; then
	printf "${GREY}Create initial ${BOTACL} file.${NN}"
	printf '\n' >"${BOTACL}"
  fi
  # check data dir file
  if [ ! -w "${DATADIR}" ]; then
	printf "${RED}ERROR: ${DATADIR} does not exist or is not writeable!.${NN}"
	exit 2
  fi
  # setup count file 
  if [ ! -f "${COUNTFILE}.jssh" ]; then
	printf '["counted_user_chat_id"]\t"num_messages_seen"\n' >> "${COUNTFILE}.jssh"
  elif [ ! -w "${COUNTFILE}.jssh" ]; then
	printf "${RED}ERROR: Can't write to ${COUNTFILE}!.${NN}"
	ls -l "${COUNTFILE}.jssh"
	exit 2
  fi
  # setup blocked file 
  if [ ! -f "${BLOCKEDFILE}.jssh" ]; then
	printf '["blocked_user_or_chat_id"]\t"name and reason"\n' >>"${BLOCKEDFILE}.jssh"
  fi
fi

if [[ ! -d "${LOGDIR}" || ! -w "${LOGDIR}" ]]; then
	LOGDIR="${RUNDIR:-.}"
fi
DEBUGLOG="${LOGDIR}/DEBUG.log"
ERRORLOG="${LOGDIR}/ERROR.log"
UPDATELOG="${LOGDIR}/BASHBOT.log"
MESSAGELOG="${LOGDIR}/MESSAGE.log"

debug_checks "start SOURCE=${SOURCE:-no}" "$@"
# read BOTTOKEN from bot database if not set
if [ -z "${BOTTOKEN}" ]; then
    BOTTOKEN="$(getConfigKey "bottoken")"
    if [ -z "${BOTTOKEN}" ]; then
		BOTERROR="Warning: can't get bot token, try to recover working config..."
		printf "${ORANGE}${BOTERROR}${NC} "
		if [ -r "${BOTCONFIG}.jssh.ok" ]; then
			log_error "${BOTERROR}"
			mv "${BOTCONFIG}.jssh" "${BOTCONFIG}.jssh.bad"
			cp "${BOTCONFIG}.jssh.ok" "${BOTCONFIG}.jssh"; printf "OK\n"
			BOTTOKEN="$(getConfigKey "bottoken")"
		else
			printf "\n${RED}Error: Can't recover from missing bot token! Remove ${BOTCONFIG}.jssh and run${NC} bashbot.sh init\n"
			exit 7
		fi
    fi
fi

# BOTTOKEN format checks
if ! check_token "${BOTTOKEN}"; then
	printf "\n${ORANGE}Warning: Your bot token is incorrect, it should have the following format:${NC}\n%b%b"\
		"<your_bot_id>${RED}:${NC}<35_alphanumeric_characters-hash> ${RED}e.g. =>${NC} 123456789${RED}:${NC}Aa-Zz_0Aa-Zz_1Aa-Zz_2Aa-Zz_3Aa-Zz_4\n\n"\
		"${GREY}Your bot token: '${NC}${BOTTOKEN//:/${RED}:${NC}}'\n"

	if [[ ! "${BOTTOKEN}" =~ ^[0-9]{8,10}: ]]; then
		printf "${GREY}\tHint: Bot id not a number or wrong len: ${NC}$(($(wc -c <<<"${BOTTOKEN%:*}")-1)) ${GREY}but should be${NC} 8-10\n"
		[ -n "$(getConfigKey "botid")" ] && printf "\t${GREEN}Did you mean: \"${NC}$(getConfigKey "botid")${GREEN}\" ?${NN}"
	fi
	[[ ! "${BOTTOKEN}" =~ :[a-zA-Z0-9_-]{35}$ ]] &&\
		printf "${GREY}\tHint: Hash contains invalid character or has not len${NC} 35 ${GREY}, hash len is ${NC}$(($(wc -c <<<"${BOTTOKEN#*:}")-1))\n"
	printf "\n"
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

declare -rx SCRIPT SCRIPTDIR MODULEDIR RUNDIR ADDONDIR BOTACL DATADIR COUNTFILE
declare -rx BOTTOKEN URL ME_URL UPD_URL GETFILE_URL

declare -ax CMD
declare -Ax UPD BOTSENT USER MESSAGE URLS CONTACT LOCATION CHAT FORWARD REPLYTO VENUE iQUERY
declare -Ax SERVICE NEWMEMBER LEFTMEMBER PINNED MIGRATE
export res CAPTION ME


##################
# read commands file if we are not sourced
COMMANDS="${BASHBOT_ETC:-.}/commands.sh"
if [  -r "${COMMANDS}" ]; then
	# shellcheck source=./commands.sh
	 source "${COMMANDS}" "source"
else
	[ -z "${SOURCE}" ] && printf "${RED}Warning: ${COMMANDS} does not exist or is not readable!.${NN}"
fi

###############
# load modules
for module in "${MODULEDIR:-.}"/*.sh ; do
	# shellcheck source=./modules/aliases.sh
	if ! _is_function "$(basename "${module}")" && [ -r "${module}" ]; then source "${module}" "source"; fi
done

#####################
# BASHBOT INTERNAL functions
#

# do we have BSD sed
sed '1ia' </dev/null 2>/dev/null || printf "${ORANGE}Warning: You may run on a BSD style system without gnu utils ...${NN}"
#jsonDB is now mandatory
if ! _is_function jssh_newDB; then
	printf "${RED}ERROR: Mandatory module jsonDB is missing or not readable!${NN}"
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

# $1 string to search for programme incl. parameters
# returns a list of PIDs of all current bot processes matching $1
proclist() {
	# shellcheck disable=SC2009
	ps -fu "${UID}" | grep -F "$1" | grep -v ' grep'| grep -F "${ME}" | sed 's/\s\+/\t/g' | cut -f 2
}

# $1 string to search for programme to kill
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
	debug_checks "end killallproc" "${1}"
}


# $ chat $2 msg_id $3 nolog
declare -xr DELETE_URL=$URL'/deleteMessage'
delete_message() {
	[ -z "$3" ] && log_update "Delete Message CHAT=${1} MSG_ID=${2}"
	sendJson "${1}" '"message_id": '"${2}"'' "${DELETE_URL}"
}

get_file() {
	[ -z "$1" ] && return
	sendJson ""  '"file_id": "'"${1}"'"' "${GETFILE_URL}"
	printf '%s\n' "${URL}"/"$(JsonGetString <<< "${res}" '"result","file_path"')"
}

# curl is preferred, try detect curl even not in PATH
# return TRUE if curl is found or custom curl detected
# return FALSE if no curl is found or wget is forced by BASHBOT_WGET
# sets BASHBOT_CURL to point to curl
DETECTED_CURL="curl"
function detect_curl() {
	# custom curl command
	[ -n "${BASHBOT_CURL}" ] && return 0
	# use wget
	if [ -n "${BASHBOT_WGET}" ]; then
		DETECTED_CURL="wget"
		return 1
	fi
	# default use curl in PATH
	BASHBOT_CURL="curl"
	_exists curl && return 0
	# search in usual locations
	local file
	for file in /usr/bin /bin /usr/local/bin; do
		if [ -x "${file}/curl" ]; then
			BASHBOT_CURL="${file}/curl"
			return 0
		fi
	done
	# curl not in PATH and not in usual locations
	DETECTED_CURL="wget"
	local warn="Warning: Curl not detected, try fallback to wget! pls install curl or adjust BASHBOT_CURL/BASHBOT_WGET environment variables."
	log_update "${warn}"; [ -n "${BASHBOTDEBUG}" ] && log_debug "${warn}"
	return 1
}

# iconv used to filter out broken utf characters, if not installed fake it
if ! _exists iconv; then
	log_update "Warning: iconv not installed, pls imstall iconv!"
	function iconv() { cat; }
fi

TIMEOUT="${BASHBOT_TIMEOUT}"
[[ "$TIMEOUT" =~ ^[0-9]+$ ]] || TIMEOUT="20"

# usage: sendJson "chat" "JSON" "URL"
sendJson(){
	local json chat=""
	if [ -n "${1}" ]; then
		 chat='"chat_id":'"${1}"','
		 [[ "${1}" == *[!0-9-]* ]] && chat='"chat_id":"'"${1}"' NAN",' # chat id not a number!
	fi
	# compose final json
	json='{'"${chat} $(iconv -f utf-8 -t utf-8 -c <<<"$2")"'}'
	if [ -n "${BASHBOTDEBUG}" ] ; then
		log_update "sendJson (${DETECTED_CURL}) CHAT=${chat#*:} JSON=${2:0:100} URL=${3##*/}"
		log_message "DEBUG sendJson ==========\n$("${JSONSHFILE}" -b -n <<<"${json}" 2>&1)"
	fi
	# chat id not a number
	if [[ "${chat}" == *"NAN\"," ]]; then
		sendJsonResult "$(printf '["ok"]\tfalse\n["error_code"]\t400\n["description"]\t"Bad Request: chat id not a number"\n')"\
			"sendJson (NAN)" "$@"
		return
	fi
	# OK here we go ...
	# route to curl/wget specific function
	res="$(sendJson_do "${json}" "${3}")"
	# check telegram response
	sendJsonResult "${res}" "sendJson (${DETECTED_CURL})" "$@"
	[ -n "${BASHBOT_EVENT_SEND[*]}" ] && event_send "send" "${@}" &
}

#
# curl / wget specific functions
#
if detect_curl ; then
  # here we have curl ----
  [ -z "${BASHBOT_CURL}" ] && BASHBOT_CURL="curl"
  getJson(){
	[[ -n "${BASHBOTDEBUG}" && -n "${3}" ]] && log_debug "getJson (curl) URL=${1##*/}"
	# shellcheck disable=SC2086
	"${BASHBOT_CURL}" -sL -k ${BASHBOT_CURL_ARGS} -m "${TIMEOUT}" "$1"
  }
  # curl variant for sendJson
  # usage: "JSON" "URL"
  sendJson_do(){
	# shellcheck disable=SC2086
	"${BASHBOT_CURL}" -s -k ${BASHBOT_CURL_ARGS} -m "${TIMEOUT}"\
		-d "${1}" -X POST "${2}" -H "Content-Type: application/json" | "${JSONSHFILE}" -b -n 2>/dev/null
  }
  #$1 Chat, $2 what, $3 file, $4 URL, $5 caption
  sendUpload() {
	[ "$#" -lt 4  ] && return
	if [ -n "$5" ]; then
	[ -n "${BASHBOTDEBUG}" ] &&\
		log_update "sendUpload CHAT=${1} WHAT=${2}  FILE=${3} CAPT=${5}"
	# shellcheck disable=SC2086
		res="$("${BASHBOT_CURL}" -s -k ${BASHBOT_CURL_ARGS} "$4" -F "chat_id=$1"\
			-F "$2=@$3;${3##*/}" -F "caption=$5" | "${JSONSHFILE}" -b -n 2>/dev/null )"
	else
	# shellcheck disable=SC2086
		res="$("${BASHBOT_CURL}" -s -k ${BASHBOT_CURL_ARGS} "$4" -F "chat_id=$1"\
			-F "$2=@$3;${3##*/}" | "${JSONSHFILE}" -b -n 2>/dev/null )"
	fi
	sendJsonResult "${res}" "sendUpload (curl)" "$@"
	[ -n "${BASHBOT_EVENT_SEND[*]}" ] && event_send "upload" "$@" &
  }
else
  # NO curl, try wget
  if _exists wget; then
    getJson(){
	[[ -n "${BASHBOTDEBUG}" && -z "${3}" ]] && log_debug "getJson (wget) URL=${1##*/}"
	# shellcheck disable=SC2086
	wget --no-check-certificate -t 2 -T "${TIMEOUT}" ${BASHBOT_WGET_ARGS} -qO - "$1"
    }
    # curl variant for sendJson
    # usage: "JSON" "URL"
    sendJson_do(){
	# shellcheck disable=SC2086
	wget --no-check-certificate -t 2 -T "${TIMEOUT}" ${BASHBOT_WGET_ARGS} -qO - --post-data="${1}" \
		--header='Content-Type:application/json' "${2}" | "${JSONSHFILE}" -b -n 2>/dev/null
    }
    sendUpload() {
	log_error "Sorry, wget does not support file upload"
	BOTSENT[OK]="false"
	[ -n "${BASHBOT_EVENT_SEND[*]}" ] && event_send "upload" "$@" &
    }
  else
	# ups, no curl AND no wget
	if [ -n "${BASHBOT_WGET}" ]; then
		printf "${RED}Error: You set BASHBOT_WGET but no wget found!${NN}"
	else
		printf "${RED}Error: curl and wget not found, install curl!${NN}"
	fi
	exit 8
  fi
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
			log_error "Error: unknown function ${retry}, cannot retry"
			return
			;;
	esac
	[ "${BOTSENT[OK]}" = "true" ] && log_error "Retry OK:${retry} ${1} ${2:0:60}"
} >>"${ERRORLOG}"

# process sendJson result
# stdout is written to ERROR.log
# $1 result $2 function $3 .. $n original arguments, $3 is Chat_id
sendJsonResult(){
	local offset=0
	BOTSENT=( )
	[ -n "${BASHBOTDEBUG}" ] && log_message "New Result ==========\n$1"
	BOTSENT[OK]="$(JsonGetLine '"ok"' <<< "${1}")"
	if [ "${BOTSENT[OK]}" = "true" ]; then
		BOTSENT[ID]="$(JsonGetValue '"result","message_id"' <<< "${1}")"
		return
		# hot path everything OK!
	else
	    # oops something went wrong!
	    if [ "${1}" != "" ]; then
			BOTSENT[ERROR]="$(JsonGetValue '"error_code"' <<< "${1}")"
			BOTSENT[DESCRIPTION]="$(JsonGetString '"description"' <<< "${1}")"
			grep -qs -F '"parameters","retry_after"' <<< "${1}" &&\
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
	    # throttled, telegram say we send too many messages
	    if [ -n "${BOTSENT[RETRY]}" ]; then
			BASHBOT_RETRY="$(( ++BOTSENT[RETRY] ))"
			printf "Retry %s in %s seconds ...\n" "${2}" "${BASHBOT_RETRY}"
			sendJsonRetry "${2}" "${BASHBOT_RETRY}" "${@:3}"
			unset BASHBOT_RETRY
			return
	    fi
	    # timeout, failed connection or blocked
	    if [ "${BOTSENT[ERROR]}" == "999" ];then
		# check if default curl and args are OK
			if ! curl -sL -k -m 2 "${URL}" >/dev/null 2>&1 ; then
				printf "%s: BASHBOT IP Address seems blocked!\n" "$(date)"
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

# get bot name and id from telegram
getBotName() {
	declare -A BOTARRAY
	Json2Array 'BOTARRAY' <<<"$(getJson "$ME_URL" | "${JSONSHFILE}" -b -n 2>/dev/null)"
	[ -z "${BOTARRAY["result","username"]}" ] && return 1
	# save botname and id
	setConfigKey "botname" "${BOTARRAY["result","username"]}"
	setConfigKey "botid" "${BOTARRAY["result","id"]}"
	printf "${BOTARRAY["result","username"]}\n"
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
	#printf "%b\n" "${out}${remain}" # seems to work ... dealyed to next dev
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
	max="$(grep -F ',"update_id"]'  <<< "${UPDATE}" | tail -1 | cut -d , -f 2 )"
	Json2Array 'UPD' <<<"${UPDATE}"
	for ((num=0; num<=max; num++)); do
		process_client "$num" "${debug}"
	done
}

process_client() {
	local num="$1" debug="$2" 
	pre_process_message "${num}"
	# log message on debug
	[[ -n "${debug}" ]] && log_message "New Message ==========\n$(grep -F '["result",'"${num}" <<<"${UPDATE}")"

	# check for users / groups to ignore
	jssh_updateArray_async "BASHBOTBLOCKED" "${BLOCKEDFILE}"
	[ -n "${USER[ID]}" ] && [[ -n "${BASHBOTBLOCKED[${USER[ID]}]}" || -n "${BASHBOTBLOCKED[${CHAT[ID]}]}" ]] && return

	# process per message type
	if [ -z "${iQUERY[ID]}" ]; then
		if grep -qs -e '\["result",'"${num}"',"edited_message"' <<<"${UPDATE}"; then
			# edited message
			UPDATE="${UPDATE//,${num},\"edited_message\",/,${num},\"message\",}"
			Json2Array 'UPD' <<<"${UPDATE}"
			MESSAGE[0]="/_edited_message "
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

declare -Ax BASHBOT_EVENT_INLINE BASHBOT_EVENT_MESSAGE BASHBOT_EVENT_CMD BASHBOT_EVENT_REPLY BASHBOT_EVENT_FORWARD BASHBOT_EVENT_SEND
declare -Ax BASHBOT_EVENT_CONTACT BASHBOT_EVENT_LOCATION BASHBOT_EVENT_FILE BASHBOT_EVENT_TEXT BASHBOT_EVENT_TIMER BASHBOT_BLOCKED

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
pre_process_message(){
	local num="${1}"
	# unset everything to not have old values
	CMD=( ); iQUERY=( ); MESSAGE=(); CHAT=(); USER=(); CONTACT=(); LOCATION=(); unset CAPTION
	REPLYTO=( ); FORWARD=( ); URLS=(); VENUE=( ); SERVICE=( ); NEWMEMBER=( ); LEFTMEMBER=( ); PINNED=( ); MIGRATE=( )
	iQUERY[ID]="${UPD["result",${num},"inline_query","id"]}"
	CHAT[ID]="${UPD["result",${num},"message","chat","id"]}"
	USER[ID]="${UPD["result",${num},"message","from","id"]}"
	[ -z "${CHAT[ID]}" ] && CHAT[ID]="${UPD["result",${num},"edited_message","chat","id"]}"
	[ -z "${USER[ID]}" ] && USER[ID]="${UPD["result",${num},"edited_message","from","id"]}"
	# always true
	return 0
}
process_inline() {
	local num="${1}"
	iQUERY[0]="$(JsonDecode "${UPD["result",${num},"inline_query","query"]}")"
	iQUERY[USER_ID]="${UPD["result",${num},"inline_query","from","id"]}"
	iQUERY[FIRST_NAME]="$(JsonDecode "${UPD["result",${num},"inline_query","from","first_name"]}")"
	iQUERY[LAST_NAME]="$(JsonDecode "${UPD["result",${num},"inline_query","from","last_name"]}")"
	iQUERY[USERNAME]="$(JsonDecode "${UPD["result",${num},"inline_query","from","username"]}")"
	# always true
	return 0
}
process_message() {
	local num="$1"
	# Message
	MESSAGE[0]+="$(JsonDecode "${UPD["result",${num},"message","text"]}" | sed 's|\\/|/|g')"
	MESSAGE[ID]="${UPD["result",${num},"message","message_id"]}"

	# Chat ID is now parsed when update is received
	CHAT[LAST_NAME]="$(JsonDecode "${UPD["result",${num},"message","chat","last_name"]}")"
	CHAT[FIRST_NAME]="$(JsonDecode "${UPD["result",${num},"message","chat","first_name"]}")"
	CHAT[USERNAME]="$(JsonDecode "${UPD["result",${num},"message","chat","username"]}")"
	# set real name as username if empty
	[ -z "${CHAT[USERNAME]}" ] && CHAT[USERNAME]="${CHAT[FIRST_NAME]} ${CHAT[LAST_NAME]}"
	CHAT[TITLE]="$(JsonDecode "${UPD["result",${num},"message","chat","title"]}")"
	CHAT[TYPE]="$(JsonDecode "${UPD["result",${num},"message","chat","type"]}")"
	CHAT[ALL_ADMIN]="${UPD["result",${num},"message","chat","all_members_are_administrators"]}"

	# user ID is now parsed when update is received
	#USER[ID]="${UPD["result",${num},"message","from","id"]}"
	USER[FIRST_NAME]="$(JsonDecode "${UPD["result",${num},"message","from","first_name"]}")"
	USER[LAST_NAME]="$(JsonDecode "${UPD["result",${num},"message","from","last_name"]}")"
	USER[USERNAME]="$(JsonDecode "${UPD["result",${num},"message","from","username"]}")"
	# set real name as username if empty
	[ -z "${USER[USERNAME]}" ] && USER[USERNAME]="${USER[FIRST_NAME]} ${USER[LAST_NAME]}"

	# in reply to message from
	if [ -n "${UPD["result",${num},"message","reply_to_message","from","id"]}" ]; then
	   REPLYTO[UID]="${UPD["result",${num},"message","reply_to_message","from","id"]}"
	   REPLYTO[0]="$(JsonDecode "${UPD["result",${num},"message","reply_to_message","text"]}")"
	   REPLYTO[ID]="${UPD["result",${num},"message","reply_to_message","message_id"]}"
	   REPLYTO[FIRST_NAME]="$(JsonDecode "${UPD["result",${num},"message","reply_to_message","from","first_name"]}")"
	   REPLYTO[LAST_NAME]="$(JsonDecode "${UPD["result",${num},"message","reply_to_message","from","last_name"]}")"
	   REPLYTO[USERNAME]="$(JsonDecode "${UPD["result",${num},"message","reply_to_message","from","username"]}")"
	fi

	# forwarded message from
	if [ -n "${UPD["result",${num},"message","forward_from","id"]}" ]; then
	   FORWARD[UID]="${UPD["result",${num},"message","forward_from","id"]}"
	   FORWARD[ID]="${MESSAGE[ID]}" # same as message ID
	   FORWARD[FIRST_NAME]="$(JsonDecode "${UPD["result",${num},"message","forward_from","first_name"]}")"
	   FORWARD[LAST_NAME]="$(JsonDecode "${UPD["result",${num},"message","forward_from","last_name"]}")"
	   FORWARD[USERNAME]="$(JsonDecode "${UPD["result",${num},"message","forward_from","username"]}")"
	fi

	# get file URL from telegram, check for any of them!
	if grep -qs -e '\["result",'"${num}"',"message","[avpsd].*,"file_id"\]' <<<"${UPDATE}"; then
	    URLS[AUDIO]="$(get_file "${UPD["result",${num},"message","audio","file_id"]}")"
	    URLS[DOCUMENT]="$(get_file "${UPD["result",${num},"message","document","file_id"]}")"
	    URLS[PHOTO]="$(get_file "${UPD["result",${num},"message","photo",0,"file_id"]}")"
	    URLS[STICKER]="$(get_file "${UPD["result",${num},"message","sticker","file_id"]}")"
	    URLS[VIDEO]="$(get_file "${UPD["result",${num},"message","video","file_id"]}")"
	    URLS[VOICE]="$(get_file "${UPD["result",${num},"message","voice","file_id"]}")"
	fi
	# Contact, must have phone_number
	if [ -n "${UPD["result",${num},"message","contact","phone_number"]}" ]; then
		CONTACT[USER_ID]="$(JsonDecode  "${UPD["result",${num},"message","contact","user_id"]}")"
		CONTACT[FIRST_NAME]="$(JsonDecode "${UPD["result",${num},"message","contact","first_name"]}")"
		CONTACT[LAST_NAME]="$(JsonDecode "${UPD["result",${num},"message","contact","last_name"]}")"
		CONTACT[NUMBER]="${UPD["result",${num},"message","contact","phone_number"]}"
		CONTACT[VCARD]="$(JsonGetString '"result",'"${num}"',"message","contact","vcard"' <<<"${UPDATE}")"
	fi

	# venue, must have a position
	if [ -n "${UPD["result",${num},"message","venue","location","longitude"]}" ]; then
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

	# service messages, group or channel only!
	if [[ "${CHAT[ID]}" == "-"* ]] ; then
	    # new chat member
	    if [ -n "${UPD["result",${num},"message","new_chat_member","id"]}" ]; then
		SERVICE[NEWMEMBER]="${UPD["result",${num},"message","new_chat_member","id"]}"
		NEWMEMBER[ID]="${SERVICE[NEWMEMBER]}"
		NEWMEMBER[FIRST_NAME]="$(JsonDecode "${UPD["result",${num},"message","new_chat_member","first_name"]}")"
		NEWMEMBER[LAST_NAME]="$(JsonDecode "${UPD["result",${num},"message","new_chat_member","last_name"]}")"
		NEWMEMBER[USERNAME]="$(JsonDecode "${UPD["result",${num},"message","new_chat_member","username"]}")"
		NEWMEMBER[ISBOT]="${UPD["result",${num},"message","new_chat_member","is_bot"]}"
		[ -z "${MESSAGE[0]}" ] &&\
		MESSAGE[0]="/_new_chat_member ${NEWMEMBER[ID]} ${NEWMEMBER[USERNAME]:=${NEWMEMBER[FIRST_NAME]} ${NEWMEMBER[LAST_NAME]}}"
	    fi
	    # left chat member
	    if [ -n "${UPD["result",${num},"message","left_chat_member","id"]}" ]; then
		SERVICE[LEFTMEMBER]="${UPD["result",${num},"message","left_chat_member","id"]}"
		LEFTMEMBER[ID]="${SERVICE[LEFTMEBER]}"
		LEFTMEMBER[FIRST_NAME]="$(JsonDecode "${UPD["result",${num},"message","left_chat_member","first_name"]}")"
		LEFTMEMBER[LAST_NAME]="$(JsonDecode "${UPD["result",${num},"message","left_chat_member","last_name"]}")"
		LEFTMEBER[USERNAME]="$(JsonDecode "${UPD["result",${num},"message","left_chat_member","username"]}")"
		LEFTMEMBER[ISBOT]="${UPD["result",${num},"message","left_chat_member","is_bot"]}"
		[ -z "${MESSAGE[0]}" ] &&\
		MESSAGE[0]="/_left_chat_member ${LEFTMEMBER[ID]} ${LEFTMEMBER[USERNAME]:=${LEFTMEMBER[FIRST_NAME]} ${LEFTMEMBER[LAST_NAME]}}"
	    fi
	    # chat title / photo, check for any of them!
	    if grep -qs -e '\["result",'"${num}"',"message","new_chat_[tp]' <<<"${UPDATE}"; then
		SERVICE[NEWTITLE]="$(JsonDecode "${UPD["result",${num},"message","new_chat_title"]}")"
		[ -z "${MESSAGE[0]}" ] && [ -n "${SERVICE[NEWTITLE]}" ] &&\
			MESSAGE[0]="/_new_chat_title ${USER[ID]} ${SERVICE[NEWTITLE]}"
		SERVICE[NEWPHOTO]="$(get_file "${UPD["result",${num},"message","new_chat_photo",0,"file_id"]}")"
		[ -z "${MESSAGE[0]}" ] && [ -n "${SERVICE[NEWPHOTO]}" ] &&\
			 MESSAGE[0]="/_new_chat_photo ${USER[ID]} ${SERVICE[NEWPHOTO]}"
	    fi
	    # pinned message
	    if [ -n "${UPD["result",${num},"message","pinned_message","message_id"]}" ]; then
		SERVICE[PINNED]="${UPD["result",${num},"message","pinned_message","message_id"]}"
		PINNED[ID]="${SERVICE[PINNED]}"
		PINNED[MESSAGE]="$(JsonDecode "${UPD["result",${num},"message","pinned_message","text"]}")"
		[ -z "${MESSAGE[0]}" ] &&\
			MESSAGE[0]="/_new_pinned_message ${USER[ID]} ${PINNED[ID]} ${PINNED[MESSAGE]}"
	    fi
	    # migrate to super group
	    if [ -n "${UPD["result",${num},"message","migrate_to_chat_id"]}" ]; then
		MIGRATE[TO]="${UPD["result",${num},"message","migrate_to_chat_id"]}"
		MIGRATE[FROM]="${UPD["result",${num},"message","migrate_from_chat_id"]}"
		SERVICE[MIGRATE]="${MIGRATE[FROM]} ${MIGRATE[TO]}"
		[ -z "${MESSAGE[0]}" ] &&\
			MESSAGE[0]="/_migrate_group ${SERVICE[MIGRATE]}"
	    fi
	    # set SERVICE to yes if a service message was received
	    [[ "${SERVICE[*]}" =~  ^[[:blank:]]*$ ]] || SERVICE[0]="yes"
	fi

	# split message in command and args
	[[ "${MESSAGE[0]}" == "/"* ]] && read -r CMD <<<"${MESSAGE[0]}" &&  CMD[0]="${CMD[0]%%@*}"
	# everything went well
	return 0
}

#########################
# main get updates loop, should never terminate
declare -A BASHBOTBLOCKED
export BASHBOT_UPDATELOG="${BASHBOT_UPDATELOG-nolog}" # allow to be ""
start_bot() {
	local DEBUGMSG OFFSET=0
	# adaptive sleep defaults
	local nextsleep="100"
	local stepsleep="${BASHBOT_SLEEP_STEP:-100}"
	local maxsleep="${BASHBOT_SLEEP:-5000}"
	# startup message
	DEBUGMSG="Start BASHBOT updates in Mode \"${1:-normal}\" =========="
	log_update "${DEBUGMSG}"
	# redirect to Debug.log
	[[ "${1}" == *"debug" ]] && exec &>>"${DEBUGLOG}"
	log_debug "${DEBUGMSG}"; DEBUGMSG="${1}"
	[[ "${DEBUGMSG}" == "xdebug"* ]] && set -x && unset BASHBOT_UPDATELOG
	# cleaup old pipes and empty logfiles
	find "${DATADIR}" -type p -delete
	find "${DATADIR}" -size 0 -name "*.log" -delete
	# load addons on startup
	for addons in "${ADDONDIR:-.}"/*.sh ; do
		# shellcheck source=./modules/aliases.sh
		[ -r "${addons}" ] && source "${addons}" "startbot" "${DEBUGMSG}"
	done
	# shellcheck source=./commands.sh
	source "${COMMANDS}" "startbot"
	# start timer events
	if [ -n "${BASHBOT_START_TIMER}" ] ; then
		# shellcheck disable=SC2064
		trap "event_timer $DEBUGMSG" ALRM
		start_timer &
		# shellcheck disable=SC2064
		trap "kill -9 $!; exit" EXIT INT HUP TERM QUIT 
	fi
	# cleanup countfile on startup
	jssh_deleteKeyDB "CLEAN_COUNTER_DATABASE_ON_STARTUP" "${COUNTFILE}"
        [ -f "${COUNTFILE}.jssh.flock" ] && rm -f "${COUNTFILE}.jssh.flock"
	# store start time and cleanup botconfig on startup
	jssh_updateKeyDB "startup" "$(date)" "${BOTCONFIG}"
        [ -f "${BOTCONFIG}.jssh.flock" ] && rm -f "${BOTCONFIG}.jssh.flock"
	# read blocked users
	jssh_readDB_async "BASHBOTBLOCKED" "${BLOCKEDFILE}"
	# inform botadmin about start
	send_normal_message "$(getConfigKey "botadmin")" "Bot $(getConfigKey "botname") started ..." &
	##########
	# bot is ready, start processing updates ...
	while true; do
		# adaptive sleep in ms rounded to next 0.1 s
		sleep "$(_round_float "${nextsleep}e-3" "1")"
		# get next update
		UPDATE="$(getJson "${UPD_URL}${OFFSET}" "${BASHBOT_UPDATELOG}" 2>/dev/null | "${JSONSHFILE}" -b -n 2>/dev/null | iconv -f utf-8 -t utf-8 -c)"
		# did we get an response?
		if [ -n "${UPDATE}" ]; then
			# we got something, do processing
			[ "${OFFSET}" = "-999" ] && [ "${nextsleep}" -gt "$((maxsleep*2))" ] &&\
				log_error "Recovered from timeout/broken/no connection, continue with telegram updates"
			# escape bash $ expansion bug
			((nextsleep+= stepsleep , nextsleep= nextsleep>maxsleep ?maxsleep:nextsleep))
			UPDATE="${UPDATE//$/\\$}"
			# Offset
			OFFSET="$(grep <<< "${UPDATE}" '\["result",[0-9]*,"update_id"\]' | tail -1 | cut -f 2)"
			((OFFSET++))

			if [ "$OFFSET" != "1" ]; then
				nextsleep="100"
				process_updates "${DEBUGMSG}"
			fi
		else
			# oops, something bad happened, wait maxsleep*10
			(( nextsleep=nextsleep*2 , nextsleep= nextsleep>maxsleep*10 ?maxsleep*10:nextsleep ))
			# second time, report problem
			if [ "${OFFSET}" = "-999" ]; then
			    log_error "Repeated timeout/broken/no connection on telegram update, sleep $(_round_float "${nextsleep}e-3")s"
			    # try to recover
			    if _is_function bashbotBlockRecover && [ -z "$(getJson "${ME_URL}")" ]; then
				log_error "Try to recover, calling bashbotBlockRecover ..."
				bashbotBlockRecover >>"${ERRORLOG}"
			    fi
			fi
			OFFSET="-999"
		fi
	done
}

# initialize bot environment, user and permissions
bot_init() {
	[ -n "${BASHBOT_HOME}" ] && cd "${BASHBOT_HOME}" || exit 1
	local DEBUG="$1"
	# upgrade from old version
	# currently no action
	printf "Check for Update actions ...\n"
	printf "Done.\n"
	# load addons on startup
	printf "Initialize modules and addons ...\n"
	for addons in "${ADDONDIR:-.}"/*.sh ; do
		# shellcheck source=./modules/aliases.sh
		[ -r "${addons}" ] && source "${addons}" "init" "${DEBUG}"
	done
	printf "Done.\n"
	# setup bashbot
	[[ "${UID}" -eq "0" ]] && RUNUSER="nobody"
	printf "Enter User to run bashbot [$RUNUSER]: "
	read -r TOUSER
	[ -z "$TOUSER" ] && TOUSER="$RUNUSER"
	if ! id "$TOUSER" &>/dev/null; then
		printf "${RED}User \"$TOUSER\" not found!${NN}"
		exit 3
	else
		printf "Adjusting files and permissions for user \"${TOUSER}\" ...\n"
		[ -w "bashbot.rc" ] && sed -i '/^[# ]*runas=/ s/runas=.*$/runas="'$TOUSER'"/' "bashbot.rc"
		chmod 711 .
		chmod -R o-w ./*
		chmod -R u+w "${COUNTFILE}"* "${BLOCKEDFILE}"* "${DATADIR}" logs "${LOGDIR}/"*.log 2>/dev/null
		chmod -R o-r,o-w "${COUNTFILE}"* "${BLOCKEDFILE}"* "${DATADIR}" "${BOTACL}" 2>/dev/null
		# jsshDB must writeable by owner
		find . -name '*.jssh*' -exec chmod u+w \{\} +
		chown -R "$TOUSER" . ./*
		printf "Done.\n"
	fi
	# ask to check bottoken online
	if [ -z "$(getConfigKey "botid")" ]; then
		printf "Seems to be your first init. Should I verify your bot token online? (y/N) N\b"
		read -r ANSWER
		if [[ "${ANSWER}" =~ ^[Yy] ]]; then
			printf "${GREEN}Contacting telegram to verify your bot token ...${NN}"
			$0 botname
		fi 
	fi
	# check if botconf seems valid
	printf "${GREEN}This is your bot config:${NN}"
	sed 's/^/\t/' "${BOTCONFIG}.jssh" | grep -vF '["bot_config_key"]'
	if check_token "$(getConfigKey "bottoken")" && [[ "$(getConfigKey "botadmin")" =~ ^[0-9]+$ ]]; then
		printf "Bot config seems to be valid. Should I make a backup copy? (Y/n) Y\b"
		read -r ANSWER
		if [[ -z "${ANSWER}" || "${ANSWER}" =~ ^[^Nn] ]]; then
			printf "Copy bot config to ${BOTCONFIG}.jssh.ok ...\n"
			cp "${BOTCONFIG}.jssh" "${BOTCONFIG}.jssh.ok"
		fi 
	else
		printf "${ORANGE}Bot config may incomplete, pls check.${NN}"
	fi
	# show result
	ls -ld "${DATADIR}" "${LOGDIR}" ./*.jssh* ./*.sh 2>/dev/null
}

if ! _is_function send_message ; then
	printf "${RED}ERROR: send_message is not available, did you deactivate ${MODULEDIR}/sendMessage.sh?${NN}"
	exit 1
fi

# check if JSON.awk exist and has x flag
JSONAWKFILE="${JSONSHFILE%.sh}.awk"
if [ -x "${JSONAWKFILE}" ] && _exists awk ; then
	JSONSHFILE="JsonAwk"; JsonAwk() { "${JSONAWKFILE}" -v "BRIEF=8" -v "STRICT=0" -; }
fi

# source the script with source as param to use functions in other scripts
# do not execute if read from other scripts

if [ -z "${SOURCE}" ]; then
  ##############
  # internal options only for use from bashbot and developers
  # shellcheck disable=SC2221,SC2222
  case "${1}" in
	# update botname when starting only
	"botname"|"start"*)
		ME="$(getBotName)"
		if [ -n "${ME}" ]; then
			# ok we have a connection and got botname, save it
			[ -n "${INTERACTIVE}" ] && printf "${GREY}Bottoken is valid ...${NN}"
			jssh_updateKeyDB "botname" "${ME}" "${BOTCONFIG}"
			rm -f "${BOTCONFIG}.jssh.flock"
		else
			printf "${GREY}Info: Can't get Botname from Telegram, try cached one ...${NN}"
			ME="$(getConfigKey "botname")"
			if [ -z "$ME" ]; then
			    printf "${RED}ERROR: No cached botname, can't continue! ...${NN}"
			    exit 1
			fi
		fi
		[ -n "${INTERACTIVE}" ] && printf "Bot Name: %s\n" "${ME}"
		[ "$1" = "botname" ] && exit
		;;&
	# used to send output of background and interactive to chats
	"outproc") # $2 chat_id $3 identifier of job, internal use only!
		[ -z "$3" ] && printf "No job identifier\n" && exit 3
		[ -z "$2"  ] && printf "No chat to send to\n" && exit 3
		ME="$(getConfigKey "botname")"
		# read until terminated
		while read -r line ;do
			[ -n "$line" ] && send_message "$2" "$line"
		done 
		# cleanup datadir, keep logfile if not empty
		rm -f -r "${DATADIR:-.}/$3"
		[ -s "${DATADIR:-.}/$3.log" ] || rm -f "${DATADIR:-.}/$3.log"
		debug_checks "end outproc" "$@"
		exit
		;;
	# finally starts the read update loop, internal use only1
	"startbot" )
		start_bot "$2"
		debug_checks "end startbot" "$@"
		exit
		;;
	# run after every update to update files and adjust permissions
	"init") 
		bot_init "$2"
		debug_checks "end init" "$@"
		exit
		;;
	# stats deprecated
	"stats"|"count")
		printf "${ORANGE}Stats is a separate command now, see bin/bashbot_stats.sh --help${NN}"
		"${BASHBOT_HOME:-.}"/bin/bashbot_stats.sh --help
		exit
		;;
	# broadcast deprecated
	'broadcast')
		printf "${ORANGE}Broadcast is a separate command now, see bin/send_broadcast.sh --help${NN}"
		"${BASHBOT_HOME:-.}"/bin/send_broadcast.sh --help
		exit
		;;
	# does what it says
	"status")
		ME="$(getConfigKey "botname")"
		SESSION="${ME:-_bot}-startbot"
		BOTPID="$(proclist "${SESSION}")"
		if [ -n "${BOTPID}" ]; then
			printf "${GREEN}Bot is running with UID ${RUNUSER}.${NN}"
			exit
		else
			printf "${ORANGE}No Bot running with UID ${RUNUSER}.${NN}"
			exit 5
		fi
		debug_checks "end status" "$@"
		;;
		 
	# start bot as background job and check if bot is running
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
		 	printf "${GREEN}Bot started successfully.${NN}"
		else
			printf "${RED}An error occurred while starting the bot.${NN}"
			exit 5
		fi
		debug_checks "end start" "$@"
		;;
	# does what it says
	"stop")
		ME="$(getConfigKey "botname")"
		SESSION="${ME:-_bot}-startbot"
		BOTPID="$(proclist "${SESSION}")"
		if [ -n "${BOTPID}" ]; then
			# shellcheck disable=SC2086
			if kill ${BOTPID}; then
				# inform botadmin about stop
				send_normal_message "$(getConfigKey "botadmin")" "Bot ${ME} stopped ..." &
				printf "${GREEN}OK. Bot stopped successfully.${NN}"
			else
				printf "${RED}An error occurred while stopping bot.${NN}"
				exit 5
			fi
		else
			printf "${ORANGE}No Bot running with UID ${RUNUSER}.${NN}"
		fi
		debug_checks "end stop" "$@"
		exit
		;;
	# suspend, resume or kill background jobs
	"suspendb"*|"resumeb"*|"killb"*)
  		_is_function job_control || { printf "${RED}Module background is not available!${NN}"; exit 3; }
		ME="$(getConfigKey "botname")"
		job_control "$1"
		debug_checks "end background $1" "$@"
		;;
	*)
		printf "${RED}${REALME##*/}: unknown command${NN}"
		printf "${RED}Available commands: ${GREY}${BOTCOMMANDS}${NN}" && exit
		exit 4
		;;
  esac

  # warn if root
  if [[ "${UID}" -eq "0" ]] ; then
	printf "\\n${ORANGE}WARNING: ${SCRIPT} was started as ROOT (UID 0)!${NN}"
	printf "${ORANGE}You are at HIGH RISK when running a Telegram BOT with root privileges!${NN}"
  fi
fi # end source
