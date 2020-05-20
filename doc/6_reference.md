#### [Home](../README.md)
## Bashbot function reference

### Send, forward, delete messages

##### send_action
```send_action``` shows users what your bot is currently doing.

*usage:* send_action "${CHAT[ID]}" "action"

*"action":* ```typing```, ```upload_photo```, ```record_video```, ```upload_video```, ```record_audio```, ```upload_audio```, ```upload_document```, ```find_location```.

*alias:* _action "action"

*example:* 
```bash
send_action "${CHAT[ID]}" "typing"
send_action "${CHAT[ID]}" "record_audio"
```


##### send_normal_message
```send_normal_message``` sends text only messages to the given chat.

*usage:*  send_normal_message "${CHAT[ID]}" "message"

*alias:* _normal_message "message"

*example:* 
```bash
send_normal_message "${CHAT[ID]}" "this is a text message"
```


##### send_markdown_message
```send_markdown_message``` sends markdown style messages to the given chat.
Telegram supports a [reduced set of Markdown](https://core.telegram.org/bots/api#markdown-style) only

*usage:* send_markdown_message "${CHAT[ID]}" "markdown message"

*alias:* _markdown "message"

*example:* 
```bash
send_markdown_message "${CHAT[ID]}" "this is a markdown  message, next word is *bold*"
send_markdown_message "${CHAT[ID]}" "*bold* _italic_ [text](link)"
```

##### send_html_message
```send_html_message``` sends HTML style messages to the given chat.
Telegram supports a [reduced set of HTML](https://core.telegram.org/bots/api#html-style) only

*usage:* send_html_message "${CHAT[ID]}" "html message" 

*alias:* _html_message "message"

*example:* 
```bash
send_normal_message "${CHAT[ID]}" "this is a markdown  message, next word is <b>bold</b>"
send_normal_message "${CHAT[ID]}" "<b>bold</b> <i>italic><i> <em>italic>/em> <a href="link">Text</a>"
```

##### forward_message
```forward_mesage``` forwards a messsage to the given chat.

*usage:* forward_message "chat_to" "chat_from" "${MESSAGE[ID]}"

*old call:* forward "${CHAT[ID]}" "$FROMCHAT" "${MESSAGE[ID]}"

*alias:* _forward "$FROMCHAT" "${MESSAGE[ID]}"

See also [Text formating options](https://core.telegram.org/bots/api#formatting-options)

----

##### delete_message
A bot can only delete messages if he is admin of a Chat, if not he can delete his own messages only.

*usage:* delete_message "${CHAT[ID]}" "${MESSAGE[ID]}"

See also [deleteMessage limitations](https://core.telegram.org/bots/api#deletemessage)

----

##### send_message
```send_message``` sends any type of message to the given chat. Type of output is steered by keywords within the message. 

The main use case for send_message is to process the output of interactive chats and background jobs. **For regular Bot commands I recommend using of the dedicated send_xxx_message() functions from above.**

*usage:* send_message "${CHAT[ID]}" "message"

*example:* - see [Usage](2_usage.md#send_message) and [Advanced Usage](3_advanced.md#Interactive-Chats)

----

### File, Location, Venue, Keyboard 


##### send_file
send_file allows you to send different type's of files, e.g. photos, stickers, audio, media, etc. [see more](https://core.telegram.org/bots/api#sending-files)

Starting with version 0.80 send_file implements the following rules:

- file names must not contain ".."
- file names must not start with "."
- file names not starting wit "/" are realtive to $TMPDIR, e.g. ./data-bot-bash
- abolute filenames must match $FILE_REGEX
- FILE_REGEX is a regular expression, not shell globbing, test you rexexes: http://www.softlion.com/webTools/RegExpTest/

*usage:* send_file "${CHAT[ID]}" "file" "caption"

*example:* 
```bash
send_file "${CHAT[ID]}" "/home/user/doge.jpg" "Lool"
send_file "${CHAT[ID]}" "https://www.domain,com/something.gif" "Something"
```

##### send_location
*usage:* send_location "${CHAT[ID]}" "Latitude" "Longitude"


##### send_venue
*usage:* send_venue "${CHAT[ID]}" "Latitude" "Longitude" "Title" "Address" "foursquare id (optional)"


----

##### send_keyboard
Note: since version 0.6 send_keyboard was changed to use native "JSON Array" notation as used from Telegram. Example Keybord Array definitions:

- yes no in two rows:
    - OLD format: 'yes' 'no' (two strings)
    - NEW format: '[ "yes" ] , [ "no" ]' (two arrays with a string)
- new layouts made easy with NEW format:
    - Yes No in one row: '[ "yes" , "no" ]'
    - Yes No plus Maybe in 2.row: '[ "yes" , "no" ] , [ "maybe" ]' 
    - numpad style keyboard: '[ "1" , "2" , "3" ] , [ "4" , "5" , "6" ] , [ "7" , "8" , "9" ] , [ "0" ]'

*usage:*  send_keyboard "chat-id" "message" "keyboard"

*alias:* _keyboard "message" "keyboard"

*example:* 
```bash
send_keyboard "${CHAT[ID]}" "Say yes or no" '[ "yes" , "no" ]' # in one row
send_keyboard "${CHAT[ID]}" "Say yes or no" '[ "yes" ] , [ "no" ]' # 2 rows
send_keyboard "${CHAT[ID]}" "Enter digit" '[ "1" , "2" , "3" ] , [ "4" , "5" , "6" ] , [ "7" , "8" , "9" ] , [ "0" ]'

_keyboard_yesno  # see aliases
_keyboard_numpad

```

##### remove_keyboard
*usage:* remove_keybord "$CHAT[ID]" "message"

*alias:* _del_keyboard "message"

*See also: [Keyboard Markup](https://core.telegram.org/bots/api/#replykeyboardmarkup)*

----

##### send_button
*usage:*  send_button "chat-id" "message" "text" "URL"

*alias:* _button "text" "URL"

*example:* 
```bash
send_button "${CHAT[ID]}" "MAKE MONEY FAST!!!" "Visit my Shop" "https://dealz.rrr.de"
```

##### send_inline_keyboard
This allows to place multiple inline buttons in a row. The inline buttons must specified as a JSON array in the following format:

```[ {"text":"text1", "url":"url1"}, ... {"text":"textN", "url":"urlN"} ]```

Each button consists of a pair of text and URL values, sourrounded by '{ }', multiple buttons are seperated by '**,**' and everthing is wrapped in '[ ]'.

*usage:*  send_inline_keyboard "chat-id" "message" "[ {"text":"text", "url":"url"} ...]"

*alias:* _inline_keyboard "[{"text":"text", "url":"url"} ...]"

*example:* 
```bash
send_inline_keyboard "${CHAT[ID]}" "MAKE MONEY FAST!!!" '[{"text":"Visit my Shop", url"":"https://dealz.rrr.de"}]'
send_inline_keyboard "${CHAT[ID]}" "" '[{"text":"button 1", url"":"url 1"}, {"text":"button 2", url"":"url 2"} ]'
send_inline_keyboard "${CHAT[ID]}" "" '[{"text":"b 1", url"":"u 1"}, {"text":"b 2", url"":"u 2"}, {"text":"b 2", url"":"u 2"} ]'
```

*See also [Inline keyboard markup](https://core.telegram.org/bots/api/#inlinekeyboardmarkup)*

----

### User Access Control
The following basic user control functions are part of the Telegram API.
More advanced API functions are currently not implemented in bashbot.

##### kick_chat_member
If your Bot is a chat admin he can kick and ban a user.

*usage:* kick_chat_member "${CHAT[ID]}" "${USER[ID]}"

*alias:* _kick_user "${USER[ID]}"

##### unban_chat_member
If your Bot is a chat admine can unban a kicked user.

*usage:*  unban_chat_member "${CHAT[ID]}" "${USER[ID]}"

*alias:* _unban "${USER[ID]}"

##### leave_chat
Your Bot will leave the chat.

*usage:* leave_chat "${CHAT[ID]}"

*alias:* _leave 

```bash
if _is_admin ; then 
 send_markdown_message "${CHAT[ID]}" "*LEAVING CHAT...*"
 leave_chat "${CHAT[ID]}"
fi
```

'See also [kick Chat Member](https://core.telegram.org/bots/api/#kickchatmember)*

----

The following functions are bashbot only and not part of the Telegram API. 

##### user_is_botadmin
Return true (0) if user is admin of bot, user id if botadmin is read from file './botadmin'.

*usage:*  user_is_botadmin "${USER[ID]}"

*alias:* _is_botadmin 

*example:* 
```bash
 _is_botadmin && send_markdown_message "${CHAT[ID]}" "You are *BOTADMIN*."
```

##### user_is_creator
Return true (0) if user is creator of given chat or chat is a private chat.

*usage:* user_is_creator "${CHAT[ID]}" "${USER[ID]}"

*alias:* _is_creator

##### user_is_admin
Return true (0) if user is admin or creator of given chat.
 
*usage:* user_is_admin "${CHAT[ID]}" "${USER[ID]}"

*alias:* _is_admin

*example:* 
```bash
if _is_admin ; then 
  send_markdown_message "${CHAT[ID]}" "*LEAVING CHAT...*"
  leave_chat "${CHAT[ID]}"
fi
```

*See also [Chat Member](https://core.telegram.org/bots/api/#chatmember)*

##### user_is_allowed
Bahsbot supports User Access Control, see [Advanced Usage](3_advanced.md)

*usage:* user_is_allowed "${USER[ID]}" "what" "${CHAT[ID]}"

*example:* 
```bash
if ! user_is_allowed "${USER[ID]}" "start" "${CHAT[ID]}" ; then
  send_normal_message "${CHAT[ID]}" "You are not allowed to start Bot."
fi
```

----

### Inline Queries - answer direct queries to bot
Inline Queries allows users to interact with your bot directly without sending extra commands.
As an answer to an inline query you can send back one or more results to the Telegram client. 
The Telegram client will then show the results to the user and let him select one.

##### answer_inline_query
answer_inline_query is provided for backward compatibility with older versions of bashbot.
It send back only one response to an inline query.

*usage:* answer_inline_query "$i{QUERY[ID]}" "type" "type arg 1" ... "type arg n" 

*example:* - see [Advanced Usage](3_advanced.md#Inline-queries)


##### answer_inline_multi
anser_inline_multi allows you to send back a list of responses. responses must be seperated by ','.

*usage:* answer_inline_multi "${iQUERY[ID]}" "res, res, ... res" 

*example:*
```bash
# note the starting " and ending " !!
answer_inline_multi "${iQUERY[ID]}" "
    $(inline_query_compose "1" "photo" "https://avatars0.githubusercontent.com/u/13046303") ,
    ...
    $(inline_query_compose "n" "photo" "https://avatars1.githubusercontent.com/u/4593242")
    "
```

##### inline_query_compose
inline_query_compose composes one response element to to send back. 

*usage:*  inline_query_compose ID type args ....

```
	ID = unique ID for this response, 1-64 byte long
	type = type of answer, e.g. article, photo, video, location ...
	args = mandatory arguments in the order they are described in telegram documentation
```

Currently the following types and arguments are implemented (optional arguments in parenthesis)
```
	"article"|"message"	title message (parse_mode description)

	"photo"			photo_URL (thumb_URL title description caption parse_mode keyboard)
	"gif"			photo_URL (thumb_URL title caption parse_mode keyboard)
	"mpeg4_gif"		mpeg_URL (thumb_URL title caption  parse_mode keyboard)
	"video"			video_URL mime_type thumb_URL title (caption parse_mode keyboard)
	"audio"			audio_URL title (caption parse_mode keyboard)
	"voice"			voice_URL title (caption parse_mode keyboard)
	"document"		title document_URL mime_type (caption description parse_mode)

	"location"		latitude longitude title
	"venue"			latitude longitude title (adress foursquare)
	"contact"		phone first (last thumb)

	"cached_photo"		file (title description caption parse_mode keyboard)
	"cached_gif"		file (title caption parse_mode keyboard)
	"cached_mpeg4_gif"	file (title caption parse_mode keyboard)
	"cached_sticker"	file (keyboard)
	"cached_document"	title file (description caption description parse_mode keyboard)
	"cached_video"		file title (description caption description parse_mode keyboard)
	"cached_voice"		file title (caption parse_mode keyboard)
	"cached_audio"		file title (caption parse_mode keyboard)
```
see [InlineQueryResult for more information](https://core.telegram.org/bots/api#inlinequeryresult) about response types and their arguments.

----


### Background and Interactive jobs
Background functions and interactive jobs extends the bot functionality to not only react to user input. You can start scripts for interative
chats and send messages based on time or other external events.

##### start_proc
```startproc``` starts a script, the output of the script is sent to the user or chat, user input will be sent back to the script. see [Advanced Usage](3_advanced.md#Interactive-Chats)

*usage:* start_proc "${CHAT[ID]}" "script"

*alias:* startproc "script"

*example:* 
```bash
startproc 'examples/calc.sh'
```


##### check_proc
Return true (0) if an interactive script is running in the chat. 

*usage:* check_prog "${CHAT[ID]}"

*alias:* checkprog 

*example:* 
```bash
if ! check_proc "${CHAT[ID]}" ; then
  startproc "examples/calc.sh"
else
   send_normal_message "${CHAT[ID]}" "Calc already running ..."
fi
```

##### kill_proc
Kill the interactive script running in the chat

*usage:* kill_proc "${CHAT[ID]}"

*alias:* killproc

*example:* 
```bash
if check_proc "${CHAT[ID]}" ; then
  killproc && send_message "${CHAT[ID]}" "Command canceled."
else
  send_message "${CHAT[ID]}" "Command is not running."
fi
```

----

##### start_back
Starts a script as a background job and attaches a jobname to it. All output from a background job is sent to the associated chat.

In contrast to interactive chats, background jobs do not recieve user input and can run forever. In addition you can suspend and restart running jobs, e.g. after reboot.

*usage:* start_back "${CHAT[ID]}" "script" "jobname"

*alias:* background "script" "jobname"

*example:* 
```bash
background "examples/notify.sh" "notify"
```

##### check_back
Return true (0) if an background job is active in the given chat. 

*usage:*  check_back "${CHAT[ID]}" "jobname"

*alias:*  checkback "jobname"

*example:* 
```bash
if ! checkback "notify" ; then
  send_normal_message "${CHAT[ID]}" "Start notify"
  background "examples/notify.sh" "notify"
else
 send_normal_message "${CHAT[ID]}" "Process notify already running."
fi
```

##### kill_back

*usage:* kill_back "${CHAT[ID]}" "jobname"

*alias:* killback "jobname"

*example:* 
```bash
checkback "notify"
if [ "$res" -eq 0 ] ; then
  send_normal_message "${CHAT[ID]}" "Kill notify"
  killback "notify"
else
  send_normal_message "${CHAT[ID]}" "Process notify not run."
fi
```

----

##### send_interactive
Form version 0.80 on forward_message is used to forward messages to interactive job. It replaces the old 'inproc' commands used for TMUX.
Usually  message is automatically forwarded in 'commands.sh', but you can forward messages wihle processing also or send your own messages.

*usage:* send_interactive "${CHAT[ID]}" "message"

*replaces:* incproc

----

### jsshDB
Since output generated by JSON.sh is so handy to use in bash, we use the format for a simple keys/value storage and providing
fucntions to read and write JSON.sh style data from and to files.
The file extions is '.jssh' and for security reasons location of jssh files is restricted to BASHBOT_ETC and BASHBOT_DATA..

Note: File names containg '..' and absolute file names pointing outside BASHBOT_ETC or BASHBOT_DATA are refused by jsshDB functions. 

Note2: Since version 0.94 jsshDB functions support file locking with flock. Write / Update operations use flock to wait until
previous operations are finished. see "man flock" for more information. Bashbot uses a maximum timeout of 10 seconds for flock.

If you don't want atomic write / update operations use the *_async variant of jsshDB functions. If flock is not availible
the *_async variant is automatically used.

*Example:* for file name:
```bash
# bashbot is installed in /usr/local/telegram-bot-bash, BASHBOT_ETC is not set.
"myfile" -> /usr/local/telegram-bot-bash/myfile.jssh
"addons/myfile" -> /usr/local/telegram-bot-bash/addons/myfile.jssh
"${DATADIR}/myfile" -> /usr/local/telegram-bot-bash/data-bot-bash/myfile.jssh
"/home/someuser/myfile" -> function returns false, nothing done.
```

##### jssh_newDB
Creats new empty jsshDB file if not exist.

*usage:*  jssh_newDB "filename"

##### jssh_checkDB
Check if DB name respects the rules mentioned above and returns the real/final path to DB file.
Used internally by all jssh DB functions, but can also used to get the real filename for a jssh DB.

*usage:*  jssh_checkDB "filename"

```bash
if file=$(jssh_checkDB somename); then
	echo "Final filename is ${file}"
else
	echo "Something wrong with somename"
fi

# somename = data-bot-bash/somevalues
Final filename is data-bot-bash/somevalues.jssh

# somename = /home/someuser/myfile
Something wrong with /home/someuser/myfile

# somename = data-bot-bash/../../../somevalues
Something wrong with data-bot-bash/../../../somevalues
```

##### jssh_writeDB
Write content of an ARRAY into jsshDB file. ARRAY name must be delared with "declare -A ARRAY" before calling writeDB.
"DB" file MUST exist or nothing is written.

Note: Existing content is overwritten.

*usage:*  jssh_writeDB "ARRAY" "filename"

*usage:*  jssh_writeDB_async "ARRAY" "filename"

*example:* 
```bash
# Prepare array to store vaules
declare -A  WRITEVALUES

WRITEVALUES["value1"]="example"
WRITEVALUES["value2"]="a value"
WRITEVALUES["whynot","subindex1"]="whynot A"
WRITEVALUES["whynot","subindex2"]="whynot B"
WRITEVALUES["whynot","subindex2","text"]="This is an example content for pseudo multidimensional bash array"

# create DB
jssh_newDB "${DATADIR:-.}/myvalues"

# write to file data-bot-bash/somevalues.jssh from array MYVALUES
jssh_writeDB "WRITEVALUES" "${DATADIR:-}/myvalues"

# show whats written
cat "${DATADIR:-}/myvalues.jssh"
["value1"]	"example"
["value2"]	"a value"
["whynot","subindex2","text"]	"This is an example content for pseudo multidimensional bash array"
["whynot","subindex2"]	"whynot B"
["whynot","subindex1"]	"whynot A"
```

##### jssh_printDB
Print content of an ARRAY to STDOUT. ARRAY name must be delared with "declare -A ARRAY" before calling printDB..

*usage:*  jssh_printDB "ARRAY" 

*example:* 
```bash
# Prepare array to store vaules
declare -A  PRINTVALUES

# read file data-bot-bash/myvalues.jssh into array READVALUES
jssh_readDB "PRINTVALUES" "${DATADIR:-}/myvalues"

# print DB to stdout
jssh_printDB READVALUES
["value1"]	"example"
["value2"]	"a value"
["whynot","subindex2","text"]	"This is an example content for pseudo multidimensional bash array"
["whynot","subindex2"]	"whynot B"
["whynot","subindex1"]	"whynot A"```
```

##### jssh_updateDB
Update/Add content of an ARRAY into a jsshDB file. ARRAY name must be delared with "declare -A ARRAY" before calling updateDB.
"DB" file MUST exist or nothing is written.

Note: Existing content not in ARRAY is kept in file.

*usage:*  jssh_updateDB "ARRAY" "filename"

*usage:*  jssh_updateDB_async "ARRAY" "filename"

*example:* 
```bash
# continued example from writeDB
MYVALUES=()
MYVALUES["newvalue"]="this is new"

# update file data-bot-bash/somevalues.jssh from array MYVALUES
jssh_updateDB "MYVALUES" "${DATADIR:-.}/myvalues"

# show whats written
["value1"]	"value1"
["loveit"]	"value2"
["whynot"]	"value3"
["newvalue"]	"this is new"

# now writeDB
cat "$DBfile"
jssh_writeDB "MYVALUES" "${DATADIR:-.}/myvalues"

# show whats written, ups!
cat "$DBfile"
["newvalue"]	"this is new"

```

##### jssh_readDB
Read content of a file in JSON.sh format into given ARRAY.  ARRAY name must be delared with "declare -A ARRAY" upfront,

*usage:*  jssh_readDB "ARRAY" "filename"

*usage:*  jssh_readDB_async "ARRAY" "filename"

Note: readDB uses concurrent / shared locking from flock so multiple proceses can read from file, as long no process is writing.
Maximum timeour for reading is 1s to not block readers.

*example:* 
```bash
# Prepare array to read vaules
declare -A  READVALUES

# read file data-bot-bash/myvalues.jssh into array READVALUES
jssh_readDB "READVALUES" "${DATADIR:-}/myvalues"

# sinple command to output values ONLY
printf "${READVALUES[*]}"
example a value This is an example content for pseudo multidimensional bash array whynot B whynot A

# print DB to stdout
jssh_printDB READVALUES
["value1"]	"example"
["value2"]	"a value"
["whynot","subindex2","text"]	"This is an example content for pseudo multidimensional bash array"
["whynot","subindex2"]	"whynot B"
["whynot","subindex1"]	"whynot A"


# access Arrray
echo "${READVALUES[vaule2]}"
a value

# change / add values
READVALUES["value2"]="this is a changed value"

echo "${READVALUES[vaule2]}"
this is a changed value

READVALUES["value3"]="new value"
READVALUES[whynot,subindex3]="new subindex value"

# new output
jssh_printDB READVALUES
["value1"]	"example"
["value3"]	"new value"
["value2"]	"this is a changed value"
["whynot","subindex2","text"]	"This is an example content for pseudo multidimensional bash array"
["whynot","subindex3"]	"new subindex value"
["whynot","subindex2"]	"whynot B"
["whynot","subindex1"]	"whynot A"
```

##### jssh_insertDB
Insert, update, append a key=value pair to a jsshDB file, key name is only allowed to contain '-a-zA-Z0-9,._'

*usage:*  jssh_insertDB "key" "value" "filename"

*usage:*  jssh_insertDB_asnyc "key" "value" "filename"

Note: insertDB uses also excusiv write locking, but with a maximum timeout of 2s. insertDB is a "fast" operation, simply adding the value to the end of the file.

*example:* 
```bash
jssh_insertDB "newkey" "an other value" "${DATADIR:-.}/myvalues"
```

##### jssh_deleteKeyDB
Deleted a key=value pair froma jsshDB file, key name is only allowed to contain '-a-zA-Z0-9,._'

*usage:*  jssh_deleteKeyDB "key" "filename"

*usage:*  jssh_deleteKeyDB_async "key" "filename"

*example:* 
```bash
jssh_deleteKeyDB "delkey"" "${DATADIR:-.}/myvalues"
```

##### jssh_countKeyDB
Increase a key=value pair from a jsshDB file by 1, key name is only allowed to contain '-a-zA-Z0-9,._'
If value is given key is increased by value.

Side effect: if value is given key is updated "in place" (slower) and file is cleand up, if no value is given fast path is used
and new count is added to the end of file.

*usage:*  jssh_countKeyDB "key" "filename" ["value"]

*usage:*  jssh_countKeyDB_async "key" "filename" ["value"]

*example:* 
```bash
jssh_countKeyDB "usercount"" "${DATADIR:-.}/myvalues"
```

https://linuxhint.com/associative_array_bash/

https://linuxconfig.org/how-to-use-arrays-in-bash-script


----

### Aliases - shortcuts for often used funtions 
Aliases are handy shortcuts for using in 'mycommands.sh', they avoid error prone typing of  "${CHAT[ID]}" "${USER[ID]}" as much as possible.
Do not use them in bashbot.sh, modules and addons.

##### _is_botadmin

*usage:* _is_botadmin

*alias for:* user_is_botadmin "${USER[ID]}"

##### _is_admin

*usage:* _is_admin

*alias for:* user_is_admin "${CHAT[ID]}" "${USER[ID]}"

##### _is_allowed

*usage:* _is_allowed "what"

*alias for:* user_is_allowed "${USER[ID]}" "what" "${CHAT[ID]}"

----

##### _kick_user

*usage:* _kick_user "${USER[ID]}"

*alias for:* kick_chat_member "${CHAT[ID]}" "${USER[ID]}"

##### _unban

*usage:* _unban "${USER[ID]}"

*alias for:*  unban_chat_member "${CHAT[ID]}" "${USER[ID]}"

##### _leave

*usage:* _leave 

*alias for:* leave_chat "${CHAT[ID]}"

----

##### _message

*usage:* _message "message"

*alias for:* send_normal_message "${CHAT[ID]}" "message"

##### _normal_message

*usage:* _normal_message "message"

*alias for:* send_normal_message "${CHAT[ID]}" "message"

##### _html_message

*usage:* _html_message "message"

*alias for:* send_html_message "${CHAT[ID]}" "message"

##### _markdown_message

*usage:* _markdown_message "message"

*alias for:* send_markdown_message "${CHAT[ID]}" "message"

----

#### _inline_button
*usage:* _inline_button "${1}" "${2}" 

*alias for:* send_inline_button "${CHAT[ID]}" "" "${1}" "${2}" 

#### _inline_keyboard
*usage:* _inline_keyboard "${1}"

*alias for:* _inline_keyboard "${CHAT[ID]}" "" "${1}"

#### _keyboard_numpad
*usage:* _keyboard_numpad

*alias for:* send_keyboard "${CHAT[ID]}" "" '["1","2","3"],["4","5","6"],["7","8","9"],["-","0","."]' "yes"

#### _keyboard_yesno
*usage:* _keyboard_yesno

*alias for:* send_keyboard '["yes","no"]'

#### _del_keyboard
*usage:* _del_keyboard 

*alias for:* remove_keyboard "${CHAT[ID]}" ""

----

### Helper functions

##### download
Download the fiven URL ans returns the final filename in TMPDIR. If the given filename exists,the filename is prefixed with a
random number. filename is not allowed to contain '/' or '..'.

*usage:* download URL filename

*example:* 
```bash
file="$(download "https://avatars.githubusercontent.com/u/13046303" "avatar.jpg")"
echo "$file" -> ./data-bot-bash/avatar.jpg
file="$(download "https://avatars.githubusercontent.com/u/13046303" "avatar.jpg")"
echo "$file" -> ./data-bot-bash/12345-avatar.jpg
```

##### _exec_if_function
Returns true, even if the given function does not exist. Return false if function exist but returns false.

*usage:* _exec_if_function function

*example:* 
```bash
_exec_if_function "answer_inline_query" "${iQUERY[ID]}" "Answer params"

# fast replacment for module functions exists check:
if _is_function "answer_inline_query"
then
	"answer_inline_query" "${iQUERY[ID]}" "Answer params"
fi

```

##### _exists
Returns true if the given function exist, can be used to check if a module is loaded.

*usage* _exists command


*example:* 
```bash
_exists "curl" && _message "Command curl is not installed!"
```

##### _is_function
Returns true if the given function exist, can be used to check if a module is loaded.

*usage* _is_function function

*example:* 
```bash
_is_function "background" && _message "you can run background jobs!"
```

----

### Bashbot internal functions
These functions are for internal use only and must not used in your bot commands.

##### procname
Returns PrefixBotname_Postfix

*usage:* procname postfix prefix

*example:*
```bash
# returns botname, if already set
procname 
# returns unique identifier for everthing related to chat
procname "${CHAT[ID]}"
# returns unique identifier for job, regardless of chat
procname "" "back-jobname-"
# returns unique identifier for a job related to a chat
# e.g. fifo, cmd and logfile name
procname "${CHAT[ID]}" "back-jobname-"
```

##### proclist
Returns process IDs of current bot processes containing string 'pattern' in name or argument.

*usage:* proclist pattern

*example:*
```bash
# list PIDs of all background processes
proclist "back-"
# list PIDs of all processes of a job
proclist "back-jobname-"
# list PIDs of all processes for a chat
proclist "_${CHAT[ID]}"
# list PIDs of all bot processes
proclist 
```
##### killallproc
kill all current bot processes containing string 'pattern' in name or argument

*usage:* killallproc pattern

*example:* 
```bash
# kill all background processes
killallproc "back-"
# kill all processes for a chat
killallproc "_${CHAT[ID]}"
# kill all bot processes, including YOURSELF!
killallproc 
```

----

##### get_file
*usage:* url="$(get_file "${CHAT[ID]}" "message")"

##### send_text
*usage:* send_text "${CHAT[ID]}" "message"

----

##### JsonDecode
Outputs decoded string to STDOUT

*usage:* JsonDecode "string"

##### JsonGetString
Reads JSON from STDIN and Outputs found String to STDOUT

*usage:*  JsonGetString `"path","to","string"`

##### JsonGetValue
Reads JSON fro STDIN and Outputs found Value to STDOUT

*usage:*  JsonGetValue `"path","to","value"`


##### Json2Array
Read JSON.sh style data from STDIN and asssign to given ARRAY
ARRAY name  must be declared with "declare -A ARRAY" before calling

*usage:* Json2Array "ARRAY"

##### Array2Json
Output ARRAY as JSON.sh style data to STDOUT

*usage:* Array2Json "ARRAY"

----

##### get_chat_member_status
*usage:* get_chat_member_status "${CHAT[ID]}" "${USER[ID]}"


----

##### process_client
Every Message sent to your Bot is processd by this function. It parse the send JSON and assign the found Values to bash variables.

##### process_updates
If new updates are availible, this functions gets the JSON from Telegram and dispatch it.

##### process_inline
Every Inline Message sent to your Bot is processd by this function. It parse the send JSON and assign the found Values to bash variables.

##### start_timer
Start the the every minute timer ...

##### event_timer
Dispatcher for BASHBOT_EVENT_TIMER

##### event_timer
Dispatcher for BASHBOT_EVENT_INLINE

##### event_timer
Dispatcher for BASHBOT_EVENT_MESSAGE and related

----

##### getBotName
The name of your bot is availible as bash variable "$ME", there is no need to call this function if Bot is running.

*usage:* ME="$(getBotName)"

#### [Prev Best Practice](5_practice.md)
#### [Next Notes for Developers](7_develop.md)

#### $$VERSION$$ v0.96-dev-7-g0153928

