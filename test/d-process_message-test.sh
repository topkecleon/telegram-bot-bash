#!/usr/bin/env bash
#### $$VERSION$$ 0.70-dev-22-g26c8523

# include common functions and definitions
# shellcheck source=test/ALL-tests.inc.sh
source "./ALL-tests.inc.sh"

set -e

# source bashbot.sh functionw
cd "${TESTDIR}" || exit 1
# shellcheck source=./bashbot.sh
source "${TESTDIR}/bashbot.sh" source

# overwrite get_file for test
get_file() {
	echo "$1"
}

# get telegram input from file
export UPDATE
UPDATE="$(cat "${INPUTFILE}")"

set -x
process_message "0" >>"${LOGFILE}" 2>&1; set +x
cd "${DIRME}" || exit 1

# output processed input
echo "Diff process_message input and output ..."
print_array "USER" "CHAT" "REPLYTO" "FORWARD" "URLS" "CONTACT" "CAPTION" "LOCATION" "MESSAGE" >"${OUTPUTFILE}"
diff -c "${REFFILE}" "${OUTPUTFILE}" || exit 1

echo "${SUCCESS}"
