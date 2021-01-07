




Bashbot README


 Bashbot - A Telegram bot written in bash.

Written by Drew (@topkecleon) and Kay M (@gnadelwartz).
Contributions by Daniil Gentili (@danog), JuanPotato, BigNerd95, TiagoDanin, iicc1 and
dcoomber.
Released to the public domain wherever applicable. Elsewhere, consider it released under
the WTFPLv2.
Linted by #ShellCheck

Prerequisites

Uses JSON.sh and the magic of sed.
Bashbot is written in bash. It depends on commands typically available in a Linux/Unix
Environment. For more concrete information on the common commands provided by recent
versions of coreutils, busybox or toybox, see Developer_Notes.
Note for MacOS and BSD Users: Bashbot will not run without installing additional software
as it uses modern bash and (gnu) grep/sed features. See Install_Bashbot.
Note for embedded systems: You need to install a "real" bash as the vanilla installation
of busybox or toybox is not sufficient. See Install_Bashbot.
Bashbot Documentation and Downloads are available on www.github.com.

Documentation


* Introduction_to_Telegram_Bots
* Install_Bashbot

  o Install release
  o Install from github
  o Update Bashbot
  o Notes on Updates

* Get_Bottoken_from_Botfather
* Getting_Started

  o Managing your Bot
  o Receive data
  o Send messages
  o Send files, locations, keyboards

* Advanced_Features

  o Access Control
  o Interactive Chats
  o Background Jobs
  o Inline queries
  o Send message errors

* Expert_Use

  o Handling UTF-8 character sets
  o Run as other user or system service
  o Schedule bashbot from Cron
  o Use from CLI and Scripts
  o Customize Bashbot Environment

* Best_Practices

  o Customize mycommands.sh
  o Overwrite/disable commands
  o Separate logic from commands
  o Test your Bot with shellcheck

* Function_Reference

  o Sending Messages, Files, Keyboards
  o User Access Control
  o Inline Queries
  o jsshDB Bashbot key-value storage
  o Background and Interactive Jobs

* Developer_Notes

  o Debug bashbot
  o Modules, addons, events
  o Setup your environment
  o Bashbot test suite

* Examples_Directory


Your very first bashbot in a nutshell

To install and run bashbot you need access to a Linux/Unix command line with bash, a
Telegram_client and a mobile phone with_a_Telegram_account.
First you need to create_a_new_Telegram_Bot_token for your bot and write it down.
Now open a Linux/Unix terminal with bash, create a new directory, change to it and install
telegram-bot-bash:

  # create bot dir
  mkdir mybot
  cd mybot

  # download latest release with wget or from https://github.com/topkecleon/telegram-bot-
  bash/releases/latest
  wget &quot;https://github.com/$(wget -q &quot;https://github.com/topkecleon/telegram-
  bot-bash/releases/latest&quot; -O - | egrep '/.*/download/.*/.*tar.gz' -o)&quot;

  # Extract the tar archive and go into bot dir
  tar -xzf *.tar.gz
  cd telegram-bot-bash

  # initialize your bot
  # Enter your bot token when asked, all other questions can be answered by hitting the
  \<Return\> key.
  ./bashbot.sh init

  # Now start your bot
  ./bashbot.sh start

  Bottoken is valid ...
  Bot Name: yourbotname_bot
  Session Name: yourbotname_bot-startbot
  Bot started successfully.

Now open the Telegram App on your mobile phone and start a chat with your bot (your bot's
username is shown after 'Bot Name:'):

  /start

  You are Botadmin
  Available commands:
    /start: _Start bot and get this message_.
    /help: _Get this message_.
    /info: _Get shorter info message about this bot_....

  /info

  This is bashbot, the Telegram bot written entirely in bash.
  It features background tasks and interactive chats, and can serve as an interface for
  CLI programs.

For more Information on how to install, customize and use your new bot, read the
Documentation.

Log files

Bashbot actions are logged to BASHBOT.log. Telegram send/receive errors are logged to
ERROR.log. Start bashbot in debug mode to see all messages sent to / received from
Telegram, as well as bash command error messages.
To enable debug mode, start bashbot with debug as third argument: bashbot start debug

  |__ logs
  |     |__ BASHBOT.log  # log what your bot is doing ...
  |     |__ ERROR.log    # connection errors from / to Telegram API
  |     |
  |     |__ DEBUG.log    # stdout/stderr of you bot (debug mode enabled)
  |     |__ MESSAGE.log  # full text of all message send/received (debug mode enabled)

------------------------------------------------------------------------------------------

Security Considerations

Running a Telegram Bot means it is connected to the public and you never know what's send
to your Bot.
Bash scripts in general are not designed to be bulletproof, so consider this Bot as a
proof of concept. Bash programmers often struggle with 'quoting hell' and globbing, see
Implications_of_wrong_quoting.
Whenever you are processing input from untrusted sources (messages, files, network) you
must be as careful as possible (e.g. set IFS appropriately, disable globbing with set -
f and quote everything). In addition remove unused scripts and examples from your Bot
(e.g. everything in example/) and disable/remove all unused bot commands.
It's important to escape or remove $ in input from user, files or network (as bashbot
does). One of the powerful features of Unix shells is variable and command substitution
using ${} and$() can lead to remote code execution (RCE) or remote information disclosure
(RID) bugs if unescaped $ is included in untrusted input (e.g. $$ or $(rm -rf /*)).
A powerful tool to improve your scripts is shellcheck. You can use_it_online or install
shellcheck_locally. Shellcheck is used extensively in bashbot development to ensure a high
code quality (e.g. it's not allowed to push changes without passing all shellcheck tests).
In addition bashbot has a test_suite to check if important functionality is working as
expected.

Use printf whenever possible

If you're writing a script that accepts external input (e.g. from the user as arguments or
the file system), you shouldn't use echo to display it. Use_printf_whenever_possible.

Run your Bot as a restricted user

I recommend running your bot as a user with almost no access rights. All files your Bot
has write access to are in danger of being overwritten/deleted if your bot is hacked. For
the same reason every file your Bot can read is in danger of being disclosed. Restrict
your Bots access rights to the absolute minimum.
Never run your Bot as root, this is the most dangerous you can do! Usually the user
'nobody' has almost no rights on Linux/Unix systems. See Expert_use on how to run your Bot
as an other user.

Secure your Bot installation

Your Bot configuration must not be readable by other users. Everyone who can read your
Bots token is able to act as your Bot and has access to all chats the Bot is in!
Everyone with read access to your Bot files can extract your Bots data. Especially your
Bot config inconfig.jssh must be protected against other users. No one except you should
have write access to the Bot files. The Bot should be restricted to have write access
tocount.jssh and data-bot-bash only, all other files must be write protected.
To set access rights for your bashbot installation to a reasonable default runsudo ./
bashbot.sh init after every update or change to your installation directory.

FAQ


Is this Bot insecure?

Bashbot is not more (in)secure than a Bot written in another language. We have done our
best to make it as secure as possible. But YOU are responsible for the bot commands you
wrote and you should know about the risks ...
Note: Up to version 0.941 (mai/22/2020) telegram-bot-bash had a remote code execution bug,
please update if you use an older version!

Why Bash and not the much better xyz?

Well, that's a damn good question... maybe because I'm a Unix admin from the stone age.
Nevertheless there are more reasons from my side:

* bashbot will run wherever bash and (gnu) sed is available, from embedded Linux to
  mainframe
* easy to integrate with other shell scripts, e.g. for sending system message / health
  status
* no need to install or learn a new programming language, library or framework
* no database, not event driven, not object oriented ...


Can I have the single bashbot.sh file back?

At the beginning bashbot was simply the filebashbot.sh that you could copy everywhere and
run the bot. Now we have 'commands.sh', 'mycommands.sh', 'modules/*.sh' and much more.
Hey no problem, if you are finished with your cool bot, rundev/make-standalone.sh to
create a stripped down version of your bot containing only 'bashbot.sh' and 'commands.sh'!
For more information see Create_a_stripped_down_version_of_your_Bot.

Can I send messages from CLI and scripts?

Of course you can send messages from command line and scripts! Simply install bashbot as
described_here, send the message '/start' to set yourself as botadmin and then stop the
bot with ./bashbot.sh stop.
Bashbot provides some ready to use scripts for sending messages from command line in bin/
dir, e.g. send_message.sh.

  bin/send_message.sh BOTADMIN &quot;This is my first message send from CLI&quot;

  bin/send_message.sh --help

You can also source bashbot for use in your scripts, for more information see Expert_Use.

Blocked by telegram?

This may happen if too many or wrong requests are sent to api.telegram.org, e.g. using a
invalid token or invalid API calls. If the block stay for longer time you can ask telegram
service to unblock your IP-Address.
You can check with curl or wget if you are blocked by Telegram:

  curl -m 10  https://api.telegram.org/bot
  #curl: (28) Connection timed out after 10001 milliseconds

  wget -t 1 -T 10 https://api.telegram.org/bot
  #Connecting to api.telegram.org (api.telegram.org)|46.38.243.234|:443... failed:
  Connection timed out.

  nc -w 2 api.telegram.org 443 || echo &quot;your IP seems blocked by telegram&quot;
  #your IP seems blocked by telegram

Bashbot offers the option to recover from broken connections (blocked). Therefore you can
provide a function named bashbotBlockRecover() in mycommands.sh, the function is called
every time when a broken connection is detected.
Possible actions are: Check if network is working, change IP-Address or simply wait some
time. See mycommnds.sh.dist for an example.
------------------------------------------------------------------------------------------
@Gnadelwartz

That's it all guys!

If you feel that there's something missing or if you found a bug, feel free to submit a
pull request!

$$VERSION$$ v1.25-dev-33-g04e3c18

