#!/bin/bash
# file: calc.sh
# example for an interactive chat, run with startproc calc.sh

# This file is public domain in the USA and all free countries.
# Elsewhere, consider it to be WTFPLv2. (wtfpl.net/txt/copying)

#### $$VERSION$$ v0.96-dev-7-g0153928

# adjust your language setting here
# https://github.com/topkecleon/telegram-bot-bash#setting-up-your-environment
export 'LC_ALL=C.UTF-8'
export 'LANG=C.UTF-8'
export 'LANGUAGE=C.UTF-8'

unset IFS
# set -f # if you are paranoid use set -f to disable globbing

echo 'Starting Calculator ...'
echo 'Enter first number.'
read -r A
echo 'Enter second number.'
read -r B
echo 'Select Operation: mykeyboardstartshere [ "Addition" , "Subtraction" , "Multiplication" , "Division" ,  "Cancel" ]'
read -r opt
echo -n 'Result: '
case $opt in
	'add'* | 'Add'* ) res="$(( A + B ))" ;;
	'sub'* | 'Sub'* ) res="$(( A - B ))" ;;
	'mul'* | 'Mul'* ) res="$(( A * B ))" ;;
	'div'* | 'Div'* ) res="$(( A / B ))" ;;
	'can'* | 'Can'* ) res="abort!" ;;
		* ) echo "unknown operator!";;
esac
echo "$res"
echo "Bye .."
