#!/bin/bash
# file: modules/jsshDB.sh
# do not edit, this file will be overwritten on update

# This file is public domain in the USA and all free countries.
# Elsewhere, consider it to be WTFPLv2. (wtfpl.net/txt/copying)
#
#### $$VERSION$$ v1.51-0-g6e66a28
#
# source from commands.sh to use jsonDB functions
#
# jsonDB provides simple functions to read and store bash Arrays
# from to file in JSON.sh output format, its a simple key/value storage.

# will be automatically sourced from bashbot
# but can be used independent from bashbot also
# e.g. to create scrupts to manage jssh files

# source once magic, function named like file
eval "$(basename "${BASH_SOURCE[0]}")(){ :; }"

# new feature: serialize / atomic operations:
# updates will be done atomic with flock
# flock should flock should be available on all system as its part of busybox
# tinybox

# lockfile filename.flock is persistent and will be testet with flock for active lock (file open)
export JSSHDB_LOCKNAME=".flock"
# an array value containing this string will not saveed to DB (unset)
export JSSHDB_UNSET="99999999999999999999_JSSHDB_UNSET_99999999999999999999"

# in UTF-8 äöü etc. are part of [:alnum:] and ranges (e.g. a-z), but we want ASCII a-z ranges!
# for more information see  doc/4_expert.md#Character_classes
azazaz='abcdefghijklmnopqrstuvwxyz'	# a-z   :lower:
AZAZAZ='ABCDEFGHIJKLMNOPQRSTUVWXYZ'	# A-Z   :upper:
o9o9o9='0123456789'			# 0-9   :digit:
azAZaz="${azazaz}${AZAZAZ}"	# a-zA-Z	:alpha:
azAZo9="${azAZaz}${o9o9o9}"	# a-zA-z0-9	:alnum:

# characters allowed for key in key/value pairs
JSSH_KEYOK="[-${azAZo9},._]"

# read string from stdin and and strip invalid characters
# $1 - invalid charcaters are replaced with first character
#      or deleted if $1 is empty
jssh_stripKey() {	# tr: we must escape first - in [-a-z...]
	if [[ "$1" =~ ^${JSSH_KEYOK} ]]; then	# tr needs [\-...
 		tr -c "${JSSH_KEYOK/\[-/[\\-}\r\n" "${1:0:1}"
	else
 		tr -dc "${JSSH_KEYOK/\[-/[\\-}\r\n"
	fi
}

# use flock if command exist
if [ "$(LC_ALL=C type -t "flock")" = "file" ]; then

  ###############
  # we have flock
  # use flock for atomic operations

  # read content of a file in JSON.sh format into given ARRAY
  # $1 ARRAY name, must be declared with "declare -A ARRAY" upfront
  # $2 filename, must be relative to BASHBOT_ETC, and not contain '..'
  jssh_readDB() {
	local DB; DB="$(jssh_checkDB "$2")"
	[ -z "${DB}" ] && return 1
	[ ! -f "${DB}" ] && return 2
	# shared lock, many processes can read, max wait 1s
	{ flock -s -w 1 200; Json2Array "$1" <"${DB}"; } 200>"${DB}${JSSHDB_LOCKNAME}"
  }

  # write ARRAY content to a file in JSON.sh format
  # Warning: old content is overwritten
  # $1 ARRAY name, must be declared with "declare -A ARRAY" upfront
  # $2 filename (must exist!), must be relative to BASHBOT_ETC, and not contain '..'
  jssh_writeDB() {
	local DB; DB="$(jssh_checkDB "$2")"
	[ -z "${DB}" ] && return 1
	[ ! -f "${DB}" ] && return 2
	# exclusive lock, no other process can read or write, maximum wait to get lock is 10s
	{ flock -e -w 10 200; Array2Json "$1" >"${DB}"; } 200>"${DB}${JSSHDB_LOCKNAME}"
  }

  # update/write ARRAY content in file without deleting keys not in ARRAY
  # $1 ARRAY name, must be declared with "declare -A ARRAY" upfront
  # $2 filename (must exist!), must be relative to BASHBOT_ETC, and not contain '..'
  # complex slow, warpper async
  jssh_updateDB() {
	# for atomic update we can't use read/writeDB
	[ -z "$2" ] && return 1
	local DB="$2.jssh"	# check in async
	[ ! -f "${DB}" ] && return 2
	{ flock -e -w 10 200; jssh_updateDB_async "$@"; } 200>"${DB}${JSSHDB_LOCKNAME}"
  }

  # insert, update, apped key/value to jsshDB
  # $1 key name, can only contain -a-zA-Z0-9,._
  # $2 key value
  # $3 filename (must exist!), must be relative to BASHBOT_ETC, and not contain '..'
  alias jssh_insertDB=jssh_insertKeyDB	# backward compatibility
  # renamed to be more consistent
  jssh_insertKeyDB() {
	[[ "$1" =~ ^${JSSH_KEYOK}+$ ]] || return 3
	local DB; DB="$(jssh_checkDB "$3")"
	[ -z "${DB}" ] && return 1
	[ ! -f "${DB}" ] && return 2
	# start atomic update here, exclusive max wait 2, it's append, not overwrite
	{ flock -e -w 2 200
	 # it's append, but last one counts, its a simple DB ...
	  printf '["%s"]\t"%s"\n' "${1//,/\",\"}" "${2//\"/\\\"}" >>"${DB}"
	} 200>"${DB}${JSSHDB_LOCKNAME}"
	
  }

  # delete key/value from jsshDB
  # $1 key name, can only contain -a-zA-Z0-9,._
  # $2 filename (must exist!), must be relative to BASHBOT_ETC, and not contain '..'
  # medium complex slow, wrapper async
  jssh_deleteKeyDB() {
	[ -z "$2" ] && return 1
	[[ "$1" =~ ^${JSSH_KEYOK}+$ ]] || return 3
	local DB="$2.jssh"
	# start atomic delete here, exclusive max wait 10s 
	{ flock -e -w 10 200; jssh_deleteKeyDB_async "$@"; } 200>"${DB}${JSSHDB_LOCKNAME}"
  }

  # get key/value from jsshDB
  # $1 key name, can only contain -a-zA-Z0-9,._
  # $2 filename (must exist!), must be relative to BASHBOT_ETC, and not contain '..'
  alias jssh_getDB=jssh_getKeyDB
  jssh_getKeyDB() {
	[[ "$1" =~ ^${JSSH_KEYOK}+$ ]] || return 3
	local DB; DB="$(jssh_checkDB "$2")"
	[ -z "${DB}" ] && return 1
	# start atomic delete here, exclusive max wait 1s 
	{ flock -s -w 1 200
	[ -r "${DB}" ] && sed -n 's/\["'"$1"'"\]\t*"\(.*\)"/\1/p' "${DB}" | tail -n 1
	} 200>"${DB}${JSSHDB_LOCKNAME}"
  }


  # add a value to key, used for conters
  # $1 key name, can only contain -a-zA-Z0-9,._
  # $2 filename (must exist!), must be relative to BASHBOT_ETC, and not contain '..'
  # $3 optional count, value added to counter, add 1 if empty 
  # side effect: if $3 is not given, we add to end of file to be as fast as possible
  # complex, wrapper to async
  jssh_countKeyDB() {
	[ -z "$2" ] && return 1
	[[ "$1" =~ ^${JSSH_KEYOK}+$ ]] || return 3
	local DB="$2.jssh"
	# start atomic delete here, exclusive max wait 5 
	{ flock -e -w 5 200; jssh_countKeyDB_async "$@"; } 200>"${DB}${JSSHDB_LOCKNAME}"
  }

  # update key/value in place to jsshDB
  # $1 key name, can only contain -a-zA-Z0-9,._
  # $2 key value
  # $3 filename (must exist!), must be relative to BASHBOT_ETC, and not contain '..'
  #no own locking, so async is the same as updatekeyDB
  jssh_updateKeyDB() {
	[[ "$1" =~ ^${JSSH_KEYOK}+$ ]] || return 3
	[ -z "$3" ] && return 1
	declare -A updARR
	# shellcheck disable=SC2034
	updARR["$1"]="$2"
	jssh_updateDB "updARR" "$3" || return 3
  }

  # $1 filename (must exist!), must be relative to BASHBOT_ETC, and not contain '..'
  jssh_clearDB() {
	local DB; DB="$(jssh_checkDB "$1")"
	[ -z "${DB}" ] && return 1
	{ flock -e -w 10 200; printf '' >"${DB}"; } 200>"${DB}${JSSHDB_LOCKNAME}"
  } 

  # updates Array if DB file has changed since last call
  # $1 name of array to update
  # $2 database
  # $3 id used to identify caller
  # medium complex, wrapper async
  jssh_updateArray() { 
	[ -z "$2" ] && return 1
	local DB="$2.jssh"	# name check in async
	[ ! -f "${DB}" ] && return 2
	declare -n ARRAY="$1"
	[[ -z "${ARRAY[*]}" ||  "${DB}" -nt "${DB}.last$3" ]] && touch "${DB}.last$3" && jssh_readDB "$1" "$2"
  }

else
  #########
  # we have no flock, use non atomic functions
  alias jssh_readDB=ssh_readDB_async
  alias jssh_writeDB=jssh_writeDB_async
  alias jssh_updateDB=jssh_updateDB_async
  alias jssh_insertDB=jssh_insertDB_async
  alias ssh_deleteKeyDB=jssh_deleteKeyDB_async
  alias jssh_getDB=jssh_getKeyDB_async
  alias jssh_getKeyDB=jssh_getKeyDB_async
  alias jssh_countKeyDB=jssh_countKeyDB_async
  alias jssh_updateKeyDB=jssh_updateKeyDB_async
  alias jssh_clearDB=jssh_clearDB_async
  alias jssh_updateArray=updateArray_async
fi

##############
# no need for atomic

# print ARRAY content to stdout instead of file
# $1 ARRAY name, must be declared with "declare -A ARRAY" upfront
jssh_printDB_async() { jssh_printDB "$@"; }
jssh_printDB() {
	Array2Json "$1"
}

# $1 filename (must exist!), must be relative to BASHBOT_ETC, and not contain '..'
jssh_newDB_async() { jssh_newDB "$@"; }
jssh_newDB() {
	local DB; DB="$(jssh_checkDB "$1")"
	[ -z "${DB}" ] && return 1
	[ -f "${DB}" ] && return 2	# already exist
	touch "${DB}"
} 

# $1 filename, check filename, it must be relative to BASHBOT_VAR, and not contain '..'
# returns real path to DB file if everything is ok
jssh_checkDB_async() { jssh_checkDB "$@"; }
jssh_checkDB(){
	local DB
	[ -z "$1" ] && return 1
	[[ "$1" = *'../.'* ]] && return 2
	if [[ "$1" == "${BASHBOT_VAR:-.}"* ]] || [[ "$1" == "${BASHBOT_DATA:-.}"* ]]; then
		DB="$1.jssh"
	else
		DB="${BASHBOT_VAR:-.}/$1.jssh"
	fi
	[ "${DB}" != ".jssh" ] && printf '%s' "${DB}"
}


######################
# implementations as non atomic functions
# can be used explictitly or as fallback if flock is not available
jssh_readDB_async() {
	local DB; DB="$(jssh_checkDB "$2")"
	[ -z "${DB}" ] && return 1
	[ ! -f "${DB}" ] && return 2
	Json2Array "$1" <"${DB}"
}

jssh_writeDB_async() {
	local DB; DB="$(jssh_checkDB "$2")"
	[ -z "${DB}" ] && return 1
	[ ! -f "${DB}" ] && return 2
	Array2Json "$1" >"${DB}"
}

jssh_updateDB_async() {
	[ -z "$2" ] && return 1
	declare -n ARRAY="$1"
	[ -z "${ARRAY[*]}" ] && return 1
	declare -A oldARR
	jssh_readDB_async "oldARR" "$2" || return "$?"
	if [ -z "${oldARR[*]}" ]; then
		# no old content
		jssh_writeDB_async "$1" "$2"
	else
		# merge arrays
		local key
		for key in "${!ARRAY[@]}"
		do
		    oldARR["${key}"]="${ARRAY["${key}"]}"
		done
		Array2Json "oldARR" >"${DB}"
	fi
}

jssh_insertDB_async() { jssh_insertKeyDB "$@"; }
jssh_insertKeyDB_async() {
	[[ "$1" =~ ^${JSSH_KEYOK}+$ ]] || return 3
	local DB; DB="$(jssh_checkDB "$3")"
	[ -z "${DB}" ] && return 1
	[ ! -f "${DB}" ] && return 2
	# its append, but last one counts, its a simple DB ...
	printf '["%s"]\t"%s"\n' "${1//,/\",\"}" "${2//\"/\\\"}" >>"${DB}"
	
}

jssh_deleteKeyDB_async() {
	[[ "$1" =~ ^${JSSH_KEYOK}+$ ]] || return 3
	local DB; DB="$(jssh_checkDB "$2")"
	[ -z "${DB}" ] && return 1
	declare -A oldARR
	Json2Array "oldARR" <"${DB}"
	unset oldARR["$1"]
	Array2Json  "oldARR" >"${DB}"
}

jssh_getKeyDB_async() {
	[[ "$1" =~ ^${JSSH_KEYOK}+$ ]] || return 3
	local DB; DB="$(jssh_checkDB "$2")"
	[ -z "${DB}" ] && return 1
	[ -r "${DB}" ] && sed -n 's/\["'"$1"'"\]\t*"\(.*\)"/\1/p' "${DB}" | tail -n 1
}

jssh_countKeyDB_async() {
	[[ "$1" =~ ^${JSSH_KEYOK}+$ ]] || return 3
	local VAL DB; DB="$(jssh_checkDB "$2")"
	[ -z "${DB}" ] && return 1
	# start atomic delete here, exclusive max wait 5 
	if [ -n "$3" ]; then
		declare -A oldARR
		Json2Array "oldARR" <"${DB}"
		(( oldARR["$1"]+="$3" ));
		Array2Json  "oldARR" >"${DB}"
	elif [ -r "${DB}" ]; then
		# it's append, but last one counts, its a simple DB ...
		VAL="$(sed -n 's/\["'"$1"'"\]\t*"\(.*\)"/\1/p' "${DB}" | tail -n 1)"
		printf '["%s"]\t"%s"\n' "${1//,/\",\"}" "$((++VAL))" >>"${DB}"
	fi
  }

# update key/value in place to jsshDB
# $1 key name, can only contain -a-zA-Z0-9,._
# $2 key value
# $3 filename (must exist!), must be relative to BASHBOT_ETC, and not contain '..'
#no own locking, so async is the same as updatekeyDB
jssh_updateKeyDB_async() {
	[[ "$1" =~ ^${JSSH_KEYOK}+$ ]] || return 3
	[ -z "$3" ] && return 1
	declare -A updARR
	# shellcheck disable=SC2034
	updARR["$1"]="$2"
	jssh_updateDB_async "updARR" "$3" || return 3
}

jssh_clearDB_async() {
	local DB; DB="$(jssh_checkDB "$1")"
	[ -z "${DB}" ] && return 1
	printf '' >"${DB}"
} 

function jssh_updateArray_async() {
	local DB; DB="$(jssh_checkDB "$2")"
	[ -z "${DB}" ] && return 1
	[ ! -f "${DB}" ] && return 2
	declare -n ARRAY="$1"
	[[ -z "${ARRAY[*]}" ||  "${DB}" -nt "${DB}.last$3" ]] && touch "${DB}.last$3" && jssh_readDB_async "$1" "$2"
}

##############
# these 2 functions does all key/value store "magic"
# and convert from/to bash array

# read JSON.sh style data and asssign to an ARRAY
# $1 ARRAY name, must be declared with "declare -A ARRAY" before calling
Json2Array() {
	# shellcheck disable=SC1091,SC1090
	# step 1: output only basic pattern
	[ -z "$1" ] || source <( printf "$1"'=( %s )'\
		 "$(sed -E -n -e 's/[`´]//g' -e 's/\t(true|false)/\t"\1"/' -e 's/([^\]|^)\$/\1\\$/g' -e '/\["[-0-9a-zA-Z_,."]+"\]\+*\t/ s/\t/=/p')" )
}
# get Config Key from jssh file without jsshDB
# output ARRAY as JSON.sh style data
# $1 ARRAY name, must be declared with "declare -A ARRAY" before calling
Array2Json() {
	[ -z "$1" ] && return 1
	local key
	declare -n ARRAY="$1"
	for key in "${!ARRAY[@]}"
       	do
		[[ ! "${key}" =~ ^${JSSH_KEYOK}+$ || "${ARRAY[${key}]}" == "${JSSHDB_UNSET}" ]] && continue
		# in case value contains newline convert to \n
		: "${ARRAY[${key}]//$'\n'/\\n}"
		printf '["%s"]\t"%s"\n' "${key//,/\",\"}" "${_//\"/\\\"}"
       	done
}
