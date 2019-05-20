#!/usr/bin/env bash
#### $$VERSION$$ v0.80-pre-0-gdd7c66d

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

# send text input to send_message

echo -n "  Send line ..."

while read -r line ; do
	echo -n "."
	send_message "123456" "$line" >>"${OUTPUTFILE}"
done < "${INPUTFILE}" #2>>"${LOGFILE}"
echo " done."

{ diff -c "${REFFILE}" "${OUTPUTFILE}" || exit 1; } | cat -v
echo "  ... all \"send_message\" functions seems to work as expected."
echo "${SUCCESS}"


