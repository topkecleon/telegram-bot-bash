#!/usr/bin/env bash
#### $$VERSION$$ v0.96-dev-7-g0153928

# include common functions and definitions
# shellcheck source=test/ALL-tests.inc.sh
source "./ALL-tests.inc.sh"

set -e

# source bashbot.sh functionw
cd "${TESTDIR}" || exit 1

# run JSON.sh with and without options
cd "test" || exit 1
echo "Check JSON.sh ..."
JSON="../JSON.sh/JSON.sh"

for i in 1 2
do
    [ "${i}" = "1" ] && echo "  ... JSON.sh -s -b -n"
    [ "${i}" = "2" ] && echo "  ... JSON.sh"
    set +f
    for jsonfile in "${REFDIR}"/*.in
    do
	set -f
	[ "${i}" = "1" ] && "${JSON}"  -s -b -n <"${jsonfile}"  >"${jsonfile}.out-${i}"
	[ "${i}" = "2" ] && "${JSON}"  <"${jsonfile}"  >"${jsonfile}.out-${i}"

	# output processed input
	diff -c "${jsonfile%.in}.result-${i}" "${jsonfile}.out-${i}" || exit 1
    done
    echo "${SUCCESS}"
done

cd "${DIRME}" || exit 1
