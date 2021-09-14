#!/usr/bin/env bash
##############################################################
#
# File: inject-json.sh
#
# Description: download and prepare JSON.sh and JSON.awk
#
# Usage: source inject-json.sh
#
#### $$VERSION$$ v1.51-0-g6e66a28
##############################################################

# download JSON.sh
JSONSHFILE="JSON.sh/JSON.sh"
if [ ! -r "${JSONSHFILE}" ]; then
	printf "Inject JSON.sh ... "
	mkdir "JSON.sh" 2>/dev/null
	curl -sL -o "${JSONSHFILE}" "https://cdn.jsdelivr.net/gh/dominictarr/JSON.sh/JSON.sh"
	chmod +x "${JSONSHFILE}"
	printf "Done!\n"
fi

# download JSON.awk
JSONSHFILE="JSON.sh/JSON.awk.dist"
if [ ! -r "${JSONSHFILE}" ]; then
	printf "Inject JSON.awk ... "
	curl -sL -o "${JSONSHFILE}" "https://cdn.jsdelivr.net/gh/step-/JSON.awk/JSON.awk" 
	curl -sL -o "${JSONSHFILE%/*}/awk-patch.sh" "https://cdn.jsdelivr.net/gh/step-/JSON.awk/tool/patch-for-busybox-awk.sh"
	chmod +x "${JSONSHFILE}"
	printf "Done!\n"
	bash "${JSONSHFILE%/*}/awk-patch.sh" "${JSONSHFILE}"
fi
# delete backup files
rm -f "${JSONSHFILE%/*}"/*.bak

