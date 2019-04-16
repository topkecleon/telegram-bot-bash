# bashbot
A Telegram bot written in bash.

Depends on [tmux](http://github.com/tmux/tmux).
Uses [JSON.sh](http://github.com/dominictarr/JSON.sh).

For full UTF-8 support you need [python on your system](doc/4_expert.md#UTF-8-Support) (optional).

Written by Drew (@topkecleon), Daniil Gentili (@danogentili), and Kay M (@gnadelwartz).

Contributions by JuanPotato, BigNerd95, TiagoDanin, and iicc1.

[Download latest release from github](https://github.com/topkecleon/telegram-bot-bash/releases)

Released to the public domain wherever applicable.
Elsewhere, consider it released under the [WTFPLv2](http://www.wtfpl.net/txt/copying/).



## Install bashbot
1. Go to the directory you want to install bashbot, e.g.
    * your $HOME directory (install and run with your user-ID)
    * /usr/local if you want to run as service
2. Clone the repository:
    ```
    git clone --recursive https://github.com/topkecleon/telegram-bot-bash
    ```
3. Change to directory ```telegram-bot.bash```, run ```./bashbot.sh init``` and follow the instructions. At this stage you are asked for your Bots token given by botfather.

## Update bashbot
[Download latest update zip from github](https://github.com/topkecleon/telegram-bot-bash/releases) extract all files and copy them to your bashbot dir. Now run ```sudo ./bashbot.sh init``` to setup your environment to the current release.

## Getting started
* [Create Telegram Bot with botfather](doc/1_firstbot.md)
* [Getting Started](doc/2_usage.md)
    * Managing your Bot
    * Recieve data
    * Send Messages
    * Send files, location  etc.
* [Advanced Features](doc/3_advanced.md)
    * Access Control
    * Interactive Chats
    * Background Jobs
    * Inline queries
* [Expert Use](doc/4_expert.md)
    * Handling UTF-8
    * Run as other user or system service
    * Scedule bashbot from Cron
* [Best Practices](doc/5_practice.md)
    * Customizing commands.sh
    * Seperate Bot logic from command
    * Test your Bot with shellcheck
* [Bashbot functions reference](doc/6_reference.md)

## Note on Keyboards
To make use of Keyboards easier the keybord format for ```send_keyboard``` and ```send_message "mykeyboardstartshere ..."``` was changed.
Keybords are now defined in an JSON Array notation e.g. "[ \\"yes\\" , \\"no\\" ]".
This has the advantage that you can create any type of keyboard supported by Telegram.
**This is incompatible change for keyboards used in older bashbot versions**

*Example Keyboards*:

- yes no in one row
    - OLD format: "yes" "no" (two strings)
    - NEW format: "[ \\"yes\\" , \\"no\\" ]" (one string with array)
- new keybord layouts, no possible with old format:
    - Yes No in two rows: "[ \\"yes\\" ] , [ \\"no\\" ]"
    - numpad style keyboard: "[ \\"1\\" , \\"2\\" , \\"3\\" ] , [ \\"4\\" , \\"5\\" , \\"6\\" ] , [ \\"7\\" , \\"8\\" , \\"9\\" ] , [ \\"0\\" ]"

## Security Considerations
Running a Telegram Bot means it is conneted to the public and you never know whats send to your Bot.

Bash scripts in general are not designed to be bullet proof, so consider this Bot as a proof of concept. More concret examples of security problems is bash's 'quoting hell' and globbing. [Implications of wrong quoting](https://unix.stackexchange.com/questions/171346/security-implications-of-forgetting-to-quote-a-variable-in-bash-posix-shells)

Whenever you are processing input from from untrusted sources (messages, files, network) you mustbe be as carefull as possible, e.g. disable globbing (set -f) and quote everthing.

A powerful tool to improve your scripts robustness is [shellcheck](https://www.shellcheck.net/). You can use it online or [install shellcheck locally](https://github.com/koalaman/shellcheck#installing). All bashbot scripts are checked by shellcheck.

### Run your Bot as a restricted user
It's important to run your bot as a user, with almost no access rights!

All files your Bot can write are in danger to be overwritten/deleted if your bot can be abused.
Every file your Bot can read is in danger of being disclosed for the same reason.

**Never run your Bot as root, this is the most dangerous you can do!** Usually the user 'nobody' has almost no rigths on Unix/Linux systems. See Expert use on how to run your Bot as an other user.

### Secure your Bot installation
You Bot configuration contains data which should not be readable from other users.

Everyone who can read your Bot files can extract your Bots secret data. Especially your Bot Token in ```token``` must be protected against other users. No one exept you should have write access to the Bot files. The Bot itself can be restricted to have write access to ```count``` and  ```tmp-bot-bash``` only, all other files should be write protected.

To set access rights for your telegram-bot-bash directory to reasonable default values you should run ```sudo ./bashbot.sh init``` after every update or change to your installation directory.

### Is this Bot insecure?
Bashbot is no more insecure as any other Bot written in any other language. But since YOU change the bot commands and run the Bot, you should know about the implications ...

## That's it!

If you feel that there's something missing or if you found a bug, feel free to submit a pull request!

#### $$VERSION$$ v0.60-rc2-2-g7727608
