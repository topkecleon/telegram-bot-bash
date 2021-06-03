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
#### $$VERSION$$ v1.51-0-g6e66a28
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
# replace any ID named BOTADMIN with ID of bot admin
json='{"result": ['"$(cat)"']}'
json="${json//\"id\":BOTADMIN,/\"id\":${BOTADMIN},}"
UPDATE="$(${JSONSHFILE} -b -n <<<"${json}" 2>/dev/null)"

# process telegram update
"${COMMAND}" "$1" 

