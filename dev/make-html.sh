#!/usr/bin/env bash
# magic to ensure that we're always inside the root of our application,
# no matter from which directory we'll run script
if [ ! -f README.html ]; then
	echo "This script must run where README.html is!" && exit 1
fi

# make html doc
mkdir html  2>/dev/null
cp README.html html/index.html
find doc -iname "*.md" -type f -exec sh -c 'pandoc -s -f commonmark -M "title=Bashobot Documentation - ${0%.md}.html"  "${0}" -o "./html/$(basename ${0%.md}.html)"' {} \;
if [ -d "examples" ]; then
	find examples -iname "*.md" -type f -exec sh -c 'pandoc -s -f commonmark -M "title=Bashobot Documentation - ${0%.md}.html"  "${0}" -o "${0%.md}.html"' {} \;
	EXAMPLES="examples"
fi
find README.html html ${EXAMPLES} -iname "*.html" -type f -exec sh -c 'sed -i -E "s/href=\"(\.\.\/)*doc\//href=\"\1html\//g;s/href=\"(.*).md(#.*)*\"/href=\"\1.html\"/g" ${0}' {} \;
