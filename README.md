# bashbot
A Telegram bot written in bash.

Depends on [tmux](http://github.com/tmux/tmux).
Uses [JSON.sh](http://github.com/dominictarr/JSON.sh).

Written by Drew (@topkecleon), Daniil Gentili (@danogentili), and Kay M (@gnadelwartz).

Contributions by JuanPotato, BigNerd95, TiagoDanin, and iicc1.

[Download from github](https://github.com/topkecleon/telegram-bot-bash/releases)

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
1. Go to the directory you want to install bashbot, e.g.

   - your $HOME directory (install and run with your user-ID)
   - /usr/local if you want to run as service

2. Clone the repository:
```
git clone --recursive https://github.com/topkecleon/telegram-bot-bash
```
3. Change to directory ```telegram-bot.bash```, run ```./bashbot.sh init``` and follow the instructions. At this stage you are asked for your Bots token given by botfather.


## Creating your own Bot

All Commands for the Bot are in the ```commands.sh``` file (this should ease upgrades of the bot core). Here you find some examples how to process messages and send out text.

Once you're done editing start the Bot with ```./bashbot.sh start```. 
If some thing doesn't work as it should, debug with ```bash -x bashbot.sh```. To stop the Bot run ```./bashbot.sh kill```

To use the functions provided in this script in other scripts simply source bashbot: ```source bashbot.sh```

Have FUN!


### Recieve data
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

### Usage of bashbot functions

#### send_message
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
To forward messages use the ```forward``` function:
```
forward "${CHAT[ID]}" "from_chat_id" "message_id"
```

#### For safety and performance reasoms I recommend to use send_xxxx_message direct and not the universal send_message function.
To send regular text without any markdown use:
```
send_text_message "${CHAT[ID]}" "lol"
```
To send text with markdown:
```
send_markdown_message "${CHAT[ID]}" "lol *bold*"
```
To send text with html:
```
send_html_message "${CHAT[ID]}" "lol <b>bold</b>"
```

If your Bot is Admin in a Chat you can delete every message, if not you can delete only your messages.
To delete a message with a known ${MESSAGE[ID]} you can simple use:
```
delete_message "${CHAT[ID]}" "${MESSAGE[ID]}"
```

#### Send files, location  etc.
To send images, videos, voice files, photos etc. use the ```send_photo``` function (remember to change the safety Regex @ line 14 of command.sh to allow sending files only from certain directories):
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
To send a chat action use the ```send_action``` function.
Allowed values: typing for text messages, upload_photo for photos, record_video or upload_video for videos, record_audio or upload_audio for audio files, upload_document for general files, find_location for locations.
```
send_action "${CHAT[ID]}" "action"
```

#### Interactice Chats
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

To insert a linebreak in your message you can insert ```mynewlinestartshere``` in your echo command:
```
echo "Text that will appear in one message  mynewlinestartshere  with this text on a new line"
```
Note: Interactive Chats run independent from main bot and continue running until your script exits or you /cancel if from your Bot. 

#### Background Jobs

A background job is similar to an interactive chat, but runs in the background and does only output massages instead of processing input from the user. In contrast to interactive chats it's possible to run multiple background jobs. To create a background job write a script or edit the notify script and use the funtion ```background``` to start it:
```
background "./notify" "jobname"
```
All output of the script will be sent to the user or chat. To stop a background job use:
```
killback "jobname"
```
You can also suspend and resume the last running background jobs from outside bashbot, e.g. in your startup schripts:
```
./bashbot.sh suspendback
./bashbot.sh resumeback
```

If you want to kill all background jobs permantly run:
```
./bashbot.sh killback

```
Note: Background Jobs run independent from main bot and continue running until your script exits or you stop if from your Bot. Backgound Jobs will continue running if your Bot is stoped (kill)!. 

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


## Managing your Bot
#### Note: running bashbot as root is highly danger and not recommended. See Expert use below.

### Start / Stop
Start or Stop your Bot use the following commands:
```
./bashbot.sh start
```
```
./bashbot.sh kill
```

### User count
To count the total number of users that ever used the bot run the following command:
```
./bashbot.sh count
```

### Sending broadcasts to all users
To send a broadcast to all of users that ever used the bot run the following command:
```
./bashbot.sh broadcast "Hey! I just wanted to let you know that the bot's been updated!"
```

## Handling UTF-8 character sets

### Setting up your Environment
In general ```bash``` and ```GNU``` utitities are UTF-8 aware, but you have to setup your environment
and your scripts accordingly:

1. Your Terminal and Editor must support UTF-8:
   Set Terminal and Editor locale to UTF-8, eg. in ```Settings/Configuration``` select UTF-8 (Unicode) as Charset.

2. Set ```Shell``` environment to UTF-8 in your  ```.profile``` and your scripts. The usual settings are:

```
export LC_ALL=C.UTF-8
export LANG=C.UTF-8
export LANGUAGE=C.UTF-8
```
   If you use other languages, eg. german or US english, change the shell settings to:
```
export LC_ALL=de_DE.UTF-8
export LANG=de_DE.UTF-8
export LANGUAGE=de_DE.UTF-8
```
```
export LC_ALL=en_US.UTF-8
export LANG=de_en_US.UTF-8
export LANGUAGE=den_US.UTF-8
```
3. make shure your bot scripts use the correct  settings, eg. include the lines above at the beginning of your scripts

To display all availible locales on your system run ```locale -a | more```. [Gentoo Wiki](https://wiki.gentoo.org/wiki/UTF-8)

### UTF-8 in Telegram
```UTF-8``` is a variable length encoding of Unicode. UTF-8 is recommended as the default encoding in JSON, XML and HTML, also Telegram make use of it.

The first 128 characters are regular ASCII, so it's a superset of and compatible with ASCII environments. The next 1,920 characters need
two bytes for encoding and covers almost all ```Latin``` alphabets, also ```Greek```, ```Cyrillic```,
```Hebrew```, ```Arabic``` and more. See [Wikipedia](https://en.wikipedia.org/wiki/UTF-8) for more deatils.

Telegram send Messages with all characters not fitting in one byte (256 bit) escaped as sequences of ```\uxxxx``` to be regular one byte ASCII (incl. iso-xxx-x), e.g. Emoticons and Arabic characters.
E.g. the Emoticons ``` 😁 😘 ❤️ 😊 👍 ``` are encoded as:
```
\uD83D\uDE01 \uD83D\uDE18 \u2764\uFE0F \uD83D\uDE0A \uD83D\uDC4D
```

'\uXXXX' and '\UXXXXXXXX' escaped endocings are supported by zsh, bash, ksh93, mksh and FreeBSD sh, GNU 'printf' and GNU 'echo -e', see [this Stackexchange Answer](https://unix.stackexchange.com/questions/252286/how-to-convert-an-emoticon-specified-by-a-uxxxxx-code-to-utf-8/252295#252295) for more information.


## Expert Use
Bashbot is desingned to run manually by the user who installed it. Nevertheless it's possible to run it by an other user-ID, as a system service or sceduled from cron. This is onyl recommended for experiend linux users.

### Run as other user or system service
Running bashbot as an other user is only possible (and strongly recommended) for root.

Setup the environment for the user you want to run bashbot and enter new username:
```
./bashbot.sh init
```

Edit the example rc file ```bashbot.rc```, uncomment the ```runcmd``` availible on your system and fill the name of your Bot in ```name```.

From now on always use bashbot.rc to start/stop your bot: 
```
./bashbot.rc start
```
Type ```ps -ef | grep bashbot``` to verify your Bot is running as the desired user.

If you started bashbot by bashbot.rc you must use bashbot.rc also to manage your Bot! The following commands are availible:
```
./bashbot.rc start
./bashbot.rc stop
./bashbot.rc status
./bashbot.rc suspendback
./bashbot.rc resumeback
./bashbot.rc killback
```
To change back the environment to your user-ID run ```./bashbot.rc init``` again and enter your user name.

To use bashbot as a system servive include a working ```bashbot.rc``` in your init system (systemd, /etc/init.d).

### Scedule bashbot from Cron
An example crontab is provided in ```bashbot.cron```.

- If you are running bashbot with your user-ID, copy the examples lines to your crontab and remove username ```nobody```.
- if you run bashbot as an other user or a system service edit ```bashbot.cron``` to fit your needs and replace username````nobody``` with the username you want to run bashbot. copy the modified file to ```/etc/cron.d/bashbot```


## Security Considerations
Running a Telegram Bot means you are conneted to the public, you never know whats send to your Bot.

Bash scripts in general are not designed to be bullet proof, so consider this Bot as a proof of concept. More concret examples of security problems is bash's 'quoting hell' and globbing. [Implications of wrong quoting](https://unix.stackexchange.com/questions/171346/security-implications-of-forgetting-to-quote-a-variable-in-bash-posix-shells)

Whenever you are processing input from outside your bot you should disable globbing (set -f) and carefully quote everthing.

### Run your Bot as a restricted user
Every file your bot can write is in danger to be overwritten/deleted, In case of bad handling of user input every file your Bot can read is in danger of being disclosed.

Never run your Bot as root, this is the most dangerous you can do! Usually the user 'nobody' has almost no rigths on Unix/Linux systems. See Expert use on how to run your Bot as an other user.

### Secure your Bot installation
Everyone who can read your Bot files can extract your Bots data. Especially your Bot Token in ```token``` must be protected against other users. No one exept you should have write access to the Bot files. The Bot itself need write access to ```count``` and  ```tmp-bot-bash``` only, all other files should be write protected.

Runing ```./bashbot init``` sets the Bot permissions to reasonable default values as a starting point.

### Is this Bot insecure?
No - its not more or less insecure as any other Bot written in any other language. But you should know about the implications ...

## That's it!

If you feel that there's something missing or if you found a bug, feel free to submit a pull request!

#### $$VERSION$$ v0.49-1-g851be83
