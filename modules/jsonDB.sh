#!/bin/bash
# file: modules/jsshDB.sh
# do not edit, this file will be overwritten on update

# This file is public domain in the USA and all free countries.
# Elsewhere, consider it to be WTFPLv2. (wtfpl.net/txt/copying)
#
#### $$VERSION$$ v0.90-dev2-9-gbbbc8ae
#
# source from commands.sh to use jsonDB functions
#
# jsonDB rovides simple functions to read and store bash Arrays
# from to file in JSON.sh output format

# read content of a file in JSON.sh format into given ARRAY
# $1 ARRAY name, must be delared with "declare -A ARRAY" upfront
# $2 filename, must be relative to BASHBOT_ETC, and not contain '..'
jssh_readDB() {
	local DB="${BASHBOT_ETC:-.}/$2.jssh"
	[ "$2" = "" ] && return 1
	[[ "$2" = *'..'* ]] && return 1
	[ ! -f "${DB}" ] && return 1
	Json2Array "$1" <"${DB}"
}

# write ARRAY content to a file in JSON.sh format
# $1 ARRAY name, must be delared with "declare -A ARRAY" upfront
# $2 filename (must exist!), must be relative to BASHBOT_ETC, and not contain '..'
jssh_writeDB() {
	local DB="${BASHBOT_ETC:-.}/$2.jssh"
	[ "$2" = "" ] && return 1
	[[ "$2" = *'..'* ]] && return 1
	[ ! -f "${DB}" ] && return 1
	Array2Json "$1" >"${DB}"
}

# $1 filename (must exist!), must be relative to BASHBOT_ETC, and not contain '..'
jssh_newDB() {
	local DB="${BASHBOT_ETC:-.}/$1.jssh"
	[ "$1" = "" ] && return 1
	[[ "$2" = *'..'* ]] && return 1
	[ -f "${DB}" ] && return 1 # already exist, do not zero out
	printf '\n' >"${DB}"
} 
