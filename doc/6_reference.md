#### [Home](../README.md)
## Bashbot function reference

### Send, forward, delete messages

To insert line brakes in a message or caption you can place `\n` in the text. 

##### send_action
`send_action` shows users what your bot is currently doing.

*usage:* send_action "CHAT[ID]" "action"

*"action":* `typing`, `upload_photo`, `record_video`, `upload_video`, `record_audio`, `upload_audio`, `upload_document`, `find_location`.

*alias:* _action "action"

*example:* 
```bash
send_action "${CHAT[ID]}" "typing"
send_action "${CHAT[ID]}" "record_audio"
```

##### send_normal_message
`send_normal_message` sends text only messages to the given chat.

*usage:*  send_normal_message "CHAT[ID]" "message"

*alias:* _normal_message "message"

*example:* 
```bash
send_normal_message "${CHAT[ID]}" "this is a text message"
```


##### send_markdownv2_message
`send_markdownv2_message` sends markdown v2 style messages to the given chat.
Telegram supports a new [Markdown V2 Style](https://core.telegram.org/bots/api#markdownv2-style) which
has more formatting codes and is more robust, but incompatible with old telegram markdown style.

To send characters reserved for markdown v2 formatting, you must prefix them with `\` ( e.g. `\| \= \_ \*`).\
*Hint*: If a message is not sent, have a look in `logs/ERROR.log`

*usage:* send_markdownv2_message "CHAT[ID]" "markdown message"

*example:* 
```bash
send_markdownv2_message "${CHAT[ID]}" "this is a markdown  message, next word is *bold*"
send_markdownv2_message "${CHAT[ID]}" "*bold* __underlined__ [text](link)"
```


##### send_markdown_message
`send_markdown_message` sends markdown style messages to the given chat.
This is the old, legacy Telegram markdown style, retained for backward compatibility.
It supports a [reduced set of Markdown](https://core.telegram.org/bots/api#markdown-style) only

*usage:* send_markdown_message "CHAT[ID]" "markdown message"

*alias:* _markdown "message"

*example:* 
```bash
send_markdown_message "${CHAT[ID]}" "this is a markdown  message, next word is *bold*"
send_markdown_message "${CHAT[ID]}" "*bold* _italic_ [text](link)"
```


##### send_html_message
`send_html_message` sends HTML style messages to the given chat.
Telegram supports a [reduced set of HTML](https://core.telegram.org/bots/api#html-style) only

*usage:* send_html_message "CHAT[ID]" "html message" 

*alias:* _html_message "message"

*example:* 
```bash
send_normal_message "${CHAT[ID]}" "this is a markdown  message, next word is <b>bold</b>"
send_normal_message "${CHAT[ID]}" "<b>bold</b> <i>italic><i> <em>italic>/em> <a href="link">Text</a>"
```

##### forward_message
`forward_mesage` forwards a message to the given chat.

*usage:* forward_message "chat_to" "chat_from" "${MESSAGE[ID]}"

*old call:* forward "${CHAT[ID]}" "$FROMCHAT" "${MESSAGE[ID]}"

*alias:* _forward "$FROMCHAT" "${MESSAGE[ID]}"

See also [Text formatting options](https://core.telegram.org/bots/api#formatting-options)

----

##### delete_message
A bot can only delete messages if he is admin of a Chat, if not he can delete his own messages only.

*usage:* delete_message "CHAT[ID]" "${MESSAGE[ID]}"

See also [deleteMessage limitations](https://core.telegram.org/bots/api#deletemessage)

----

##### send_message
`send_message` sends any type of message to the given chat. Type of output is steered by keywords within the message. 

The main use case for send_message is to process the output of interactive chats and background jobs. **For regular Bot commands I recommend using of the dedicated send_xxx_message() functions from above.**

*usage:* send_message "CHAT[ID]" "message"

*example:* - see [Usage](2_usage.md#send_message) and [Advanced Usage](3_advanced.md#Interactive-Chats)

----

### File, Album, Location, Venue, Keyboard 

##### send_file
send_file can send local files, URL's or file_id's as different filex types (_e.g. photo video sticker_)

*usage:* send_file "CHAT[ID]" "file/URL/file_id" "caption" ["type"]

URL's must start with `http://` or `https://` and remote server must send an appropriate media type.
A file_id must start with `file_id://`, all other file names are threated as local files.
If Telegram accepts the file `BOTSENT[FILE_ID]` and `BOTSENT[FILE_TYPE]` are set. 

Argument "type" is optional, if not given `send_file` detects file type by the file extension.
if file/URL has no extension `photo` is assumed. Unknown types and extensions are send as type `document`

Supported file types are: photo (_png jpg jpeg gif pic_) audio (_mp3 flac_) sticker (_webp_) video (_mp4_) voice (_ogg_) or document.

It's recommended to use __absolute path names__ for local files (_starting with `/`_), as relative path names are threated as __relative to UPLOADDIR__ `data-bot-bash/upload`!

For security reasons the following restrictions apply to local files:

- absolute path name must match the __shell regex__ `FILE_REGEX`
- relative path name is threated as relative to `UPLOADDIR` (_default: data-bot-bash/upload_)
- path must not start with `./` and not contain `../`


*example:*
```bash
# send picture from web
send_file "${CHAT[ID]}" "https://dealz.rrr.de/assets/images/rbofd-1.gif" "My Bot" "photo"
send_file "${CHAT[ID]}" "https://images-na.ssl-images-amazon.com/images/I/81DQ0FpoSNL._AC_SL1500_.jpg"

# local file recommended: absolute path
send_file "${CHAT[ID]}" "/home/user/dog.jpg" "My Dog"

# relative to UPLOADDIR: data-bot-bash/upload/dog.jpg
send_file "${CHAT[ID]}" "dog.jpg" "My Dog"

# change to personal upload dir
UPLOADDIR="/home/user/myuploaddir"
# relative to personal upload dir: /home/user/myuploaddir/dog.jpg
send_file "${CHAT[ID]}" "dog.jpg" "My Dog"
```

##### send_album

*usage:* send_album "CHAT[ID]" "URL1" "URL2" ... "URLn"

*example:*
```bash
send_album "$(getConfigKey "botadmin")" "http://www.rrr.de/slider/main-image1.jpg" "http://www.rrr.de/slider/main-image5.jpg"
```

##### send_location
*usage:* send_location "CHAT[ID]" "Latitude" "Longitude"


##### send_venue
*usage:* send_venue "CHAT[ID]" "Latitude" "Longitude" "Title" "Address" "foursquare id (optional)"


##### send_sticker
`send_sticker` sends a sticker using a `file_id` to send a sticker that exists on the Telegram servers.

*usage:*  send_sticker "CHAT[ID]" "file_id"

##### send_dice
`send_dice` send an animated emoji and returns a value (_e.g. points shown on die_).

*usage:* send_dice "CHAT[ID]" "emoji"

Emoji must be one of '🎲', '🎯', '🏀', '⚽', '🎰' or ":game_die:" ":dart:" ":basketball:" ":soccer:" :slot_machine:".
Dice can have values 1-6 for '🎲' and '🎯', values 1-5 for '🏀' and '⚽', and values 1-64 for '🎰'. Defaults to '🎲' 

*example:*
```bash
# send die and output points
send_dice "${CHAT[ID]}" ":game_die:"
[ "${BOTSENT[OK]}" = "true" ] && send_markdownv2_message "${CHAT[ID]}" "*Congratulation* you got *${BOTSENT[RESULT]} Point(s)*."
```

----

##### send_keyboard
`send_keyboard` sends a custom keyboard, Telegram clients will show it instead of the regular keyboard.
If the user press a button on the custom keyboard, the text shown on the button is send to the chat.

Example Keyboard Array definitions:

    - Yes No in one row: '[ "yes" , "no" ]'
    - Yes No plus Maybe in 2.row: '[ "yes" , "no" ] , [ "maybe" ]' 
    - number pad style keyboard: '[ "1" , "2" , "3" ] , [ "4" , "5" , "6" ] , [ "7" , "8" , "9" ] , [ "0" ]'

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
`remove_keyboard` deletes the last custom keyboard. Depending on used Telegram client this will hide or delete the custom keyboard.

*usage:* remove_keybord "$CHAT[ID]" "message"

*alias:* _del_keyboard "message"

*See also: [Keyboard Markup](https://core.telegram.org/bots/api/#replykeyboardmarkup)*


----

##### send_button
`send_button` sends a text message with a single button to open an URL attached.

*usage:*  send_button "$CHAT[ID]" "message" "text" "URL"

*alias:* _button "text" "URL"

*example:* 
```bash
send_button "${CHAT[ID]}" "Awesome Deals!" "Visit my Shop" "https://dealz.rrr.de"
```

### Inline buttons
Functions to send/edit messages with with some buttons attached.

##### send_inline_buttons
`senbd_inline_buttons` sends a message with multiple buttons attached.  Buttons can be an URL or a CALLBACK button.
By default all buttons are displayed on one row, an empty string `""` starts a new row.  

*usage:* send_inline_buttons "CHAT[ID]" "text|url" "text|url" "" "url" "" "text|url" ...

URL buttons are specified as a `"text|url"` pair separated by `|`, `text` is shown on the button and `url` is opened on button click.
If `"url"` without text is given, `url` is shown on the button and opened on button click.

*Important* An `url` not startung with http(s):// or tg:// will create  a
[CALLBACK Button](https://core.telegram.org/bots/2-0-intro#callback-buttons).


*example:* 
```bash
# one button, same as send_button
send_inline_buttons "${CHAT[ID]}" "Best Dealz!" "Visit my Shop|https://dealz.rrr.de"

# result
   Best Dealz!
  +----------------------------+
  |       Visit my Shop        |
  +----------------------------+

# one button row
send_inline_buttons "${CHAT[ID]}" "message" "Button 1|http://rrr.de" "Button 2|http://rrr.de"

# result
   message ...
  +----------------------------+
  |   Button 1  |   Button 2   |
  +----------------------------+

# multiple button rows
send_inline_buttons "${CHAT[ID]}" "message" "Button 1|http://rrr.de" "Button 2|http://rrr.de" "" "Button on second row|http://rrr.de"

# result
   message ...
  +----------------------------+
  |   Button 1  |   Button 2   |
  |----------------------------|
  |   Button on second row     |
  +----------------------------+

```

##### edit_inline_buttons
`edit_inline_buttons` add inline buttons to existing messages,  existing inline buttons will be replaced.
Only the attached buttons will be changed, not the message.

*usage:*  edit_inline_buttons "CHAT[ID]" "MESSAGE[ID]" "text|url" "text|url" ...


*example:* 
```bash
# message without button
send_markdownv2_message "${CHAT[ID]}" "*HI* this is a _markdown_ message ..."
echo ${BOTSEND[ID]}
567

# add one button row
edit_inline_keyboard "${CHAT[ID]}" "567" "button 1|http://rrr.de" "button 2|http://rrr.de"

# change buttons
edit_inline_keyboard "${CHAT[ID]}" "567" "Success edit_inline_keyboard|http://rrr.de"

# delete button by replace whole message
edit_markdownv2_message "${CHAT[ID]}" "*HI* this is a _markdown_ message inline *removed*..."

```

##### answer_callback_query
Each request send from a CALLBACK button must be answered by a call to `answer_callback_query`.
If alert is given an alert will be shown by the Telegram client instead of a notification.

*usage:*  answer_callback_query "iBUTTON[ID]" "text notification ..." ["alert"]

*example:* 
```bash
answer_callback_query "${iBUTTON[ID]}" "Button data is: ${iBUTTON[DATA]}"

answer_callback_query "${iBUTTON[ID]}" "Alert: Button pressed!" "alert"
```


```bash
# CALLBACK button example
send_inline_buttons "${CHAT[ID]}" "Press Button ..." "   Button   |RANDOM-BUTTON"

# result
   Press Button ...
  +----------------------------+
  |         Button             |
  +----------------------------+

# react on button press from mycommands
   CALLBACK="1" # enable callbacks
...
   mycallbacks() {
	local answer
	#######################
	# callbacks from buttons attached to messages will be  processed here
	if [ "${iBUTTON[DATA]}" = "RANDOM-BUTTON" ]; then
	    answer="Button pressed"
	    edit_inline_buttons "${iBUTTON[CHAT_ID]}" "${iBUTTON[MESSAGE_ID]}" " Button ${RANDOM}|RANDOM-BUTTON"
	fi

	# Telegram needs an ack each callback query, default empty
	answer_callback_query "${iBUTTON[ID]}" "${answer}"
	;;
   }

# result, XXXXX: random number changed on each press
   Press Button ...
  +----------------------------+
  |      Button  XXXXXX        |
  +----------------------------+

```

----

#### Inline keyboards
Functions to send/edit more complex button layouts (keyboards), I suggest to start with the simpler inline buttons above.

##### _button_row
`_button_row` is a helper function to specify a keyboard row in the form "text|url" pairs.
Internally used by inline buttons also.

*usage:*  _button_row "text|url" "text|url" "url" "text|url" ...

*example:* 
```bash
# similar to send_button
send_inline_keyboard "${CHAT[ID]}" "Best Dealz!" "$(_button_row "Visit my Shop|https://dealz.rrr.de")"

# similar to send_inline_button
send_inline_keyboard "${CHAT[ID]}" "message" "$(_button_row "button 1|http://rrr.de" "button 2|http://rrr.de")"

# multiple button rows
send_inline_keyboard "${CHAT[ID]}" "message" "$(_button_row "b1|http://rrr.de" "b2|http://rrr.de" "" "b3|http://rrr.de" "b4|http://rrr.de")"
```

##### send_inline_keyboard
`send_inline_keyboard` sends a message with keyboards attached, keyboards must be specified in JSON format.

*usage:*  send_inline_keyboard "CHAT[ID]" "message" "[JSON button array]"

I suggest to use `_button_row` to create the used JSON. For hand crafted JSON the following format must be used,
see [Inline Keyboard Markup](https://core.telegram.org/bots/api#inlinekeyboardmarkup)

URL `[ {"text":"text1", "url":"url1"}, ... {"text":"textN", "url":"urlN"} ],[...]`\
CALLBACK `[ {"text":"text1", "callback_data":"abc"}, ... {"text":"textN", "callback_data":"defg"} ],[...]`\
An URL Button opens the given URL, a CALLBACK button sends an update the bot must react on. 

*example:* 
```bash
# send_button
send_inline_keyboard "${CHAT[ID]}" "Best Dealz!" '[{"text":"Visit my Shop", "url":"https://dealz.rrr.de"}]'

# send_inline_button
send_inline_keyboard "${CHAT[ID]}" "message" '[{"text":"button 1", url"":"http://rrr.de"}, {"text":"button 2", "url":"http://rrr.de"} ]'

# multiple button rows
send_inline_keyboard "${CHAT[ID]}" "message" '[{"text":"b1", "url":"http://rrr.de"}, {"text":"b2", "url":"http://rrr.de"}], [{"text":"b3", "url":"http://rrr.de"}, "text":"b4", "url":"http://rrr.de"}]'

# more complex keyboard, note the ,
keyboard_text="Deal-O-Mat public groups ..."
keyboard_json="$(_button_row "🤖 #Home of Deal-O-Mat Bot 🤖|https://dealz.rrr.de/dealzbot.html")
, $(_button_row "Amazon DE|https://t.me/joinchat/IvvRtlxxxxx" "Home & Family|https://t.me/joinchat/VPh_wexxxxx")
, $(_button_row "Amz International |https://t.me/joinchat/IvvRtkxxxxx" "Amazon WHD|https://t.me/joinchat/IvvRxxxxx")
, $(_button_row "Smartphones|https://t.me/joinchat/IvvRthtqxxxxx" "Gaming|https://t.me/joinchat/IvvRthRyrsmxxxxx")
, $(_button_row "Accessoires|https://t.me/joinchat/IvvRthlJxxxxx" "eBay|https://t.me/joinchat/IvvRthxxxxx")
, $(_button_row "!! Offtopic Discussions !!|https://t.me/joinchat/IvvRthRhxxxxx-pZrWw")
, $(_button_row "Deals >100|https://t.me/joinchat/IvvRtxxxxx" "Leasing|https://t.me/joinchat/IvvRthRbxxxxx")
, $(_button_row "Deals >1000|https://t.me/joinchat/IvvRtlxxxxx" "Deals >500|https://t.me/joinchat/IvvRthvbHxxxxx")

send_inline_keyboard "CHAT[ID]" "${keyboard_text}" "${keyboard_json}"

# result
  +---------------------------------+
  |  🤖 #Home of Deal-O-Mat Bot 🤖  |
  |---------------------------------|
  |    Amazon DE   | Home & Family  |
  |----------------|----------------|
  |  Amz Internat  |   Amazon WHD   |
  |----------------|----------------|
  |  Smartphones   |     Gaming     |
  |----------------|----------------|
  |  Accessoires   |     eBay       |
  |---------------------------------|
  |   !!  Offtopic Discussions !!   |
  |---------------------------------|
  |   Deals >100   |    Leasing     |
  |----------------|----------------|
  |  Deals >1000   |   Deals >500   |
  +---------------------------------+

```

*See also [Inline keyboard markup](https://core.telegram.org/bots/api/#inlinekeyboardmarkup)*

##### edit_inline_keyboard
`edit_inline_keyboard` add inline keyboards to existing messages and replace existing inline keyboards.
Only the attached keyboard will be changed, not the message.

*usage:*  edit_inline_keyboard "CHAT[ID]" "MESSAGE[ID]" "[JSON button array]"

To create a JSON button array I suggest to use `_button_row`.

*example:* 
```bash
# message without button
send_markdownv2_message "${CHAT[ID]}" "*HI* this is a _markdown_ message ..."
echo ${BOTSEND[ID]}
567

# add one button row with help of _button_row
edit_inline_keyboard "${CHAT[ID]}" "567" "$(_button_row "button 1|http://rrr.de" "button 2|http://rrr.de")"

# change buttons with help of _button_row
edit_inline_keyboard "${CHAT[ID]}" "567" "$(_button_row "Success edit_inline_keyboard|http://rrr.de")"

# delete button by replace whole message
edit_markdownv2_message "${CHAT[ID]}" "*HI* this is a _markdown_ message inline *removed*..."

```

----


### Edit / Replace Messages

Edit a message means replace the content of the message in place. The message stay on the same position in the chat and keep the same
message id.
If new message  is the same than current message Telegram return error 400 with description "Bad Request: chat message is not modified"

There is no need to use the same format when replace a message, e.g. a message sent with `send_normal_message` can be replaced with
`edit_markdown_message` or `edit_html_message` and vice versa. 

To replace a message you must know the message id of the the original message. The best way to get the message id is to save the value of
`BOTSENT[ID]` after sending the original message.

##### edit_normal_message
`edit_normal_message` replace a message with a text message in the given chat.

*usage:*  edit_normal_message "CHAT[ID]" "MESSAGE-ID" "message"

*example:* 
```bash
send_normal_message "${CHAT[ID]}" "this is a text message"
saved-id="${BOTSENT[ID]}"

edit_normal_message "${CHAT[ID]}" "${saved-id}" "this is another text"
```

##### edit_markdownv2_message
`edit_markdownv2_message` replace a message with a markdown v2 message in the given chat.

*usage:*  edit_markdownv2_message "CHAT[ID]" "MESSAGE-ID" "message"

*example:* 
```bash
send_normal_message "${CHAT[ID]}" "this is a text message"
saved-id="${BOTSENT[ID]}"

edit_markdownv2_message "${CHAT[ID]}" "${saved-id}" "this is __markdown__ *V2* text"
```

##### edit_markdown_message
`edit_markdown_message` replace a message with a markdown message in the given chat.

*usage:*  edit_markdown_message "CHAT[ID]" "MESSAGE-ID" "message"

*example:* 
```bash
send_normal_message "${CHAT[ID]}" "this is a text message"
saved-id="${BOTSENT[ID]}"

edit_markdown_message "${CHAT[ID]}" "${saved-id}" "this is *markdown* text"
```

##### edit_html_message
`edit_html_message` replace a message with a html message in the given chat.

*usage:*  edit_html_message "CHAT[ID]" "MESSAGE-ID" "message"

*example:* 
```bash
send_normal_message "${CHAT[ID]}" "this is a text message"
saved-id="${BOTSENT[ID]}"

edit_html_message "${CHAT[ID]}" "${saved-id}" "this is <b>html</b> text"
```

##### edit_message_caption
`edit_message_caption` changes the caption of a message (photo, audio, video, document) in the given chat.

*usage:*  edit_message_caption "CHAT[ID]" "MESSAGE-ID" "caption"


----

### Get files from Telegram

##### download_file
`download_file` download a file to `DATADIR` and returns the local `path` to the file on disc, main use is to download files send to chats.
I tried to be as compatible as possible with old function `download`.

*usage:* download_file path_to_ile prosed_filename

*alias*: download

*Note:* You must use `download_file` to download  `URLS[...]` or `SERVICE[NEWPHOTO]` URLs from Telegram server.

*example:* 
```bash
########
# download from Telegram server
# photo received in a chat
photo="${URLS[PHOTO]}")"
echo "$photo" -> photo/file_1234.jpg

# first download
file="$(download_file "${photo}"
echo "$file" -> ./data-bot-bash/photo-file_1234.jpg

# second download
file="$(download_file "${photo}"
echo "$file" -> ./data-bot-bash/jkdfhi-photo-file_1234.jpg

ls data-bot-bash/*.jpg
photo-file_1234.jpg  jkdfhi-photo-file_1234.jpg


########
# download from other sources (full URL)
file="$(download "https://avatars.githubusercontent.com/u/13046303")"
echo "$file" -> ./data-bot-bash/download-askjgftGJGdh1Z

file="$(download "https://avatars.githubusercontent.com/u/13046303" "avatar.jpg")"
echo "$file" -> ./data-bot-bash/avatar.jpg

file="$(download "https://avatars.githubusercontent.com/u/13046303" "avatar.jpg")"
echo "$file" -> ./data-bot-bash/jhsdf-avatar.jpg

ls data-bot-bash/
avatar.jpg  jhsdf-avatar.jpg  download-askjgftGJGdh1Z  


#######
# manually download files to current directory (not recommended)
getJson "${FILEURL}/${photo}" >"downloaded_photo.jpg"
getJson "https://avatars.githubusercontent.com/u/13046303" >"avatar.jpg"

ls -F
JSON.sh/ bin/ modules/ data-bot-bash/
avatar.jpg  bashbot.sh*  botconfig.jssh  commands.sh  count.jssh  downloaded_photo.jpg  mycommands.sh ...

```

##### get_file
`get_file` get the `path` to a file on Telegram server by it's `file_id`. File `path` is only valid for use with your bot token.

*usage:* url="$(get_file "file_id")"

*example*:

```bash
# download file by file_id
file_id="kjhdsfhkj-kjshfbsdbfkjhsdkfjn"

path="$(get_file "${file_id}")"
file="$(download_file "${path}")"

# one line
file="$(download_file "$(get_file "${file_id}")")"

```

---

### Manage Group
To use the following functions the bot must have administrator status in the chat / group

##### chat_member_count
`chat_member_count` returns (putput) number of chat members.

*usage:* num_members="$(chat_member_count "CHAT[ID]")"

##### set_chat_title
`set_chat_title` sets a new chat title. If new title is the same than current title Telegram return error 400
with description "Bad Request: chat title is not modified"

*usage:* set_chat_title "CHAT[ID]" "new chat title"


##### set_chat_description
`set_chat_description` sets a new description title. If new description is the same than current description Telegram return error 400
with description "Bad Request: chat description is not modified"

*usage:* set_chat_description "CHAT[ID]" "new chat description"


##### set_chat_photo
`set_chat_photo` sets a new  profile photo for the chat, can't be changed for private chat.
Photo must be a local image file in a supported format (_.jpg, .jpeg, .png, .gif, .bmp, .tiff_)

Same location and naming restrictions as with `send_file` apply.

*usage:* set_chat_photo "CHAT[ID]" "file"


##### new_chat_invite
`new_chat_invite` generate a new invite link for a chat; any previously generated link is revoked. 
Returns the new invite link as String on success.

*usage:* new_chat_invite "CHAT[ID]"


##### delete_chat_photo

*usage:* delete_chat_photo "CHAT[ID]"


##### pin_chat_message
`pin_chat_message` add a message to the list of pinned messages in a chat.

*usage:* pin_chat_message "CHAT[ID]" "message_id"


##### unpin_chat_message
`unpin_chat_message` remove a message from the list of pinned messages in a chat.

*usage:* unpin_chat_message "CHAT[ID]" "message_id"


##### unpinall_chat_message
`unpinall_chat_message` clear the list of pinned messages in a chat.

*usage:* unpinall_chat_message "CHAT[ID]"


##### delete_chat_stickers
`delete_chat_stickers` deletes a group sticker set from a supergroup.

*usage:* delete_chat_stickers "CHAT[ID]"


##### set_chatadmin_title
`set_chatadmin_title` set a custom title for an administrator in a supergroup promoted by the bot.
 Admin title can be 0-16 characters long, emoji are not allowed.

*usage:* set_chatadmin_title "CHAT[ID]" "USER[ID]" "admin title"


----

### User Access Control
The following basic user control functions are part of the Telegram API.
More advanced API functions are currently not implemented in bashbot.

##### kick_chat_member
If your Bot is a chat admin he can kick and ban a user.

*usage:* kick_chat_member "CHAT[ID]" "USER[ID]"

*alias:* _kick_user "USER[ID]"

##### unban_chat_member
If your Bot is a chat admin can unban a kicked user.

*usage:*  unban_chat_member "CHAT[ID]" "USER[ID]"

*alias:* _unban "USER[ID]"

##### leave_chat
Your Bot will leave the chat.

*usage:* leave_chat "CHAT[ID]"

*alias:* _leave 

```bash
if bot_is_admin ; then 
 send_markdown_message "${CHAT[ID]}" "*LEAVING CHAT...*"
 leave_chat "${CHAT[ID]}"
fi
```

See also [kick Chat Member](https://core.telegram.org/bots/api/#kickchatmember)*


##### promote_chat_member
`promote_chat_member` promote or denote user rights in a chat. Bot must be admin and can only promote/denote rights he owns.

Right are specified as "right:bool" pairs, where right is one of `long` or `short` listed below, followed
by `:true` or `:false`. Anything but `:true` (e.g. nothing or :xyz) is `:false`.

long: `is_anonymous can_change_info can_post_messages can_edit_messages can_delete_messages can_invite_users can_restrict_members can_pin_messages can_promote_member`
short: `anon change post edit delete invite restrict pin promote`

*usage:* promote_chat_member "CHAT[ID]" "USER[ID]" "right[:true|false]" ... "right[:true|false]"

See also [promote Chat Member](https://core.telegram.org/bots/api#promotechatmember)*

*example:* 
```bash
#                                 USER      can post,      can't edit,     can't delete, can't pin message, can invite users
promote_chat_member "CHAT[ID}" "USER[ID]" "post:true"  "can_edit_message" "delete:false"   "pin:xxx"        "invite:true"
```
----

The following functions are bashbot only and not part of the Telegram API. 

##### bot_is_admin
Return true (0) if bot is admin or creator of given chat.
 
*usage:* bot_is_admin "CHAT[ID]"


*example:* 
```bash
if bot_is_admin "${CHAT[ID]}"; then 
  send_markdown_message "${CHAT[ID]}" "*I'm admin...*"
fi
```

##### user_is_botadmin
Return true (0) if user is admin of bot, user id if botadmin is read from file './botadmin'.

*usage:*  user_is_botadmin "USER[ID]"

*alias:* _is_botadmin 

*example:* 
```bash
user_is_botadmin "${CHAT[ID]}" && send_markdown_message "${CHAT[ID]}" "You are *BOTADMIN*."
```

##### user_is_creator
Return true (0) if user is creator of given chat or chat is a private chat.

*usage:* user_is_creator "CHAT[ID]" "USER[ID]"

*alias:* _is_creator

##### user_is_admin
Return true (0) if user is admin or creator of given chat.
 
*usage:* user_is_admin "CHAT[ID]" "USER[ID]"

*alias:* _is_admin

*example:* 
```bash
if user_is_admin "${CHAT[ID]}" ; then 
  send_markdown_message "${CHAT[ID]}" "*LEAVING CHAT...*"
  leave_chat "${CHAT[ID]}"
fi
```

*See also [Chat Member](https://core.telegram.org/bots/api/#chatmember)*

##### user_is_allowed
`uers_is_allowed` checks if: user id botadmin, user is group admin or user is allowed to execute action..
Allowed actions are configured as User Access Control rules, see [Advanced Usage](3_advanced.md)

*usage:* user_is_allowed "USER[ID]" "action" "CHAT[ID]"

*example:* 
```bash
if ! user_is_allowed "${USER[ID]}" "start" "${CHAT[ID]}" ; then
  send_normal_message "${CHAT[ID]}" "You are not allowed to start Bot."
fi
```

----

### Inline Query
Inline Queries allows users to interact with your bot directly without sending extra commands.
As an answer to an inline query you can send back one or more results to the Telegram client. 
The Telegram client will then show the results to the user and let him select one.

##### answer_inline_query
answer_inline_query is provided for backward compatibility with older versions of bashbot.
It send back only one response to an inline query.

*usage:* answer_inline_query "$i{QUERY[ID]}" "type" "type arg 1" ... "type arg n" 

*example:* - see [Advanced Usage](3_advanced.md#Inline-queries)


##### answer_inline_multi
anwser_inline_multi allows you to send back a list of responses. Responses must be separated by ','.

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
	"venue"			latitude longitude title (address foursquare)
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
Background functions and interactive jobs extends the bot functionality to not only react to user input. You can start scripts for interactive
chats and send messages based on time or other external events.

##### start_proc
`startproc` starts a script, the output of the script is sent to the user or chat, user input will be sent back to the script. see [Advanced Usage](3_advanced.md#Interactive-Chats)

*usage:* start_proc "CHAT[ID]" "script"

*alias:* startproc "script"

*example:* 
```bash
startproc 'examples/calc.sh'
```


##### check_proc
Return true (0) if an interactive script is running in the chat. 

*usage:* check_prog "CHAT[ID]"

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

*usage:* kill_proc "CHAT[ID]"

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
Starts a script as a background job and attaches a job name to it. All output from a background job is sent to the associated chat.

In contrast to interactive chats, background jobs do not receive user input and can run forever. In addition you can suspend and restart running jobs, e.g. after reboot.

*usage:* start_back "CHAT[ID]" "script" "jobname"

*alias:* background "script" "jobname"

*example:* 
```bash
background "examples/notify.sh" "notify"
```

##### check_back
Return true (0) if an background job is active in the given chat. 

*usage:*  check_back "CHAT[ID]" "jobname"

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

*usage:* kill_back "CHAT[ID]" "jobname"

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
`send_interactive` is used to forward messages to interactive jobs.
Usually a message is automatically forwarded from within `commands.sh`, but you can send messages yourself.

*usage:* send_interactive "CHAT[ID]" "message"

----

### jsshDB

Output generated by `JSON.sh` can easily converted to bash associative arrays. Therefore Bashbot use this format for key/value file store too.

#### fast and slow operations

jsshDB files are flat text files containing key/value pairs in `JSON.sh` format.
Key/value pairs appearing later in the file overwrites earlier key/value pairs, Bashbot use this behavior to implement "fast replace" file operations.

"fast functions" add a new key/value pair to the end of a file without deleting an existing one, this is fast but over time the file grows to infinity.

"slow functions" read the file, modify the key/value pairs in memory and write the whole file back, this is slower but removes duplicate keys from the file.

Fast functions:

```
   jssh_insertKeyDB , jssh_addKeyDB , jssh_countKeyDB
```

Slow functions:

```
   jssh_writeDB, jssh_updateDB , jssh_deleteKeyDB, jssh_clearDB
```

#### Key / Value

JsshBD use bash associative arrays to store key/value pairs in memory. Associative arrays must be created with `declare -A` before first use.

```bash
# create key / value array
decleare -A ARRAY

ARRAY["key"]="value"
ARRAY["key,subkey"]="value2"
```

Only the following characters are allowed for keys: `a-z A-Z 0-9 _ .`, multiple keys must be separated by `,`.
Keys contaiing other characters will be discarded when written to a file.

To delete (unset) a key/value pair in memory you can `unset ARRAY["abc"]` but this will not delete the key/value
pair when using `jssh_updateDB` to update a file. Therefore the special value `${JSSHDB_UNSET}` exists, see `jssh_updateDB`


```bash
ARRAY["abc"]="abc"         # OK
ARRAY["abx###"]="abc"      # works in bash but will not saved to file

# write to file will discard second value
jssh_writeDB "ARRAY" "file"

cat file.jssh
["abc"]      "abc"

```

```bash
# strip key containing invalid characters
KEY="123abcABC,.#?(<>123ÄÖ*%&§"
OK_KEY="$(tr -dc "[:alnum:],.\r\n" <<<"${KEY}")"

# show stripped key
printf "%s\n" "${OK_KEY}"

123abcABC,.123
```

#### File naming and locking

A jssh fileDB consists of two files and must reside inside `BASHBOT_ETC` or `BASHBOT_DATA`.

- `filename.jssh` is the file containing the key/value pairs in JSON.sh format.
- `filename.jssh.flock` is used to provide read/write locking with flock

Path names containing `..` or not located in `BASHBOT_ETC` or `BASHBOT_DATA` are refused by jsshDB functions with an error.

jsshDB functions use file locking if `flock is available, read/write operations are serialised to wait until
previous operations are finished, see "man flock". To avoid deadlocks bashbot use a timeout of 10s for write and 5s for read operations. 

For every `jssh_...DB` function a `jsshj_...DB_async` function exists also.  In case don't want locking, use `jssh_...DB_async` functions.

*Example:* for allowed file names:
```bash
# bashbot is installed in /usr/local/telegram-bot-bash, BASHBOT_ETC is not set.
"myfile" -> /usr/local/telegram-bot-bash/myfile.jssh
"addons/myfile" -> /usr/local/telegram-bot-bash/addons/myfile.jssh
"${DATADIR}/myfile" -> /usr/local/telegram-bot-bash/data-bot-bash/myfile.jssh
"/home/someuser/myfile" -> function returns false, nothing done.
```

##### jssh_newDB
Creates new empty jsshDB file if not exist.

*usage:*  jssh_newDB "filename"

*usage:*  jssh_newDB_async "filename"

##### jssh_clearDB
Delete all contents of jsshDB file.

*usage:*  jssh_clearDB "filename"

*usage:*  jssh_clearDB_async "filename"

##### jssh_checkDB
Check if DB name respects the rules mentioned above and print to STDOUT  the real/final path to DB file.
Used internally by all jssh DB functions, but can also used to get the real filename for a jssh DB.

An error is returned and nothing is printed if the given filename is not valid

*usage:*  jssh_checkDB "filename"

*usage:*  jssh_checkDB_async "filename"

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
Write content of an ARRAY into jsshDB file. ARRAY name must be declared with `declare -A ARRAY` before calling writeDB.
if "DB" file  does not exist nothing is written.

Note: Existing content is overwritten.

*usage:*  jssh_writeDB "ARRAY" "filename"

*usage:*  jssh_writeDB_async "ARRAY" "filename"

*example:* 
```bash
# Prepare array to store values
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

# show what's written
cat "${DATADIR:-}/myvalues.jssh"
["value1"]	"example"
["value2"]	"a value"
["whynot","subindex2","text"]	"This is an example content for pseudo multidimensional bash array"
["whynot","subindex2"]	"whynot B"
["whynot","subindex1"]	"whynot A"
```

##### jssh_printDB
Print content of an ARRAY to STDOUT. ARRAY name must be declared with `declare -A ARRAY` before calling printDB..

*usage:*  jssh_printDB "ARRAY" 

*example:* 
```bash
# Prepare array to store values
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
`jssh_updateDB updates key/value pairs of an ARRAY in a jsshDB file. ARRAY name must be declared with `declare -A ARRAY` before calling updateDB.
if "DB" file  does not exist nothing is written.

*usage:*  jssh_updateDB "ARRAY" "filename"

*usage:*  jssh_updateDB_async "ARRAY" "filename"

`jssh_updateDB` update new or changed keys/value pairs only, it will not delete an existing key/value pair.
To delete an existing key/value pair you must assign the "unset value" `${JSSJDB_UNSET}` to it instead.

*example:* 
```bash
# continued example from writeDB
MYVALUES=()
MYVALUES["newvalue"]="this is new"

# update file data-bot-bash/somevalues.jssh from array MYVALUES
jssh_updateDB "MYVALUES" "${DATADIR:-.}/myvalues"

# show what's written
cat ${DATADIR:-.}/myvalues".jssh
["value1"]	"value1"
["loveit"]	"value2"
["whynot"]	"value3"
["newvalue"]	"this is new"

#######
# update does not delete key/value pairs
# uset in bash and update file
unset MYVALUES["newvalue"]
jssh_updateDB "MYVALUES" "${DATADIR:-.}/myvalues"

["value1"]      "value1"
["loveit"]      "value2"
["whynot"]      "value3"
["newvalue"]    "this is new"		# value exists!

# use JSSHDB_UNSET value
MYVALUES["newvalue"]="${JSSHDB_UNSET}"
jssh_updateDB "MYVALUES" "${DATADIR:-.}/myvalues"

["value1"]      "value1"
["loveit"]      "value2"
["whynot"]      "value3"

```

##### jssh_readDB
Read content of a file in JSON.sh format into given ARRAY.  ARRAY name must be declared with `declare -A ARRAY` upfront,

*usage:*  jssh_readDB "ARRAY" "filename"

*usage:*  jssh_readDB_async "ARRAY" "filename"

Note: readDB uses concurrent / shared locking from flock so multiple processes can read from file, as long no process is writing.
Maximum timeout for reading is 1s to not block readers.

*example:* 
```bash
# Prepare array to read values
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


# access Array
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

##### jssh_insertKeyDB
Insert, update, append a key=value pair to a jsshDB file, key name is only allowed to contain '-a-zA-Z0-9,._'

*usage:*  jssh_insertKeyDB "key" "value" "filename"

*usage:*  jssh_insertKeyDB_asnyc "key" "value" "filename"

*deprecated:* jssh_insertDB *was renamed in version 0.96 to* jssh_insertKeyDB

Note: inserKeytDB uses also excusive write locking, but with a maximum timeout of 2s. insertKeyDB is a "fast" operation, simply adding the value to the end of the file.

*example:* 
```bash
jssh_insertKeyDB "newkey" "an other value" "${DATADIR:-.}/myvalues"
```

##### jssh_deleteKeyDB
Deleted a key=value pair from a jsshDB file, key name is only allowed to contain '-a-zA-Z0-9,._'

*usage:*  jssh_deleteKeyDB "key" "filename"

*usage:*  jssh_deleteKeyDB_async "key" "filename"

*example:* 
```bash
jssh_deleteKeyDB "delkey"" "${DATADIR:-.}/myvalues"
```

##### jssh_countKeyDB
Increase a key=value pair from a jsshDB file by 1, key name is only allowed to contain '-a-zA-Z0-9,._'
If value is given key is increased by value.

Side effect: if value is given key is updated "in place" (slower) and file is cleaned up, if no value is given fast path is used
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

### Manage webhook
Bashbot default mode is to poll Telegram server for updates but Telegram offers also webhook as a more efficient method to deliver updates.

*Important*: Before enable webhook you must setup your server to [receive and process webhook updates from Telegram](../examples/webhook)
I recommend to use webhook with a test bot first.

##### get_webhook_info
`get_webhook_info` get current status of webhook for your bot, e.g. url, waiting updates, last error.

*usage:*  get_webhook_info
 
*example:* 
```bash
bin/any_command.sh get_webhook_info

["URL"] ""
["OK"]  "true"
["LASTERR"]     ""
["COUNT"]       "0"
["CERT"]        "false"
["result","pending_update_count"]       "0"
["ok"]  "true"
["result","has_custom_certificate"]     "false"
```


##### delete_webhook
`delete_webhook` deletes your bots current webhook, deletes outstanding updates also if second arg is `true`

*usage:*  delete_webhook [true|false]
 
*example:* 

```bash
bin/any_command.sh delete_webhook false

["RESULT"]      "true"
["OK"]  "true"
["result"]      "true"
["ok"]  "true"
["description"] "Webhook was deleted"
```


##### set_webhook
`set_webhook` instructs Telegram to use your bots webhook for delivering updates. If webhook is set 
it's no more possible to pull updates from `bashbot start`, you must delete webhook first.

*Important*: Before using webhook you must setup your server to receive and process updates from Telegram!

*usage:*  set_webhook "https://host.dom[:port][/path]" [max_conn]
 
First arg is webhook URL used to send updates to your bot, `:port` and `/path` are optional. 
If `:port` is given it must be one of `:443`, `:80`, `:88` or `:8443`, default is`:80`.
For security reasons `BOTTOKEN` will be added to URL (_e.g. `https://myhost.com` -> `https://myhost.com/12345678:azndfhbgdfbbbdsfg/`_).

Second arg is max connection rate in the range 1-100, bashbot default is 1.

*example:* 

```bash
bin/any_command.sh set_webhook "https://myhost.com/telegram" "2"

["OK"]  "true"
["RESULT"]      "true"
["ok"]  "true"
["result"]      "true"
["description"] "Webhook is set"

bin/any_command.sh get_webhook_info

["OK"]  "true"
["URL"] "https://myhost.com/telegram/12345678:AABBCCDDEE...aabbccee124567890/"
["COUNT"]       "0"
["CERT"]        "false"
["ok"]  "true"
["result","ip_address"] "1.2.3.4"
["result","url"]        "https://myhost.com/telegram/12345678:AABBCCDDEE...aabbccee124567890/"
["result","pending_update_count"]       "0"
["result","max_connections"]    "2"
["result","has_custom_certificate"]     "false"
```

----

### Aliases - shortcuts for often used functions 
Aliases are handy shortcuts for use in `mycommands.sh` *only*, they avoid error prone typing of  "${CHAT[ID]}" "${USER[ID]}" as much as possible.
Do not use them in other files e.g. `bashbot.sh`, modules, addons etc.

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

*usage:* _kick_user "USER[ID]"

*alias for:* kick_chat_member "${CHAT[ID]}" "${USER[ID]}"

##### _unban

*usage:* _unban "USER[ID]"

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

##### _exec_if_function
Returns true, even if the given function does not exist. Return false if function exist but returns false.

*usage:* _exec_if_function function

*example:* 
```bash
_exec_if_function "answer_inline_query" "${iQUERY[ID]}" "Answer params"

# fast replacement for module functions exists check:
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
# returns unique identifier for everything related to chat
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

##### JsonDecode
Outputs decoded string to STDOUT

*usage:* JsonDecode "string"


##### Json2Array
Read JSON.sh style data from STDIN and assign to given ARRAY
ARRAY name  must be declared with `declare -A ARRAY` before calling

*usage:* Json2Array "ARRAY"

##### Array2Json
Output ARRAY as JSON.sh style data to STDOUT

*usage:* Array2Json "ARRAY"

----

##### get_chat_member_status
*usage:* get_chat_member_status "CHAT[ID]" "USER[ID]"


----

##### process_client
Every Message sent to your Bot is processed by this function. It parse the send JSON and assign the found Values to bash variables.

##### process_updates
If new updates are available, this functions gets the JSON from Telegram and dispatch it.

##### process_inline
Every Inline Message sent to your Bot is processed by this function. It parse the send JSON and assign the found Values to bash variables.

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
The name of your bot is available as bash variable "$ME", there is no need to call this function if Bot is running.

*usage:* ME="$(getBotName)"


#### [Prev Best Practice](5_practice.md)
#### [Next Notes for Developers](7_develop.md)

#### $$VERSION$$ v1.51-0-g6e66a28

