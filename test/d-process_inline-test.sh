#!/usr/bin/env bash
#### $$VERSION$$ v0.96-dev-7-g0153928

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
	echo "$1"
}

# get telegram input from file
export UPDATE UPD
UPDATE="$(cat "${INPUTFILE}")"
declare -A UPD
source <( printf 'UPD=( %s )' "$(sed <<<"${UPDATE}" -E -e 's/\t/=/g' -e 's/=(true|false)/="\1"/')" )

# run process_message with and without phyton
echo "Check process_inline ..."
for i in 1 2
do
	[ "${i}" = "1" ] && ! command -v python >/dev/null 2>&1 && continue
	[ "${i}" = "1" ] && echo "  ... with JsonDecode Phyton" && unset BASHBOT_DECODE
	[ "${i}" = "2" ] && echo "  ... with JsonDecode Bash" && export BASHBOT_DECODE="yes"
	set -x
	{ process_inline "0";  set +x; } >>"${LOGFILE}" 2>&1;

	# output processed input
	print_array "iQUERY" >"${OUTPUTFILE}"
	diff -c "${REFFILE}" "${OUTPUTFILE}" || exit 1
	echo "${SUCCESS}"
done

cd "${DIRME}" || exit 1
