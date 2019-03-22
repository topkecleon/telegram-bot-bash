# bashbot
A Telegram bot written in bash.

Depends on [tmux](http://github.com/tmux/tmux).
Uses [JSON.sh](http://github.com/dominictarr/JSON.sh).

Released to the public domain wherever applicable.
Elsewhere, consider it released under the [WTFPLv2](http://www.wtfpl.net/txt/copying/).


## Instructions
### Create your first bot

1. Message @botfather https://telegram.me/botfather with the following
text: `/newbot`
   If you don't know how to message by username, click the search
field on your Telegram app and type `@botfather`, you should be able
to initiate a conversation. Be careful not to send it to the wrong
contact, because some users has similar usernames to `botfather`.

   ![botfather initial conversation](http://i.imgur.com/aI26ixR.png)

2. @botfather replies with `Alright, a new bot. How are we going to
call it? Please choose a name for your bot.`

3. Type whatever name you want for your bot.

4. @botfather replies with `Good. Now let's choose a username for your
bot. It must end in bot. Like this, for example: TetrisBot or
tetris_bot.`

5. Type whatever username you want for your bot, minimum 5 characters,
and must end with `bot`. For example: `telesample_bot`

6. @botfather replies with:

    Done! Congratulations on your new bot. You will find it at
telegram.me/telesample_bot. You can now add a description, about
section and profile picture for your bot, see /help for a list of
commands.

    Use this token to access the HTTP API:
    <b>123456789:AAG90e14-0f8-40183D-18491dDE</b>

    For a description of the Bot API, see this page:
https://core.telegram.org/bots/api

7. Note down the 'token' mentioned above.

8. Type `/setprivacy` to @botfather.

   ![botfather later conversation](http://i.imgur.com/tWDVvh4.png)

9. @botfather replies with `Choose a bot to change group messages settings.`

10. Type `@telesample_bot` (change to the username you set at step 5
above, but start it with `@`)

11. @botfather replies with

    'Enable' - your bot will only receive messages that either start
with the '/' symbol or mention the bot by username.
    'Disable' - your bot will receive all messages that people send to groups.
    Current status is: ENABLED

12. Type `Disable` to let your bot receive all messages sent to a
group. This step is up to you actually.

13. @botfather replies with `Success! The new status is: DISABLED. /help`

### Install bashbot
Clone the repository:
```
git clone --recursive https://github.com/topkecleon/telegram-bot-bash
```

Create a file called token and paste the token in there.
Then start editing the commands.

### Receive data
You can read incoming data using the following variables:

* ```$MESSAGE```: Incoming messages
* ```${MESSAGE[ID]}```: ID of incoming message
* ```$CAPTION```: Captions
* ```$REPLYTO```: Original message wich was replied to
* ```$USER```: This array contains the First name, last name, username and user id of the sender of the current message.
 * ```${USER[ID]}```: User id
 * ```${USER[FIRST_NAME]}```: User's first name
 * ```${USER[LAST_NAME]}```: User's last name
 * ```${USER[USERNAME]}```: Username
* ```$CHAT```: This array contains the First name, last name, username, title and user id of the chat of the current message.
 * ```${CHAT[ID]}```: Chat id
 * ```${CHAT[FIRST_NAME]}```: Chat's first name
 * ```${CHAT[LAST_NAME]}```: Chat's last name
 * ```${CHAT[USERNAME]}```: Username
 * ```${CHAT[TITLE]}```: Title
 * ```${CHAT[TYPE]}```: Type
 * ```${CHAT[ALL_MEMBERS_ARE_ADMINISTRATORS]}```: All members are administrators (true if true)
* ```$REPLYTO```: This array contains the First name, last name, username and user id of the ORIGINAL sender of the REPLEYED message.
 * ```${REPLYTO[ID]}```: ID of message wich was replied to
 * ```${REPLYTO[UID]}```: Original user's id
 * ```${REPLYTO[FIRST_NAME]}```: Original user's first name
 * ```${REPLYTO[LAST_NAME]}```: Original user's' last name
 * ```${REPLYTO[USERNAME]}```: Original user's username
* ```$FORWARD```: This array contains the First name, last name, username and user id of the ORIGINAL sender of the FORWARDED message.
 * ```${FORWARD[ID]}```: Same as MESSAGE[ID] if message is forwarded
 * ```${FORWARD[UID]}```: Original user's id
 * ```${FORWARD[FIRST_NAME]}```: Original user's first name
 * ```${FORWARD[LAST_NAME]}```: Original user's' last name
 * ```${FORWARD[USERNAME]}```: Original user's username
* ```$URLS```: This array contains documents, audio files, stickers, voice recordings and stickers stored in the form of URLs.
 * ```${URLS[AUDIO]}```: Audio files
 * ```${URLS[VIDEO]}```: Videos
 * ```${URLS[PHOTO]}```: Photos (maximum quality)
 * ```${URLS[VOICE]}```: Voice recordings
 * ```${URLS[STICKER]}```: Stickers
 * ```${URLS[DOCUMENT]}```: Any other file
* ```$CONTACT```: This array contains info about contacts sent in a chat.
 * ```${CONTACT[NUMBER]}```: Phone number
 * ```${CONTACT[FIRST_NAME]}```: First name
 * ```${CONTACT[LAST_NAME]}```: Last name
 * ```${CONTACT[ID]}```: User id
* ```$LOCATION```: This array contains info about locations sent in a chat.
 * ```${LOCATION[LONGITUDE]}```: Longitude
 * ```${LOCATION[LATITUDE]}```: Latitude

### Usage
To send messages use the ```send_message``` function:
```
send_message "${CHAT[ID]}" "lol"
```
To send html or markdown put the following strings before the text, depending on the parsing mode you want to enable:
```
send_message "${CHAT[ID]}" "markdown_parse_mode lol *bold*"
```
```
send_message "${CHAT[ID]}" "html_parse_mode lol <b>bold</b>"
```
This function also allows a third parameter that disables additional function parsing (for safety use this when reprinting user input):
```
send_message "${CHAT[ID]}" "lol" "safe"
```
To send images, videos, voice files, photos ecc use the ```send_photo``` function (remember to change the safety Regex @ line 14 of command.sh to allow sending files only from certain directories):
```
send_file "${CHAT[ID]}" "/home/user/doge.jpg" "Lool"
```
To send custom keyboards use the ```send_keyboard``` function:
```
send_keyboard "${CHAT[ID]}" "Text that will appear in chat?" "Yep" "No"
```
To send locations use the ```send_location``` function:
```
send_location "${CHAT[ID]}" "Latitude" "Longitude"
```
To send venues use the ```send_venue``` function:
```
send_venue "${CHAT[ID]}" "Latitude" "Longitude" "Title" "Address" "optional foursquare id"
```
To forward messages use the ```forward``` function:
```
forward "${CHAT[ID]}" "from_chat_id" "message_id"
```
To send a chat action use the ```send_action``` function.
Allowed values: typing for text messages, upload_photo for photos, record_video or upload_video for videos, record_audio or upload_audio for audio files, upload_document for general files, find_location for locations.
```
send_action "${CHAT[ID]}" "action"
```

#### Interactice Chats and background jobs
To create interactive chats, write (or edit the question script) a normal bash (or C or python) script, chmod +x it and then change the argument of the startproc function to match the command you usually use to start the script.
The text that the script will output will be sent in real time to the user, and all user input will be sent to the script (as long as it's running or until the user kills it with /cancel).
To open up a keyboard in an interactive script, print out the keyboard layout in the following way:
```
echo "Text that will appear in chat? mykeyboardstartshere \"Yep, sure\" \"No, highly unlikely\""
```
Same goes for files:
```
echo "Text that will appear in chat? myfilelocationstartshere /home/user/doge.jpg"
```
And locations:
```
echo "Text that will appear in chat. mylatstartshere 45 mylongstartshere 45"
```
And venues:
```
echo "Text that will appear in chat. mylatstartshere 45 mylongstartshere 45 mytitlestartshere my home myaddressstartshere Diagon Alley N. 37"
```
You can combine them:
```
echo "Text that will appear in chat? mykeyboardstartshere \"Yep, sure\" \"No, highly unlikely\" myfilelocationstartshere /home/user/doge.jpg mylatstartshere 45 mylongstartshere 45"
```
Please note that you can either send a location or a venue, not both. To send a venue add the mytitlestartshere and the myaddressstartshere keywords.

A background job is similar to an interactive chat, but runs in the background and does only output massages instead of processing input from the user. In contrast to interactive chats it's possible to run multiple background jobs. To create a background job write a script or edit the notify script and use the funtion background to start it:
```
background "./notify" "jobname"
```
All output of the script will be sent to the user or chat. To stop a background job use:
```
killback "jobname"
```
You can restart the last running background jobs, e.g. after a reboot, with the command:
```
./bashbot.sh background
```

#### Inline queries
The following commands allows users to interact with your bot via *inline queries*.
In order to enable **inline mode**, send `/setinline` command to [@BotFather](https://telegram.me/botfather) and provide the placeholder text that the user will see in the input field after typing your bot’s name.
Also, edit line 12 from `commands.sh` putting a "1".
Note that you can't modify the first two parameters of the function `answer_inline_query`, only the ones after them.

To send messsages or links through an *inline query*:
```
answer_inline_query "$iQUERY_ID" "article" "Title of the result" "Content of the message to be sent"
```
To send photos in jpeg format and less than 5MB, from a website through an *inline query*:
```
answer_inline_query "$iQUERY_ID" "photo" "A valid URL of the photo" "URL of the thumbnail"
```
To send standard gifs from a website (less than 1MB) through an *inline query*:
```
answer_inline_query "$iQUERY_ID" "gif" "gif url"
```
To send mpeg4 gifs from a website (less than 1MB) through an *inline query*:
```
answer_inline_query "$iQUERY_ID" "mpeg4_gif" "mpeg4 gif url"
```
To send videos from a website through an *inline query*:
```
answer_inline_query "$iQUERY_ID" "video" "valid video url" "Select one mime type: text/html or video/mp4" "URL of the thumbnail" "Title for the result"
```
To send photos stored in Telegram servers through an *inline query*:
```
answer_inline_query "$iQUERY_ID" "cached_photo" "identifier for the photo"
```
To send gifs stored in Telegram servers through an *inline query*:
```
answer_inline_query "$iQUERY_ID" "cached_gif" "identifier for the gif"
```
To send mpeg4 gifs stored in Telegram servers through an *inline query*:
```
answer_inline_query "$iQUERY_ID" "cached_mpeg4_gif" "identifier for the gif"
```
To send stickers through an *inline query*:
```
answer_inline_query "$iQUERY_ID" "cached_sticker" "identifier for the sticker"
```


To modify the responses to commands edit the commands.sh file (this should ease upgrades of the bot core).

Once you're done editing start the bot with ```./bashbot.sh start```. If you want to do some more changes make them and then rerun the same command.
To stop the bot run ```./bashbot.sh kill```.
If some thing doesn't work as it should, debug with ```bash -x bashbot.sh```.

To use the functions provided in this script in other scripts simply source bashbot: ```source bashbot.sh```


## User count
To count the total number of users that ever used the bot run the following command:
```
bash bashbot.sh count
```


## Sending broadcasts to all users
To send a broadcast to all of users that ever used the bot run the following command:
```
bash bashbot.sh broadcast "Hey! I just wanted to let you know that the bot's been updated!"
```




That's it!

If you feel that there's something missing or if you found a bug, feel free to submit a pull request!
