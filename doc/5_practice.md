#### [Home](../README.md)
## Best Practices

### New to bot development?

If you are new to Bot development read [Bots: An introduction for developers](https://core.telegram.org/bots) and consult [Telegram Bot API Documentation](https://core.telegram.org/bots/api/).

In addition you should know about [BotFather, the one bot to rule them all](https://core.telegram.org/bots#3-how-do-i-create-a-bot). It will help you create new bots and change settings for existing ones. [Commands known by Botfather](https://core.telegram.org/bots#generating-an-authorization-token)

If you dont't have a github account, it may time to [sepup a free account now](https://github.com/pricing)

### Add commands to mycommands.sh only
To ease updates never change ```bashbot.sh```, instead your commands and functions must go to  ```mycommands.sh``` .  Insert your Bot commands in the ```case ... esac``` block of the 'mycommands()' function:
```bash
# file: mycommands.sh
# your additional bahsbot commands

# uncomment the following lines to overwrite info and help messages
 bashbot_info='This is *MY* variant of _bashbot_, the Telegram bot written entirely in bash.
'

 bashbot_help='*Available commands*:
/echo message - _echo the given messsage_
'

# NOTE: command can have @botname attached, you must add * in case tests... 
mycommands() {

	case "$MESSAGE" in
		'/echo'*) # example echo command
			send_normal_message "${CHAT[ID]}" "$MESSAGE"
			;;
		# .....
	esac
}
```

### Overwrite, extend and disable global commands

You can overwrite a global bashbot command by placing the same commands in ```mycommands.sh``` and add ```return 1```
ad the end of your command, see '/kickme' below.

To disable a global bashbot command place create a command simply containing 'return 1', see '/leave' below.

In case you want to add some processing to the global bashbot command add ```return 0```, then both command will be executed.

**Learn more about [Bot commands](https://core.telegram.org/bots#commands).**

```bash
# file: commands.sh

	case "$MESSAGE" in
		##########
		# command overwrite examples
		'info'*) # output date in front of regular info
			send_normal_message "${CHAT[ID]}" "$(date)"
			return 0
			;;
		'/kickme'*) # this will replace the /kickme command
			send_markdown_mesage "${CHAT[ID]}" "*This bot will not kick you!*"
			return 1
			;;
		'/leave'*) # disable all commands starting with leave
			return 1
			;;
	esac
```


### Seperate logic from commands

If a command need more than 2-3 lines of code, you should use a function to seperate logic from command. Place your functions in ```mycommands.sh``` and call the from your command. Example:
```bash
# file: mycommands.sh
# your additional bahsbot commands

mycommands() {

	case "$MESSAGE" in
		'/process'*) # logic for /process is done in process_message 
			result="$(process_message "$MESSAGE")"
			send_normal_message "${CHAT[ID]}" "$result" 
			;;
	esac

}

# place your functions here

process_message() {
   local ARGS="${1#/* }"	# remove command 
   local TEXT OUTPUT=""

   # process every word in MESSAGE, avoid globbing
   set -f
   for WORD in $ARGS
   do
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

#### $$VERSION$$ v0.96-dev-7-g0153928

