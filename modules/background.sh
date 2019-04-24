#!/bin/bash
# file: modules/background.sh
# do not edit, this file will be overwritten on update

# This file is public domain in the USA and all free countries.
# Elsewhere, consider it to be WTFPLv2. (wtfpl.net/txt/copying)
#
#### $$VERSION$$ v0.70-dev2-17-g92ad9e4

# source from commands.sh if you want ro use interactive or background jobs

## to statisfy shellcheck
export res

####
# I placed send_message here because main use case is interactive chats and background jobs
send_message() {
	local text arg keyboard file lat long title address sent
	[ "$2" = "" ] && return 1
	local mychat="$1"
	text="$(echo "$2" | sed 's/ mykeyboardstartshere.*//g;s/ myfilelocationstartshere.*//g;s/ mylatstartshere.*//g;s/ mylongstartshere.*//g;s/ mytitlestartshere.*//g;s/ myaddressstartshere.*//g;s/ mykeyboardendshere.*//g')"
	arg="$3"
	[ "$arg" != "safe" ] && {
		text="${text// mynewlinestartshere /$'\r\n'}"
		no_keyboard="$(echo "$2" | sed '/mykeyboardendshere/!d;s/.*mykeyboardendshere.*/mykeyboardendshere/')"

		keyboard="$(echo "$2" | sed '/mykeyboardstartshere /!d;s/.*mykeyboardstartshere //g;s/ myfilelocationstartshere.*//g;s/ mylatstartshere.*//g;s/ mylongstartshere.*//g;s/ mytitlestartshere.*//g;s/ myaddressstartshere.*//g;s/ mykeyboardendshere.*//g')"

		file="$(echo "$2" | sed '/myfilelocationstartshere /!d;s/.*myfilelocationstartshere //g;s/ mykeyboardstartshere.*//g;s/ mylatstartshere.*//g;s/ mylongstartshere.*//g;s/ mytitlestartshere.*//g;s/ myaddressstartshere.*//g;s/ mykeyboardendshere.*//g')"

		lat="$(echo "$2" | sed '/mylatstartshere /!d;s/.*mylatstartshere //g;s/ mykeyboardstartshere.*//g;s/ myfilelocationstartshere.*//g;s/ mylongstartshere.*//g;s/ mytitlestartshere.*//g;s/ myaddressstartshere.*//g;s/ mykeyboardendshere.*//g')"

		long="$(echo "$2" | sed '/mylongstartshere /!d;s/.*mylongstartshere //g;s/ mykeyboardstartshere.*//g;s/ myfilelocationstartshere.*//g;s/ mylatstartshere.*//g;s/ mytitlestartshere.*//g;s/ myaddressstartshere.*//g;s/ mykeyboardendshere.*//g')"

		title="$(echo "$2" | sed '/mytitlestartshere /!d;s/.*mylongstartshere //g;s/ mykeyboardstartshere.*//g;s/ myfilelocationstartshere.*//g;s/ mylatstartshere.*//g;s/ myaddressstartshere.*//g;s/ mykeyboardendshere.*//g')"

		address="$(echo "$2" | sed '/myaddressstartshere /!d;s/.*mylongstartshere //g;s/ mykeyboardstartshere.*//g;s/ myfilelocationstartshere.*//g;s/ mylatstartshere.*//g;s/ mytitlestartshere.*//g;s/ mykeyboardendshere.*//g')"

	}
	if [ "$no_keyboard" != "" ]; then
		echo "remove_keyboard $mychat $text" > "${TMPDIR:-.}/prova"
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
	if [ "$file" != "" ]; then
		send_file "$mychat" "$file" "$text"
		sent=y
	fi
	if [ "$lat" != "" ] && [ "$long" != "" ] && [ "$address" = "" ] && [ "$title" = "" ]; then
		send_location "$mychat" "$lat" "$long"
		sent=y
	fi
	if [ "$lat" != "" ] && [ "$long" != "" ] && [ "$address" != "" ] && [ "$title" != "" ]; then
		send_venue "$mychat" "$lat" "$long" "$title" "$address"
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
