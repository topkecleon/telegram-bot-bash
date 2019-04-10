## Best Practices

### Customizing commands.sh
To ease Updates never change ```bashbot.sh```, all changes should be done in ```commands.sh``` .

Insert your own Bot commands in the ```case ... esac``` block in commands.sh:
```bash
	case "$MESSAGE" in
		'/echo') # my first own command, echo MESSAGE
			send_normal_message "${CHAT[ID]}" "${MESSAGE}"
			;;

		################################################
		# DEFAULT commands start here, edit messages only
		'/info')
			send_markdown_message "${CHAT[ID]}" "This is bashbot, the *Telegram* bot written entirely in *bash*."
			;;
		'/start')
			send_action "${CHAT[ID]}" "typing"
			send_markdown_message "${CHAT[ID]}" "This is bashbot, the Telegram bot written entirely in bash."
			;;
		[...]
	esac
```
after editing commands.sh restart Bot.

### Seperate Bot logic from command
If a Bot command needs more than 2-3 lines of code I recommend to factor it out to bash functions in a seperate file, e.g.
```mybotcommands.inc.sh``` and source the file from bashbot.sh.
```bash
	source mybotcommands.inc.sh

	case "$MESSAGE" in
		'/report') # report dealz from database and output result
			send_normal_message "${CHAT[ID]}" "$(process_message "$MESSAGE")" 
			;;

		################################################
		# DEFAULT commands start here, edit messages only
		'/info')
			send_markdown_message "${CHAT[ID]}" "This is bashbot, the *Telegram* bot written entirely in *bash*."
			;;
		'/start')
			send_action "${CHAT[ID]}" "typing"
			send_markdown_message "${CHAT[ID]}" "This is bashbot, the Telegram bot written entirely in bash."
			;;
		[...]
	esac
```
Doing it this way keeps command.sh small and clean, while allowing complex tasks to be done in the included function. example ```mybotcommands.inc.sh```:
```bash
#!/bin/bash
#
process_message() {

   local MESSAGE="$1"		# store arg
   local ARGS="${MESSAGE#/r* }" # remove command
   local TEXT=""
   local OUTPUT=""

   # process every word in MESSAGE, avoid globbing from MESSAGE
   set -f
   for WORD in $ARGS
   do
	set +f
	# process links 
	if [[ "$WORD" == "https://"* ]]; then
		# remove utf chars from URL 
		WORD="$(echo "$WORD" |  uni2ascii -q -a F -B)"
		REPORT="$(dosomething_with_link "$WORD")"
	# no link, add as text
	else
		# TEXT incl UTF to ascii transformation
		TEXT="$(echo "${TEXT} $WORD"'| iconv -c -f utf-8 -t ascii//TRANSLIT)"
		continue
	fi
	# compose result components
	OUTPUT="* ${REPORT} ${WORD} ${TEXT}"
	TEXT=""
   done

   # return result, reset globbing in case we had no ARGS
   set +f
   echo "${OUTPUT}${TEXT}"
}

```

### Test your Bot with shellcheck

#### $$VERSION$$ v0.51-0-g4d5d386

