#!/usr/bin/env bash
#### $$VERSION$$ 0.70-dev-21-gd4cd756

# include common functions and definitions
# shellcheck source=test/ALL-tests.inc.sh
source "./ALL-tests.inc.sh"

set -e

# source bashbot.sh functionw
cd "${TESTDIR}" || exit 1
# shellcheck source=./bashbot.sh
source "${TESTDIR}/bashbot.sh" source

export UPDATE
UPDATE="$(cat ${DIRME}/${REFDIR}/${REFDIR}.input)"

# overwrite get_file for test
get_file() {
	echo "$1"
}

set -x
process_message "0" >>${LOGFILE} 2>&1
set +x
cd "${DIRME}" || exit 1

# output processed input

print_array() {
  local idx t
  local arrays=( "${@}" )
  for idx in "${arrays[@]}"; do
    declare -n temp="$idx"
	for t in "${!temp[@]}"; do 
  		printf "%s:\t%s\t%s\n" "$idx" "$t" "${temp[$t]}"
	done | sort
  done | grep -v '^USER:	0'
}

print_array "USER" "CHAT" "REPLYTO" "FORWARD" "URLS" "CONTACT" "CAPTION" "LOCATION" "MESSAGE"

echo "${SUCCESS}"
