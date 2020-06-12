#!/bin/bash
# file: modules/jsshDB.sh
# do not edit, this file will be overwritten on update

# This file is public domain in the USA and all free countries.
# Elsewhere, consider it to be WTFPLv2. (wtfpl.net/txt/copying)
#
#### $$VERSION$$ v0.96-0-g3871ca9
#
# source from commands.sh to use jsonDB functions
#
# jsonDB provides simple functions to read and store bash Arrays
# from to file in JSON.sh output format, its a simple key/value storage.


# source once magic, function named like file
eval "$(basename "${BASH_SOURCE[0]}")(){ :; }"

# new feature: serialize / atomic operations:
# updates will be done atomic with flock
# flock should flock should be availible on all system as its part of busybox
# tinybox

# lockfile filename.flock is persistent and will be testet with flock for active lock (file open)
export BASHBOT_LOCKNAME=".flock"

if _exists flock; then
  ###############
  # we have flock
  # use flock for atomic operations

  # read content of a file in JSON.sh format into given ARRAY
  # $1 ARRAY name, must be delared with "declare -A ARRAY" upfront
  # $2 filename, must be relative to BASHBOT_ETC, and not contain '..'
  jssh_readDB() {
	local DB; DB="$(jssh_checkDB "$2")"
	[ -z "${DB}" ] && return 1
	[ ! -f "${DB}" ] && return 2
	# shared lock, many processes can read, max wait 1s
	{ flock -s -w 1 200; Json2Array "$1" <"${DB}"; } 200>"${DB}${BASHBOT_LOCKNAME}"
  }

  # write ARRAY content to a file in JSON.sh format
  # Warning: old content is overwritten
  # $1 ARRAY name, must be delared with "declare -A ARRAY" upfront
  # $2 filename (must exist!), must be relative to BASHBOT_ETC, and not contain '..'
  jssh_writeDB() {
	local DB; DB="$(jssh_checkDB "$2")"
	[ -z "${DB}" ] && return 1
	[ ! -f "${DB}" ] && return 2
	# exclusive lock, no other process can read or write, maximum wait to get lock is 10s
	{ flock -e -w 10 200; Array2Json "$1" >"${DB}"; } 200>"${DB}${BASHBOT_LOCKNAME}"
  }

  # update/write ARRAY content in file without deleting keys not in ARRAY
  # $1 ARRAY name, must be delared with "declare -A ARRAY" upfront
  # $2 filename (must exist!), must be relative to BASHBOT_ETC, and not contain '..'
  jssh_updateDB() {
	# for atomic update we cant use read/writeDB
	local DB; DB="$(jssh_checkDB "$2")"
	[ -z "${DB}" ] && return 1
	[ ! -f "${DB}" ] && return 2

	declare -n ARRAY="$1"
	[ -z "${ARRAY[*]}" ] && return 1
	declare -A oldARR

	# start atomic update here, exclusive max wait 10s
	{ flock -e -w 10 200
	Json2Array "oldARR" <"${DB}"
	if [ -z "${oldARR[*]}" ]; then
		# no old content
		Array2Json "$1" >"${DB}"
	else
		# merge arrays
		local key
		for key in "${!ARRAY[@]}"
		do
		    oldARR["${key}"]="${ARRAY["${key}"]}"
		done
		Array2Json  "oldARR" >"${DB}"
	fi
	} 200>"${DB}${BASHBOT_LOCKNAME}"
  }

  # insert, update, apped key/value to jsshDB
  # $1 key name, can onyl contain -a-zA-Z0-9,._
  # $2 key value
  # $3 filename (must exist!), must be relative to BASHBOT_ETC, and not contain '..'
  alias jssh_insertDB=jssh_insertKeyDB # backward compatibility
  # renamed to be more consistent
  jssh_insertKeyDB() {
	[[ "$1" =~ ^[-a-zA-Z0-9,._]+$ ]] || return 3
	local key="$1" value="$2"
	local DB; DB="$(jssh_checkDB "$3")"
	[ -z "${DB}" ] && return 1
	[ ! -f "${DB}" ] && return 2
	# start atomic update here, exclusive max wait 2, it's append, not overwrite
	{ flock -e -w 2 200
	 # it's append, but last one counts, its a simple DB ...
	  printf '["%s"]\t"%s"\n' "${key//,/\",\"}" "${value//\"/\\\"}" >>"${DB}"
	} 200>"${DB}${BASHBOT_LOCKNAME}"
	
  }

  # delete key/value from jsshDB
  # $1 key name, can onyl contain -a-zA-Z0-9,._
  # $2 filename (must exist!), must be relative to BASHBOT_ETC, and not contain '..'
  jssh_deleteKeyDB() {
	[[ "$1" =~ ^[-a-zA-Z0-9,._]+$ ]] || return 3
	local DB; DB="$(jssh_checkDB "$2")"
	declare -A oldARR
	# start atomic delete here, exclusive max wait 10s 
	{ flock -e -w 10 200
	Json2Array "oldARR" <"${DB}"
	unset oldARR["$1"]
	Array2Json  "oldARR" >"${DB}"
	} 200>"${DB}${BASHBOT_LOCKNAME}"
  }

  # get key/value from jsshDB
  # $1 key name, can onyl contain -a-zA-Z0-9,._
  # $2 filename (must exist!), must be relative to BASHBOT_ETC, and not contain '..'
  alias jssh_getDB=jssh_getKeyDB
  jssh_getKeyDB() {
	[[ "$1" =~ ^[-a-zA-Z0-9,._]+$ ]] || return 3
	local DB; DB="$(jssh_checkDB "$2")"
	declare -A oldARR
	# start atomic delete here, exclusive max wait 1s 
	{ flock -s -w 1 200
	Json2Array "oldARR" <"${DB}"
	} 200>"${DB}${BASHBOT_LOCKNAME}"
	printf '%s' "${oldARR["$1"]}"
  }


  # add a value to key, used for conters
  # $1 key name, can onyl contain -a-zA-Z0-9,._
  # $2 filename (must exist!), must be relative to BASHBOT_ETC, and not contain '..'
  # $3 optional count, value added to counter, add 1 if empty 
  # side effect: if $3 is not given, we add to end of file to be as fast as possible
  jssh_countKeyDB() {
	[[ "$1" =~ ^[-a-zA-Z0-9,._]+$ ]] || return 3
	local DB; DB="$(jssh_checkDB "$2")"
	declare -A oldARR
	# start atomic delete here, exclusive max wait 5 
	{ flock -e -w 5 200
	Json2Array "oldARR" <"${DB}"
	if [ "$3" != "" ]; then
		(( oldARR["$1"]+="$3" ));
		Array2Json  "oldARR" >"${DB}"
	else
		# it's append, but last one counts, its a simple DB ...
		(( oldARR["$1"]++ ));
		printf '["%s"]\t"%s"\n' "${1//,/\",\"}" "${oldARR["$1"]//\"/\\\"}" >>"${DB}"
	fi
	} 200>"${DB}${BASHBOT_LOCKNAME}"
  }

  # update key/value in place to jsshDB
  # $1 key name, can onyl contain -a-zA-Z0-9,._
  # $2 key value
  # $3 filename (must exist!), must be relative to BASHBOT_ETC, and not contain '..'
  #no own locking, so async is the same as updatekeyDB
  jssh_updateKeyDB() {
	[[ "$1" =~ ^[-a-zA-Z0-9,._]+$ ]] || return 3
	declare -A oldARR
	oldARR["$1"]="$2"
	jssh_updateDB "oldARR" "${3}" || return 3
  }

  # $1 filename (must exist!), must be relative to BASHBOT_ETC, and not contain '..'
  jssh_clearDB() {
	local DB; DB="$(jssh_checkDB "$1")"
	[ -z "${DB}" ] && return 1
	{ flock -e -w 10 200
	printf '' >"${DB}"
	} 200>"${DB}${BASHBOT_LOCKNAME}"
  } 

else
  #########
  # we have no flock, use "old" not atomic functions
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
fi

##############
# no need for atomic

# print ARRAY content to stdout instead of file
# $1 ARRAY name, must be delared with "declare -A ARRAY" upfront
jssh_printDB_async() { jssh_printDB "$@"; }
jssh_printDB() {
	Array2Json "$1"
}

# $1 filename (must exist!), must be relative to BASHBOT_ETC, and not contain '..'
jssh_newDB_async() { jssh_newDB "$@"; }
jssh_newDB() {
	local DB; DB="$(jssh_checkDB "$1")"
	[ -z "${DB}" ] && return 1
	[ -f "${DB}" ] && return 2 # already exist
	touch "${DB}"
} 

# $1 filename, check filename, it must be relative to BASHBOT_VAR, and not contain '..'
# returns real path to DB file if everything is ok
jssh_checkDB_sync() { jssh_checkDB "$@"; }
jssh_checkDB(){
	local DB
	[ -z "$1" ] && return 1
	[[ "$1" = *'..'* ]] && return 2
	if [[ "$1" == "${BASHBOT_VAR:-.}"* ]] || [[ "$1" == "${BASHBOT_DATA:-.}"* ]]; then
		DB="$1.jssh"
	else
		DB="${BASHBOT_VAR:-.}/$1.jssh"
	fi
	printf '%s' "${DB}"
}


######################
# implementations as non atomic functions
# can be used explictitly or as fallback if flock is not availible
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
	[[ "$1" =~ ^[-a-zA-Z0-9,._]+$ ]] || return 3
	local key="$1" value="$2"
	local DB; DB="$(jssh_checkDB "$3")"
	[ -z "${DB}" ] && return 1
	[ ! -f "${DB}" ] && return 2
	# its append, but last one counts, its a simple DB ...
	printf '["%s"]\t"%s"\n' "${key//,/\",\"}" "${value//\"/\\\"}" >>"${DB}"
	
}

jssh_deleteKeyDB_async() {
	[[ "$1" =~ ^[-a-zA-Z0-9,._]+$ ]] || return 3
	local DB; DB="$(jssh_checkDB "$2")"
	declare -A oldARR
	Json2Array "oldARR" <"${DB}"
	unset oldARR["$1"]
	Array2Json  "oldARR" >"${DB}"
}

jssh_getKeyDB_async() {
	[[ "$1" =~ ^[-a-zA-Z0-9,._]+$ ]] || return 3
	local DB; DB="$(jssh_checkDB "$2")"
	declare -A oldARR
	Json2Array "oldARR" <"${DB}"
	printf '%s' "${oldARR["$1"]}"
}

jssh_countKeyDB_async() {
	[[ "$1" =~ ^[-a-zA-Z0-9,._]+$ ]] || return 3
	local DB COUNT="1"; DB="$(jssh_checkDB "$2")"
	[ "$3" != "" ] && COUNT="$3"
	declare -A oldARR
	# start atomic delete here, exclusive max wait 10s 
	Json2Array "oldARR" <"${DB}"
	(( oldARR["$1"]+=COUNT ));
	Array2Json  "oldARR" >"${DB}"
}

# updatie key/value in place to jsshDB
# $1 key name, can onyl contain -a-zA-Z0-9,._
# $2 key value
# $3 filename (must exist!), must be relative to BASHBOT_ETC, and not contain '..'
#no own locking, so async is the same as updatekeyDB
jssh_updateKeyDB_async() {
	[[ "$1" =~ ^[-a-zA-Z0-9,._]+$ ]] || return 3
	declare -A oldARR
	oldARR["$1"]="$2"
	jssh_updateDB_async "oldARR" "${3}" || return 3
}

jssh_clearDB_async() {
	local DB; DB="$(jssh_checkDB "$1")"
	[ -z "${DB}" ] && return 1
	printf '' >"${DB}"
} 


