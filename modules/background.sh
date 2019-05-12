#!/bin/bash
# file: modules/background.sh
# do not edit, this file will be overwritten on update

# This file is public domain in the USA and all free countries.
# Elsewhere, consider it to be WTFPLv2. (wtfpl.net/txt/copying)
#
#### $$VERSION$$ v0.80-dev2-6-g5b10e75

# source from commands.sh if you want ro use interactive or background jobs

######
# interactive and background functions

background() {
	echo "${CHAT[ID]}:$2:$1" >"${TMPDIR:-.}/${copname:--}$2-back.cmd"
	startproc "$1" "back-$2-"
}

startproc() {
	killproc "$2"
	local fifo="$2${copname}"
	mkfifo "${TMPDIR:-.}/${fifo}"
	tmux new-session -d -s "${fifo}" "$1 &>${TMPDIR:-.}/${fifo}; echo imprettydarnsuredatdisisdaendofdacmd>${TMPDIR:-.}/${fifo}"
	tmux new-session -d -s "sendprocess_${fifo}" "bash $SCRIPT outproc ${CHAT[ID]} ${fifo}"
}


checkback() {
	checkproc "back-$1-"
}

checkproc() {
	tmux ls | grep -q "$1${copname}"
	# shellcheck disable=SC2034
	res=$?; return $?
}

killback() {
	killproc "back-$1-"
	rm -f "${TMPDIR:-.}/${copname}$1-back.cmd"
}

killproc() {
	local fifo="$1${copname}"
	(tmux kill-session -t "${fifo}"; echo imprettydarnsuredatdisisdaendofdacmd>"${TMPDIR:-.}/${fifo}"; tmux kill-session -t "sendprocess_${fifo}"; rm -f -r "${TMPDIR:-.}/${fifo}")2>/dev/null
}

inproc() {
	tmux send-keys -t "$copname" "${MESSAGE[0]} ${URLS[*]}
"
}
