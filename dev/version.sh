#!/bin/bash
#
#### $$VERSION$$ v1.25-dev-33-g04e3c18
# shellcheck disable=SC2016
#
# Easy Versioning in git:
#
# for setting your Version in git use e.g.:
# git tag -a v0.5 -m 'Version 0.5'
#
# Push tags upstream—this is not done by default:
# git push --tags
#
# # in case of a wrong tag remove it:
# git tag -d v0.5
#
# delete remote tag (eg, GitHub version)
# git push origin :refs/tags/v0.5
#
# Then use the describe command:
#
# git describe --tags --long
# This gives you a string of the format:
# 
# v0.5-0-gdeadbee
# ^    ^ ^^
# |    | ||
# |    | |'-- SHA of HEAD (first seven chars)
# |    | '-- "g" is for git
# |    '---- number of commits since last tag
# |
# '--------- last tag
#
# run this script to (re)place Version number in files
#

# magic to ensure that we're always inside the root of our application,
# no matter from which directory we'll run script
GIT_DIR=$(git rev-parse --git-dir 2>/dev/null)
if [ "${GIT_DIR}" != "" ] ; then
	cd "${GIT_DIR}/.." || exit 1
else
	printf "Sorry, no git repository %s\n" "$(pwd)" && exit 1
fi

unset IFS
# set -f # if you are paranoid use set -f to disable globbing

VERSION="$(git describe --tags --long)"
printf "Update to version %s ...\n" "${VERSION}"

FILES="$(find ./*)"
[ "$1" != "" ] && FILES="$*"

# autogenerate REMADME.html REMADE.txt
if [[ "${FILES}" == *"README.md"* ]]; then
	FILES+=" README.html README.txt"
	type -f pandoc >/dev/null && pandoc -s -f commonmark -M "title=Bashbot README" README.md >README.html
	if type -f html2text >/dev/null; then
		html2text -style pretty -width 90  README.html >README.txt
	else
		type -f fold >/dev/null && fold -s -w 90 README.md >README.txt
	fi
fi

# change version string in given files
for file in ${FILES}
do
	[ ! -f "${file}" ] && continue
	#[ "${file}" == "version" ] && continue
	printf "%s" " ${file}" >&2
	sed -i 's/^#### $$VERSION$$.*/#### \$\$VERSION\$\$ '"${VERSION}"'/' "${file}"
done

printf " done.\n"

