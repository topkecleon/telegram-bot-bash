#### [Home](../README.md)
## Bashbot function reference

### Send, forward, delete messages

##### send_action
```send_action``` shows users what your bot is currently doing.

*usage:* send_action "${CHAT[ID]}" "action"

*"action":* ```typing```, ```upload_photo```, ```record_video```, ```upload_video```, ```record_audio```, ```upload_audio```, ```upload_document```, ```find_location```.

*example:* 
```bash
send_action "${CHAT[ID]}" "typing"
send_action "${CHAT[ID]}" "record_audio"
```


##### send_normal_message
```send_normal_message``` sends text only messages to the given chat.

*usage:*  send_normal_message "${CHAT[ID]}" "message"

*example:* 
```bash
send_normal_message "${CHAT[ID]}" "this is a text message"
```


##### send_markdown_message
```send_markdown_message``` sends markdown style messages to the given chat.
Telegram supports a [reduced set of Markdown](https://core.telegram.org/bots/api#markdown-style) only

*usage:* send_markdown_message "${CHAT[ID]}" "markdown message"

*example:* 
```bash
send_markdown_message "${CHAT[ID]}" "this is a markdown  message, next word is *bold*"
send_markdown_message "${CHAT[ID]}" "*bold* _italic_ [text](link)"
```

##### send_html_message
```send_html_message``` sends HTML style messages to the given chat.
Telegram supports a [reduced set of HTML](https://core.telegram.org/bots/api#html-style) only

*usage:* send_html_message "${CHAT[ID]}" "html message" 

*example:* 
```bash
send_normal_message "${CHAT[ID]}" "this is a markdown  message, next word is <b>bold</b>"
send_normal_message "${CHAT[ID]}" "<b>bold</b> <i>italic><i> <em>italic>/em> <a href="link">Text</a>"
```

##### forward_message
```forward_mesage``` forwards a messsage to the given chat.

*usage:* forward_message "chat_to" "chat_from" "${MESSAGE[ID]}"

*old call:* forward "${CHAT[ID]}" "$FROMCHAT" "${MESSAGE[ID]}"

See also [Text formating options](https://core.telegram.org/bots/api#formatting-options)

----

##### delete_message
If your Bot is admin of a Chat he can delete every message, if not he can delete only his messages.

*usage:* delete_message "${CHAT[ID]}" "${MESSAGE[ID]}"

See also [deleteMessage limitations](https://core.telegram.org/bots/api#deletemessage)

----

##### answer_inline_query
Inline Queries allows users to interact with your bot directly without sending extra commands.
answer_inline_query provide the result to a users Inline Query

*usage:* answer_inline_query "$iQUERY_ID" "type" "type arg 1" ... "type arg n" 

*example:* - see [Advanced Usage](3_advanced.md#Inline-queries)

----

### File, Location, Venue, Keyboard 


##### send_file
send_file allows you to send different type's of files, e.g. photos, stickers, audio, media, etc. [see more](https://core.telegram.org/bots/api#sending-files)

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

*example:* 
```bash
send_keyboard "${CHAT[ID]}" "Say yes or no" "[ \\"yes\" , \\"no\" ]""
send_keyboard "${CHAT[ID]}" "Say yes or no" "[ \\"yes\\" ] , [ \\"no\\" ]"
send_keyboard "${CHAT[ID]}" "Enter digit" "[ \\"1\\" , \\"2\\" , \\"3\\" ] , [ \\"4\\" , \\"5\\" , \\"6\\" ] , [ \\"7\\" , \\"8\\" , \\"9\\" ] , [ \\"0\\" ]"
```

##### remove_keyboard
*usage:* remove_keybord "$CHAT[ID]" "message"

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

### Manage users 

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

### User Access Control

##### user_is_botadmin
Return true (0) if user is admin of bot, user id if botadmin is read from file './botadmin'.

*usage:*  user_is_botadmin "${USER[ID]}"

*modules/alias:* _is_botadmin 

*example:* 
```bash
 _is_botadmin && send_markdown_message "${CHAT[ID]}" "You are *BOTADMIN*."
```

##### user_is_creator
Return true (0) if user is creator of given chat or chat is a private chat.

*usage:* user_is_creator "${CHAT[ID]}" "${USER[ID]}"

*modules/alias:* _is_creator

##### user_is_admin
Return true (0) if user is admin or creator of given chat.
 
*usage:* user_is_admin "${CHAT[ID]}" "${USER[ID]}"

*modules/alias:* _is_admin

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

### Aliases - shortcuts for often used funtions 
You must not disable  ```source modules/aliases.sh``` in 'commands.sh' to have the following functions availible.

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

### Interactive and backgound jobs
You must not disable  ```source modules/background.sh``` in 'commands.sh' to have the following functions availible.

##### startproc
```startproc``` starts a script, the output of the script is sent to the user or chat, user input will be sent back to the script. see [Advanced Usage](3_advanced.md#Interactive-Chats)

*usage:* startproc "script"

*example:* 
```bash
startproc 'examples/calc.sh'
```

##### checkproc
Return true (0) if an interactive script is running in the chat. 

*usage:* checkprog

*example:* 
```bash
checkproc 
if [ "$res" -gt 0 ] ; then
  startproc "examples/calc.sh"
else
   send_normal_message "${CHAT[ID]}" "Calc already running ..."
fi
```

##### killproc
Kill the interactive script running in the chat

*usage:* killproc

*example:* 
```bash
checkprog
if [ "$res" -eq 0 ]; then
  killproc && send_message "${CHAT[ID]}" "Command canceled."
else
  send_message "${CHAT[ID]}" "Command is not running."
fi
```

----

##### background
Starts a script as a background job and attaches a jobname to it. All output from a background job is sent to the associated chat.

In contrast to interactive chats, background jobs do not recieve user input and can run forever. In addition you can suspend and restart running jobs, e.g. after reboot.

*usage:* background "script" "jobname"

*example:* 
```bash
background "examples/notify.sh" "notify"
```

##### checkback
Return true (0) if an background job is active in the given chat. 

*usage:*  checkback "jobname"

*example:* 
```bash
checkback "notify"
if [ "$res" -gt 0 ] ; then
  send_normal_message "${CHAT[ID]}" "Start notify"
  background "examples/notify.sh" "notify"
else
 send_normal_message "${CHAT[ID]}" "Process notify already running."
fi
```

##### killback
*usage:* killback "jobname"

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

##### send_message
```send_message``` sends any type of message to the given chat. Type of output is steered by keywords within the message. 

The main use case for send_message is to process the output of interactive chats and background jobs. **For regular Bot commands I recommend using of the dedicated send_xxx_message() functions from above.**

*usage:* send_message "${CHAT[ID]}" "message"

*example:* - see [Usage](2_usage.md#send_message) and [Advanced Usage](3_advanced.md#Interactive-Chats)

----

### Helper functions

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

##### get_file
*usage:* url="$(get_file "${CHAT[ID]}" "message")"

----

##### send_text
*usage:* send_text "${CHAT[ID]}" "message"

----

##### JsonDecode
Outputs decoded string to STDOUT

*usage:* JsonDecode "string"

##### JsonGetString
Reads JSON fro STDIN and Outputs found String to STDOUT

*usage:*  JsonGetString `"path","to","string"`

##### JsonGetValue
Reads JSON fro STDIN and Outputs found Value to STDOUT

*usage:*  JsonGetValue `"path","to","value"`

----

##### get_chat_member_status
*usage:* get_chat_member_status "${CHAT[ID]}" "${USER[ID]}"

this may get an official function ...

----

##### process_client
Every Message sent to your Bot is processd by this function. It parse the send JSON and assign the found Values to bash variables.

##### process_updates
If new updates are availible, this functions gets the JSON from Telegram and dispatch it.

----
##### getBotName
The name of your bot is availible as bash variable "$ME", there is no need to call this function if Bot is running.

*usage:* ME="$(getBotNiname)"

##### inproc
Send Input from Telegram to waiting Interactive Chat.

#### [Prev Best Practice](5_practice.md)
#### [Next Notes for Developers](7_develop.md)

#### $$VERSION$$ v0.70-0-g6243be9

