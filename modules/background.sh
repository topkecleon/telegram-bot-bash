#!/bin/bash
# file: modules/background.sh
# do not edit, this file will be overwritten on update

# This file is public domain in the USA and all free countries.
# Elsewhere, consider it to be WTFPLv2. (wtfpl.net/txt/copying)
#
# shellcheck disable=SC1117,SC2059
#### $$VERSION$$ v1.51-0-g6e66a28

# will be automatically sourced from bashbot

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

# inline and background functions
# $1 chatid
# $2 program
# $3 jobname
# $4 $5 parameters
start_back() {
	local cmdfile; cmdfile="${DATADIR:-.}/$(procname "$1")$3-back.cmd"
	printf '%s\n' "$1:$3:$2" >"${cmdfile}"
	restart_back "$@"
}
# $1 chatid
# $2 program
# $3 jobname
# $4 $5 parameters
restart_back() {
	local fifo; fifo="${DATADIR:-.}/$(procname "$1" "back-$3-")"
	log_update "Start background job CHAT=$1 JOB=${fifo##*/} CMD=${2##*/} $4 $5"
	check_back "$1" "$3" && kill_proc "$1" "back-$3-"
	nohup bash -c "{ $2 \"$4\" \"$5\" \"${fifo}\" | \"${SCRIPT}\" outproc \"$1\" \"${fifo}\"; }" &>>"${fifo}.log" &
	sleep 0.5	# give bg job some time to init
}


# $1 chatid
# $2 program
# $3 $4 parameters
start_proc() {
	[ -z "$2" ] && return
	[ -x "${2%% *}" ] || return 1
	local fifo; fifo="${DATADIR:-.}/$(procname "$1")"
	check_proc "$1" && kill_proc "$1"
	mkfifo "${fifo}"
	log_update "Start interactive script CHAT=$1 JOB=${fifo##*/} CMD=$2 $3 $4"
	nohup bash -c "{ $2 \"$4\" \"$5\" \"${fifo}\" | \"${SCRIPT}\" outproc \"$1\" \"${fifo}\"
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
	if [ -n "${prid}" ]; then
		log_update "Stop interactive / background CHAT=$1 JOB=${fifo##*/}"
		kill ${prid}
	fi
	[ -s "${fifo}.log" ] || rm -f "${fifo}.log"
	[ -p "${fifo}" ] && rm -f "${fifo}";
}

# $1 chatid
# $2 message
send_interactive() {
	local fifo; fifo="${DATADIR:-.}/$(procname "$1")"
	[ -p "${fifo}" ] && printf '%s\n' "$2" >"${fifo}" &	# not blocking!
}

# old style but may not work because of local checks
inproc() {
	send_interactive "${CHAT[ID]}" "${MESSAGE[0]}"
}

# start stop all jobs 
# $1 command #	kill suspend resume restart
job_control() {
	local BOT ADM content proc CHAT job fifo killall=""
	BOT="$(getConfigKey "botname")"
	ADM="${BOTADMIN}"
	debug_checks "Enter job_control" "$1"
	# cleanup on start
	[[ "$1" == "re"* ]] && bot_cleanup "startback"
	for FILE in "${DATADIR:-.}/"*-back.cmd; do
		[ "${FILE}" = "${DATADIR:-.}/*-back.cmd" ] && printf "${RED}No background processes.${NN}" && break
		content="$(< "${FILE}")"
		CHAT="${content%%:*}"
		job="${content#*:}"
		proc="${job#*:}"
		job="${job%:*}"
		fifo="$(procname "${CHAT}" "${job}")" 
		debug_checks "Execute job_control" "$1" "${FILE##*/}"
		case "$1" in
		"resume"*|"restart"*)
			printf "Restart Job: %s %s\n" "${proc}" " ${fifo##*/}"
			restart_back "${CHAT}" "${proc}" "${job}"
			# inform botadmin about stop
			[ -n "${ADM}" ] && send_normal_message "${ADM}" "Bot ${BOT} restart background jobs ..." &
			;;
		"suspend"*)
			printf "Suspend Job: %s %s\n" "${proc}" " ${fifo##*/}"
			kill_proc "${CHAT}" "${job}"
			# inform botadmin about stop
			[ -n "${ADM}" ] && send_normal_message "${ADM}" "Bot ${BOT} suspend background jobs ..." &
			killall="y"
			;;
		"kill"*)
			printf "Kill Job: %s %s\n" "${proc}" " ${fifo##*/}"
			kill_proc "${CHAT}" "${job}"
			rm -f "${FILE}"	# remove job
			# inform botadmin about stop
			[ -n "${ADM}" ] && send_normal_message "${ADM}" "Bot ${BOT} kill  background jobs ..." &
			killall="y"
			;;
		esac
		# send message only onnfirst job
		ADM=""
	done
	debug_checks "end job_control" "$1"
	# kill all requestet. kill ALL background jobs, even not listed in data-bot-bash
	[ "${killall}" = "y" ] && killallproc "back-"
}
