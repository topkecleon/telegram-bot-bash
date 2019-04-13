
## Advanced Features
### Access control
Bashbot offers functions to check if a has Telegram capabilities like chat admin or chat creator:
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
In addtion you can configure individual capabilities for users in the file ```./botacl```:
```bash
# botacl
# if a user is not listed here, function 'user_is_allowed' will always return false
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
you have to check yourself if a user is allowed to to something by calling function ```user_is_allowed```.
example to check if a user is allowed to start bot:
```bash
	case "$MESSAGE" in
		'/start')
			user_is_botadmin "${USER[ID]}" && send_markdown_message "${CHAT[ID]}" "You are *BOTADMIN*."
			if user_is_allowed "${USER[ID]}" "start" "${CHAT[ID]}" ; then
				bot_help "${CHAT[ID]}"
			else
				send_normal_message "${CHAT[ID]}" "You are not allowed to start Bot."
			;;
	esac
```

### Interactive Chats
To create interactive chats, write (or edit the question script) a normal bash (or C or python) script, chmod +x it and then change the argument of the startproc function to match the command you usually use to start the script.
The text that the script will output will be sent in real time to the user, and all user input will be sent to the script (as long as it's running or until the user kills it with /cancel).
To open up a keyboard in an interactive script, print out the keyboard layout in the following way:
```bash
echo "Text that will appear in chat? mykeyboardstartshere \"Yep, sure\" \"No, highly unlikely\""
```
Same goes for files:
```bash
echo "Text that will appear in chat? myfilelocationstartshere /home/user/doge.jpg"
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
echo "Text that will appear in chat? mykeyboardstartshere \"Yep, sure\" \"No, highly unlikely\" myfilelocationstartshere /home/user/doge.jpg mylatstartshere 45 mylongstartshere 45"
```
Please note that you can either send a location or a venue, not both. To send a venue add the mytitlestartshere and the myaddressstartshere keywords.

To insert a linebreak in your message you can insert ```mynewlinestartshere``` in your echo command:
```bash
echo "Text that will appear in one message  mynewlinestartshere  with this text on a new line"
```
Note: Interactive Chats run independent from main bot and continue running until your script exits or you /cancel if from your Bot. 

### Background Jobs

A background job is similar to an interactive chat, but runs in the background and does only output massages instead of processing input from the user. In contrast to interactive chats it's possible to run multiple background jobs. To create a background job write a script or edit the notify script and use the funtion ```background``` to start it:
```bash
background "./notify" "jobname"
```
All output of the script will be sent to the user or chat. To stop a background job use:
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
Note: Background Jobs run independent from main bot and continue running until your script exits or you stop if from your Bot. Backgound Jobs will continue running if your Bot is stoped (kill)!. 

### Inline queries
The following commands allows users to interact with your bot via *inline queries*.
In order to enable **inline mode**, send `/setinline` command to [@BotFather](https://telegram.me/botfather) and provide the placeholder text that the user will see in the input field after typing your bot’s name.
Also, edit line 12 from `commands.sh` putting a "1".
Note that you can't modify the first two parameters of the function `answer_inline_query`, only the ones after them.

To send messsages or links through an *inline query*:
```bash
answer_inline_query "$iQUERY_ID" "article" "Title of the result" "Content of the message to be sent"
```
To send photos in jpeg format and less than 5MB, from a website through an *inline query*:
```bash
answer_inline_query "$iQUERY_ID" "photo" "A valid URL of the photo" "URL of the thumbnail"
```
To send standard gifs from a website (less than 1MB) through an *inline query*:
```bash
answer_inline_query "$iQUERY_ID" "gif" "gif url"
```
To send mpeg4 gifs from a website (less than 1MB) through an *inline query*:
```bash
answer_inline_query "$iQUERY_ID" "mpeg4_gif" "mpeg4 gif url"
```
To send videos from a website through an *inline query*:
```bash
answer_inline_query "$iQUERY_ID" "video" "valid video url" "Select one mime type: text/html or video/mp4" "URL of the thumbnail" "Title for the result"
```
To send photos stored in Telegram servers through an *inline query*:
```bash
answer_inline_query "$iQUERY_ID" "cached_photo" "identifier for the photo"
```
To send gifs stored in Telegram servers through an *inline query*:
```bash
answer_inline_query "$iQUERY_ID" "cached_gif" "identifier for the gif"
```
To send mpeg4 gifs stored in Telegram servers through an *inline query*:
```bash
answer_inline_query "$iQUERY_ID" "cached_mpeg4_gif" "identifier for the gif"
```
To send stickers through an *inline query*:
```bash
answer_inline_query "$iQUERY_ID" "cached_sticker" "identifier for the sticker"
```

#### $$VERSION$$ v0.52-0-gdb7b19f

