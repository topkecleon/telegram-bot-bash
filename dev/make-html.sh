#!/usr/bin/env bash
##############################################################
#
# File: make-html.sh
#
# Description: creates html version from *.md files
#
# Usage: source make-hmtl
#
#### $$VERSION$$ v1.51-0-g6e66a28
##############################################################

# check for correct dir
if [[ ! ( -f README.html && -f README.md )  ]]; then
    printf "Error: Can't create html, script must run where README.md and README.html is!\n"

else
    # check if pandoc installed
    if [ "$(type -t pandoc)" != "file" ]; then
	printf "pandoc not found, skipping html generation ...\n"

    else
	########
	# everything seems ok, start html generation
	printf "Start hmtl conversion "
	# create dir for html doc and index.html there
	mkdir html 2>/dev/null
	cp README.html html/index.html
	# convert *.md files in doc to *.hmtl in html
	find doc -iname "*.md" -type f -exec sh -c\
		 'printf "."; pandoc -s -f commonmark -M "title=Bashobot Documentation - ${0%.md}.html"  "$0" -o "./html/$(basename ${0%.md}.html)"' {} \;
	# html for examples dir
	if [ -d "examples" ]; then
		EXAMPLES="examples" # add to final conversion job
		find examples -iname "*.md" -type f -exec sh -c\
			'printf "."; pandoc -s -f commonmark -M "title=Bashobot Documentation - ${0%.md}.html"  "$0" -o "${0%.md}.html"' {} \;
	fi
	# final: convert links from *.md to *.html
	# shellcheck disable=SC2248
	find README.html html ${EXAMPLES} -iname "*.html" -type f -exec sh -c\
		'sed -i -E "s/href=\"(\.\.\/)*doc\//href=\"\1html\//g;s/href=\"(.*).md(#.*)*\"/href=\"\1.html\"/g" $0' {} \;
	printf " Done!\n"
    fi
fi
