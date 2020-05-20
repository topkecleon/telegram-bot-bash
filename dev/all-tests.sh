#!/usr/bin/env bash
# this has to run once atfer git clone
# and every time we create new hooks
#### $$VERSION$$ v0.96-dev-7-g0153928

# magic to ensure that we're always inside the root of our application,
# no matter from which directory we'll run script
GIT_DIR=$(git rev-parse --git-dir 2>/dev/null)
if [ "$GIT_DIR" != "" ] ; then
	cd "$GIT_DIR/.." || exit 1
else
	echo "Sorry, no git repository $(pwd)" && exit 1
fi

# create test environment
TESTENV="/tmp/bashbot.test$$"
mkdir "${TESTENV}"
cp -r ./* "${TESTENV}"
cd "test" || exit 1

#set -e
fail=0
tests=0
passed=0
#all_tests=${__dirname:}
#echo PLAN ${#all_tests}
for test in $(find ./*-test.sh | sort -u) ;
do
  [ "${test}" = "test/all-tests.sh" ] && continue
  [ ! -x "${test}" ] && continue
  tests=$((tests+1))
  echo "TEST: ${test}"
  "${test}" "${TESTENV}"
  ret=$?
  if [ "$ret" -eq 0 ] ; then
    echo "OK: ---- ${test}"
    passed=$((passed+1))
  else
    echo "FAIL: $test $fail"
    fail=$((fail+ret))
    break
  fi
done

if [ "$fail" -eq 0 ]; then
  /bin/echo -n 'SUCCESS '
  exitcode=0
  rm -rf "${TESTENV}"
else
  /bin/echo -n 'FAILURE '
  exitcode=1
  rm -rf "${TESTENV}/test"
  find "${TESTENV}/"* ! -name '[a-z]-*' -delete
fi

echo -e "${passed} / ${tests}\\n"
[ -d "${TESTENV}" ] && echo "Logfiles from run are in ${TESTENV}"

ls -ld /tmp/bashbot.test* 2>/dev/null && echo "Don not forget to deleted bashbot test files in /tmp!!"

exit ${exitcode}
