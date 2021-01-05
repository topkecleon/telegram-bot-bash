#!/bin/bash
# files: mycommands.sh.dist
# copy to mycommands.sh and add all your commands an functions here ...
export res

# your additional bashbot commands ...
mycommands() {

	case "${MESSAGE}" in
		'/run_'*) 
			myback="run_${MESSAGE#*_}"
			if [ -x "./${myback}.sh" ]; then
			    checkback "${myback}"
			    if [ "${res}" -gt 0 ] ; then
				send_normal_message "${CHAT[ID]}" "Start ${myback}, use /kill${myback} to stop it."
				background "./${myback}.sh" "${myback}"
			    else
				send_normal_message "${CHAT[ID]}" "Background job ${myback} already running."
			    fi
			fi
			;;
		'/kill_'*)
			myback="run_${MESSAGE#*_}"
			if [ -x "./${myback}.sh" ]; then
			    checkback "${myback}"
			    if [ "${res}" -eq 0 ] ; then
				killback "${myback}"
				send_normal_message "${CHAT[ID]}" "Stopping ${myback}, use /run_${myback} to start again."
			    else
				send_normal_message "${CHAT[ID]}" "No background job ${myback}."
			    fi
			fi
			;;
	esac
}

# place your additional processing functions here ...

# inifnite loop for waching a given dir for new files
# $1 dir to wtach for new files
watch_dir_loop() {
	local newfile old
	[ ! -d "$1" ] && echo "ERROR: no directory $1 found!" >&2 && exit 1
	# wait for new files in WATCHDIR
	inotifywait -q -m "$1" -e create --format "%f" \
	  | while true
	  do
		# read in newfile
		read -r newfile

		#skip if not match or same name as last time
		[ "${newfile}" = "${old}" ] && continue
		sleep 0.2

		# process content and output message
		echo "$(date): new file: ${newfile}" >>"$0.log"
		# note: loop callback must a function in the calling script! 
		if _is_function loop_callback ; then
			loop_callback "$1/${newfile}"
		else
			echo "ERROR: loop_callback not found!" >&2
			exit 1
		fi
	  done
} # 2>>"$0.log"


output_telegram() {
	# output to telegram
	sed <<< "${1}" -e ':a;N;$!ba;s/\n/ mynewlinestartshere /g'
} # 2>>"$0.log"

# name and location of the tml file

# $1 string to output
# $2 file to add file to
output_html_file() {
	local date
	date="$(date)"
	output_file "$(sed <<< "<div class=\"newdeal\">$1 <br>${date}</div>" '
	s/ my[a-z]\{3,15}\(start\|ends\)here.*<br>/<br>/g
	s/ *mynewlinestartshere */<br>/
	s/\n/<br>/
	')"
} # >>"$0.log" 2>&1

# $1 string to output
# $2 file to add file to
output_file() {
	local publish="${2}"
	[ ! -w "${publish}" ] && echo "ERROR: file ${publish} is not writeable or does not exist!" && exit
	
	# output at beginnung of file, add date to message
	sed <<< "${1}" '
	s/ *mynewlinestartshere */\n/
	s/ my[a-z]\{3,15}\(start\|ends\)here.*//g
	' >"${publish}$$"
	cat  "${publish}" >>"${publish}$$"
	mv "${publish}$$" "${publish}"
} # >>"$0.log" 2>&1

