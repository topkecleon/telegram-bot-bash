# bashbot
A Telegram bot written in bash.

Written by Drew (@topkecleon), Daniil Gentili (@danogentili), and Kay M 
(@gnadelwartz).

Contributions by JuanPotato, BigNerd95, TiagoDanin, and iicc1.

Released to the public domain wherever applicable.
Elsewhere, consider it released under the 
[WTFPLv2](http://www.wtfpl.net/txt/copying/).

## Prerequisites
Depends on [tmux](http://github.com/tmux/tmux).
Uses [JSON.sh](http://github.com/dominictarr/JSON.sh).

Most complete [UTF-8 support for 
bashbot](doc/4_expert.md#Bashbot-UTF-8-Support) is availible if phyton is 
installed (optional).

Bashbot [Documentation](https://github.com/topkecleon/telegram-bot-bash) and 
[Downloads](https://github.com/topkecleon/telegram-bot-bash/releases) are 
availible on www.github.com

## Documentation
* [Introdution to Telegram Bots](https://core.telegram.org/bots)
    * [One Bot to rule them 
all](https://core.telegram.org/bots#3-how-do-i-create-a-bot)
    * [Bot commands](https://core.telegram.org/bots#commands)
* [Install Bashbot](doc/0_install.md)
    * Install release
    * Install from githup
    * Update Bashbot
    * Notes on Updates
* [Create a new Telegram Bot with botfather](doc/1_firstbot.md)
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
* [Best Practices](doc/5_practice.md)
    * Customize commands.sh
    * Seperate logic from commands
    * Test your Bot with shellcheck
* [Bashbot function reference](doc/6_reference.md)
* [Deveoper Notess](doc/7_develop.md)
    * Setup your environment
    * Test, Add, Push changes
    * Prepare a new version
    * Bashbot testsuite
* [Customize bashbot environment](doc/8_custom.md)
* [Examples](examples/README.md)

## Security Considerations
Running a Telegram Bot means it is connected to the public and you never know 
whats send to your Bot.

Bash scripts in general are not designed to be bullet proof, so consider this 
Bot as a proof of concept. More concret examples of security problems are: 
bash's 'quoting hell' and globbing. [Implications of wrong 
quoting](https://unix.stackexchange.com/questions/171346/security-implications-o
f-forgetting-to-quote-a-variable-in-bash-posix-shells)

Whenever you are processing input from from untrusted sources (messages, files, 
network) you must be as carefull as possible, e.g. set IFS appropriate, disable 
globbing (set -f) and quote everthing. In addition disable not used Bot 
commands and delete unused scripts from your Bot, e.g. example scripts 
'notify', 'calc', 'question',

A powerful tool to improve your scripts robustness is ```shellcheck```. You can 
[use it online](https://www.shellcheck.net/) or [install shellcheck 
locally](https://github.com/koalaman/shellcheck#installing). All bashbot 
scripts are checked by shellcheck.

### Run your Bot as a restricted user
**I recommend to run your bot as a user, with almost no access rights.** 
All files your Bot have write access to are in danger to be overwritten/deleted 
if your bot is hacked.
For the same reason ervery file your Bot can read is in danger to be disclosed. 
Restict your Bots access rigths to the absolute minimum.

**Never run your Bot as root, this is the most dangerous you can do!** Usually 
the user 'nobody' has almost no rights on Unix/Linux systems. See [Expert 
use](doc/4_expert.md) on how to run your Bot as an other user.

### Secure your Bot installation
**Your Bot configuration must no be readable from other users.** Everyone who 
can read your Bots token can act as your Bot and has access to all chats your 
Bot is in!

Everyone with read access to your Bot files can extract your Bots data. 
Especially your Bot Token in ```token``` must be protected against other users. 
No one exept you must have write access to the Bot files. The Bot must be 
restricted to have write access to ```count``` and  ```tmp-bot-bash``` only, 
all other files must be write protected.

To set access rights for your bashbot installation to a reasonable default run 
```sudo ./bashbot.sh init``` after every update or change to your installation 
directory.

### Is this Bot insecure?
Bashbot is not more (in)secure as any other Bot written in any other language, 
we have done our best to make it as secure as possible. But YOU are responsible 
for the bot commands you wrote and you should know about the risks ...

### Why Bash and not the much better xyz?
Well, thats a damn good question ... may be because I'm an Unix/Linux admin 
from stone age. Nevertheless there are more reasons from my side:

- bashbot will run everywhere where bash is availible, from ebedded linux to 
mainframe
- easy to integrate with other shell script, e.g. for sending system message / 
health status
- no need to install or learn a new programming language, library or framework
- no database, not event driven, not OO ...

@Gnadelwartz

## That's it!

If you feel that there's something missing or if you found a bug, feel free to 
submit a pull request!

#### $$VERSION$$ v0.7-rc1-0-g8279bdb
