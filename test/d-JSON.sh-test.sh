#!/usr/bin/env bash
#### $$VERSION$$ v1.52-1-g0dae2db

# include common functions and definitions
# shellcheck source=test/ALL-tests.inc.sh
source "./ALL-tests.inc.sh"

set -e

# source bashbot.sh functionw
cd "${TESTDIR}" || exit 1

# run JSON.sh with and without options
cd "test" || exit 1
printf "Check JSON.sh ...\n"
JSON="../JSON.sh/JSON.sh"

for i in 1 2
do
    [ "${i}" = "1" ] && printf "  ... JSON.sh -b -n\n"
    [ "${i}" = "2" ] && printf "  ... JSON.sh\n"
    set +f
    for jsonfile in "${REFDIR}"/*.in
    do
	set -f
	[ "${i}" = "1" ] && "${JSON}" -b -n <"${jsonfile}"  >"${jsonfile}.out-${i}"
	[ "${i}" = "2" ] && "${JSON}"  <"${jsonfile}"  >"${jsonfile}.out-${i}"

	# output processed input
	diff -c "${jsonfile%.in}.result-${i}" "${jsonfile}.out-${i}" || exit 1
    done
    printf "%s\n" "${SUCCESS}"
done

cd "${DIRME}" || exit 1
