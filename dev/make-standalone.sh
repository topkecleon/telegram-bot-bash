#!/usr/bin/env bash
# file: make-standalone.sh
# even after make-distribution.sh bashbot is not self contained as it was in the past.
#
# If you your bot is finished you can use make-standalone.sh to create the
# the old all-in-one bashbot:  bashbot.sh and commands.sh only!
#
#### $$VERSION$$ v0.96-dev-7-g0153928

# magic to ensure that we're always inside the root of our application,
# no matter from which directory we'll run script
GIT_DIR=$(git rev-parse --git-dir 2>/dev/null)
if [ "$GIT_DIR" != "" ] ; then
	cd "$GIT_DIR/.." || exit 1
else
	[ ! -f "bashbot.sh" ] && echo "bashbot.sh not found in $(pwd)" && exit 1
fi

#DISTNAME="telegram-bot-bash"
DISTDIR="./STANDALONE/${DISTNAME}" 
DISTFILES="bashbot.sh  commands.sh  mycommands.sh modules LICENSE README.txt token count botacl botadmin"

# run tests first!

for test in "dev/all-tests.sh"
do
   [ ! -x "${test}" ] && continue
   if ! "${test}" ; then
	echo "Test ${test} failed, can't create standalone!"
	exit 1
  fi
done

# create dir for distribution and copy files
mkdir -p "${DISTDIR}" 2>/dev/null
# shellcheck disable=SC2086
cp -r ${DISTFILES} "${DISTDIR}" 2>/dev/null
cd "${DISTDIR}" || exit 1

#######################
# here the magic starts
# create all in one bashbot.sh file

echo "OK, noe lets do the magic ..."
echo "    ... create unified commands.sh"

{ 
  # first head of commands.sh
  sed -n '0,/^if / p' commands.sh | head -n -2 | grep -v 'mycommands.sh'

  # then mycommands from first non comment line on
  printf '\n##############################\n# my commands starts here ...\n'
  sed -n '/^$/,$ p' mycommands.sh

  # last tail of commands.sh
  printf '\n##############################\n# default commands starts here ...\n'
  sed -n '/\/mycommands.sh"/,$ p' commands.sh | tail -n +2 

} >>$$commands.sh

mv $$commands.sh commands.sh
rm -f mycommands.sh

echo "    ... create unified bashbot.sh"

{ 
  # first head of bashbot.sh
  sed -n '0,/for modules in/ p' bashbot.sh | head -n -3

  # then mycommands from first non comment line on
  printf '\n##############################\n# bashbot modules starts here ...\n'
  cat modules/*.sh | sed -e 's/^#\!\/bin\/bash.*//' 

  # last tail of commands.sh
  printf '\n##############################\n# bashbot internal functions starts here ...\n\n'
  sed -n '/BASHBOT INTERNAL functions/,$ p' bashbot.sh | head -n -4

} >>$$bashbot.sh

mv $$bashbot.sh bashbot.sh
chmod +x bashbot.sh

rm -rf modules

echo "Done!"

cd .. || exit 1

echo -e "\\nStandalone bashbot files are now availible in \"${DISTDIR}\":\\n"
ls -l "${DISTDIR}"*

