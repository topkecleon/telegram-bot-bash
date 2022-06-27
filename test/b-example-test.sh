#!/usr/bin/env bash
#===============================================================================
#
#          FILE: b-example-test.sh
# 
#         USAGE: must run only from dev/all-tests.sh
#
#   DESCRIPTION: minimal test file as template
# 
#	LICENSE: WTFPLv2 http://www.wtfpl.net/txt/copying/
#        AUTHOR: KayM (gnadelwartz), kay@rrr.de
#
#### $$VERSION$$ v1.52-1-g0dae2db
#===============================================================================

# include common functions and definitions
# shellcheck source=test/ALL-tests.inc.sh
source "./ALL-tests.inc.sh"

###
# place your tests here ....

# example: test if TESTDIR contains file bashbot.sh
printf "Check if bashbot.sh exists in %s ...\n" " ${TESTDIR}"
if [ -f "${TESTDIR}/bashbot.sh" ]; then
	printf "    ... bashbot.sh found!\n"
else
	# stop test script if test failed
	printf "%s\n" "${NOSUCCESS} ${TESTDIR}/bashbot.sh missing!"
	exit 1
fi

# only if all tests was successful
printf "%s\n" "${SUCCESS}"

