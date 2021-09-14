#!/bin/bash
# file. multibot.sh
# description:  run multiple telegram bots from one installation
#
#### $$VERSION$$ v1.51-0-g6e66a28

if [ "$2" = "" ] || [ "$2" = "-h" ]; then
	echo "Usage: $0 botname command"
	exit 1
fi

BOT="$1"
[ "${#BOT}" -lt 5 ] && echo "Botname must have a minimum length of 5 characters" && exit 1

# where should the bots live?
# true in one dir, false in separate dirs
if true; then
  # example for all in one bashbot dir
  BINDIR="/usr/local/telegram-bot-bash"
  ETC="${BINDIR}"
  VAR="${BINDIR}"

else
  # alternative Linux-like locations
  BINDIR="/usr/local/bin"
  ETC="/etc/bashbot"
  VAR="/var/bashbot"
  export BASHBOT_JSONSH="/usr/local/bin/JSON.sh"

fi

# set final ENV
export BASHBOT_ETC="${ETC}/${BOT}"
export BASHBOT_VAR="${VAR}/${BOT}"

# some checks
[ ! -d "${BINDIR}" ] && echo "Dir ${BINDIR} does not exist" && exit 1
[ ! -d "${BASHBOT_ETC}" ] && echo "Dir ${BASHBOT_ETC} does not exist" && exit 1
[ ! -d "${BASHBOT_VAR}" ] && echo "Dir ${BASHBOT_VAR} does not exist" && exit 1
[ ! -x "${BINDIR}/bashbot.sh" ] && echo "${BINDIR}/bashbot.sh not executable or does not exist" && exit 1
[ ! -r "${BASHBOT_ETC}/commands.sh" ] && echo "${BASHBOT_ETC}/commands.sh not readable or does not exist" && exit 1
[ ! -r "${BASHBOT_ETC}/mycommands.sh" ] && echo "${BASHBOT_ETC}/mycommands.sh not readable or does not exist" && exit 1

"${BINDIR}/bashbot.sh" "$2"
