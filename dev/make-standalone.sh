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
#### $$VERSION$$ v1.31-dev-13-g127cc85
###################################################################

#shellcheck disable=SC1090
source "${0%/*}/dev.inc.sh"
[ ! -f "bashbot.sh" ] && printf "bashbot.sh not found in %s\n" " $(pwd)" && exit 1

#DISTNAME="telegram-bot-bash"
DISTDIR="./STANDALONE" 
DISTMKDIR="data-bot-bash logs bin bin/logs addons"
DISTFILES="bashbot.sh  bashbot.rc commands.sh  mycommands.sh dev/obfuscate.sh modules bin scripts LICENSE README.* doc botacl botconfig.jssh $(echo "addons/"*.sh)"

# run pre_commit on files
[ "$1" != "--notest" ] &&  dev/hooks/pre-commit.sh

# create dir for distribution and copy files
printf "Create directories and copy files\n"
mkdir -p "${DISTDIR}" 2>/dev/null

# shellcheck disable=SC2086
cp -r ${DISTFILES} "${DISTDIR}" 2>/dev/null
cd "${DISTDIR}" || exit 1

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

printf "\n... create unified bashbot.sh\n"

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

