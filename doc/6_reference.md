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
send_normal_message "${CHAT[ID]}" "this is a markdown  message, next word is *bold*"
send_normal_message "${CHAT[ID]}" "*bold* _italic_ [text](link)"
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

*alias:* forward "${CHAT[ID]}" "$FROMCHAT" "${MESSAGE[ID]}"

----

##### send_message
```send_message``` sends any type of message to the given chat. Type of output is steered by keywords within the message. 

The main use case for send_message is to process the output of interactive chats and background jobs. **For regular Bot commands I recommend using of the dedicated send_xxx_message() functions from above.**

*usage:* send_message "${CHAT[ID]}" "message"

*example:* - see [Usage](2_usage.md#send_message) and [Advanced Usage](3_advanced.md#Interactive-Chats)

----

##### delete_message
If your Bot is admin of a Chat he can delete every message, if not he can delete only his messages.

*usage:* delete_message "${CHAT[ID]}" "${MESSAGE[ID]}"

----

##### answer_inline_query
Inline Queries allows users to interact with your bot directly without sending extra commands.
answer_inline_query provide the result to a users Inline Query

*usage:* answer_inline_query "$iQUERY_ID" "type" "type arg 1" ... "type arg n" 

*example:* - see [Advanced Usage](3_advanced.md#Inline-queries)

----

### File, Location, Venu, keyboards 

##### get_file
*usage:* 

*example:* 
```bash
```

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

- yes no in one row
    - OLD format: "yes" "no" (two strings)
    - NEW format: "[ \\"yes\\" , \\"no\\" ]" (string containing an array)
- new keybord layouts, no possible with old format:
    - Yes No in two rows: "[ \\"yes\\" ] , [ \\"no\\" ]"
    - numpad style keyboard: "[ \\"1\\" , \\"2\\" , \\"3\\" ] , [ \\"4\\" , \\"5\\" , \\"6\\" ] , [ \\"7\\" , \\"8\\" , \\"9\\" ] , [ \\"0\\" ]"


*usage:*  send_keyboard "chat-id" "keyboard"

*example:* 
```bash
send_keyboard "${CHAT[ID]}" "[ \\"yes\" , \\"no\" ]""
send_keyboard "${CHAT[ID]}" "[ \\"yes\\" ] , [ \\"no\\" ]"
send_keyboard "${CHAT[ID]}" "[ \\"1\\" , \\"2\\" , \\"3\\" ] , [ \\"4\\" , \\"5\\" , \\"6\\" ] , [ \\"7\\" , \\"8\\" , \\"9\\" ] , [ \\"0\\" ]"
```

##### remove_keyboard
*usage:* 


### Manage users 

##### kick_chat_member
If your Bot is Admin of a chat he can kick and ban a user.

*usage:*  kick_chat_member "${CHAT[ID]}" "${USER[ID]}"


##### unban_chat_member
If your Bot is Admin of a chat he can unban a kicked user.

*usage:*  unban_chat_member "${CHAT[ID]}" "${USER[ID]}"

##### leave_chat
Bot will leave given chat.

*usage:* leave_chat "${CHAT[ID]}"

```bash
if _is_admin ; then 
 send_markdown_message "${CHAT[ID]}" "*LEAVING CHAT...*"
 leave_chat "${CHAT[ID]}"
fi
```

----

##### user_is_creator
Return true (0) if user is creator of given chat or chat is a private chat.

*usage:* user_is_creator "${CHAT[ID]}" "${USER[ID]}"

*alias:* _is_creator

##### user_is_admin
Return true (0) if user is admin or creator of given chat.
 
*usage:* user_is_admin "${CHAT[ID]}" "${USER[ID]}"

*alias:* _is_creator

*example:* 
```bash
if _is_admin ; then 
  send_markdown_message "${CHAT[ID]}" "*LEAVING CHAT...*"
  leave_chat "${CHAT[ID]}"
fi
```

##### user_is_botadmin
Return true (0) if user is owner / admin of bot. 
Name or ID botadmin must be placed in './botadmin' file.

*usage:*  user_is_botadmin "${CHAT[ID]}" "${USER[ID]}"

*alias:* _is_botadmin

*example:* 
```bash
 _is_botadmin && send_markdown_message "${CHAT[ID]}" "You are *BOTADMIN*."
```

##### user_is_allowed
Bahsbot supports User Access Control, see [Advanced Usage](4_advanced.ma)

*usage:* user_is_allowed "${USER[ID]}" "what" "${CHAT[ID]}"

*example:* 
```bash
if ! user_is_allowed "${USER[ID]}" "start" "${CHAT[ID]}" ; then
  send_normal_message "${CHAT[ID]}" "You are not allowed to start Bot."
fi
```

### Interactive and backgound jobs

##### startproc
```startproc``` starts a script (or C or python program etc.) running in parallel to your Bot. The text that the script outputs is sent to the user or chat, user input will be sent back to the script. see [Advanced Usage](3_advanced.md#Interactive-Chats)

*usage:* startproc "./script"

*example:* 
```bash
startproc './calc'
```

##### checkproc
Return true (0) if an interactive script active in the given chat. 

*usage:* checkprog

*example:* 
```bash
checkproc 
if [ "$res" -gt 0 ] ; then
  startproc "./calc"
else
   send_normal_message "${CHAT[ID]}" "Calc already running ..."
fi
```

##### killproc
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
```background``` starts a script / programm as a background job and attaches a jobname to it. All output from a background job is sent to the associated chat.

In contrast to interactive chats, background jobs do not recieve user input and can run forever. In addition you can suspend and restart running jobs, e.g. after reboot.

*usage:* background "./script" "jobname"

*example:* 
```bash
background "./notify" "notify"
```

##### checkback
Return true (0) if an background job is active in the given chat. 

*usage:*  checkback "jobname"

*example:* 
```bash
checkback "notify"
if [ "$res" -gt 0 ] ; then
  send_normal_message "${CHAT[ID]}" "Start notify"
  background "./notify" "notify"
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

### Bashbot internal functions
These functions are for internal use only and must not used in your bot commands.

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

#### $$VERSION$$ v0.60-rc2-4-g1bf26b9

