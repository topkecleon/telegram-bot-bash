# bashbot
A Telegram bot written in bash.

Depends on [tmux](http://github.com/tmux/tmux).
Uses [JSON.sh](http://github.com/dominictarr/JSON.sh).

Written by Drew (@topkecleon), Daniil Gentili (@danogentili), and Kay M (@gnadelwartz).

Contributions by JuanPotato, BigNerd95, TiagoDanin, and iicc1.

[Download latest release from github](https://github.com/topkecleon/telegram-bot-bash/releases)

Released to the public domain wherever applicable.
Elsewhere, consider it released under the [WTFPLv2](http://www.wtfpl.net/txt/copying/).



## Install bashbot
1. Go to the directory you want to install bashbot, e.g.
  - your $HOME directory (install and run with your user-ID)
  - /usr/local if you want to run as service
2. Clone the repository:
```
git clone --recursive https://github.com/topkecleon/telegram-bot-bash
```
3. Change to directory ```telegram-bot.bash```, run ```./bashbot.sh init``` and follow the instructions. At this stage you are asked for your Bots token given by botfather.

## Update bashbot
[Download latest update zip from github](https://github.com/topkecleon/telegram-bot-bash/releases) and copy all files to bashbot dir. run ```sudo ./bashbot.sh init```.

## Getting started
 - [Create your first telegram bot](doc/1_firstbot.md)
 - [Make your own Bot](doc/2_usage.md)
   - Managing your own Bot
   - Recieve data
   - Send Messages
   - Send files, location  etc.
 - [Advanced Features](doc/3_advanced.md)
   - Access Control
   - Interactive Chats
   - Background Jobs
   - Inline queries
 - [Expert Use](doc/4_expert.md)
   - Handling UTF-8
   - Run as other user or system service
   - Scedule bashbot from Cron
 - [Best Practices](doc/5_practice.md)
   - Customizing commands.sh
   - Seperate Bot logic from command
   - Test your Bot with shellcheck

## Security Considerations
Running a Telegram Bot means you are conneted to the public, you never know whats send to your Bot.

Bash scripts in general are not designed to be bullet proof, so consider this Bot as a proof of concept. More concret examples of security problems is bash's 'quoting hell' and globbing. [Implications of wrong quoting](https://unix.stackexchange.com/questions/171346/security-implications-of-forgetting-to-quote-a-variable-in-bash-posix-shells)

Whenever you are processing input from outside your bot you should disable globbing (set -f) and carefully quote everthing.

To improve you scripts we recommend to lint them with [shellcheck](https://www.shellcheck.net/). This can be done online or you can [install shellcheck locally](https://github.com/koalaman/shellcheck#installing). bashbot itself is also linted by shellcheck.

### Run your Bot as a restricted user
Every file your bot can write is in danger to be overwritten/deleted, In case of bad handling of user input every file your Bot can read is in danger of being disclosed.

Never run your Bot as root, this is the most dangerous you can do! Usually the user 'nobody' has almost no rigths on Unix/Linux systems. See Expert use on how to run your Bot as an other user.

### Secure your Bot installation
Everyone who can read your Bot files can extract your Bots data. Especially your Bot Token in ```token``` must be protected against other users. No one exept you should have write access to the Bot files. The Bot itself need write access to ```count``` and  ```tmp-bot-bash``` only, all other files should be write protected.

Runing ```./bashbot.sh init``` sets the Bot permissions to reasonable default values as a starting point.

### Is this Bot insecure?
No - its not less (in)secure as any other Bot written in any other language. But you should know about the implications ...

## That's it!

If you feel that there's something missing or if you found a bug, feel free to submit a pull request!

#### $$VERSION$$ v0.52-0-gdb7b19f
