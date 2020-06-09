#!/usr/bin/env bash
#
# ADD a new test skeleton to test dir, but does not activate test
#
#### $$VERSION$$ v0.96-dev-7-g0153928

# magic to ensure that we're always inside the root of our application,
# no matter from which directory we'll run script
GIT_DIR=$(git rev-parse --git-dir)
cd "${GIT_DIR}/.." || exit 1

echo -ne "\\nDo your really want to create an new test for bashbot test suite? (y/N) N\\b"
read -r REALLY

[ "${REALLY}" != "y" ] && echo "Aborting ..." && exit 1

# enter name
echo -ne "\\nEnter Name for the the new test, 6+ chars, no :space: (empty to abort) abort\\b\\b\\b\\b\\b"
read -r NAME

if [ "${NAME}" = "" ] || [ "${NAME}" = "" ]; then echo "Aborting ..."; exit 1; fi

# enter pass a-z
echo -ne "\\nEnter PASS \"a\" to \"z\" to execute the new test,  d\\b"
read -r PASS

# pass to lower, default pass d 
PASS="${PASS,,}" 
[ "${PASS}" = "" ] && PASS="d"
[ "${#PASS}" != '1' ] && echo "Sorry, PASS must exactly one charater from a to z, aborting ..." && exit 1

TEST="${PASS}-${NAME}-test"

echo -e "  OK! You entered name \"${NAME}\" and pass \"${PASS}\".\\n"

# check if already exist
if [ -f "test/${TEST}.sh" ] || [ -d "test/${TEST}" ]; then
	echo "TEST EXIST ALREADY! Aborting ..."
	exit 1
fi

echo "The following files will be created for test \"${TEST}.sh\":"
echo -e "   test/${TEST}.sh\\n   test/${TEST}/${TEST}.input\\n   test/${TEST}/${TEST}.result"

echo -ne "\\nCreate the new test for bashbot test suite? (y/N) N\\b"
read -r REALLY

[ "${REALLY}" != "y" ] && echo "Aborting ..." && exit 1

echo -e "    OK!\\n"

# create files
cat >"test/${TEST}.sh" <<EOF 
#!/usr/bin/env bash
#### \$\$VERSION\$\$

# include common functions and definitions
# shellcheck source=test/ALL-tests.inc.sh
source "./ALL-tests.inc.sh"

set -e

cd "\${TESTDIR}" || exit 1

# source bashbot.sh function, uncomment if you want to test functions
# shellcheck source=./bashbot.sh
# source "\\${TESTDIR}/bashbot.sh" source
# source "\\${TESTDIR}/commands.sh" source 

# start writing your tests here ...

EOF

mkdir "test/${TEST}"
touch "test/${TEST}/${TEST}.input" "test/${TEST}/${TEST}.result"

set +f
ls -l test/"${PASS}"-"${NAME}"-*

echo "Done."
