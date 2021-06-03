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
# Usage: bashbot.sh BOTCOMMAND
BOTCOMMANDS="-h  help  init  start  stop  status  suspendback  resumeback  killback"
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
#### $$VERSION$$ v1.51-0-g6e66a28
##################################################################

# are we running in a terminal?
NN="\n"
if [ -t 1 ] && [ -n "${TERM}" ];  then
    INTERACTIVE='yes'
    RED='\e[31m'
    GREEN='\e[32m'
    ORANGE='\e[35m'
    GREY='\e[1;30m'
    NC='\e[0m'
    NN="${NC}\n"
fi
declare -r INTERACTIVE RED GREEN ORANGE GREY NC NN

# telegram uses utf-8 characters, check if we have an utf-8 charset
if [ "${LANG}" = "${LANG%[Uu][Tt][Ff]*}" ]; then
	printf "${ORANGE}Warning: Telegram uses utf-8, but looks like you are using non utf-8 locale:${NC} ${LANG}\n"
fi

# we need some bash 4+ features, check for old bash by feature
if [ "$({ LC_ALL=C.utf-8 printf "%b" "\u1111"; } 2>/dev/null)" = "\u1111" ]; then
	printf "${ORANGE}Warning: Missing unicode '\uxxxx' support, missing C.utf-8 locale or to old bash version.${NN}"
fi


# in UTF-8 äöü etc. are part of [:alnum:] and ranges (e.g. a-z), but we want ASCII a-z ranges!
# for more information see  doc/4_expert.md#Character_classes
azazaz='abcdefghijklmnopqrstuvwxyz'	# a-z   :lower:
AZAZAZ='ABCDEFGHIJKLMNOPQRSTUVWXYZ'	# A-Z   :upper:
o9o9o9='0123456789'			# 0-9   :digit:
azAZaz="${azazaz}${AZAZAZ}"	# a-zA-Z	:alpha:
azAZo9="${azAZaz}${o9o9o9}"	# a-zA-z0-9	:alnum:

# some important helper functions
# returns true if command exist
_exists() {
	[ "$(type -t "$1")" = "file" ]
}
# execute function if exists
_exec_if_function() {
	[ "$(type -t "$1")" != "function" ] && return 1
	"$@"
}
# returns true if function exist
_is_function() {
	[ "$(type -t "$1")" = "function" ]
}
# round $1 in international notation! , returns float with $2 decimal digits
# if $2 is not given or is not a positive number zero is assumed
_round_float() {
	local digit="$2"; [[ "$2" =~ ^[${o9o9o9}]+$ ]] || digit="0"
	: "$(LC_ALL=C printf "%.${digit}f" "$1" 2>/dev/null)"
	printf "%s" "${_//,/.}"	# make more LANG independent
}
# date is external, printf is much faster
_date(){
	printf "%(%c)T\n" -1
}
setConfigKey() {
	[[ "$1" =~ ^[-${azAZo9},._]+$ ]] || return 3
	[ -z "${BOTCONFIG}" ] && return 1
	printf '["%s"]\t"%s"\n' "${1//,/\",\"}" "${2//\"/\\\"}" >>"${BOTCONFIG}.jssh"
}
getConfigKey() {
	[[ "$1" =~ ^[-${azAZo9},._]+$ ]] || return 3
	[ -r "${BOTCONFIG}.jssh" ] && sed -n 's/\["'"$1"'"\]\t*"\(.*\)"/\1/p' "${BOTCONFIG}.jssh" | tail -n 1
}
# escape characters in json strings for telegram 
# $1 string, output escaped string
JsonEscape(){
	sed -E -e 's/\r//g' -e 's/([-"`´,§$%&/(){}#@!?*.\t])/\\\1/g' <<< "${1//$'\n'/\\n}"
}
# clean \ from escaped json string
# $1 string, output cleaned string
cleanEscape(){	# remove "	all \ but  \n\u		\n or \r
	sed -E -e 's/\\"/+/g' -e 's/\\([^nu])/\1/g' -e 's/(\r|\n)//g' <<<"$1"
}
# check if $1 seems a valid token
# return true if token seems to be valid
check_token(){
	[[ "$1" =~ ^[${o9o9o9}]{8,10}:[${azAZo9}_-]{35}$ ]] && return 0
	return 1
}
# log $1 with date
log_error(){ printf "%(%c)T: %s\n" -1 "$*" >>"${ERRORLOG}"; }
log_debug(){ printf "%(%c)T: %s\n" -1 "$*" >>"${DEBUGLOG}"; }
log_update(){ printf "%(%c)T: %s\n" -1 "$*" >>"${UPDATELOG}"; }
# log $1 with date, special first \n
log_message(){ printf "\n%(%c)T: %s\n" -1 "${1/\\n/$'\n'}" >>"${MESSAGELOG}"; }
# curl is preferred, try detect curl even not in PATH
# sets BASHBOT_CURL to point to curl
DETECTED_CURL="curl"
detect_curl() {
	local file warn="Warning: Curl not detected, try fallback to wget! pls install curl or adjust BASHBOT_CURL/BASHBOT_WGET environment variables."
	# custom curl command
	[ -n "${BASHBOT_CURL}" ] && return 0
	# use wget
	[ -n "${BASHBOT_WGET}" ] && DETECTED_CURL="wget" && return 1
	# default use curl in PATH
	BASHBOT_CURL="curl"
	_exists curl && return 0
	# search in usual locations
	for file in /usr/bin /bin /usr/local/bin; do
		[ -x "${file}/curl" ] && BASHBOT_CURL="${file}/curl" && return 0
	done
	# curl not in PATH and not in usual locations
	DETECTED_CURL="wget"
	log_update "${warn}"; [ -n "${BASHBOTDEBUG}" ] && log_debug "${warn}"
	return 1
}

# additional tests if we run in debug mode
export BASHBOTDEBUG
[[ "${BASH_ARGV[0]}" == *"debug"* ]] && BASHBOTDEBUG="yes"

# $1 where $2 command $3 may debug 
# shellcheck disable=SC2094
debug_checks(){ {
	[  -z "${BASHBOTDEBUG}" ] && return
	local token where="$1"; shift
	printf "%(%c)T: debug_checks: %s: bashbot.sh %s\n" -1 "${where}" "${1##*/}"
	# shellcheck disable=SC2094
	[ -z "${DEBUGLOG}" ] && printf "%(%c)T: %s\n" -1 "DEBUGLOG not set! =========="
	token="$(getConfigKey "bottoken")"
	[ -z "${token}" ] && printf "%(%c)T: %s\n" -1 "Bot token is missing! =========="
	check_token "${token}" || printf "%(%c)T: %s\n%s\n" -1 "Invalid bot token! ==========" "${token}"
	[ -z "$(getConfigKey "botadmin")" ] && printf "%(%c)T: %s\n" -1 "Bot admin is missing! =========="
	# call user defined debug_checks if exists
	_exec_if_function my_debug_checks "$(_date)" "${where}" "$*"
	} 2>/dev/null >>"${DEBUGLOG}"
}

# some Linux distributions (e.g. Manjaro) doesn't seem to have C locale activated by default
if _exists locale && [ "$(locale -a | grep -c -e "^C$" -e "^C.[uU][tT][fF]")" -lt 2 ]; then
	printf "${ORANGE}Warning: locale ${NC}${GREY}C${NC}${ORANGE} and/or ${NC}${GREY}C.utf8${NC}${ORANGE} seems missing, use \"${NC}${GREY}locale -a${NC}${ORANGE}\" to show what locales are installed on your system.${NN}"
fi

# get location and name of bashbot.sh
SCRIPT="$0"
REALME="${BASH_SOURCE[0]}"
SCRIPTDIR="$(dirname "${REALME}")"
RUNDIR="$(dirname "$0")"

MODULEDIR="${SCRIPTDIR}/modules"

# adjust stuff for source, use return from source without source
exit_source() { exit "$1"; }
if [[ "${SCRIPT}" != "${REALME}" || "$1" == "source" ]]; then
	SOURCE="yes"
	SCRIPT="${REALME}"
	[ -z "$1" ] && exit_source() { printf "Exit from source ...\n"; return "$1"; }
fi

# emmbeded system may claim bash but it is not
# check for bash like ARRAY handlung
if ! (unset a; set -A a a; eval "a=(a b)"; eval '[ -n "${a[1]}" ]'; ) > /dev/null 2>&1; then
	printf "Error: Current shell does not support ARRAY's, may be busybox ash shell. pls install a real bash!\n"
	exit_source 10
fi

# adjust path variables
if [ -n "${BASHBOT_HOME}" ]; then
	SCRIPTDIR="${BASHBOT_HOME}"
 else
	BASHBOT_HOME="${SCRIPTDIR}"
fi
[ -z "${BASHBOT_ETC}" ] && BASHBOT_ETC="${BASHBOT_HOME}"
[ -z "${BASHBOT_VAR}" ] && BASHBOT_VAR="${BASHBOT_HOME}"

ADDONDIR="${BASHBOT_ETC:-.}/addons"
RUNUSER="${USER}"	# save original USER

# provide help
case "$1" in
	"") [ -z "${SOURCE}" ] && printf "${ORANGE}Available commands: ${GREY}${BOTCOMMANDS}${NN}" && exit
		;;
	"-h"*)	LOGO="${BASHBOT_HOME:-.}/doc/bashbot.ascii"
		{ [ -r "${LOGO}" ] && cat "${LOGO}"
		sed -nE -e '/(NOT EDIT)|(shellcheck)/d' -e '3,/###/p' "$0"; } | more
		exit;;
	"help") HELP="${BASHBOT_HOME:-.}/README"
		if [ -n "${INTERACTIVE}" ];then
			_exists w3m && w3m "${HELP}.html" && exit
			_exists lynx && lynx "${HELP}.html" && exit
			_exists less && less "${HELP}.txt" && exit
		fi
		cat "${HELP}.txt"
		exit;;
esac

# OK, ENVIRONMENT is set up, let's do some additional tests
if [[ -z "${SOURCE}" && -z "${BASHBOT_HOME}" ]] && ! cd "${RUNDIR}" ; then
	printf "${RED}ERROR: Can't change to ${RUNDIR} ...${NN}"
	exit_source 1
fi
RUNDIR="."
[ ! -w "." ] && printf "${ORANGE}WARNING: ${RUNDIR} is not writeable!${NN}"

# check if JSON.sh is available
JSONSHFILE="${BASHBOT_JSONSH:-${SCRIPTDIR}/JSON.sh/JSON.sh}"
if [ ! -x "${JSONSHFILE}" ]; then
	printf "${RED}ERROR:${NC} ${JSONSHFILE} ${RED}does not exist, are we in dev environment?${NN}${GREY}%s${NN}\n"\
		"\$JSONSHFILE is set wrong or bashbot is not installed correctly, see doc/0_install.md"
	exit_source 3
fi

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
	[ "$1" != "init" ] && exit_source 2 # skip on init
  fi
  # setup count file 
  if [ ! -f "${COUNTFILE}.jssh" ]; then
	printf '["counted_user_chat_id"]\t"num_messages_seen"\n' >> "${COUNTFILE}.jssh"
  elif [ ! -w "${COUNTFILE}.jssh" ]; then
	printf "${RED}WARNING: Can't write to ${COUNTFILE}!.${NN}"
	ls -l "${COUNTFILE}.jssh"
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
			exit_source 7
		fi
    fi
fi

# BOTTOKEN format checks
if ! check_token "${BOTTOKEN}"; then
	printf "\n${ORANGE}Warning: Your bot token is incorrect, it should have the following format:${NC}\n%b%b"\
		"<your_bot_id>${RED}:${NC}<35_alphanumeric_characters-hash> ${RED}e.g. =>${NC} 123456789${RED}:${NC}Aa-Zz_0Aa-Zz_1Aa-Zz_2Aa-Zz_3Aa-Zz_4\n\n"\
		"${GREY}Your bot token: '${NC}${BOTTOKEN//:/${RED}:${NC}}'\n"

	if [[ ! "${BOTTOKEN}" =~ ^[${o9o9o9}]{8,10}: ]]; then
		printf "${GREY}\tHint: Bot id not a number or wrong len: ${NC}$(($(wc -c <<<"${BOTTOKEN%:*}")-1)) ${GREY}but should be${NC} 8-10\n"
		[ -n "$(getConfigKey "botid")" ] && printf "\t${GREEN}Did you mean: \"${NC}$(getConfigKey "botid")${GREEN}\" ?${NN}"
	fi
	[[ ! "${BOTTOKEN}" =~ :[${azAZo9}_-]{35}$ ]] &&\
		printf "${GREY}\tHint: Hash contains invalid character or has not len${NC} 35 ${GREY}, hash len is ${NC}$(($(wc -c <<<"${BOTTOKEN#*:}")-1))\n"
	printf "\n"
fi


##################
# here we start with the real stuff
BASHBOT_RETRY=""	# retry by default

URL="${BASHBOT_URL:-https://api.telegram.org/bot}${BOTTOKEN}"
FILEURL="${URL%%/bot*}/file/bot${BOTTOKEN}"
ME_URL=${URL}'/getMe'

#################
# BASHBOT COMMON functions

declare -rx SCRIPT SCRIPTDIR MODULEDIR RUNDIR ADDONDIR BOTACL DATADIR COUNTFILE
declare -rx BOTTOKEN URL ME_URL

declare -ax CMD
declare -Ax UPD BOTSENT USER MESSAGE URLS CONTACT LOCATION CHAT FORWARD REPLYTO VENUE iQUERY iBUTTON
declare -Ax SERVICE NEWMEMBER LEFTMEMBER PINNED MIGRATE
export res CAPTION ME BOTADMIN


###############
# load modules
for module in "${MODULEDIR:-.}"/*.sh ; do
	# shellcheck source=./modules/aliases.sh
	if ! _is_function "$(basename "${module}")" && [ -r "${module}" ]; then source "${module}" "source"; fi
done

##################
# read commands file if we are not sourced
COMMANDS="${BASHBOT_ETC:-.}/commands.sh"
if [  -r "${COMMANDS}" ]; then
	# shellcheck source=./commands.sh
	 source "${COMMANDS}" "source"
else
	[ -z "${SOURCE}" ] && printf "${RED}Warning: ${COMMANDS} does not exist or is not readable!.${NN}"
fi
# no debug checks on source
[ -z "${SOURCE}" ] && debug_checks "start" "$@"


#####################
# BASHBOT INTERNAL functions
#

# do we have BSD sed
sed '1ia' </dev/null 2>/dev/null || printf "${ORANGE}Warning: You may run on a BSD style system without gnu utils ...${NN}"
#jsonDB is now mandatory
if ! _is_function jssh_newDB; then
	printf "${RED}ERROR: Mandatory module jsonDB is missing or not readable!${NN}"
	exit_source 6
fi

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
	debug_checks "end killallproc" "$1"
}

# URL path for file id, $1 file_id
# use download_file "path" to  download file
get_file() {
	[ -z "$1" ] && return
	sendJson ""  '"file_id": "'"$1"'"' "${URL}/getFile"
	printf "%s\n" "${UPD["result,file_path"]}"
}
# download file to DATADIR
# $1 URL path, $2 proposed filename (may modified/ignored)
# outputs final filename
# keep old function name for backward compatibility
alias download="download_file"
download_file() {
	local url="$1" file="${2:-$1}"
	# old mode if full URL is given
	if [[  "${1}" =~ ^https*:// ]]; then
	   # random filename if not given for http
	   if [ -z "$2" ]; then
		: "$(mktemp -u  -p . "XXXXXXXXXX" 2>/dev/null)"
		file="download-${_#./}"
	  fi
	else
		# prefix https://api.telegram...
		url="${FILEURL}/${url}"
	fi
	# filename: replace "/" with "-", use mktemp if exist
	file="${DATADIR:-.}/${file//\//-}"
	[ -f "${file}" ] && file="$(mktemp -p "${DATADIR:-.}" "XXXXX-${file##*/}" )"
	getJson "${url}" >"${file}" || return
	# output absolute file path
	printf "%s\n" "$(cd "${file%/*}" >/dev/null 2>&1 && pwd)/${file##*/}"
}
# notify mycommands about errors while sending
# $1 calling function  $2 error $3 chat $4 user $5 error message $6 ... remaining args to calling function
# calls function based on error: bashbotError{function} basbotError{error}
# if no specific function exist try to call bashbotProcessError
processError(){
	local func="$1" err="$2"
	[[ "${err}" != "4"* ]] && return 1
	# check for bashbotError${func} provided in mycommands
	# shellcheck disable=SC2082
	if _is_function "bashbotError_${func}"; then 
		"bashbotError_${func}" "$@"
	# check for bashbotError${err} provided in mycommands
	elif _is_function "bashbotError_${err}"; then 
		"bashbotError_${err}" "$@"
	# noting found, try bashbotProcessError
	else
		_exec_if_function bashbotProcessError "$@"
	fi
}

# iconv used to filter out broken utf characters, if not installed fake it
if ! _exists iconv; then
	log_update "Warning: iconv not installed, pls imstall iconv!"
	function iconv() { cat; }
fi

TIMEOUT="${BASHBOT_TIMEOUT:-20}"
[[ "${TIMEOUT}" =~ ^[${o9o9o9}]+$ ]] || TIMEOUT="20"

# usage: sendJson "chat" "JSON" "URL"
sendJson(){
	local json chat=""
	if [ -n "$1" ]; then
		 chat='"chat_id":'"$1"','
		 [[ "$1" == *[!${o9o9o9}-]* ]] && chat='"chat_id":"'"$1"' NAN",'	# chat id not a number!
	fi
	# compose final json
	json='{'"${chat} $(iconv -f utf-8 -t utf-8 -c <<<"$2")"'}'
	if [ -n "${BASHBOTDEBUG}" ] ; then
		log_update "sendJson (${DETECTED_CURL}) CHAT=${chat#*:} JSON=$(cleanEscape "${json:0:100}") URL=${3##*/}"
		log_message "DEBUG sendJson ==========\n$("${JSONSHFILE}" -b -n  <<<"$(cleanEscape "${json}")" 2>&1)"
	fi
	# chat id not a number
	if [[ "${chat}" == *"NAN\"," ]]; then
		sendJsonResult "$(printf '["ok"]\tfalse\n["error_code"]\t400\n["description"]\t"Bad Request: chat id not a number"\n')"\
			"sendJson (NAN)" "$@"
		return
	fi
	# OK here we go ...
	# route to curl/wget specific function
	res="$(sendJson_do "${json}" "$3")"
	# check telegram response
	sendJsonResult "${res}" "sendJson (${DETECTED_CURL})" "$@"
	[ -n "${BASHBOT_EVENT_SEND[*]}" ] && event_send "send" "${@}" &
}

UPLOADDIR="${BASHBOT_UPLOAD:-${DATADIR}/upload}"

# $1 chat $2 file, $3 calling function
# return final file name or empty string on error
checkUploadFile() {
	local err file="$2"
	[[ "${file}" == *'..'* || "${file}" == '.'* ]] && err=1 	# no directory traversal
	if [[ "${file}" == '/'* ]] ; then
		[[ ! "${file}" =~ ${FILE_REGEX} ]] && err=2	# absolute must match REGEX
	else
		file="${UPLOADDIR:-NOUPLOADDIR}/${file}"	# others must be in UPLOADDIR
	fi
	[ ! -r "${file}" ] && err=3	# and file must exits of course
	# file path error, generate error response
	if [ -n "${err}" ]; then
	    BOTSENT=(); BOTSENT[OK]="false"
	    case "${err}" in
		1) BOTSENT[ERROR]="Path to file $2 contains to much '../' or starts with '.'";;
		2) BOTSENT[ERROR]="Path to file $2 does not match regex: ${FILE_REGEX} ";;
		3) if [[ "$2" == "/"* ]];then
			BOTSENT[ERROR]="File not found: $2"
		   else
			BOTSENT[ERROR]="File not found: ${UPLOADDIR}/$2"
		   fi;;
	    esac
	    [ -n "${BASHBOTDEBUG}" ] && log_debug "$3: CHAT=$1 FILE=$2 MSG=${BOTSENT[DESCRIPTION]}"
	    return 1
	fi
	printf "%s\n" "${file}"
}


#
# curl / wget specific functions
#
if detect_curl ; then
  # here we have curl ----
  [ -z "${BASHBOT_CURL}" ] && BASHBOT_CURL="curl"
  # $1 URL, $2 hack: log getJson if not ""
  getJson(){
	# shellcheck disable=SC2086
	"${BASHBOT_CURL}" -sL -k ${BASHBOT_CURL_ARGS} -m "${TIMEOUT}" "$1"
  }
  # curl variant for sendJson
  # usage: "JSON" "URL"
  sendJson_do(){
	# shellcheck disable=SC2086
	"${BASHBOT_CURL}" -s -k ${BASHBOT_CURL_ARGS} -m "${TIMEOUT}"\
		-d "$1" -X POST "$2" -H "Content-Type: application/json" | "${JSONSHFILE}" -b -n 2>/dev/null
  }
  #$1 Chat, $2 what, $3 file, $4 URL, $5 caption
  sendUpload() {
	[ "$#" -lt 4  ] && return
	if [ -n "$5" ]; then
		[ -n "${BASHBOTDEBUG}" ] &&\
			log_update "sendUpload CHAT=$1 WHAT=$2  FILE=$3 CAPT=$5"
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
	# shellcheck disable=SC2086
	wget --no-check-certificate -t 2 -T "${TIMEOUT}" ${BASHBOT_WGET_ARGS} -qO - "$1"
    }
    # curl variant for sendJson
    # usage: "JSON" "URL"
    sendJson_do(){
	# shellcheck disable=SC2086
	wget --no-check-certificate -t 2 -T "${TIMEOUT}" ${BASHBOT_WGET_ARGS} -qO - --post-data="$1" \
		--header='Content-Type:application/json' "$2" | "${JSONSHFILE}" -b -n 2>/dev/null
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
	exit_source 8
  fi
fi 

# retry sendJson
# $1 function $2 sleep $3 ... $n arguments
sendJsonRetry(){
	local retry="$1"; shift
	[[ "$1" =~ ^\ *[${o9o9o9}.]+\ *$ ]] && sleep "$1"; shift
	printf "%(%c)T: RETRY %s %s %s\n" -1 "${retry}" "$1" "${2:0:60}"
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
	[ "${BOTSENT[OK]}" = "true" ] && log_error "Retry OK:${retry} $1 ${2:0:60}"
} >>"${ERRORLOG}"

# process sendJson result
# stdout is written to ERROR.log
# $1 result $2 function $3 .. $n original arguments, $3 is Chat_id
sendJsonResult(){
	local offset=0
	BOTSENT=( )
	Json2Array 'UPD' <<<"$1"
	[ -n "${BASHBOTDEBUG}" ] && log_message "New Result ==========\n$1"
	BOTSENT[OK]="${UPD["ok"]}"
	if [ "${BOTSENT[OK]}" = "true" ]; then
		BOTSENT[ID]="${UPD["result,message_id"]}"
		BOTSENT[CHAT]="${UPD["result,chat,id"]}"
		[ -n "${UPD["result"]}" ] && BOTSENT[RESULT]="${UPD["result"]}"
		return
		# hot path everything OK!
	else
	    # oops something went wrong!
	    if [ -n "$1" ]; then
			BOTSENT[ERROR]="${UPD["error_code"]}"
			BOTSENT[DESCRIPTION]="${UPD["description"]}"
			[ -n "${UPD["parameters,retry_after"]}" ] && BOTSENT[RETRY]="${UPD["parameters,retry_after"]}"
	    else
			BOTSENT[OK]="false"
			BOTSENT[ERROR]="999"
			BOTSENT[DESCRIPTION]="Send to telegram not possible, timeout/broken/no connection"
	    fi
	    # log error
	    [[ "${BOTSENT[ERROR]}" = "400" && "${BOTSENT[DESCRIPTION]}" == *"starting at byte offset"* ]] &&\
			 offset="${BOTSENT[DESCRIPTION]%* }"
	    printf "%(%c)T: RESULT=%s FUNC=%s CHAT[ID]=%s ERROR=%s DESC=%s ACTION=%s\n" -1\
			"${BOTSENT[OK]}"  "$2" "$3" "${BOTSENT[ERROR]}" "${BOTSENT[DESCRIPTION]}" "${4:${offset}:100}"
	    # warm path, do not retry on error, also if we use wegt
	    [ -n "${BASHBOT_RETRY}${BASHBOT_WGET}" ] && return

	    # OK, we can retry sendJson, let's see what's failed
	    # throttled, telegram say we send too many messages
	    if [ -n "${BOTSENT[RETRY]}" ]; then
			BASHBOT_RETRY="$(( ++BOTSENT[RETRY] ))"
			printf "Retry %s in %s seconds ...\n" "$2" "${BASHBOT_RETRY}"
			sendJsonRetry "$2" "${BASHBOT_RETRY}" "${@:3}"
			unset BASHBOT_RETRY
			return
	    fi
	    # timeout, failed connection or blocked
	    if [ "${BOTSENT[ERROR]}" == "999" ];then
		# check if default curl and args are OK
		if ! curl -sL -k -m 2 "${URL}" >/dev/null 2>&1 ; then
			printf "%(%c)T: BASHBOT IP Address seems blocked!\n" -1
			# user provided function to recover or notify block
			if _exec_if_function bashbotBlockRecover; then
				BASHBOT_RETRY="2"
				printf "bashbotBlockRecover returned true, retry %s ...\n" "$2"
				sendJsonRetry "$2" "${BASHBOT_RETRY}" "${@:3}"
				unset BASHBOT_RETRY
			fi
	       # seems not blocked, try if blockrecover and default curl args working
		elif [ -n "${BASHBOT_CURL_ARGS}" ] || [ "${BASHBOT_CURL}" != "curl" ]; then
			printf "Problem with \"%s %s\"? retry %s with default config ...\n"\
				"${BASHBOT_CURL}" "${BASHBOT_CURL_ARGS}" "$2"
			BASHBOT_RETRY="2"; BASHBOT_CURL="curl"; BASHBOT_CURL_ARGS=""
			_exec_if_function bashbotBlockRecover
			sendJsonRetry "$2" "${BASHBOT_RETRY}" "${@:3}"
			unset BASHBOT_RETRY
		fi
		[ -n "${BOTSENT[ERROR]}" ] && processError "$3" "${BOTSENT[ERROR]}" "$4" "" "${BOTSENT[DESCRIPTION]}" "$5" "$6"
	    fi
	fi
} >>"${ERRORLOG}"

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
	Json2Array 'BOTARRAY' <<<"$(getJson "${ME_URL}" | "${JSONSHFILE}" -b -n 2>/dev/null)"
	[ -z "${BOTARRAY["result","username"]}" ] && return 1
	# save botname and id
	setConfigKey "botname" "${BOTARRAY["result","username"]}"
	setConfigKey "botid" "${BOTARRAY["result","id"]}"
	printf "${BOTARRAY["result","username"]}\n"
}

# pure bash implementation, done by KayM (@gnadelwartz)
# see https://stackoverflow.com/a/55666449/9381171
JsonDecode() {
	local remain U out="$1"
	local regexp='(.*)\\u[dD]([0-9a-fA-F]{3})\\u[dD]([0-9a-fA-F]{3})(.*)'
	while [[ "${out}" =~ ${regexp} ]] ; do
	U=$(( ( (0xd${BASH_REMATCH[2]} & 0x3ff) <<10 ) | ( 0xd${BASH_REMATCH[3]} & 0x3ff ) + 0x10000 ))
			remain="$(printf '\\U%8.8x' "${U}")${BASH_REMATCH[4]}${remain}"
			out="${BASH_REMATCH[1]}"
	done
	printf "%b\n" "${out}${remain}"
}


EVENT_SEND="0"
declare -Ax BASHBOT_EVENT_SEND
event_send() {
	# max recursion level 5 to avoid fork bombs
	(( EVENT_SEND++ )); [ "${EVENT_SEND}" -gt "5" ] && return
	# shellcheck disable=SC2153
	for key in "${!BASHBOT_EVENT_SEND[@]}"
	do
		_exec_if_function "${BASHBOT_EVENT_SEND[${key}]}" "$@"
	done
}

# cleanup activities on startup, called from startbot and resume background jobs
# $1 action, timestamp for action is saved in config
bot_cleanup() {
	# cleanup countfile on startup
	jssh_deleteKeyDB "CLEAN_COUNTER_DATABASE_ON_STARTUP" "${COUNTFILE}"
        [ -f "${COUNTFILE}.jssh.flock" ] && rm -f "${COUNTFILE}.jssh.flock"
	# store action time and cleanup botconfig on startup
	[ -n "$1" ] && jssh_updateKeyDB "$1" "$(_date)" "${BOTCONFIG}"
        [ -f "${BOTCONFIG}.jssh.flock" ] && rm -f "${BOTCONFIG}.jssh.flock"
}

# fallback version, full version is in  bin/bashbot_init.in.sh
# initialize bot environment, user and permissions
bot_init() {
	if [ -n "${BASHBOT_HOME}" ] && ! cd "${BASHBOT_HOME}"; then
		 printf "Can't change to BASHBOT_HOME"
		 exit 1
	fi
	# initialize addons
	printf "Initialize addons ...\n"
	for addons in "${ADDONDIR:-.}"/*.sh ; do
		# shellcheck source=./modules/aliases.sh
		[ -r "${addons}" ] && source "${addons}" "init" "$1"
	done
	printf "Done.\n"
	# adjust permissions
	printf "Adjusting files and permissions ...\n"
	chmod 711 .
	chmod -R o-w ./*
	chmod -R u+w "${COUNTFILE}"* "${BLOCKEDFILE}"* "${DATADIR}" logs "${LOGDIR}/"*.log 2>/dev/null
	chmod -R o-r,o-w "${COUNTFILE}"* "${BLOCKEDFILE}"* "${DATADIR}" "${BOTACL}" 2>/dev/null
	# jsshDB must writeable by owner
	find . -name '*.jssh*' -exec chmod u+w \{\} +
	printf "Done.\n"
	_exec_if_function my_init
}

if ! _is_function send_message ; then
	printf "${RED}ERROR: send_message is not available, did you deactivate ${MODULEDIR}/sendMessage.sh?${NN}"
	exit_source 1
fi

# check if JSON.awk exist and has x flag
JSONAWKFILE="${JSONSHFILE%.sh}.awk"
if [ -x "${JSONAWKFILE}" ] && _exists awk ; then
	JSONSHFILE="JsonAwk"; JsonAwk() { "${JSONAWKFILE}" -v "BRIEF=8" -v "STRICT=0" -; }
fi

# source the script with source as param to use functions in other scripts
# do not execute if read from other scripts

BOTADMIN="$(getConfigKey "botadmin")"

if [ -z "${SOURCE}" ]; then
  ##############
  # internal options only for use from bashbot and developers
  # shellcheck disable=SC2221,SC2222
  case "$1" in
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
			if [ -z "${ME}" ]; then
			    printf "${RED}ERROR: No cached botname, can't continue! ...${NN}"
			    exit 1
			fi
		fi
		[ -n "${INTERACTIVE}" ] && printf "Bot Name: %s\n" "${ME}"
		[ "$1" = "botname" ] && exit
		;;&
	# used to send output of background and interactive to chats
	"outproc")	# $2 chat_id $3 identifier of job, internal use only!
		[ -z "$3" ] && printf "No job identifier\n" && exit 3
		[ -z "$2"  ] && printf "No chat to send to\n" && exit 3
		ME="$(getConfigKey "botname")"
		# read until terminated
		while read -r line ;do
			[ -n "${line}" ] && send_message "$2" "${line}"
		done 
		# cleanup datadir, keep logfile if not empty
		rm -f -r "${DATADIR:-.}/$3"
		[ -s "${DATADIR:-.}/$3.log" ] || rm -f "${DATADIR:-.}/$3.log"
		debug_checks "end outproc" "$@"
		exit
		;;
	# finally starts the read update loop, internal use only
	"startbot" )
		_exec_if_function start_bot "$2" "polling mode"
		_exec_if_function get_updates "$2"
		debug_checks "end startbot" "$@"
		exit
		;;
	# run after every update to update files and adjust permissions
	"init") 
		# shellcheck source=./bin/bashbot._init.inc.sh"
		[ -r "${BASHBOT_HOME:-.}/bin/bashbot_init.inc.sh" ] && source "${BASHBOT_HOME:-.}/bin/bashbot_init.inc.sh"
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
		SESSION="${ME:-_bot}-startbot"
		BOTPID="$(proclist "${SESSION}")"
		if _is_function process_update; then 
			# shellcheck disable=SC2086
			[ -n "${BOTPID}" ] && kill ${BOTPID} && printf "${GREY}Stop already running bot ...${NN}"
			nohup "${SCRIPT}" "startbot" "$2" "${SESSION}" &>/dev/null &
			printf "Session Name: %s\n" "${SESSION}"
			sleep 1
		else
			printf "${ORANGE}Update processing disabled, bot can only send messages.${NN}"
			[ -n "${BOTPID}" ] && printf "${ORANGE}Already running bot found ...${NN}"
		fi
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
				send_normal_message "${BOTADMIN}" "Bot ${ME} polling mode stopped ..." &
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
	"suspendb"*|"resumeb"*|'restartb'*|"killb"*)
  		_is_function job_control || { printf "${RED}Module background is not available!${NN}"; exit 3; }
		ME="$(getConfigKey "botname")"
		job_control "$1"
		debug_checks "end background $1" "$@"
		;;
	*)
		printf "${RED}${REALME##*/}: unknown command${NN}"
		printf "${ORANGE}Available commands: ${GREY}${BOTCOMMANDS}${NN}" && exit
		exit 4
		;;
  esac

  # warn if root
  if [[ "${UID}" -eq "0" ]] ; then
	printf "\n${ORANGE}WARNING: ${SCRIPT} was started as ROOT (UID 0)!${NN}"
	printf "${ORANGE}You are at HIGH RISK when running a Telegram BOT with root privileges!${NN}"
  fi
fi # end source
