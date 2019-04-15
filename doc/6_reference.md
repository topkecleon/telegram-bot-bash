## Bashbot functions reference

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
*usage:* 

*example:* 

##### send_markdown_message
*usage:* 

*example:* 

##### send_html_message
*usage:* 

*example:* 

##### forward
*usage:* 

*example:* 

----

##### send_message
Send Message must (only) used to process the output of interactive chats and background jobs.
**For your commands I reccommend the more dedicated send_xxx_message() functions above.**

*usage:* 

*example:* - see [Usage](2_usage.md#send_message) and [Advanced Usage](3_advanced.md#Interactive-Chats)

----

##### delete_message
*usage:* 

*example:* 

----

##### answer_inline_query
*usage:* 

*example:* 

----

### File, Location, Venu, keyboards 

##### get_file
*usage:* 

*example:* 

##### send_file
*usage:* 

*example:* 

##### send_location
*usage:* 

*example:* 

##### send_venue
*usage:* 

*example:* 

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

*example:* 

### Manage users 

##### kick_chat_member
*usage:* 

*example:* 

##### unban_chat_member
*usage:* 

*example:* 

##### leave_chat
*usage:* 

*example:* 

----

##### user_is_creator
*usage:* 

*example:* 

##### user_is_admin
*usage:* 

*example:* 

##### user_is_botadmin
*usage:* 

*example:* 

##### user_is_allowed
*usage:* 

*example:* 

### Interactive and backgound jobs

##### startproc
*usage:* 

*example:* 

##### checkproc
*usage:* 

*example:* 

##### killproc
*usage:* 

*example:* 

----

##### background
*usage:* 

*example:* 

##### checkback
*usage:* 

*example:* 

##### killback
*usage:* 

*example:* 

### Bashbot internal 
These functions are for internal use only and must not used in your bot commands.

##### send_text
*usage:* 

----

##### JsonDecode
*usage:* 

##### JsonGetString
*usage:* 

##### JsonGetValue
*usage:* 

----

##### get_chat_member_status
*usage:* 

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

#### $$VERSION$$ v0.6-rc1-11-gba80ec6

