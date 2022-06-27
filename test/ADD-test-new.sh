#!/usr/bin/env bash
#===============================================================================
#
#          FILE: ADD-test-new.sh
# 
#         USAGE: ADD-test-new.sh
#
#   DESCRIPTION: creates interactive a new test skeleton, but does not activate test
# 
#	LICENSE: WTFPLv2 http://www.wtfpl.net/txt/copying/
#        AUTHOR: KayM (gnadelwartz), kay@rrr.de
#
#### $$VERSION$$ v1.52-1-g0dae2db
#===============================================================================

# magic to ensure that we're always inside the root of our application,
# no matter from which directory we'll run script
GIT_DIR=$(git rev-parse --git-dir)
cd "${GIT_DIR}/.." || exit 1

printf "\nDo your really want to create an new test for bashbot test suite? (y/N) N\b"
read -r REALLY

[ "${REALLY}" != "y" ] && printf "Stop ...\n\n" && exit 1

# enter name
printf "\nEnter Name for the the new test, 6+ chars, no :space: (empty to stop) stop\b\b\b\b"
read -r NAME

if [ "${NAME}" = "" ] || [ "${NAME}" = "" ]; then printf "Stop ...\n\n"; exit 1; fi

# enter pass a-z
printf "\nEnter PASS \"a\" to \"z\" to execute the new test,  d\b"
read -r PASS

# pass to lower, default pass d 
PASS="${PASS,,}" 
[ "${PASS}" = "" ] && PASS="d"
[ "${#PASS}" != '1' ] && printf "SORRY: PASS must exactly one character from a to z! Stop ...\n\n" && exit 1

TEST="${PASS}-${NAME}-test"

printf "%s\n\n" "  OK! Let's create test name \"${NAME}\" for pass \"${PASS}\"."

# check if already exist
if [ -f "test/${TEST}.sh" ] || [ -d "test/${TEST}" ]; then
	printf "%s\n\n" "SORRY: Test test/${TEST}.sh already exists! Stop ..."
	exit 1
fi

printf "The following files will be created:\n"
printf "%s\n%s\n%s\n" "   test/${TEST}.sh" "   test/${TEST}/${TEST}.input" "   test/${TEST}/${TEST}.result"

printf "\nCreate the new test for bashbot test suite? (y/N) N\b"
read -r REALLY

[ "${REALLY}" != "y" ] && printf "Stop ...\n\n" && exit 1

printf "    OK!\n\n"

# create files
cat >"test/${TEST}.sh" <<EOF 
#!/usr/bin/env bash
#===============================================================================
#
#          FILE: test/${TEST}.sh
# 
#         USAGE: must run only from dev/all-tests.sh
#
#   DESCRIPTION: test ,,,
# 
#	LICENSE: WTFPLv2 http://www.wtfpl.net/txt/copying/
#        AUTHOR: yourname, your@e-mail.com
#
#### \$\$VERSION\$\$
#===============================================================================

# include common functions and definitions
# shellcheck source=test/ALL-tests.inc.sh
source "./ALL-tests.inc.sh"

set -e

cd "\${TESTDIR}" || exit 1

# source bashbot.sh function, uncomment if you want to test functions
# shellcheck source=./bashbot.sh
# source "\${TESTDIR}/bashbot.sh" source
# source "\${TESTDIR}/commands.sh" source 

# start writing your tests here ...

EOF

mkdir "test/${TEST}"
touch "test/${TEST}/${TEST}.input" "test/${TEST}/${TEST}.result"

set +f
ls -l test/"${PASS}"-"${NAME}"-*

printf "\nDone.\n"
