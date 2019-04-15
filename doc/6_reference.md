## Bashbot function reference

### Send, forward, delete Messages

##### send_action
To send a chat action use the send_action function. Allowed values: ```typing``` for text messages, ```upload_photo``` for photos, ```record_video``` or ```upload_video``` for videos, ```record_audio``` or ```upload_audio``` for audio files, ```upload_document``` for general files, ```find_location``` for locations.

*usage:* send_action "${CHAT[ID]}" "action"

*example:* 
```bash
send_action "${CHAT[ID]}" "typing"
send_action "${CHAT[ID]}" "record_audio"
```


##### send_normal_message
sen_normal_message send text only messages to chat.

*usage:*  send_normal_message "${CHAT[ID]}" "message"

*example:* 
```bash
send_normal_message "${CHAT[ID]}" "this is a text message"
```


##### send_markdown_message
Telegram supports onyl a [reduced set of Markdown](https://core.telegram.org/bots/api#markdown-style)

*usage:* send_markdown_message "${CHAT[ID]}" "message"

*example:* 
```bash
send_normal_message "${CHAT[ID]}" "this is a markdown  message, next word is *bold*"
send_normal_message "${CHAT[ID]}" "*bold* _italic_ [text](link)"
```

##### send_html_message
Telegram supports onyl a [reduced set of HTML](https://core.telegram.org/bots/api#html-style)

*usage:* send_html_message "${CHAT[ID]}" "message" 

*example:* 
```bash
send_normal_message "${CHAT[ID]}" "this is a markdown  message, next word is <b>bold</b>"
send_normal_message "${CHAT[ID]}" "<b>bold</b> <i>italic><i> <em>italic>/em> <a href="link">Text</a>"
```

##### forward
*usage:* forward "${CHAT[ID]}" "${MESSAGE[ID]}"


----

##### send_message
Send Message must (only) used to process the output of interactive chats and background jobs.
**For your commands I reccommend the more dedicated send_xxx_message() functions above.**

*usage:* send_message "${CHAT[ID]}" "message"

*example:* - see [Usage](2_usage.md#send_message) and [Advanced Usage](3_advanced.md#Interactive-Chats)

----

##### delete_message
If your Bot is Admin in a Chat you can delete every message, if not you can delete only your Bot messages.

*usage:* delete_message "${CHAT[ID]}" "${MESSAGE[ID]}"

----

##### answer_inline_query
Inline Queries allows users to interact with your bot via directly without sending extra commands.
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
There are some ways to send files (photos, stickers, audio, media, etc.), [see more](https://core.telegram.org/bots/api#sending-files)

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
Note: since version 0.6 send_keyboard was changed to use native "JSON Array" as used from Telegram.
 
*usage:*  send_keyboard "chat-id" "keyboard"

*example:* 
```bash
send_keyboard "${CHAT[ID]}" "[ \"yes\" , \"no\" ]"
send_keyboard "${CHAT[ID]}" "[ \"yes\" ] , [ \"no\" ]"
send_keyboard "${CHAT[ID]}" "[ \"1\" , \"2\" , \"3\" ] , [ \"4\" , \"5\" , \"6\" ] , [ \"7\" , \"8\" , \"9\" ] , [ \"0\" ]"
```

##### remove_keyboard
*usage:* 


### Manage users 

##### kick_chat_member
If Bot is Admin you can kick and ban a user.

*usage:*  kick_chat_member "${CHAT[ID]}" "${USER[ID]}"


##### unban_chat_member
If Bot is Admin you can unban a kicked user.

*usage:*  unban_chat_member "${CHAT[ID]}" "${USER[ID]}"

##### leave_chat
Bot will leave chat.

*usage:* leave_chat "${CHAT[ID]}"

```bash
if _is_admin ; then 
 send_markdown_message "${CHAT[ID]}" "*LEAVING CHAT...*"
 leave_chat "${CHAT[ID]}"
fi
```

----

##### user_is_creator
Returns true (0) if user is creator of chat or chat is a one2one / private chat.

*usage:* user_is_creator "${CHAT[ID]}" "${USER[ID]}"

*alias:* _is_creator

##### user_is_admin
Returns true (0) if user is admin or creator of chat.
 
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
Returns true (0) if user is owner / admin of bot. 
botadmin is stored in file './botadmin'

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
With ```startproc``` you can start scrips (or C or python program etc.). The text that the script will output will be sent in real time to the user, and all user input will be sent to the script. see [Advanced Usage](3_advanced.md#Interactive-Chats)

*usage:* startproc "./script"

*example:* 
```bash
startproc './calc'
```

##### checkproc
Returns true (0) if an interactive script is running in chat. 

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
*usage:* background "./script" "jobname"

*example:* 
```bash
background "./notify" "notify"
```

##### checkback
Returns true (0) if an background job is running in chat. 

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

### Bashbot internal 
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

#### $$VERSION$$ v0.60-rc2-0-gc581932

