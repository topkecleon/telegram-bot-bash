#!/bin/bash
########################################################################
#
# File: calc.sh
#
# Description: example for an background job, see mycommands.sh.dist
#
# Usage: runback calc  example/calc.sh  - or run in terminal
#        killback calc - to stop background job
#
# This file is public domain in the USA and all free countries.
# Elsewhere, consider it to be WTFPLv2. (wtfpl.net/txt/copying)
#
#### $$VERSION$$ v1.51-0-g6e66a28
########################################################################

######
# parameters
# $1 $2 args as given to starct_proc chat script arg1 arg2
# $3 path to named pipe/log

INPUT="${3:-/dev/stdin}"

# adjust your language setting here
# https://github.com/topkecleon/telegram-bot-bash#setting-up-your-environment
export 'LC_ALL=C.UTF-8'
export 'LANG=C.UTF-8'
export 'LANGUAGE=C.UTF-8'

unset IFS
# set -f # if you are paranoid use set -f to disable globbing

printf 'Starting Calculator ...\n'
printf 'Enter first number.\n'
read -r A <"${INPUT}"
printf 'Enter second number.\n'
read -r B <"${INPUT}"
printf 'Select Operation: mykeyboardstartshere [ "Addition" , "Subtraction" , "Multiplication" , "Division" ,  "Cancel" ]\n'
read -r opt <"${INPUT}"
printf 'Result: '
case ${opt,,} in
	'a'*) res="$(( A + B ))" ;;
	's'*) res="$(( A - B ))" ;;
	'm'*) res="$(( A * B ))" ;;
	'd'*) res="$(( A / B ))" ;;
	'c'*) res="abort!" ;;
	* ) printf "unknown operator!\n";;
esac
printf "%s\nBye ...\n" "${res}"

