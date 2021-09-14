#### [Home](../README.md)
## Advanced Features

### Access control
Bashbot offers functions to check what Telegram capabilities like `chat admin` or `chat creator` the given user has:

```bash
# return true if user is admin/owner of the bot
user_is_botadmin "user"  

# return true if user is creator or admin of a chat
user_is_admin "chat" "user"

# return true if user is creator of a chat or it's a one to one chat
user_is_creator "chat" "user"

# examples:
user_is_botadmin "${USER[ID]}" && send_markdown_message "${CHAT[ID]}" "You are *BOTADMIN*."

user_is_admin "${CHAT[ID]}" "${USER[ID]}" && send_markdown_message "${CHAT[ID]}" "You are *CHATADMIN*."

```

In addition you can check individual capabilities of users as you must define in the file `./botacl`:

```bash
# file: botacl
# a user not listed here, will return false from 'user_is_allowed'
#
# Format:
# user:resource:chat

# allow user 123456789 access to all resources in all chats
123456789:*:*

# allow user 12131415 to start bot in all chats
12131415:start:*

# allow user 987654321 only to start bot in chat 98979695
987654321:start:98979695

# special case allow ALL users ONE action in all groups or in one group
ALL:search:*
ALL:search:98979695

# not valid, ALL must have an action!
ALL:*:*

# * are only allowed on the right hand side and not for user!
# the following examples are NOT valid!
*:*:*
*:start:*
*:*:98979695


```
You must use the function `user_is_allowed` to check if a user has the capability to do something. Example: Check if user has capability to start bot.

```bash
	case "$MESSAGE" in
		################################################
		# GLOBAL commands start here, only edit messages
		'/start'*)
			user_is_botadmin "${USER[ID]}" && send_markdown_message "${CHAT[ID]}" "You are *BOTADMIN*."
			#  true if: user is botadmin, user is group admin, user is allowed 
			if user_is_allowed "${USER[ID]}" "start" "${CHAT[ID]}" ; then
				bot_help "${CHAT[ID]}"
			else
				send_normal_message "${CHAT[ID]}" "You are not allowed to start Bot."
			;;
	esac
```
**See also [Bashbot User Access Control functions](6_reference.md#User-Access-Control)**

### Interactive Chats
Interactive chats are short running scripts, reading user input and echo data to the user.

To create a new interactive chat script copy `scripts/interactive.sh.clean` to e.g. `scripts/mynewinteractive.sh`, make it executable
and then use `start_proc` function from your bot, it's possible to pass two arguments. You find more examples for interactive scripts in 'examples'

*usage*: start_proc chat_id script arg1 arg2

*usage*: kill_proc chat_id

*usage*: check_prog chat_id

**IMPORTANT:** Scripts must read user input from '$3' instead of stdin!

```bash
#!/bin/bash

######
# parameters
# $1 $2 args as given to start_proc chat script arg1 arg2
# $3 path to named pipe

#######################
# place your commands here
#
INPUT="${3:-/dev/stdin}" # read from stdin if run in terminal

echo "Enter a message:"
read -r test <"${INPUT}"
echo -e "Your Message: ${test}\nbye!"
```

#### message formatting and keyboards

The output of the script will be processed by `send_messages`, so you can not only send text, but also keyboards, files, locations and more.
Each newline in the output will start an new message to the user. To have line breaks in your message you must insert `\n` instead.

To open up a keyboard in an interactive script, print out the keyboard layout in the following way:
```bash
echo "Text that will appear in chat? mykeyboardstartshere [ \"Yep, sure\" , \"No, highly unlikely\" ]"
```
Same goes for files:
```bash
echo "Text that will appear in chat? myfilestartshere /home/user/dog.jpg"
```
*Note*: Use an _absolute path name_ (starting with `/`), a relative path name is relative to `data-bot-bash/upload`!
See [send_file documentation](6_reference.md#send_file) for more information.
	
And buttons:
```bash
echo "Text that will appear in chat. mybtextstartshere Click me myburlstartshere https://dealz.rrr.de"
```
And locations:
```bash
echo "Text that will appear in chat. mylatstartshere 45 mylongstartshere 45"
```
And venues:
```bash
echo "Text that will appear in chat. mylatstartshere 45 mylongstartshere 45 mytitlestartshere my home myaddressstartshere Diagon Alley N. 37"
```
You can combine them:
```bash
echo "Text that will appear in chat? mykeyboardstartshere [ \"Yep, sure\" , \"No, highly unlikely\" ] myfilestartshere /home/user/doge.jpg mylatstartshere 45 mylongstartshere 45"
```
Please note that you can either send a location or a venue, not both. To send a venue add the mytitlestartshere and the myaddressstartshere keywords.

To insert a line break in your message you can insert `\n` in your echo command:
```bash
echo "Text that will appear in one message \nwith this text on a new line"
```

In case you want extend a message already containing a location, a file, a keyboard etc.,
with an additionial text simply add ` mytextstartshere additional text` at the end of the string:
```bash
out="Text that will appear mylatstartshere 45 mylongstartshere 45"
[[ "$out" != *'in chat'* ]] &&  out="$out mytextstartshere in chat."
echo "$out"
```

### Background Jobs

A background job is similar to an interactive chat, but can be a long running job and does only output massages, user input is ignored.
It's possible to run multiple background jobs from the same chat.

To create a new interactive chat script copy 'scripts/interactive.sh.clean' to e.g. 'scripts/mynewbackground.sh', make it executable
and then use 'start_back' function from your bot, it's possible to pass two arguments. You find more examples for background scripts in 'examples'

*usage*: start_back chat_id script jobname arg1 arg2

*usage*: kill_back chat_id jobname

*usage*: check_back chat_id jobname

```bash
start_back "examples/notify.sh" "${CHAT[ID]}" "jobname"
```
All output of the script will be sent to the user, to stop a background job use:
```bash
kill_back "${CHAT[ID]}" "jobname"
```
You can also suspend and resume currently running background jobs from outside bashbot, e.g. in your startup scripts:
```bash
./bashbot.sh suspendback
./bashbot.sh resumeback
```

If you want to kill all background jobs permanently run:
```bash
./bashbot.sh killback

```
Note: Background jobs run independent from main bot and continue running until your script exits or you stop it. Background jobs will continue running if your Bot is stopped and must be terminated separately e.g. by `bashbot.sh killback`

### Inline queries
**Inline queries** allow users to send commands to your bot from every chat without going to a private chat. An inline query is started if the user type the bots name, e.g. @myBot. Everything after @myBot is immediately send to the bot.

In order to enable **inline mode**, send `/setinline` command to [@BotFather](https://telegram.me/botfather) and provide the placeholder text that the user will see in the input field after typing your bot’s name.

The following commands allows you to send ansers to *inline queries*. To enable bashbot to process inline queries set `INLINE="1"` in `mycommands.sh`.

To send messages or links through an *inline query*:
```bash
answer_inline_query "${iQUERY[ID]}" "article" "Title of the result" "Content of the message to be sent"
```
To send photos in jpeg format and less than 5MB, from a website through an *inline query*:
```bash
answer_inline_query "${iQUERY[ID]}" "photo" "A valid URL of the photo" "URL of the thumbnail"
```
To send standard gifs from a website (less than 1MB) through an *inline query*:
```bash
answer_inline_query "${iQUERY[ID]}" "gif" "gif url"
```
To send mpeg4 gifs from a website (less than 1MB) through an *inline query*:
```bash
answer_inline_query "${iQUERY[ID]}" "mpeg4_gif" "mpeg4 gif url"
```
To send videos from a website through an *inline query*:
```bash
answer_inline_query "${iQUERY[ID]}" "video" "valid video url" "Select one mime type: text/html or video/mp4" "URL of the thumbnail" "Title for the result"
```
To send photos stored in Telegram servers through an *inline query*:
```bash
answer_inline_query "${iQUERY[ID]}" "cached_photo" "identifier for the photo"
```
To send gifs stored in Telegram servers through an *inline query*:
```bash
answer_inline_query "${iQUERY[ID]}" "cached_gif" "identifier for the gif"
```
To send mpeg4 gifs stored in Telegram servers through an *inline query*:
```bash
answer_inline_query "${iQUERY[ID]}" "cached_mpeg4_gif" "identifier for the gif"
```
To send stickers through an *inline query*:
```bash
answer_inline_query "${iQUERY[ID]}" "cached_sticker" "identifier for the sticker"
```
See also [answer_inline_multi, answer_inline_compose](6_reference.md#answer_inline_multi) and [mycommands.sh](../mycommands.sh) for more information.


### Send message results

Our examples usually do not care about errors happening while sending a message, this is OK as long your bot does not send an
massive aoumnt of messages. By default bashbot detects if a message is not sent and try to recover when possible,
e.g. resend on throttling. In addition every send error is logged in logs/ERROR.log


#### Transmission results

On every message send to telegram (transmission) the results are provided in bash variables, like its done when a new message
is received.

**Note**: the values of the variables contains always the result of the LAST transmission to telegram,
every send action will overwrite them!

* `$BOTSENT`: This array contains the parsed results from the last transmission to telegram.
    * `${BOTSENT[OK]}`: contains the string `true`: after a successful transmission
    * `${BOTSENT[ID]}`: Message ID if OK is true
    * `${BOTSENT[ERROR]}`: Error code if an error occurred
    * `${BOTSENT[DESC]}`: Description text for error
    * `${BOTSENT[RETRY]}`: Seconds to wait if telegram requests throtteling.
* `$res`: temporary variable containing the full transmission result, may be overwritten by any bashbot function.

By default you don't have to care about retry, as bashbot resend the message after the requested time automatically.
Only if the retry fails also an error is returned. The downside is that send_message functions will wait until resend is done.

If you want to disable automatic error processing  and handle all errors manually (or don't care)
set `BASHBOT_RETRY` to any no zero value.

[Telegram Bot API error codes](https://github.com/TelegramBotAPI/errors)


#### Detect bot blocked

If the we can't connect to telegram, e.g. blocked from telegram server but also any other reason,
bashbot set `BOTSENT[ERROR]` to `999`.

To get a notification on every connection problem create a function named `bashbotBlockRecover` and handle blocks there.
If the function returns true (0 or no value) bashbot will retry once and then return to the calling function.
In case you return any non 0 value bashbot will return to the calling function without retry.

Note: If you disable automatic retry, se above, you disable also connection problem notification.

```bash
  # somewhere in myfunctions.sh ...
  MYBLOCKED="0"

  function bashbotBlockRecover() {
      # ups, we are blocked!
      (( MYBLOCKED++ ))
      # log what we got
      printf "%s: Blocked %d times: %s\n" "$(date)" "${MYBLOCKED}" "$*" >>"${ERRORLOG}" 

      if [ "${MYBLOCKED}" -gt 10 ]; then
           printf "Permanent problem abort current command: %s\n" "${MESSAGE}">>"${ERRORLOG}"
          exit
      fi
      if do_something_to_unblock; then
         # may be we removed block, e.g. changed IP address, try again
         return 0
      fi
      # do not retry if we can't recover
      return 1
  }

```


#### [Prev Getting started](2_usage.md)
#### [Next Expert Use](4_expert.md)

#### $$VERSION$$ v1.51-0-g6e66a28

