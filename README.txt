<h2><img align="middle" 
src="https://raw.githubusercontent.com/odb/official-bash-logo/master/assets/Logo
s/Icons/PNG/64x64.png" >
Bashbot - A Telegram bot written in bash.
</h2>
Written by Drew (@topkecleon) and Kay M (@gnadelwartz).

Contributions by Daniil Gentili (@danogentili), JuanPotato, BigNerd95, 
TiagoDanin, and iicc1.

Released to the public domain wherever applicable.
Elsewhere, consider it released under the 
[WTFPLv2](http://www.wtfpl.net/txt/copying/).

Linted by [#ShellCheck](https://github.com/koalaman/shellcheck)

## Prerequisites
Uses [JSON.sh](http://github.com/dominictarr/JSON.sh) and the magic of sed.

Even bashbot is written in bash, it depends on commands typically available in 
a Unix/Linux Environment.
More concrete on the common commands provided by recent versions of 
[coreutils](https://en.wikipedia.org/wiki/List_of_GNU_Core_Utilities_commands), 
[busybox](https://en.wikipedia.org/wiki/BusyBox#Commands) or 
[toybox](https://landley.net/toybox/help.html), see [Developer 
Notes](doc/7_develop.md#common-commands)

**Note for MacOS and BSD Users:** As bashbot heavily uses modern bash and (gnu) 
grep/sed features, bashbot will not run without installing additional software, 
see [Install Bashbot](doc/0_install.md)

**Note for embedded systems:** busybox or toybox ONLY is not sufficient, you 
need a to install a "real" bash, see also [Install Bashbot](doc/0_install.md)  

Bashbot [Documentation](https://github.com/topkecleon/telegram-bot-bash) and 
[Downloads](https://github.com/topkecleon/telegram-bot-bash/releases) are 
available on www.github.com

## Documentation
* [Introduction to Telegram Bots](https://core.telegram.org/bots)
* [Install Bashbot](doc/0_install.md)
    * Install release
    * Install from github
    * Update Bashbot
    * Notes on Updates
* [Get Bottoken from Botfather](doc/1_firstbot.md)
* [Getting Started](doc/2_usage.md)
    * Managing your Bot
    * Receive data
    * Send messages
    * Send files, locations, keyboards
* [Advanced Features](doc/3_advanced.md)
    * Access Control
    * Interactive Chats
    * Background Jobs
    * Inline queries
    * Send message errors
* [Expert Use](doc/4_expert.md)
    * Handling UTF-8 character sets
    * Run as other user or system service
    * Schedule bashbot from Cron
    * Use from CLI and Scripts
    * Customize Bashbot Environment
* [Best Practices](doc/5_practice.md)
    * Customize mycommands.sh
    * Overwrite/disable commands
    * Separate logic from commands
    * Test your Bot with shellcheck
* [Function Reference](doc/6_reference.md)
    * Sending Messages, Files, Keyboards
    * User Access Control
    * Inline Queries
    * jsshDB Bashbot key-value storage
    * Background and Interactive Jobs
* [Developer Notes](doc/7_develop.md)
    * Debug bashbot
    * Modules, addons, events
    * Setup your environment
    * Bashbot test suite
* [Examples Dir](examples/README.md)

### Your really first bashbot in a nutshell

To install and run bashbot you need access to a linux/unix command line with 
bash, a [Telegram client](https://telegram.org) and a mobile phone [with a 
Telegram account](https://telegramguide.com/create-a-telegram-account/).

First you need to [create a new Telegram Bot token](doc/1_firstbot.md) for your 
bot and write it down.

Now open a linux/unix terminal with bash, create a new directory, change to it 
and install telegram-bot-bash:

```bash
# create bot dir
mkdir mybot
cd mybot

# download latest release with wget or from 
https://github.com/topkecleon/telegram-bot-bash/releases/latest
wget "https://github.com/$(wget -q 
"https://github.com/topkecleon/telegram-bot-bash/releases/latest" -O - | egrep 
'/.*/download/.*/.*tar.gz' -o)"

# Extract the tar archive and go into bot dir
tar -xzf *.tar.gz
cd telegram-bot-bash

# initialize your bot
# Enter your bot token when asked, all other questions can be answered by 
hitting the \<Return\> key.
./bashbot.sh init

# Now start your bot
./bashbot.sh start

Bottoken is valid ...
Bot Name: yourbotname_bot
Session Name: yourbotname_bot-startbot
Bot started successfully.
```

Now open the Telegram App on your mobile phone and start a chatting with your 
bot (_your bot's username is shown after 'Bot Name:'_):

```
/start

You are Botadmin
*Available commands*:
*• /start*: _Start bot and get this message_.
*• /help*: _Get this message_.
*• /info*: _Get shorter info message about this bot_....

/info

This is bashbot, the Telegram bot written entirely in bash.
It features background tasks and interactive chats, and can serve as an 
interface for CLI programs.
```
For more Information on how to install, customize and use your new bot, read 
the [Documentation](#Documentation)

### Log files

Since version 0.96 bashbot log commands received/send and connection errors. If 
you start bashbot in debug mode
bash stdout, stderr and all send/received telegram message are logged also.

To enable debug mode start bashbot with debug as third argument: `bashbot start 
debug`

```
├── logs 
│   ├── BASHBOT.log      # log what your bot is doing ...
│   ├── ERROR.log        # connection errors from / to telegram API
│   │
│   ├── DEBUG.log        # stdout/stderr of you bot (debug mode enabled)
│   └── MESSAGE.log      # full text of all message send/received (debug mode 
enabled)
```

----

## Security Considerations
Running a Telegram Bot means it is connected to the public and you never know 
what's send to your Bot.

Bash scripts in general are not designed to be bullet proof, so consider this 
Bot as a proof of concept. Bash programmers often struggle with 'quoting hell' 
and globbing, see [Implications of wrong 
quoting](https://unix.stackexchange.com/questions/171346/security-implications-o
f-forgetting-to-quote-a-variable-in-bash-posix-shells)

Whenever you are processing input from untrusted sources (messages, files, 
network) you must be as careful as possible, e.g. set IFS appropriate, disable 
globbing (set -f) and quote everything. In addition delete unused scripts and 
examples from your Bot, e.g. scripts 'notify', 'calc', 'question', and disable 
all not used commands.

**Note:** Up to version v0.941 (mai/22/2020) telegram-bot-bash had a remote 
code execution (RCE) bug, please update if you use an older version!
see [Issue #125](https://github.com/topkecleon/telegram-bot-bash/issues/125)

One of the most powerful features of unix shells is variable and command 
substitution using ```${}``` and ```$()```,
but as they are expanded in double quotes, this can lead to RCE and information 
disclosing bugs in complex scripts like bashbot.
So it's more secure to escape or remove '$' in input from user, files or 
network.

A powerful tool to improve your scripts is ```shellcheck```. You can [use it 
online](https://www.shellcheck.net/) or [install shellcheck 
locally](https://github.com/koalaman/shellcheck#installing). Shellcheck is used 
extensively in bashbot development to ensure a high code quality, e.g. it's not 
allowed to push changes without passing all shellcheck tests.
In addition bashbot has a [test suite](doc/7_develop.md) to check if important 
functionality is working as expected.

### Use printf whenever possible

If you're writing a script and it is taking external input (from the user as 
arguments or file system...),
you shouldn't use echo to display it. [Use printf whenever 
possible](https://unix.stackexchange.com/a/6581)

```bash
  # very simple
  echo "text with variables. PWD=$PWD"
  printf '%s\n' "text with variables. PWD=$PWD"
  printf 'text with variables. PWD=%s\n' "$PWD"
  -> text with variables. PWD=/home/xxx

  # more advanced
  FLOAT="1.2346777892864" INTEGER="12345.123"
  echo "float=$FLOAT, integer=$INTEGER, PWD=$PWD"
  -> float=1.2346777892864, integer=12345.123, PWD=/home/xxx

  printf "text with variables. float=%.2f, integer=%d, PWD=%s\n" "$FLOAT" 
"$INTEGER" "$PWD"
  -> float=1.23, integer=12345, PWD=/home/xxx
```

### Do not use #!/usr/bin/env bash

**We stay with /bin/bash shebang, because it's more save from security 
perspective.**

Use of a fixed path to the system provided bash makes it harder for attackers 
or users to place alternative versions of bash
and avoids using a possibly broken, mangled or compromised bash executable. 

If you are a BSD /  MacOS user or must to use an other bash location, see 
[Install Bashbot](doc/0_install.md)

### Run your Bot as a restricted user
**I recommend to run your bot as a user, with almost no access rights.** 
All files your Bot have write access to are in danger to be overwritten/deleted 
if your bot is hacked.
For the same reason every file your Bot can read is in danger to be disclosed. 
Restrict your Bots access rights to the absolute minimum.

**Never run your Bot as root, this is the most dangerous you can do!** Usually 
the user 'nobody' has almost no rights on unix/linux systems. See [Expert 
use](doc/4_expert.md) on how to run your Bot as an other user.

### Secure your Bot installation
**Your Bot configuration must no be readable from other users.** Everyone who 
can read your Bots token is able to act as your Bot and has access to all chats 
the Bot is in!

Everyone with read access to your Bot files can extract your Bots data. 
Especially your Bot config in ```config.jssh``` must be protected against other 
users. No one except you should have write access to the Bot files. The Bot 
should be restricted to have write access to ```count.jssh``` and  
```data-bot-bash``` only, all other files must be write protected.

To set access rights for your bashbot installation to a reasonable default run 
```sudo ./bashbot.sh init``` after every update or change to your installation 
directory.

## FAQ

### Is this Bot insecure?
Bashbot is not more (in)secure as any Bot written in an other language, we have 
done our best to make it as secure as possible. But YOU are responsible for the 
bot commands you wrote and you should know about the risks ...

**Note:** Up to version 0.941 (mai/22/2020) telegram-bot-bash had a remote code 
execution bug, please update if you use an older version!

### Why Bash and not the much better xyz?
Well, that's a damn good question ... may be because I'm an unix admin from 
stone age. Nevertheless there are more reasons from my side:

- bashbot will run everywhere where bash and (gnu) sed is available, from 
embedded linux to mainframe
- easy to integrate with other shell script, e.g. for sending system message / 
health status
- no need to install or learn a new programming language, library or framework
- no database, not event driven, not object oriented ...

### Can I have the single bashbot.sh file back?
At the beginning bashbot was simply the file ```bashbot.sh``` you can copy 
everywhere and run the bot. Now we have 'commands.sh', 'mycommands.sh', 
'modules/*.sh' and much more.

Hey no Problem, if you are finished with your cool bot run 
```dev/make-standalone.sh``` to create a stripped down Version of your bot 
containing only
'bashbot.sh' and 'commands.sh'! For more information see [Create a stripped 
down Version of your Bot](doc/7_develop.md)

### Can I send messages from CLI and scripts?
Of course, you can send messages from CLI and scripts, simply install bashbot 
as [described here](#Your-really-first-bashbot-in-a-nutshell),
send the message '/start' to set yourself as botadmin and stop the bot with 
```./bashbot.sh stop```.

Run the following commands in your bash shell or script while you are in the 
installation directory:

```bash
# prepare bash / script to send commands
export BASHBOT_HOME="$(pwd)"
source ./bashbot.sh source

# send me a test message
send_message "$(getConfigKey "botadmin")" "test"

# send me output of a system command
send_message "$(getConfigKey "botadmin")" "$(df -h)"
```
For more information see [Expert Use](doc/8_custom.md)


### Blocked by telegram?
This may happen if to many or wrong requests are sent to api.telegram.org, e.g. 
using a invalid token or not existing API calls.
If the block stay for longer time you can ask telegram service to unblock your 
IP-Adress. 

You can check with curl or wget if you are blocked by Telegram:
```bash
curl -m 10  https://api.telegram.org/bot
#curl: (28) Connection timed out after 10001 milliseconds

wget -t 1 -T 10 https://api.telegram.org/bot
#Connecting to api.telegram.org (api.telegram.org)|46.38.243.234|:443... 
failed: Connection timed out.

nc -w 2 api.telegram.org 443 || echo "your IP seems blocked by telegram"
#your IP seems blocked by telegram
```

Since Version 0.96 bashbot offers the option to recover from broken connections 
(aka blocked). Therefore you can provide a function
named `bashbotBlockRecover()` in `mycommands.sh`. If the function exists it is 
called every time when a broken connection is detected.

Possible actions are: Check if network is working, change IP-Adress or simply 
wait some time.

If everything seems OK return 0 for retry or any non 0 value to give up.

```bash
# called when bashbot sedn command failed because we can not connect to telegram
# return 0 to retry, return non 0 to give up
bashbotBlockRecover() {
	# place your commands to unblock here, e.g. change IP-Adess or simply 
wait
	sleep 60 && return 0 # may be temporary
	return 1 
    }

```
 

@Gnadelwartz

## That's it all guys!

If you feel that there's something missing or if you found a bug, feel free to 
submit a pull request!

#### $$VERSION$$ v1.21-dev-15-ga1f7215
