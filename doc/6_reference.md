## Bashbot functions reference

### Send, forward, delete Messages

##### send_action
*usage:* 

*example:* 

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
Send Message is only used to process the output of interactive chats an background jobs.
I reccommend to use the more dedicated send_xxx_message() functions above.

*usage:* 

*example:* see [Usage](2_usage.md#send_message) and [Advanced Usage](3_advanced.md#Interactive-Chats)

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
*usage:* 

*example:* 

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
These function are for internal use only and must not used for your bot commands.

##### send_text
*usage:* 

*example:* 

----

##### JsonDecode
*usage:* 

*example:* 

##### JsonGetString
*usage:* 

*example:* 

##### JsonGetValue
*usage:* 

*example:* 

----

##### get_chat_member_status
*usage:* 

*example:* 

----

##### process_client
*usage:* 

*example:* 

##### process_updates
*usage:* 

*example:* 

----
##### getBotName
*usage:* 

*example:* 

##### inproc
*usage:* 

*example:* 

#### $$VERSION$$ v0.6-rc1-6-ge18b200

