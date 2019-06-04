#!/bin/bash
# file: modules/jsshDB.sh
# do not edit, this file will be overwritten on update

# This file is public domain in the USA and all free countries.
# Elsewhere, consider it to be WTFPLv2. (wtfpl.net/txt/copying)
#
#### $$VERSION$$ v0.91-4-gaad0bfe
#
# source from commands.sh to use jsonDB functions
#
# jsonDB provides simple functions to read and store bash Arrays
# from to file in JSON.sh output format, its a simple key/value storage.

# read content of a file in JSON.sh format into given ARRAY
# $1 ARRAY name, must be delared with "declare -A ARRAY" upfront
# $2 filename, must be relative to BASHBOT_ETC, and not contain '..'
jssh_readDB() {
	local DB; DB="$(jssh_checkname "$2")"
	[ "${DB}" = "" ] && return 1
	[ ! -f "${DB}" ] && return 2
	Json2Array "$1" <"${DB}"
}

# write ARRAY content to a file in JSON.sh format
# $1 ARRAY name, must be delared with "declare -A ARRAY" upfront
# $2 filename (must exist!), must be relative to BASHBOT_ETC, and not contain '..'
jssh_writeDB() {
	local DB; DB="$(jssh_checkname "$2")"
	[ "${DB}" = "" ] && return 1
	[ ! -f "${DB}" ] && return 2
	Array2Json "$1" >"${DB}"
}

# insert, update, apped key/value to jsshDB
# $1 key name, can onyl contain -a-zA-Z0-9,._
# $2 key value
# $3 filename (must exist!), must be relative to BASHBOT_ETC, and not contain '..'
jssh_insertDB() {
	[[ "$1" =~ ^[-a-zA-Z0-9,._]+$ ]] || return 3
	local key="$1" value="$2"
	local DB; DB="$(jssh_checkname "$3")"
	[ "${DB}" = "" ] && return 1
	[ ! -f "${DB}" ] && return 2
	# its append, but last one counts, its a simple DB ...
	printf '["%s"]\t"%s"\n' "${key//,/\",\"}" "${value//\"/\\\"}" >>"${DB}"
	
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
	local DB; DB="$(jssh_checkname "$1")"
	[ "${DB}" = "" ] && return 1
	[ -f "${DB}" ] && return 2 # already exist, do not zero out
	printf '\n' >"${DB}"
} 

# $1 filename, check if must be relative to BASHBOT_ETC, and not contain '..'
jssh_checkname(){
	[ "$1" = "" ] && return 1
	local DB="${BASHBOT_ETC:-.}/$1.jssh"
	[[ "$1" = "${BASHBOT_ETC:-.}"* ]] && DB="$1.jssh"
	[[ "$1" = *'..'* ]] && return 2
	printf '%s\n' "${DB}"
}

