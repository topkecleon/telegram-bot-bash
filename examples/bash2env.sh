#!/usr/bin/env bash
# file: bash2env.sh
# simole helper script to convert bash shebang from
# ! /bin/bash TO ! /usr/bin/env bash

# This file is public domain in the USA and all free countries.
# Elsewhere, consider it to be WTFPLv2. (wtfpl.net/txt/copying)
# shellcheck disable=SC1117
#### $$VERSION$$ v1.51-0-g6e66a28

# adjust your language setting here
# https://github.com/topkecleon/telegram-bot-bash#setting-up-your-environment
export 'LC_ALL=C.UTF-8'
export 'LANG=C.UTF-8'
export 'LANGUAGE=C.UTF-8'

unset IFS
MYSHEBANG=""

################
# uncomment one of the following lines to make the conversion
# Linux/Unix  bash
# MYSHEBANG="#!/bin/bash"

# BSD bash
# MYSHEBANG="#!/usr/bin/bash"

# homebrew gnu bash on MacOS
# MYSHEBANG="#!/usr/local/opt/bash"

# use portable /usr/bin/env
# MYSHEBANG="#!/usr/bin/env bash"

# bashbot default bash
FROMSHEBANG="#!/bin/bash"

# uncomment to convert back to bashbot default bash
# FROMSHEBANG="#!/usr/bin/env bash"
# MYSHEBANG="#!/bin/bash"

if [ "$1" = "" ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
	echo "$0: convert bash shebang to point to your local installation"
	echo "usage: $0 script [script ...]"
	exit
fi

# loop tomprocess files
if [ "${MYSHEBANG}" != "" ]; then
	echo "Warning, shebang will changed from ${FROMSHEBANG} changed to ${MYSHEBANG}!"
else
	echo "Dry run, demonstration only!"
	echo "Uncomment one of the MYSHEBANG= lines fitting your environment to make the changes permanent."

fi

echo "Press enter  to continue ..."
#shellcheck disable=SC2034
read -r CONTINUE


for file in "$@"
do
	file "${file}"
	if [[ "$(file -b "${file}")" =~  Bourne.*script.*text ]]; then
	    echo "Processing ${file} ..."
	    if head -n 1 "${file}" | grep -q "^${FROMSHEBANG}"; then
		if [ "${MYSHEBANG}" != "" ]; then
		    sed -i -e '1 s|^'"${FROMSHEBANG}"'|'"${MYSHEBANG}"'|' "${file}"
		    head -n 1 "${file}"
		else
		    sed -n -e '1 s|^'"${FROMSHEBANG}"'|#!/some/shebang/bash (dry run)|p' "${file}"
		fi
	    else
		echo "Found: $(head -n 1 "${file}") - Nothing to convert."
	    fi
	    echo -e "... done.\n"
	else
		echo -e "Not a bash script, skipping ${file} ...\n"
	fi
done
