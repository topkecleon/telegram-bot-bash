#!/usr/bin/env bash
#### $$VERSION$$ 0.70-dev-17-gb1aef7d

TOKENFILE="./token"
TESTTOKEN="bashbottestscript"
TESTME="$(basename "$0")"
NEWFILES="${TOKENFILE} botacl count botadmin JSON.sh/JSON.sh  tmp-bot-bash"

set -e

# let's fake failing test for now 
echo "Running bashbot init"
echo "............................" 
# change to test env
[ "$1" = "" ] && echo "not called from testsuite, exit" && exit
cd "$1" || exit 1


unset IFS; set -f

# run bashbot first time with init
export TERM=""
"${1}/bashbot.sh" init >"${TESTME}.log"  <<EOF
$TESTTOKEN
nobody
botadmin
EOF
echo "OK"

# files must exsit after init
echo "Check check new files ..."
for file in ${NEWFILES}
do
	ls -d "${file}" >/dev/null
done
echo "OK"

echo "Check value of token ..."
if [ "${TESTTOKEN}" = "$(cat "${TOKENFILE}")" ]; then
	echo "OK"
else
	echo "Token not correct or not written!"
	exit 1
fi

echo "Test Sourcing of bashbot.sh ..."
trap exit 1 EXIT

# shellcheck source=./bashbot.sh
source "$1/bashbot.sh" source
trap '' EXIT
