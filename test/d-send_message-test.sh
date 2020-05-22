#!/usr/bin/env bash
#### $$VERSION$$ v0.96-dev-7-g0153928

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

_is_function send_message || echo "Send Message not found!"

# start writing your tests here ...

# over write sendJson to output parameter only
sendEmpty() {
	printf 'chat:%s\tJSON:%s\nURL:%s\n\n' "${1}" "${2}" "${3}"
}

sendJson() {
	printf 'chat:%s\tJSON:%s\nURL:%s\n\n' "${1}" "${2}" "${3}"
}
sendUpload() {
#JSON:"document":"/tmp/allowed/this_is_my.doc","caption":"Text plus absolute file will appear in chat""
	printf 'chat:%s\tJSON:"%s":"%s","caption":"%s"\nURL:%s\n\n' "${1}" "${2}" "${3}" "${5}" "${4}"
}

# send text input to send_message

echo -n "  Send line ..."

# create dummy files for upload
ALLOW='/tmp/allowed'
FILE_REGEX="$ALLOW/.*"
[ -d "$ALLOW" ] || mkdir "$ALLOW"
touch "$ALLOW/this_is_my.gif" "$ALLOW/this_is_my.doc"
touch "$DATADIR/this_is_my.gif" "$DATADIR/this_is_my.doc"

while read -r line ; do
	echo -n "."
	set -x
	send_message "123456" "$line" >>"${OUTPUTFILE}"
	set +x
done < "${INPUTFILE}" 2>>"${LOGFILE}"
[ -d "$ALLOW" ] && rm -rf "$ALLOW"

echo " done."

{ diff -c "${REFFILE}" "${OUTPUTFILE}" || exit 1; } | cat -v
echo "  ... all \"send_message\" functions seems to work as expected."
echo "${SUCCESS}"


