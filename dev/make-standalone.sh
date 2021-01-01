#!/usr/bin/env bash
###################################################################
#
# File: make-standalone.sh
#
# Description:
#    even after make-distribution.sh bashbot is not self contained as it was in the past.
#
#   If you your bot is finished you can use make-standalone.sh to create the
#    the old all-in-one bashbot:  bashbot.sh and commands.sh only!
#
#### $$VERSION$$ v1.21-pre-4-g3193169
###################################################################

# magic to ensure that we're always inside the root of our application,
# no matter from which directory we'll run script
GIT_DIR=$(git rev-parse --git-dir 2>/dev/null)
if [ "$GIT_DIR" != "" ] ; then
	[[ "$GIT_DIR" != "/"* ]] && GIT_DIR="${PWD}/${GIT_DIR}"
	cd "$GIT_DIR/.." || exit 1
else
	[ ! -f "bashbot.sh" ] && printf "bashbot.sh not found in %s\n" " $(pwd)" && exit 1
fi

#DISTNAME="telegram-bot-bash"
DISTDIR="./STANDALONE/${DISTNAME}" 
DISTFILES="bashbot.sh  bashbot.rc commands.sh  mycommands.sh dev/obfuscate.sh modules scripts logs LICENSE README.* doc botacl botconfig.jssh"

# run pre_commit on files
dev/hooks/pre-commit.sh

# create dir for distribution and copy files
mkdir -p "${DISTDIR}" 2>/dev/null
# shellcheck disable=SC2086
cp -r ${DISTFILES} "${DISTDIR}" 2>/dev/null
cd "${DISTDIR}" || exit 1

# inject JSON.sh into distribution
# shellcheck disable=SC1090
source "$GIT_DIR/../dev/inject-json.sh"

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
  sed -n '0,/for modules in/ p' bashbot.sh | head -n -3

  # then mycommands from first non comment line on
  printf '\n##############################\n# bashbot modules starts here ...\n'
  cat modules/*.sh | sed -e 's/^#\!\/bin\/bash.*//' 

  # last tail of commands.sh
  printf '\n##############################\n# bashbot internal functions starts here ...\n\n'
  sed -n '/BASHBOT INTERNAL functions/,$ p' bashbot.sh

} >>$$bashbot.sh

mv $$bashbot.sh bashbot.sh
chmod +x bashbot.sh

rm -rf modules

printf "Create minimized Version of bashbot.sh and commands.sh\n"
sed -E -e '/(shellcheck)|(#!\/bin\/bash)/! s/^[[:space:]]*#.*//' -e 's/^[[:space:]]*//' -e '/^$/d' -e 'N;s/\\\n/ /;P;D' bashbot.sh |\
	sed 'N;s/\\\n/ /;P;D' > bashbot.sh.min
sed -E -e '/(shellcheck)|(#!\/bin\/bash)/! s/^[[:space:]]*#.*//' -e 's/^[[:space:]]*//' -e 's/\)[[:space:]]+#.*/)/' -e '/^$/d' commands.sh |\
	sed 'N;s/\\\n/ /;P;D' > commands.sh.min
chmod +x bashbot.sh.min

# make html doc
printf "Create html doc\n"
#shellcheck disable=SC1090
source "$GIT_DIR/../dev/make-html.sh"

printf "%s Done!\n" "$0"

cd .. || exit 1

printf "\nStandalone bashbot files are now available in %s:\n\n" "${DISTDIR}"
ls -l "${DISTDIR}"

