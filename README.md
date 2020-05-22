<h2><img align="middle" src="https://raw.githubusercontent.com/odb/official-bash-logo/master/assets/Logos/Icons/PNG/64x64.png" >
Bashbot - A Telegram bot written in bash.
</h2>
Written by Drew (@topkecleon), Daniil Gentili (@danogentili), and Kay M (@gnadelwartz).

Contributions by JuanPotato, BigNerd95, TiagoDanin, and iicc1.

Released to the public domain wherever applicable.
Elsewhere, consider it released under the [WTFPLv2](http://www.wtfpl.net/txt/copying/).

## Prerequisites
Uses [JSON.sh](http://github.com/dominictarr/JSON.sh), but no more TMUX.

Even bashbot is written in bash, it depends on commands typically availible in a Unix/Linux Environment.
More concret on the common commands provided by recent versions of [coreutils](https://en.wikipedia.org/wiki/List_of_GNU_Core_Utilities_commands), [busybox](https://en.wikipedia.org/wiki/BusyBox#Commands) or [toybox](https://landley.net/toybox/help.html), see [Developer Notes](doc/7_develop.md#common-commands)

*Note for MacOS and BSD Users:* As bashbot use behavior of recent bash and (gnu)sed versions, bashbot may not run without installing additional software, see [Install Bashbot](doc/0_install.md)


Bashbot [Documentation](https://github.com/topkecleon/telegram-bot-bash) and [Downloads](https://github.com/topkecleon/telegram-bot-bash/releases) are availible on www.github.com

## Documentation
* [Introdution to Telegram Bots](https://core.telegram.org/bots)
* [Install Bashbot](doc/0_install.md)
    * Install release
    * Install from githup
    * Update Bashbot
    * Notes on Updates
* [Get Bottoken from Botfather](doc/1_firstbot.md)
* [Getting Started](doc/2_usage.md)
    * Managing your Bot
    * Recieve data
    * Send messages
    * Send files, locations, keyboards
* [Advanced Features](doc/3_advanced.md)
    * Access Control
    * Interactive Chats
    * Background Jobs
    * Inline queries
* [Expert Use](doc/4_expert.md)
    * Handling UTF-8 character sets
    * Run as other user or system service
    * Scedule bashbot from Cron
    * Use from CLI and Scripts
    * Customize Bashbot Environment
* [Best Practices](doc/5_practice.md)
    * Customize mycommands.sh
    * Overwrite/disable commands
    * Seperate logic from commands
    * Test your Bot with shellcheck
* [Function Reference](doc/6_reference.md)
    * Sending Messages, Files, Keyboards
    * User Access Control
    * Inline Queries
    * Background and Interactive Jobs
* [Deveoper Notes](doc/7_develop.md)
    * Debug bashbot
    * Modules, addons, events
    * Setup your environment
    * Bashbot testsuite
* [Examples Dir](examples/README.md)

### Your really first bashbot in a nutshell

To install and run bashbot you need acess to a linux/unix command line. If you don't know how to get accces to a linux/unix/bsd like command line you should stop reading here :-(

In addition you need a [Telegram client](https://telegram.org) and a mobile phone to [register an account](https://telegramguide.com/create-a-telegram-account/).
If you don't want to register for Telegram you should stop reading here ;-)

After you're registered to Telegram send a message to [@botfather](https://telegram.me/botfather),
[create a new Telegram Bot token](doc/1_firstbot.md) and write it down. You need the token to install the bot.

Now open a linux/unix/bsd terminal and check if bash is installed: ```which bash && echo "bash installed!"```.
If you get an error message bash is not installed.

Create a new directory and change to it:  ```mkdir tbb; cd tbb``` and download the latest '*.tar.gz' file from
[https://github.com/topkecleon/telegram-bot-bash/releases](https://github.com/topkecleon/telegram-bot-bash/releases). This can be done with the commands:
```bash
wget -q https://github.com/$(wget -q https://github.com/topkecleon/telegram-bot-bash/releases/latest -O - | egrep '/.*/.*/.*tar.gz' -o)
```

Extract the '*.tar.gz' file and change to bashbot directory: ```tar -xzf *.tar.gz; cd telegram-bot-bash```,
install bashbot: ```./bashbot.sh init``` and enter your bot token when asked. All other questions can be answered
by hitting the \<Return\> key.

Thats all, now you can start your bot with ```./bashbot.sh start``` and send him messages:
```
/start

You are Botadmin
*Available commands*:
*• /start*: _Start bot and get this message_.
*• /help*: _Get this message_.
*• /info*: _Get shorter info message about this bot_....

/info

his is bashbot, the Telegram bot written entirely in bash.
It features background tasks and interactive chats, and can serve as an interface for CLI programs.
```
For more Information on how to install, customize and use your new bot, read the [Documentation](#Documentation)

----

## Security Considerations
Running a Telegram Bot means it is connected to the public and you never know whats send to your Bot.

Bash scripts in general are not designed to be bullet proof, so consider this Bot as a proof of concept. Bash programmers often struggle with 'quoting hell' and globbing, see [Implications of wrong quoting](https://unix.stackexchange.com/questions/171346/security-implications-of-forgetting-to-quote-a-variable-in-bash-posix-shells)

Whenever you are processing input from from untrusted sources (messages, files, network) you must be as carefull as possible, e.g. set IFS appropriate, disable globbing (set -f) and quote everthing. In addition delete unused scripts and examples from your Bot, e.g. scripts 'notify', 'calc', 'question', and disable all not used commands.

**Note:** Until v0.941 (mai/22/2020) telegram-bot-bash has a remote code execution bug, pls update if you use an older version!
One of the most powerful features of unix shells like bash is variable and command substitution, this can lead to RCE and information disclosing bugs if you do not escape '$' porperly, see [Issue #125](https://github.com/topkecleon/telegram-bot-bash/issues/125)

A powerful tool to improve your scripts is ```shellcheck```. You can [use it online](https://www.shellcheck.net/) or [install shellcheck locally](https://github.com/koalaman/shellcheck#installing). Shellcheck is used extensive in bashbot development to enshure a high code quality, e.g. it's not allowed to push changes without passing all shellcheck tests.
In addition bashbot has a [test suite](doc/7_develop.md) to check if important functionality is working as expected.

### Do not use #!/usr/bin/env bash

**We stay with /bin/bash shebang, because it's more save from security perspective.**

Using a fixed path to the system provided bash makes it harder for attackers or users to place alternative versions of bash
and avoids using a possibly broken, mangled or compromised bash executable. 

If you are a BSD /  MacOS user or must to use an other bash location, see [Install Bashbot](doc/0_install.md)

### Run your Bot as a restricted user
**I recommend to run your bot as a user, with almost no access rights.** 
All files your Bot have write access to are in danger to be overwritten/deleted if your bot is hacked.
For the same reason ervery file your Bot can read is in danger to be disclosed. Restict your Bots access rigths to the absolute minimum.

**Never run your Bot as root, this is the most dangerous you can do!** Usually the user 'nobody' has almost no rights on Unix/Linux systems. See [Expert use](doc/4_expert.md) on how to run your Bot as an other user.

### Secure your Bot installation
**Your Bot configuration must no be readable from other users.** Everyone who can read your Bots token can act as your Bot and has access to all chats your Bot is in!

Everyone with read access to your Bot files can extract your Bots data. Especially your Bot Token in ```token``` must be protected against other users. No one exept you must have write access to the Bot files. The Bot must be restricted to have write access to ```count``` and  ```tmp-bot-bash``` only, all other files must be write protected.

To set access rights for your bashbot installation to a reasonable default run ```sudo ./bashbot.sh init``` after every update or change to your installation directory.

## FAQ

### Is this Bot insecure?
Bashbot is not more (in)secure as any other Bot written in any other language, we have done our best to make it as secure as possible. But YOU are responsible for the bot commands you wrote and you should know about the risks ...

**Note:** Until v0.941 (mai/22/2020) telegram-bot-bash has a remote code execution bug, pls update if you use an older version!

### Why Bash and not the much better xyz?
Well, thats a damn good question ... may be because I'm an Unix/Linux admin from stone age. Nevertheless there are more reasons from my side:

- bashbot will run everywhere where bash is availible, from ebedded linux to mainframe
- easy to integrate with other shell script, e.g. for sending system message / health status
- no need to install or learn a new programming language, library or framework
- no database, not event driven, not OO ...

### Can I have the single bashbot.sh file back?
At the beginning bashbot was simply the file ```bashbot.sh``` you can copy everywhere and run the bot. Now we have 'commands.sh', 'mycommands.sh', 'modules/*.sh' and much more.

Hey no Problem, if you are finished with your cool bot run ```dev/make-standalone.sh``` to create a stripped down Version of your bot containing only
'bashbot.sh' and 'commands.sh'! For more information see [Create a stripped down Version of your Bot](doc/7_develop.md)

### Can I send messages from CLI and scripts?
Of course, you can send messages from CLI and scripts, simply install bashbot as [described here](#Your-really-first-bashbot-in-a-nutshell),
send the messsage '/start' to set yourself as botadmin and stop the bot with ```./bashbot.sh kill```.

Run the following commands in your bash shell or script while you are in the installation directory:

```bash
# prepare bash / script to send commands
export BASHBOT_HOME="$(pwd)"
source ./bashbot.sh source

# send me a test message
send_message "$(cat "$BOTADMIN")" "test"

# send me output of a system command
send_message "$(<"$BOTADMIN")" "$(df -h)"
```
For more information see [Expert Use](doc/8_custom.md)


### Why do I get "EXPECTED value GOT EOF" on start?
May be your IP is blocked by telegram. You can test this by running curl or wget manually:
```bash
curl -m 10  https://api.telegram.org/bot
#curl: (28) Connection timed out after 10001 milliseconds

wget -t 1 -T 10 https://api.telegram.org/bot
#Connecting to api.telegram.org (api.telegram.org)|46.38.243.234|:443... failed: Connection timed out.
```
This may happen if to many wrong requests are sent to api.telegram.org, e.g. using a wrong token or not existing API calls.  If you have a fixed IP you can ask telegram service to unblock your ip or change your IP. If you are running a socks or  tor proxy on your server look for the ```BASHBOT_CURL_ARGS``` lines in 'mycommands.sh' as example.


@Gnadelwartz

## That's it!

If you feel that there's something missing or if you found a bug, feel free to submit a pull request!

#### $$VERSION$$ v0.96-dev-8-ge63590b
