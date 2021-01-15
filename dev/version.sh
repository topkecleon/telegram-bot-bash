#!/bin/bash
#
#### $$VERSION$$ v1.30-dev-20-g541a279
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

#shellcheck disable=SC1090
source "${0%/*}/dev.inc.sh"

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
	cat "doc/bashbot.ascii" >"README.txt"
	if [ -r "README.html" ] && type -f html2text >/dev/null; then
		# convert html links to text [link]
		sed -E 's/<a href="([^>]+)">([^<#]+)<\/a>/\2 [\1]/' <README.html |\
		html2text -style pretty -width 90 - >>README.txt
	else
		type -f fold >/dev/null && fold -s -w 90 README.md >>README.txt
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

