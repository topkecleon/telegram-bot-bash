#!/usr/bin/env bash
# this has to run once atfer git clone
# and every time we create new hooks
#### $$VERSION$$ 0.70-dev-17-gb1aef7d

# magic to ensure that we're always inside the root of our application,
# no matter from which directory we'll run script
GIT_DIR=$(git rev-parse --git-dir)
cd "${GIT_DIR}/.." || exit 1

# create test environment
TESTENV="/tmp/bashbot.test$$"
cp -r . "${TESTENV}"

#cd "${TESTENV}" || exit 1

#set -e
fail=0
tests=0
passed=0
#all_tests=${__dirname:}
#echo PLAN ${#all_tests}
for test in $(find test/*-test.sh | sort -u) ;
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
else
  /bin/echo -n 'FAILURE '
  exitcode=1
fi

#rm -rf "${TESTENV}"
echo "${passed} / ${tests}"
exit ${exitcode}
