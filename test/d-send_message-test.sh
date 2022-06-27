#!/usr/bin/env bash
#===============================================================================
#
#          FILE: d-send_message-test.sh
# 
#         USAGE: must run only from dev/all-tests.sh
#
#   DESCRIPTION: test sending messages
# 
#	LICENSE: WTFPLv2 http://www.wtfpl.net/txt/copying/
#        AUTHOR: KayM (gnadelwartz), kay@rrr.de
#
#### $$VERSION$$ v1.52-1-g0dae2db
#===============================================================================

# include common functions and definitions
# shellcheck source=test/ALL-tests.inc.sh
source "./ALL-tests.inc.sh"

set -e
set +f

cd "${TESTDIR}" || exit 1

# source bashbot.sh function, uncomment if you want to test functions
# shellcheck source=./bashbot.sh
source "${TESTDIR}/bashbot.sh" source
# shellcheck source=./bashbot.sh
source "${TESTDIR}/commands.sh" source

_is_function send_message || printf "Send Message not found!\n"

# start writing your tests here ...

# over write sendJson to output parameter only
sendEmpty() {
	printf 'chat:%s\tJSON:%s\nURL:%s\n\n' "$1" "$2" "$3"
}

sendJson() {
	printf 'chat:%s\tJSON:%s\nURL:%s\n\n' "$1" "$2" "$3"
}
sendUpload() {
#JSON:"document":"/tmp/allowed/this_is_my.doc","caption":"Text plus absolute file will appear in chat""
	printf 'chat:%s\tJSON:"%s":"%s","caption":"%s"\nURL:%s\n\n' "$1" "$2" "$3" "$5" "$4"
}

# send text input to send_message

printf "  Send line ..."

# create dummy files for upload
ALLOW='/tmp/allowed'
FILE_REGEX="${ALLOW}/.*"
[ -d "${ALLOW}" ] || mkdir "${ALLOW}"
touch "${ALLOW}/this_is_my.gif" "${ALLOW}/this_is_my.doc"
touch "${DATADIR}/this_is_my.gif" "${DATADIR}/this_is_my.doc"

while read -r line ; do
	set -x; set +e
	send_message "123456" "${line}" >>"${OUTPUTFILE}"
	set +x; set -e
	printf "."
done < "${INPUTFILE}" 2>>"${LOGFILE}"
[ -d "${ALLOW}" ] && rm -rf "${ALLOW}"

printf " done.\n"

{ compare_sorted "${REFFILE}" "${OUTPUTFILE}" || exit 1; } | cat -v
rm -f "${REFFILE}.sort"

printf "  ... all \"send_message\" functions seems to work as expected.\n"

printf "%s\n" "${SUCCESS}"


