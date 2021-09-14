#!/bin/bash
#
# joke hack to obfuscate bashbot.min.sh
#
#### $$VERSION$$ v1.51-0-g6e66a28
# shellcheck disable=SC2028,SC2016,SC1117

infile="bashbot.sh"
outfile="./bashbot.obf.sh"

if [ ! -f "${infile}" ]; then
	printf "This is a hack to obfuscate %s, run me in STANDALONE after running make-standalone.sh\n" "${infile}"
	exit 1
fi
# create gzipped base64 encoded file plus commands to decode
{
# shellcheck disable=SC2183
printf '#!/bin/bash\na="$PWD";cd "$(mktemp -d)"||exit;%s'\
	'printf '"'$(gzip -9 <"${infile}" | base64)'"'|base64 -d|gunzip >a;export BASHBOT_HOME="$a";chmod +x a;./a "$@";a="$PWD";cd ..;rm -rf "$a"'
} >"${outfile}"

chmod +x "${outfile}"
ls -l "${outfile}"
printf "Try to run %s init ;-)\n" "${outfile}"
