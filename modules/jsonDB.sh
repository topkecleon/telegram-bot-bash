#!/bin/bash
# file: modules/jsshDB.sh
# do not edit, this file will be overwritten on update

# This file is public domain in the USA and all free countries.
# Elsewhere, consider it to be WTFPLv2. (wtfpl.net/txt/copying)
#
#### $$VERSION$$ v0.96-dev-7-g0153928
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
	declare -A oldARR newARR

	# start atomic update here, exclusive max wait 10s
	{ flock -e -w 10 200
	Json2Array "oldARR" <"${DB}"
	if [ -z "${oldARR[*]}" ]; then
		# no old content
		Array2Json "$1" >"${DB}"
	else
		# merge arrays
		local o1 o2 n1 n2
		o1="$(declare -p oldARR)"; o2="${o1#*\(}"
		n1="$(declare -p ARRAY)";  n2="${n1#*\(}"
		unset IFS; set -f
		#shellcheck disable=SC2034,SC2190,SC2206
		newARR=( ${o2:0:${#o2}-1} ${n2:0:${#n2}-1} )
		set +f
		Array2Json  "newARR" >"${DB}"
	fi
	} 200>"${DB}${BASHBOT_LOCKNAME}"
  }

  # insert, update, apped key/value to jsshDB
  # $1 key name, can onyl contain -a-zA-Z0-9,._
  # $2 key value
  # $3 filename (must exist!), must be relative to BASHBOT_ETC, and not contain '..'
  jssh_insertDB() {
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

  # delete key/value from jsshDB
  # $1 key name, can onyl contain -a-zA-Z0-9,._
  # $2 filename (must exist!), must be relative to BASHBOT_ETC, and not contain '..'
  jssh_getKeyDB() {
	[[ "$1" =~ ^[-a-zA-Z0-9,._]+$ ]] || return 3
	local DB; DB="$(jssh_checkDB "$2")"
	declare -A oldARR
	# start atomic delete here, exclusive max wait 1s 
	{ flock -e -w 1 200
	Json2Array "oldARR" <"${DB}"
	} 200>"${DB}${BASHBOT_LOCKNAME}"
	echo "${oldARR["$1"]}"
  }


  # add a value to key, used for conters
  # $1 key name, can onyl contain -a-zA-Z0-9,._
  # $2 filename (must exist!), must be relative to BASHBOT_ETC, and not contain '..'
  # $3 optional count, value added to count3r, add 1 if empty 
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


else
  #########
  # we have no flock, use "old" not atomic functions
  jssh_readDB() {
	jssh_readDB_async "$@"
  }

  jssh_writeDB() {
	jssh_writeDB_async "$@"
  }

  jssh_updateDB() {
	jssh_updateDB_async "$@"
  }

  jssh_insertDB() {
	jssh_insertDB_async "$@"
	
  }

  jssh_deleteKeyDB() {
	jssh_deleteKeyDB_async "$@"
  }

  jssh_getKeyDB() {
	jssh_getKeyDB_async "$@"
  }
  jssh_countKeyDB() {
	jssh_countKeyDB "$@"
  }
fi

##############
# no need for atomic

# print ARRAY content to stdout instead of file
# $1 ARRAY name, must be delared with "declare -A ARRAY" upfront
jssh_printDB() {
	Array2Json "$1"
}

# get key/value from jsshDB
# $1 key name, can onyl contain -a-zA-Z0-9,._
# $2 key value
# $3 filename (must exist!), must be relative to BASHBOT_ETC, and not contain '..'
# returns value
jssh_getDB() {
	[[ "$1" =~ ^[-a-zA-Z0-9,._]+$ ]] || return 3
	declare -A getARR
	jssh_readDB "getARR" "$3" || return "$?"
	printf '%s\n' "${getARR[${key}]}"
}

# $1 filename (must exist!), must be relative to BASHBOT_ETC, and not contain '..'
jssh_newDB() {
	local DB; DB="$(jssh_checkDB "$1")"
	[ -z "${DB}" ] && return 1
	[ -f "${DB}" ] && return 2 # already exist, do not zero out
	printf '\n' >"${DB}"
} 

# $1 filename, check filename, it must be relative to BASHBOT_ETC, and not contain '..'
# returns real path to DB file if everything is ok
jssh_checkDB(){
	[ -z "$1" ] && return 1
	local DB="${BASHBOT_ETC:-.}/$1.jssh"
	if [[ "$1" = "${BASHBOT_ETC:-.}"* ]] || [[ "$1" = "${BASHBOT_DATA:-.}"* ]]; then
		DB="$1.jssh"
	fi
	[[ "$1" = *'..'* ]] && return 2
	printf '%s\n' "${DB}"
}


######################
# "old" implementations as non atomic functions
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
	declare -A oldARR newARR
	jssh_readDB_async "oldARR" "$2" || return "$?"
	if [ -z "${oldARR[*]}" ]; then
		# no old content
		jssh_writeDB_async "$1" "$2"
	else
		# merge arrays
		local o1 o2 n1 n2
		o1="$(declare -p oldARR)"; o2="${o1#*\(}"
		n1="$(declare -p ARRAY)";  n2="${n1#*\(}"
		unset IFS; set -f
		#shellcheck disable=SC2034,SC2190,SC2206
		newARR=( ${o2:0:${#o2}-1} ${n2:0:${#n2}-1} )
		set +f
		jssh_writeDB_async "newARR" "$2" 
	fi
}

jssh_insertDB_async() {
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
	jssh_readDB_async "oldARR" "$2" || return "$?"
	unset oldARR["$1"]
	jssh_writeDB_async "oldARR" "$2"
}

jssh_getKeyDB_async() {
	[[ "$1" =~ ^[-a-zA-Z0-9,._]+$ ]] || return 3
	local DB; DB="$(jssh_checkDB "$2")"
	declare -A oldARR
	Json2Array "oldARR" <"${DB}"
	echo "${oldARR["$1"]}"
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

