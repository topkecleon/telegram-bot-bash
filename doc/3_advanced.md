#### [Home](../README.md)
## Advanced Features

### Access control
Bashbot offers functions to check what Telegram capabilities like 'chat admin' or 'chat creator' the given user has:

```bash
# return true if user is admin/owner of the bot
# -> botadmin is stored in file './botadmin'
user_is_botadmin "user"  

# return true if user is creator or admin of a chat
user_is_admin "chat" "user"

# return true if user is creator of a chat or it's a one to one chat
user_is_creator "chat" "user"

# examples:
user_is_botadmin "${USER[ID]}" && send_markdown_message "${CHAT[ID]}" "You are *BOTADMIN*."

user_is_admin "${CHAT[ID]}" "${USER[ID]}" && send_markdown_message "${CHAT[ID]}" "You are *CHATADMIN*."

```
In addition you can check individual capabilities of users as you must define in the file ```./botacl```:
```bash
# file: botacl
# a user not listed here, will return false from 'user_is_allowed'
#
# Format:
# user:ressource:chat

# allow user 123456789 access to all resources in all chats
123456789:*:*

# allow user 12131415 to start bot in all chats
12131415:start:*

# allow user 987654321 only to start bot in chat 98979695
987654321:start:98979695

# * are only allowed on the right hand side and not for user!
# the following exaples are NOT valid!
*:*:*
*:start:*
*:*:98979695
```
You must use the function ```user_is_allowed``` to check if a user has the capability to do something. Example: Check if user has capability to start bot.
```bash
	case "$MESSAGE" in
		################################################
		# GLOBAL commands start here, only edit messages
		'/start'*)
			user_is_botadmin "${USER[ID]}" && send_markdown_message "${CHAT[ID]}" "You are *BOTADMIN*."
			if user_is_allowed "${USER[ID]}" "start" "${CHAT[ID]}" ; then
				bot_help "${CHAT[ID]}"
			else
				send_normal_message "${CHAT[ID]}" "You are not allowed to start Bot."
			;;
	esac
```
**See also [Bashbot User Access Control functions](6_reference.md#User-Access-Control)**

### Interactive Chats
To create interactive chats, write *(or edit the 'exmaples/question.sh' script)* a bash *(or C or python)* script, make it executable 
and then use the 'startproc' function to  start the script.
The output of the script will be sent to the user and user input will be sent to the script.
To stop the script use the function 'killprog'

The output of the script will be processed by 'send_messages' to enable you to not only send text, but also keyboards, files, locations and more.
Each newline in the output will start an new message to the user, to have line breaks in your message you can use 'mynewlinestartshere'.

To open up a keyboard in an interactive script, print out the keyboard layout in the following way:
```bash
echo "Text that will appear in chat? mykeyboardstartshere [ \"Yep, sure\" , \"No, highly unlikely\" ]"
```
Same goes for files:
```bash
echo "Text that will appear in chat? myfilelocationstartshere /home/user/doge.jpg"
```
And buttons:
```bash
echo "Text that will appear in chat. mybtextstartshere Klick me myburlstartshere https://dealz.rrr.de"
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
echo "Text that will appear in chat? mykeyboardstartshere [ \"Yep, sure\" , \"No, highly unlikely\" ] myfilelocationstartshere /home/user/doge.jpg mylatstartshere 45 mylongstartshere 45"
```
Please note that you can either send a location or a venue, not both. To send a venue add the mytitlestartshere and the myaddressstartshere keywords.

New in v0.6: To insert a linebreak in your message you can insert ```mynewlinestartshere``` in your echo command:
```bash
echo "Text that will appear in one message  mynewlinestartshere  with this text on a new line"
```

New in v0.7: In case you must extend a message already containing a location, a file, a keyboard etc.,
with additionial text simply add ``` mytextstartshere additional text``` at the end of the string:
```bash
out="Text that will appear mylatstartshere 45 mylongstartshere 45"
[[ "$out" != *'in chat'* ]] &&  out="$out mytextstartshere in chat."
echo "$out"
```
Note: Interactive Chats run independent from main bot and continue running until your script exits or you /cancel if from your Bot. 

### Background Jobs

A background job is similar to an interactive chat, but runs in the background and does only output massages and does not get user input. In contrast to interactive chats it's possible to run multiple background jobs. To create a background job write a script or edit 'examples/notify.sh'  script and use the funtion ```background``` to start it:
```bash
background "examples/notify.sh" "jobname"
```
All output of the script will be sent to the user, to stop a background job use:
```bash
killback "jobname"
```
You can also suspend and resume the last running background jobs from outside bashbot, e.g. in your startup schripts:
```bash
./bashbot.sh suspendback
./bashbot.sh resumeback
```

If you want to kill all background jobs permantly run:
```bash
./bashbot.sh killback

```
Note: Background Jobs run independent from main bot and continue running until your script exits or you stop if from your Bot. Backgound Jobs will continue running if your Bot is stopeda and must be terminated, e.g. by ```bashbot.sh killback``` 

### Inline queries
**Inline queries** allow users to send commands to your bot from every chat without going to a private chat. An inline query is started if the user type the bots name, e.g. @myBot. Everything after @myBot is immediatly send to the bot.

In order to enable **inline mode**, send `/setinline` command to [@BotFather](https://telegram.me/botfather) and provide the placeholder text that the user will see in the input field after typing your bot’s name.

The following commands allows you to send ansers to *inline queries*. To enable bashbot to process inline queries set ```INLINE="1"``` in 'mycommands.sh'.

To send messsages or links through an *inline query*:
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

#### [Prev Getting started](2_usage.md)
#### [Next Expert Use](4_expert.md)

#### $$VERSION$$ v0.96-dev-7-g0153928

