#!/usr/bin/env bash
###################################################################
#
# File: make-standalone.sh
#
# Description:
#    even after make-distribution.sh bashbot is not self contained as it was in the past.
#
# Options: --notest
#
#   If you your bot is finished you can use make-standalone.sh to create the
#    the old all-in-one bashbot:  bashbot.sh and commands.sh only!
#
#### $$VERSION$$ v1.51-0-g6e66a28
###################################################################

# include git config and change to base dir
incfile="${0%/*}/dev.inc.sh"
#shellcheck disable=SC1090
[ -f "${incfile}" ] && source "${incfile}"

# seems we are not in a dev env
if [ -z "${BASE_DIR}" ]; then
	BASE_DIR="$(pwd)"
	[[ "${BASE_DIR}" == *"/dev" ]] &&  BASE_DIR="${BASE_DIR%/*}"
	# go to basedir
	cd "${BASE_DIR}" || exit 1
fi

# see if if bashbot is in base dir
[ ! -f "bashbot.sh" ] && printf "bashbot.sh not found in %s\n" " $(pwd)" && exit 1

# run pre_commit if exist
[[ -f "dev/dev.inc.sh"  && "$1" != "--notest" ]] &&  dev/hooks/pre-commit.sh

# files and dirs to copy
#DISTNAME="telegram-bot-bash"
DISTDIR="./STANDALONE" 
DISTMKDIR="data-bot-bash logs bin/logs addons"
DISTFILES="bashbot.sh commands.sh mycommands.sh modules scripts LICENSE README.* doc addons"
DISTBINFILES="bin/bashbot_env.inc.sh bin/bashbot_stats.sh bin/process_batch.sh bin/process_update.sh bin/send_broadcast.sh bin/send_message.sh"

# add extra files, minimum mycommands.conf
extrafile="${BASE_DIR}/dev/${0##*/}.include"
[ ! -f "${extrafile}" ] && printf "bashbot.rc\nbotacl\nbotconfig.jssh\nmycommands.conf\ndev/obfuscate.sh\n" >"${extrafile}" 
DISTFILES+=" $(<"${extrafile}")"

# create dir for distribution and copy files
printf "Create directories and copy files\n"
mkdir -p "${DISTDIR}/bin" 2>/dev/null
# shellcheck disable=SC2086
cp -rp ${DISTFILES} "${DISTDIR}" 2>/dev/null
# shellcheck disable=SC2086
cp -p ${DISTBINFILES} "${DISTDIR}/bin" 2>/dev/null

cd "${DISTDIR}" || exit 1

# remove log files
find . -name '*.log' -delete

# shellcheck disable=SC2250
for dir in $DISTMKDIR
do
	[ ! -d "${dir}" ] && mkdir "${dir}"
done

# inject JSON.sh into distribution
# shellcheck disable=SC1090
source "${BASE_DIR}/dev/inject-json.sh"

#######################
# here the magic starts
# create all in one bashbot.sh file

printf "OK, now lets do the magic ...\n\t... create unified commands.sh\n"

{ 
  # first head of commands.sh
  sed -n '0,/^if / p' commands.sh | grep -v -F -e "___" -e "*MUST*" -e "mycommands.sh.dist" -e "mycommands.sh.clean"| head -n -2 

  # then mycommands from first non comment line on
  printf '\n##############################\n# my commands starts here ...\n'
  sed -n '/^$/,$ p' mycommands.sh

  # last tail of commands.sh
  printf '\n##############################\n# default commands starts here ...\n'
  sed -n '/source .*\/mycommands.sh"/,$ p' commands.sh | tail -n +2 

} >>$$commands.sh

mv $$commands.sh commands.sh
rm -f mycommands.sh

printf "\t... create unified bashbot.sh\n"

{ 
  # first head of bashbot.sh
  sed -n '0,/for module in/ p' bashbot.sh | head -n -3

  # then modules without shebang
  printf '\n##############################\n# bashbot modules starts here ...\n'
  # shellcheck disable=SC2016
  cat modules/*.sh | sed -e 's/^#\!\/bin\/bash.*//' -e '/^#.*\$\$VERSION\$\$/d' 

  # last remaining commands.sh
  printf '\n##############################\n'
  sed -n '/^# read commands file/,$ p' bashbot.sh

} >>$$bashbot.sh

mv $$bashbot.sh bashbot.sh
chmod +x bashbot.sh

rm -rf modules

printf "Create minimized Version of bashbot.sh and commands.sh\n"
# shellcheck disable=SC2016
sed -E -e '/(shellcheck)|(^#!\/)|(\$\$VERSION\$\$)/! s/^[[:space:]]*#.*//' -e '/shellcheck/! s/\t+#.*//' -e 's/^[[:space:]]*//'\
	 -e '/^$/d' bashbot.sh | sed 'N;s/\\\n/ /;P;D' | sed 'N;s/\\\n/ /;P;D' > bashbot.sh.min
# shellcheck disable=SC2016
sed -E -e '/(shellcheck)|(^#!\/)|(\$\$VERSION\$\$)/! s/^[[:space:]]*#.*//' -e '/shellcheck/! s/\t+#.*//' -e 's/^[[:space:]]*//'\
	  -e '/^$/d' commands.sh | sed 'N;s/\\\n/ /;P;D' > commands.sh.min
chmod +x bashbot.sh.min

# make html doc
printf "Create html doc\n"
#shellcheck disable=SC1090
source "${BASE_DIR}/dev/make-html.sh"

printf "%s Done!\n" "$0"

cd .. || exit 1

printf "\nStandalone bashbot files are now available in %s:\n\n" "${DISTDIR}"
ls -l "${DISTDIR}"

