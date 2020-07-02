#!/usr/bin/env bash
#### $$VERSION$$ v0.98-0-g5b5447e

# include common functions and definitions
# shellcheck source=test/ALL-tests.inc.sh
source "./ALL-tests.inc.sh"

set -e

# source bashbot.sh functionw
cd "${TESTDIR}" || exit 1
# shellcheck source=./bashbot.sh
source "${TESTDIR}/bashbot.sh" source
# shellcheck source=./bashbot.sh
source "${TESTDIR}/commands.sh" source 

# overwrite get_file for test
get_file() {
	echo "$1"
}

# get telegram input from file
export UPDATE
declare -Ax UPD

# run process_message --------------
ARRAYS="USER CHAT REPLYTO FORWARD URLS CONTACT CAPTION LOCATION MESSAGE VENUE SERVICE NEWMEMBER LEFTMEMBER PINNED"

echo "Check process_message regular message..."

UPDATE="$(< "${INPUTFILE}")"
Json2Array 'UPD' <"${INPUTFILE}"
set -x
{ pre_process_message "0"; process_message "0";  set +x; } >>"${LOGFILE}" 2>&1;
USER[ID]="123456789"; CHAT[ID]="123456789"

# output processed input
# shellcheck disable=SC2086
print_array ${ARRAYS}  >"${OUTPUTFILE}"
compare_sorted "${REFFILE}" "${OUTPUTFILE}" || exit 1

# run process_message ------------
echo "Check process_message service message..."

UPDATE="$(cat "${INPUTFILE2}")"
Json2Array 'UPD' <"${INPUTFILE2}"
set -x
{ pre_process_message "0"; process_message "0";  set +x; } >>"${LOGFILE}" 2>&1;
USER[ID]="123456789"; CHAT[ID]="123456789"

# output processed input
# shellcheck disable=SC2086
print_array ${ARRAYS}  >"${OUTPUTFILE}"
compare_sorted "${REFFILE2}" "${OUTPUTFILE}" || exit 1


echo "${SUCCESS}"

cd "${DIRME}" || exit 1
