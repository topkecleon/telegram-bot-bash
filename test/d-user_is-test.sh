#!/usr/bin/env bash
#===============================================================================
#
#          FILE: d-user_is-test.sh
# 
#         USAGE: must run only from dev/all-tests.sh
#
#   DESCRIPTION: test user ACLs
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
set +f

cd "${TESTDIR}" || exit 1

# reset BOTADMIN
printf '["botadmin"]	"?"\n' >>"${ADMINFILE}" # auto mode

# source bashbot.sh function, uncomment if you want to test functions
# shellcheck source=./bashbot.sh
source "${TESTDIR}/bashbot.sh" source
# shellcheck source=./bashbot.sh
source "${TESTDIR}/commands.sh" source 

# start writing your tests here ...

# first user asking for botadmin will botadmin
printf "Check \"user_is_botadmin\" ...\n"

printf "BOTADMIN ...\n"
user_is_botadmin "BOTADMIN" || exit 1 # should never fail
printf "NOBOTADMIN ...\n"
user_is_botadmin "NOBOTADMIN" && exit 1 # should fail
printf "BOTADMIN ...\n"
user_is_botadmin "BOTADMIN" || exit 1 # same name as first one, should work

printf "Check config file ...\n"
if [ "$(getConfigKey "botadmin")" = "BOTADMIN" ]; then
	printf "  ... \"user_is_botadmin\" seems to work as expected.\n"
else
	exit 1
fi
printf "%s\n" "${SUCCESS}"

# lets see If UAC works ...
printf "Check \"user_is_allowed\" ...\n"

printf "  ... with not rules\n"
user_is_allowed "NOBOTADMIN" "ANYTHING" && exit 1 # should always fail because no rules exist
user_is_allowed "BOTADMIN" "ANYTHING" && exit 1 # should fail even is BOTADMIN
printf "%s\n" "${SUCCESS}"

printf "  ... with BOTADMIN:*:*\n"
printf 'BOTADMIN:*:*\n' >"${ACLFILE}" # RULE allow BOTADMIN everything

user_is_allowed "BOTADMIN" "ANYTHING" || exit 1 # should work now
user_is_allowed "NOBOTADMIN" "ANYTHING" && exit 1 # should fail because user is not listed
printf "%s\n" "${SUCCESS}"

printf "  ... with NOBOTAMIN:SOMETHING:*\n"
printf 'NOBOTADMIN:SOMETHING:*\n' >>"${ACLFILE}" # RULE allow NOBOTADMIN something

user_is_allowed "BOTADMIN" "ANYTHING" || exit 1 # should work
user_is_allowed "BOTADMIN" "SOMETHING" || exit 1 # should work
user_is_allowed "NOBOTADMIN" "SOMETHING" || exit 1 # should work now
user_is_allowed "NOBOTADMIN" "ANYTHING" && exit 1 # should fail because only SOMETHING is listed 

printf "%s\n" "${SUCCESS}"

printf "  ... \"user_is_allowed\" seems to work as expected.\n"

