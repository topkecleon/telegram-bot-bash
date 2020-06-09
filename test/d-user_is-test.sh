#!/usr/bin/env bash
#### $$VERSION$$ v0.96-dev-7-g0153928

# include common functions and definitions
# shellcheck source=test/ALL-tests.inc.sh
source "./ALL-tests.inc.sh"

set -e
set +f

cd "${TESTDIR}" || exit 1

# source bashbot.sh function, uncomment if you want to test functions
# shellcheck source=./bashbot.sh
source "${TESTDIR}/bashbot.sh" source
# shellcheck source=./bashbot.sh
source "${TESTDIR}/commands.sh" source 

# start writing your tests here ...

# first user asking for botadmin will botadmin
echo "Check \"user_is_botadmin\" ..."

echo '?' >"${ADMINFILE}" # auto mode

user_is_botadmin "BOTADMIN" || exit 1 # should never fail
user_is_botadmin "NOBOTADMIN" && exit 1 # should fail
user_is_botadmin "BOTADMIN" || exit 1 # same name as first one, should work

if [ "$(cat "${ADMINFILE}")" = "BOTADMIN" ]; then
	echo "  ... \"user_is_botadmin\" seems to work as expected."
else
	exit 1
fi
echo "${SUCCESS}"

# lets see If UAC works ...
echo "Check \"user_is_allowed\" ..."

echo "  ... with not rules"
user_is_allowed "NOBOTADMIN" "ANYTHING" && exit 1 # should always fail because no rules exist
user_is_allowed "BOTADMIN" "ANYTHING" && exit 1 # should fail even is BOTADMIN
echo "${SUCCESS}"

echo "  ... with BOTADMIN:*:*"
echo 'BOTADMIN:*:*' >"${ACLFILE}" # RULE allow BOTADMIN everything

user_is_allowed "BOTADMIN" "ANYTHING" || exit 1 # should work now
user_is_allowed "NOBOTADMIN" "ANYTHING" && exit 1 # should fail because user is not listed
echo "${SUCCESS}"

echo "  ... with NOBOTAMIN:SOMETHING:*"
echo 'NOBOTADMIN:SOMETHING:*' >>"${ACLFILE}" # RULE allow NOBOTADMIN something

user_is_allowed "BOTADMIN" "ANYTHING" || exit 1 # should work
user_is_allowed "BOTADMIN" "SOMETHING" || exit 1 # should work
user_is_allowed "NOBOTADMIN" "SOMETHING" || exit 1 # should work now
user_is_allowed "NOBOTADMIN" "ANYTHING" && exit 1 # should fail because only SOMETHING is listed 

echo "${SUCCESS}"

echo "  ... \"user_is_allowed\" seems to work as expected."

