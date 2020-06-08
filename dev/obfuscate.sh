#!/bin/bash
# shellcheck disable=SC2028,2016
# joke hack to obfuscate bashbot.min.sh

infile="bashbot.sh"
outfile="./bashbot.obf.sh"

[ ! -f "${infile}" ] && echo "Hey, this is a joke hack to obfuscate ${infile}, copy me to STANDANLONE first" && exit

{
echo '#!/bin/bash'
echo 'b="./bashbot";h="$PWD";cd "$(mktemp -d)"||exit'
echo 'printf '"'%s\n'"' '"'$(gzip -9 <bashbot.sh | base64)'"'|base64 -d|gunzip >"$b";export BASHBOT_HOME="$h";chmod +x "$b";"$b" "$@";b="$(pwd)";cd ..;rm -rf "$b"'
} >"${outfile}"

chmod +x "${outfile}"
ls -l "${outfile}"
echo "Try to run ${outfile} init ;-)"
