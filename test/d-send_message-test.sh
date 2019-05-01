#!/usr/bin/env bash
#### $$VERSION$$ v0.70-0-g6243be9

# include common functions and definitions
# shellcheck source=test/ALL-tests.inc.sh
source "./ALL-tests.inc.sh"

set -e

cd "${TESTDIR}" || exit 1

# source bashbot.sh function, uncomment if you want to test functions
# shellcheck source=./bashbot.sh
source "${TESTDIR}/bashbot.sh" source
source "${TESTDIR}/modules/background.sh" 

# start writing your tests here ...

# over write sendJson to output parameter only
sendJson() {
	printf 'chat:%s\tJSON:%s\nURL:%s\n\n' "${1}" "${2}" "${3}"
}

# send text input to send_message

#set -x
echo -n "  Send line ..."
while IFS='' read -r line || [[ -n "$line" ]]; do
	echo -n "."
	send_message "123456" "$line" >>"${OUTPUTFILE}"
done < "${INPUTFILE}" 2>>"${LOGFILE}"
echo " done."

{ diff -c "${REFFILE}" "${OUTPUTFILE}" || exit 1; } | cat -v
echo "  ... all \"send_message\" functions seems to work as expected."
echo "${SUCCESS}"


