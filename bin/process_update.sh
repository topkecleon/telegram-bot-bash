#!/bin/bash
# shellcheck disable=SC1090,SC2034,SC2059
#===============================================================================
#
#          FILE: bin/process_update.sh
#
USAGE='process_update.sh [-h|--help] [debug] [<file]'
# 
#   DESCRIPTION: processes ONE telegram update read from stdin, e.g. form file or webhook
#                 
#                -h - display short help
#                --help -  this help
#
#	LICENSE: WTFPLv2 http://www.wtfpl.net/txt/copying/
#        AUTHOR: KayM (gnadelwartz), kay@rrr.de
#       CREATED: 30.01.2021 19:14
#
#### $$VERSION$$ v1.45-dev-38-g882efa8
#===============================================================================

####
# parse args
COMMAND="process_multi_updates"

# set bashbot environment
source "${0%/*}/bashbot_env.inc.sh" "debug" # debug
print_help "${1:-nix}"


####
# ready, do stuff here -----

# read json from stdin and convert update format
json='{"result": ['"$(cat)"']}'
UPDATE="$(${JSONSHFILE} -b -n <<<"${json}" 2>/dev/null)"

# process telegram update
"${COMMAND}" "$1" 

