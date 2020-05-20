#!/bin/bash
# file: modules/background.sh
# do not edit, this file will be overwritten on update

# This file is public domain in the USA and all free countries.
# Elsewhere, consider it to be WTFPLv2. (wtfpl.net/txt/copying)
#
#### $$VERSION$$ v0.96-dev-7-g0153928

# source from commands.sh if you want ro use interactive or background jobs

# source once magic, function named like file
eval "$(basename "${BASH_SOURCE[0]}")(){ :; }"

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
	local fifo; fifo="${DATADIR:-.}/$(procname "$1")"
	printf '%s\n' "$1:$3:$2" >"${fifo}$3-back.cmd"
	start_proc "$1" "$2" "back-$3-"
}


# $1 chatid
# $2 program
# $3 prefix
start_proc() {
	[ -z "$2" ] && return
	[ -x "${2%% *}" ] || return 1
	local fifo; fifo="${DATADIR:-.}/$(procname "$1" "$3")"
	kill_proc "$1" "$3"
	mkfifo "${fifo}"
	nohup bash -c "{ tail -f  < \"${fifo}\" | $2 \"\" \"\" \"$fifo\" | \"${SCRIPT}\" outproc \"${1}\" \"${fifo}\"
		rm \"${fifo}\"; [ -s \"${fifo}.log\" ] || rm -f \"${fifo}.log\"; }" &>>"${fifo}.log" &
}


# $1 chatid
# $2 jobname
check_back() {
	check_proc "$1" "back-$2-"
}

# $1 chatid
# $2 prefix
check_proc() {
	[ -n "$(proclist "$(procname "$1" "$2")")" ]
	# shellcheck disable=SC2034
	res=$?; return $?
}

# $1 chatid
# $2 jobname
kill_back() {
	kill_proc "$1" "back-$2-"
	rm -f "${DATADIR:-.}/$(procname "$1")$2-back.cmd"
}


# $1 chatid
# $2 prefix
kill_proc() {
	local fifo prid
	fifo="$(procname "$1" "$2")"
	prid="$(proclist "${fifo}")"
	fifo="${DATADIR:-.}/${fifo}"
	# shellcheck disable=SC2086
	[ -n "${prid}" ] && kill ${prid}
	[ -s "${fifo}.log" ] || rm -f "${fifo}.log"
	[ -p "${fifo}" ] && rm -f "${fifo}";
}

# $1 chat
# $2 message
send_interactive() {
	local fifo; fifo="${DATADIR:-.}/$(procname "$1")"
	[ -p "${fifo}" ] && printf '%s\n' "$2" >"${fifo}" & # not blocking!
}

# old style but may not work because of local checks
inproc() {
	send_interactive "${CHAT[ID]}" "${MESSAGE}"
}

# start stopp all jobs
# $1 command
#	killb*
#	suspendb*
#	resumeb*
job_control() {
	local content proc CHAT job fifo killall=""
	for FILE in "${DATADIR:-.}/"*-back.cmd; do
		[ "${FILE}" = "${DATADIR:-.}/*-back.cmd" ] && echo -e "${RED}No background processes.${NC}" && break
		content="$(< "${FILE}")"
		CHAT="${content%%:*}"
		job="${content#*:}"
		proc="${job#*:}"
		job="back-${job%:*}-"
		fifo="$(procname "${CHAT}" "${job}")" 
		case "$1" in
		"resumeb"*|"backgr"*)
			echo "Restart Job: ${proc}  ${fifo}"
			start_proc "${CHAT}" "${proc}" "${job}"
			;;
		"suspendb"*)
			echo "Suspend Job: ${proc}  ${fifo}"
			kill_proc "${CHAT}" "${job}"
			killall="y"
			;;
		"killb"*)
			echo "Kill Job: ${proc}  ${fifo}"
			kill_proc "${CHAT}" "${job}"
			rm -f "${FILE}" # remove job
			killall="y"
			;;
		esac
	done
	# kill all requestet. kill ALL background jobs, even not listed in data-bot-bash
	[ "${killall}" = "y" ] && killallproc "back-"
}
