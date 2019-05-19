#!/bin/bash
# file: modules/background.sh
# do not edit, this file will be overwritten on update

# This file is public domain in the USA and all free countries.
# Elsewhere, consider it to be WTFPLv2. (wtfpl.net/txt/copying)
#
#### $$VERSION$$ v0.80-dev3-6-gbeb77a4

# source from commands.sh if you want ro use interactive or background jobs

######
# interactive and background functions

# old syntax as aliases
background() {
	start_back "${CHAT[ID]}" "$1" "$2"
}
startproc() {
	start_proc "${CHAT[ID]}" "$1" "$2"
}
checkback() {
	check_back "${CHAT[ID]}" "$1"
}
checkproc() {
	check_proc "${CHAT[ID]}" "$1"
}
killback() {
	kill_back  "${CHAT[ID]}" "$1"
}
killproc() {
	kill_proc "${CHAT[ID]}" "$1"
}

# inline and backgound functions
# $1 chatid
# $2 program
# $3 jobname
start_back() {
	local fifo; fifo="${TMPDIR:-.}/$(procname "$1")"
	echo "$1:$3:$2" >"${fifo}$3-back.cmd"
	start_proc "$1" "$2" "back-$3-"
}


# $1 chatid
# $2 program
# $3 prefix
start_proc() {
	[ "$2" = "" ] && return
	local fifo; fifo="${TMPDIR:-.}/$(procname "$1" "$3")"
	kill_proc "$1" "$3"
	mkfifo "${fifo}"
	nohup bash &>>"${fifo}.log" <<HEREDOC &
{ tail -f  < "${fifo}" | $2 "" "" "$fifo" | "${SCRIPT}" outproc "${1}" "${fifo}"
rm "${fifo}"; [ -s "${fifo}.log" ] || rm -f "${fifo}.log"; }
HEREDOC
}


# $1 chatid
# $2 jobname
check_back() {
	check_proc "$1" "back-$2-"
}

# $1 chatid
# $2 prefix
check_proc() {
	[ "$(proclist "$(procname "$1" "$2")")" != "" ]
	# shellcheck disable=SC2034
	res=$?; return $?
}

# $1 chatid
# $2 jobname
kill_back() {
	kill_proc "$1" "back-$2-"
	rm -f "${TMPDIR:-.}/$(procname "$1")$2-back.cmd"
}


# $1 chatid
# $2 prefix
kill_proc() {
	local fifo prid
	fifo="$(procname "$1" "$2")"
	prid="$(proclist "${fifo}")"
	fifo="${TMPDIR:-.}/${fifo}"
	# shellcheck disable=SC2086
	[ "${prid}" != "" ] && kill ${prid}
	[ -s "${fifo}.log" ] || rm -f "${fifo}.log"
	[ -p "${fifo}" ] && rm -f "${fifo}";
}

# $1 chat
# $2 message
forward_interactive() {
	local fifo; fifo="${TMPDIR:-.}/$(procname "$1")"
	[ -p "${fifo}" ] && echo "$2" >"${fifo}"
}
