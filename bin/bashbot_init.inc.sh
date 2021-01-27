#!/bin/bash
#===============================================================================
#
#          FILE: bashbot_init.inc.sh
# 
#         USAGE: source bashbot_init.inc.sh
#
#   DESCRIPTION: extend / overwrite bashbot initialisation 
# 
#	LICENSE: WTFPLv2 http://www.wtfpl.net/txt/copying/
#        AUTHOR: KayM (gnadelwartz), kay@rrr.de
#       CREATED: 27.01.2021 13:42
#
#### $$VERSION$$ v1.35-dev-27-gca9ea1b
#===============================================================================

##########
# commands to execute before bot_init() is called


#########
# uncomment to overwrite default init
# bot_init() { my_init(); }

########
# called after default init is finished
my_init() {
	: # ypur commands here
}
