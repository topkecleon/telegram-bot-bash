#### [Home](../README.md)
## Best Practices

### Customize commands.sh only

To ease Updates never change ```bashbot.sh```, instead individual commands should go to  ```commands.sh``` .  Insert your Bot commands in the ```case ... esac``` block:
```bash
	case "$MESSAGE" in
		'/echo') # my first own command, echo MESSAGE
			send_normal_message "${CHAT[ID]}" "${MESSAGE}"
			;;

		################################################
		# DEFAULT commands start here, do not edit below this!
		'/info')
			bashbot_info "${CHAT[ID]}"
			;;
	esac
```

### Seperate logic from commands

If a command need more than 2-3 lines of code, you should use a function to seperate logic from command. Place your functions in a seperate file, e.g. ```mycommands.inc.sh``` and source it from bashbot.sh. Example:
```bash
	source "mycommands.inc.sh"

	case "$MESSAGE" in
		'/process') # logic for /process is done in process_message 
			result="$(process_message "$MESSAGE")"
			send_normal_message "${CHAT[ID]}" "$result" 
			;;

		################################################
		# DEFAULT commands start here, do not edit below this!
		'/info')
			bashbot_info "${CHAT[ID]}"
			;;
		'/start')
			send_action "${CHAT[ID]}" "typing"
			bashbot_help "${CHAT[ID]}"
			;;
	esac
```
```bash
#!/bin/bash
# file: mycommands.inc.sh

process_message() {
   local ARGS="${1#/* }"	# remove command 
   local TEXT OUTPUT=""

   # process every word in MESSAGE, avoid globbing
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
As you can see my ```mybotcommands.inc.sh``` contains an useless echo command in 'TEXT=' assigment and can be replaced by ```TEXT="${TEXT}${WORD}"```
```bash
$ shellcheck -x examples/notify
OK
$ shellcheck -x examples/question
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
The example show two warnings in bashbots scripts. The first is a hint you may use shell substitions instead of sed, this is fixed and much faster as the "echo | sed" solution.
The second warning is about an unused variable, this is true because in our examples CONTACT is not used but assigned in case you want to use it :-)

#### [Prev Best Practice](5_practice.md)
#### [Next Functions Reference](6_reference.md)

#### $$VERSION$$ v0.62-0-g5d5dbae

