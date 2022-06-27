#!/usr/bin/env bash
#===============================================================================
#
#          FILE: d-process_inline-test.sh
# 
#         USAGE: must run only from dev/all-tests.sh
#
#   DESCRIPTION: test response to inline messages
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

# source bashbot.sh functionw
cd "${TESTDIR}" || exit 1
# shellcheck source=./bashbot.sh
source "${TESTDIR}/bashbot.sh" source
# shellcheck source=./bashbot.sh
source "${TESTDIR}/modules/answerInline.sh" source

# overwrite get_file for test
get_file() {
	printf "%s\n" "$1"
}

# get telegram input from file
export UPDATE UPD
UPDATE="$(cat "${INPUTFILE}")"
declare -A UPD
source <( printf 'UPD=( %s )' "$(sed <<<"${UPDATE}" -E -e 's/\t/=/g' -e 's/=(true|false)/="\1"/')" )

# run process_message with and without python
printf "Check process_inline ...\n"
printf "  ... with JsonDecode Bash\n"
set -x
{ process_inline_query "0";  set +x; } >>"${LOGFILE}" 2>&1;

# output processed input
print_array "iQUERY" >"${OUTPUTFILE}"
compare_sorted "${REFFILE}" "${OUTPUTFILE}" || exit 1

printf "%s\n" "${SUCCESS}"

cd "${DIRME}" || exit 1
