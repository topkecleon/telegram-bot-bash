#!/bin/bash
# file: bash2env.sh
# simole helper script to convert bash shebang from
# ! /bin/bash TO ! /usr/bin/env bash

# This file is public domain in the USA and all free countries.
# Elsewhere, consider it to be WTFPLv2. (wtfpl.net/txt/copying)

#### $$VERSION$$ v0.94-3-g96fda44

# adjust your language setting here
# https://github.com/topkecleon/telegram-bot-bash#setting-up-your-environment
export 'LC_ALL=C.UTF-8'
export 'LANG=C.UTF-8'
export 'LANGUAGE=C.UTF-8'

unset IFS

################
# uncomment thenfollowing line to make the conversion
# DOIT="yes"

if [ "$1" = "" ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
	echo "$0: convert bash shebang to /usr/bin/env bash"
	echo "usage: $0 script [script ...]"
	exit
fi

# loop tomprocess files
if [ "${DOIT}" = "yes" ]; then
	echo "Warning, changes will be done!"
else
	echo "Dry run, output changes only!"
	echo "Uncomment DOIT=\"yes\" in script to make the changes permanent."

fi

echo "Press enter  to continue ..."
#shellcheck disable=SC2034
read -r CONTINUE


for file in "$@"
do
	file "${file}"
	if [[ "$(file -b "${file}")" =~  Bourne.*script.*text ]]; then
	    echo "Processing ${file} ..."
	    if head -n 1 "${file}" | grep -q '^#!/bin/bash'; then
		if [ "${DOIT}" = "yes" ]; then
		    sed -i -e '1 s|^#!/bin/bash|#!/usr/bin/env bash|' "${file}"
		    head -n 1 "${file}"
		else
		    sed -n -e '1 s|^#!/bin/bash|#!/usr/bin/env bash (dry run)|p' "${file}"
		fi
	    else
		echo "No #!/bin/bash shebang, nothing to convert."
	    fi
	    echo -e "... done.\n"
	else
		echo -e "Not a bash script, skipping ${file} ...\n"
	fi
done
