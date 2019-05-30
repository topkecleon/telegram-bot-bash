#!/bin/bash
# file: modules/jsshDB.sh
# do not edit, this file will be overwritten on update

# This file is public domain in the USA and all free countries.
# Elsewhere, consider it to be WTFPLv2. (wtfpl.net/txt/copying)
#
#### $$VERSION$$ v0.90-rc1-0-g93b4914
#
# source from commands.sh to use jsonDB functions
#
# jsonDB rovides simple functions to read and store bash Arrays
# from to file in JSON.sh output format

# read content of a file in JSON.sh format into given ARRAY
# $1 ARRAY name, must be delared with "declare -A ARRAY" upfront
# $2 filename, must be relative to BASHBOT_ETC, and not contain '..'
jssh_readDB() {
	local DB; DB="$(jssh_checkname "$2")"
	[ "${DB}" = "" ] && return 1
	[ ! -f "${DB}" ] && return 1
	Json2Array "$1" <"${DB}"
}

# write ARRAY content to a file in JSON.sh format
# $1 ARRAY name, must be delared with "declare -A ARRAY" upfront
# $2 filename (must exist!), must be relative to BASHBOT_ETC, and not contain '..'
jssh_writeDB() {
	local DB; DB="$(jssh_checkname "$2")"
	[ "${DB}" = "" ] && return 1
	[ ! -f "${DB}" ] && return 1
	Array2Json "$1" >"${DB}"
}

# $1 filename (must exist!), must be relative to BASHBOT_ETC, and not contain '..'
jssh_newDB() {
	local DB; DB="$(jssh_checkname "$1")"
	[ "${DB}" = "" ] && return 1
	[ -f "${DB}" ] && return 1 # already exist, do not zero out
	printf '\n' >"${DB}"
} 

# $1 filename, check if must be relative to BASHBOT_ETC, and not contain '..'
jssh_checkname(){
	[ "$1" = "" ] && return 1
	local DB="${BASHBOT_ETC:-.}/$1.jssh"
	[[ "$1" = "${BASHBOT_ETC:-.}"* ]] && DB="$1.jssh"
	[[ "$1" = *'..'* ]] && return  1
	printf '%s\n' "${DB}"
}
