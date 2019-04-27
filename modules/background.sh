#!/bin/bash
# file: modules/background.sh
# do not edit, this file will be overwritten on update

# This file is public domain in the USA and all free countries.
# Elsewhere, consider it to be WTFPLv2. (wtfpl.net/txt/copying)
#
#### $$VERSION$$ v0.70-pre1-4-g0d38a67

# source from commands.sh if you want ro use interactive or background jobs

## to statisfy shellcheck
export res

####
# I placed send_message here because main use case is interactive chats and background jobs
send_message() {
	local text arg keyboard btext burl no_keyboard file lat long title address sent
	[ "$2" = "" ] && return
	local mychat="$1"
	text="$(sed <<< "${2}" 's/ mynewlinestartshere/\r\n/g; s/ my[kfltab][a-z]\{2,13\}startshere.*//g;s/ mykeyboardendshere.*//g')"
	arg="$3"
	[ "$arg" != "safe" ] && {
		no_keyboard="$(sed <<< "${2}" '/mykeyboardendshere/!d;s/.*mykeyboardendshere.*/mykeyboardendshere/')"
		keyboard="$(sed <<< "${2}" '/mykeyboardstartshere /!d;s/.*mykeyboardstartshere //g;s/ my[kfltab][a-z]\{2,13\}startshere.*//g;s/ mykeyboardendshere.*//g')"
		btext="$(sed <<< "${2}" '/mybtextstartshere /!d;s/.*mybtextstartshere //g;s/ my[kfltab][a-z]\{2,13\}startshere.*//g;s/ mykeyboardendshere.*//g')"
		burl="$(sed <<< "${2}" '/myburlstartshere /!d;s/.*myburlstartshere //g;s/ my[kfltab][a-z]\{2,13\}startshere.*//g;s/ mykeyboardendshere.*//g')"
		file="$(sed <<< "${2}" '/myfilelocationstartshere /!d;s/.*myfilelocationstartshere //g;s/ my[kfltab][a-z]\{2,13\}startshere.*//g;s/ mykeyboardendshere.*//g')"
		lat="$(sed <<< "${2}" '/mylatstartshere /!d;s/.*mylatstartshere //g;s/ my[kfltab][a-z]\{2,13\}startshere.*//g;s/ mykeyboardendshere.*//g')"
		long="$(sed <<< "${2}" '/mylongstartshere /!d;s/.*mylongstartshere //g;s/ my[kfltab][a-z]\{2,13\}startshere.*//g;s/ mykeyboardendshere.*//g')"
		title="$(sed <<< "${2}" '/mytitlestartshere /!d;s/.*mytitlestartshere //g;s/ my[kfltab][a-z]\{2,13\}startshere.*//g;s/ mykeyboardendshere.*//g')"
		address="$(sed <<< "${2}" '/myaddressstartshere /!d;s/.*myaddressstartshere //g;s/ my[kfltab][a-z]\{2,13\}startshere.*//g;s/ mykeyboardendshere.*//g')"
	}
	if [ "$no_keyboard" != "" ]; then
		remove_keyboard "$mychat" "$text"
		sent=y
	fi
	if [ "$keyboard" != "" ]; then
		if [[ "$keyboard" != *"["* ]]; then # pre 0.60 style
			keyboard="[ ${keyboard//\" \"/\" \] , \[ \"} ]"
		fi
		send_keyboard "$mychat" "$text" "$keyboard"
		sent=y
	fi
	if [ "$btext" != "" ] && [ "$burl" != "" ]; then
		send_button "$mychat" "$text" "$btext" "$burl"
		sent=y
	fi
	if [ "$file" != "" ]; then
		send_file "$mychat" "$file" "$text"
		sent=y
	fi
	if [ "$lat" != "" ] && [ "$long" != "" ]; then
		if [ "$address" != "" ] && [ "$title" != "" ]; then
			send_venue "$mychat" "$lat" "$long" "$title" "$address"
		else
			send_location "$mychat" "$lat" "$long"
		fi
		sent=y
	fi
	if [ "$sent" != "y" ];then
		send_text "$mychat" "$text"
	fi

}

send_text() {
	case "$2" in
		html_parse_mode*)
			send_html_message "$1" "${2//html_parse_mode}"
			;;
		markdown_parse_mode*)
			send_markdown_message "$1" "${2//markdown_parse_mode}"
			;;
		*)
			send_normal_message "$1" "$2"
			;;
	esac
}

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
	tmux ls | grep -q "$1${copname}"; res=$?; return $?
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
