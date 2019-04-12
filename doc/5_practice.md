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
			bashbot_info "${CHAT[ID]}"
			;;
	esac
```
after editing commands.sh restart Bot.

### Seperate Bot logic from command

If a Bot command needs more than 2-3 lines of code I recommend to factor it out to a bash function in a seperate file, e.g.
```mybotcommands.inc.sh``` and source the file from bashbot.sh. ```bashbot_info and bashbot_help``` are examples how to use
bash functions to make customisation easy and keep case block small. ```process_message``` is an example for a complex
processing logic as a bash funtcion in a seperate file.
```bash
	source mybotcommands.inc.sh

	case "$MESSAGE" in
		'/report') # report dealz from database and output result
			send_normal_message "${CHAT[ID]}" "$(process_message "$MESSAGE")" 
			;;

		################################################
		# DEFAULT commands start here, edit messages only
		'/info')
			bashbot_info "${CHAT[ID]}"
			;;
		'/start')
			send_action "${CHAT[ID]}" "typing"
			bashbot_help "${CHAT[ID]}"
			;;
	esac
```
Example ```mybotcommands.inc.sh```:
```bash
#!/bin/bash
#
process_message() {
   local ARGS="${1#/* }"	# remove command /*
   local TEXT OUTPUT=""

   # process every word in MESSAGE, avoid globbing from MESSAGE
   set -f
   for WORD in $ARGS
   do
	set +f
	# process links 
	if [[ "$WORD" == "https://"* ]]; then
		REPORT="$(dosomething_with_link "$WORD")"
	# no link, add as text
	else
		TEXT="$(echo "${TEXT} $WORD")"
		continue
	fi
	# compose result
	OUTPUT="* ${REPORT} ${WORD} ${TEXT}"
	TEXT=""
   done

   # return result, reset globbing in case we had no ARGS
   set +f
   echo "${OUTPUT}${TEXT}"
}

```
Doing it this way keeps commands.sh small and clean, while allowing complex tasks to be done in the included function.

### Test your Bot with shellcheck
Shellcheck is a static linter for shell scripts providing excellent tips and hints for shell coding pittfalls. You can [use it online](https://www.shellcheck.net/) or [install it on your system](https://github.com/koalaman/shellcheck#installing).
All bashbot scripts are linted by shellcheck.

Shellcheck examples:
```bash
$ shellcheck -x mybotcommands.inc.sh
 
Line 17:
                TEXT="$(echo "${TEXT} $WORD")"
                      ^-- SC2116: Useless echo? Instead of 'cmd $(echo foo)', just use 'cmd foo'.
 
```
```bash
$ shellcheck -x notify
OK
$ shellcheck -x question
OK
$ shellcheck -x commands.sh
OK
$ shellcheck -x bashbot.sh

In bashbot.sh line 123:
                text="$(echo "$text" | sed 's/ mynewlinestartshere /\r\n/g')" # hack for linebreaks in startproc scripts
                        ^-- SC2001: See if you can use ${variable//search/replace} instead.


In bashbot.sh line 490:
        CONTACT[USER_ID]="$(sed -n -e '/\["result",'$PROCESS_NUMBER',"message","contact","user_id"\]/  s/.*\][ \t]"\(.*\)"$/\1/p' <"$TMP")"
        ^-- SC2034: CONTACT appears unused. Verify it or export it.
```
As you can see there are only two warnings in bashbots scripts. The first is a hint you may use shell substitions instead of sed, but this is only possible for simple cases. The second warning is about an unused variable, this is true because in our examples CONTACT is not used but assigned in case you want to use it :-)

#### $$VERSION$$ v0.52-0-gdb7b19f

