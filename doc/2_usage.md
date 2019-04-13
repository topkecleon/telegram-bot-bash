## Make your own Bot

All Commands for the Bot are in the ```commands.sh``` file (this should ease upgrades of the bot core). Here you find some examples how to process messages and send out text.

Once you're done editing start the Bot with ```./bashbot.sh start```. 
If some thing doesn't work as it should, debug with ```bash -x bashbot.sh```. To stop the Bot run ```./bashbot.sh kill```

To use the functions provided in this script in other scripts simply source bashbot: ```source bashbot.sh```

Have FUN!

## Managing your own Bot
#### Note: running bashbot as root is highly danger and not recommended. See Expert use.

### Start / Stop
Start or Stop your Bot use the following commands:
```bash
./bashbot.sh start
```
```bash
./bashbot.sh kill
```

### User count
To count the total number of users that ever used the bot run the following command:
```bash
./bashbot.sh count
```

### Sending broadcasts to all users
To send a broadcast to all of users that ever used the bot run the following command:
```bash
./bashbot.sh broadcast "Hey! I just wanted to let you know that the bot's been updated!"
```

## Recieve data
Evertime a Message is recieved, you can read incoming data using the following variables:

* ```$MESSAGE```: Incoming messages
* ```${MESSAGE[ID]}```: ID of incoming message
* ```$CAPTION```: Captions
* ```$REPLYTO```: Original message wich was replied to
* ```$USER```: This array contains the First name, last name, username and user id of the sender of the current message.
  - ```${USER[ID]}```: User id
  - ```${USER[FIRST_NAME]}```: User's first name
  - ```${USER[LAST_NAME]}```: User's last name
  - ```${USER[USERNAME]}```: Username
* ```$CHAT```: This array contains the First name, last name, username, title and user id of the chat of the current message.
  - ```${CHAT[ID]}```: Chat id
  - ```${CHAT[FIRST_NAME]}```: Chat's first name
  - ```${CHAT[LAST_NAME]}```: Chat's last name
  - ```${CHAT[USERNAME]}```: Username
  - ```${CHAT[TITLE]}```: Title
  - ```${CHAT[TYPE]}```: Type
  - ```${CHAT[ALL_MEMBERS_ARE_ADMINISTRATORS]}```: All members are administrators (true if true)
* ```$REPLYTO```: This array contains the First name, last name, username and user id of the ORIGINAL sender of the message REPLIED to.
  - ```${REPLYTO[ID]}```: ID of message wich was replied to
  - ```${REPLYTO[UID]}```: Original user's id
  - ```${REPLYTO[FIRST_NAME]}```: Original user's first name
  - ```${REPLYTO[LAST_NAME]}```: Original user's' last name
  - ```${REPLYTO[USERNAME]}```: Original user's username
* ```$FORWARD```: This array contains the First name, last name, username and user id of the ORIGINAL sender of the FORWARDED message.
  - ```${FORWARD[ID]}```: Same as MESSAGE[ID] if message is forwarded
  - ```${FORWARD[UID]}```: Original user's id
  - ```${FORWARD[FIRST_NAME]}```: Original user's first name
  - ```${FORWARD[LAST_NAME]}```: Original user's' last name
  - ```${FORWARD[USERNAME]}```: Original user's username
* ```$URLS```: This array contains documents, audio files, stickers, voice recordings and stickers stored in the form of URLs.
  - ```${URLS[AUDIO]}```: Audio files
  - ```${URLS[VIDEO]}```: Videos
  - ```${URLS[PHOTO]}```: Photos (maximum quality)
  - ```${URLS[VOICE]}```: Voice recordings
  - ```${URLS[STICKER]}```: Stickers
  - ```${URLS[DOCUMENT]}```: Any other file
* ```$CONTACT```: This array contains info about contacts sent in a chat.
  - ```${CONTACT[NUMBER]}```: Phone number
  - ```${CONTACT[FIRST_NAME]}```: First name
  - ```${CONTACT[LAST_NAME]}```: Last name
  - ```${CONTACT[ID]}```: User id
* ```$LOCATION```: This array contains info about locations sent in a chat.
  - ```${LOCATION[LONGITUDE]}```: Longitude
  - ```${LOCATION[LATITUDE]}```: Latitude

## Usage of bashbot functions

#### send_message
To send messages use the ```send_message``` function:
```bash
send_message "${CHAT[ID]}" "lol"
```
To send html or markdown put the following strings before the text, depending on the parsing mode you want to enable:
```bash
send_message "${CHAT[ID]}" "markdown_parse_mode lol *bold*"
```
```bash
send_message "${CHAT[ID]}" "html_parse_mode lol <b>bold</b>"
```
This function also allows a third parameter that disables additional function parsing (for safety use this when reprinting user input):
```bash
send_message "${CHAT[ID]}" "lol" "safe"
```
To forward messages use the ```forward``` function:
```bash
forward "${CHAT[ID]}" "from_chat_id" "message_id"
```

#### For safety and performance reasoms I recommend to use send_xxxx_message direct and not the universal send_message function.
To send regular text without any markdown use:
```bash
send_text_message "${CHAT[ID]}" "lol"
```
To send text with markdown:
```bash
send_markdown_message "${CHAT[ID]}" "lol *bold*"
```
To send text with html:
```bash
send_html_message "${CHAT[ID]}" "lol <b>bold</b>"
```

If your Bot is Admin in a Chat you can delete every message, if not you can delete only your messages.
To delete a message with a known ${MESSAGE[ID]} you can simple use:
```bash
delete_message "${CHAT[ID]}" "${MESSAGE[ID]}"
```

#### Send files, location  etc.
To send images, videos, voice files, photos etc. use the ```send_photo``` function (remember to change the safety Regex @ line 14 of command.sh to allow sending files only from certain directories):
```bash
send_file "${CHAT[ID]}" "/home/user/doge.jpg" "Lool"
```
To send custom keyboards use the ```send_keyboard``` function:
```bash
send_keyboard "${CHAT[ID]}" "Text that will appear in chat?" "Yep" "No"
```
To send locations use the ```send_location``` function:
```bash
send_location "${CHAT[ID]}" "Latitude" "Longitude"
```
To send venues use the ```send_venue``` function:
```bash
send_venue "${CHAT[ID]}" "Latitude" "Longitude" "Title" "Address" "optional foursquare id"
```
To send a chat action use the ```send_action``` function.
Allowed values: typing for text messages, upload_photo for photos, record_video or upload_video for videos, record_audio or upload_audio for audio files, upload_document for general files, find_location for locations.
```bash
send_action "${CHAT[ID]}" "action"
```

#### $$VERSION$$ v0.52-0-gdb7b19f


