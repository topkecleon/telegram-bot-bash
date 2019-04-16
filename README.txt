bashbot
-------

A Telegram bot written in bash.

Depends on http://github.com/tmux/tmux[tmux]. Uses
http://github.com/dominictarr/JSON.sh[JSON.sh].

For full UTF-8 support you need
link:doc/4_expert.md#UTF-8-Support[python on your system] (optional).

Written by Drew (@topkecleon), Daniil Gentili (@danogentili), and Kay M
(@gnadelwartz).

Contributions by JuanPotato, BigNerd95, TiagoDanin, and iicc1.

https://github.com/topkecleon/telegram-bot-bash/releases[Download latest
release from github]

Released to the public domain wherever applicable. Elsewhere, consider
it released under the http://www.wtfpl.net/txt/copying/[WTFPLv2].

Install bashbot
~~~~~~~~~~~~~~~

1.  Go to the directory you want to install bashbot, e.g.
* your $HOME directory (install and run with your user-ID)
* /usr/local if you want to run as service
2.  Clone the repository:
+
....
git clone --recursive https://github.com/topkecleon/telegram-bot-bash
....
3.  Change to directory `telegram-bot.bash`, run `./bashbot.sh init` and
follow the instructions. At this stage you are asked for your Bots token
given by botfather.

Update bashbot
~~~~~~~~~~~~~~

https://github.com/topkecleon/telegram-bot-bash/releases[Download latest
update zip from github], extract all files and copy them to your bashbot
dir. Now run `sudo ./bashbot.sh init` to setup your environment for the
new release.

Getting started
~~~~~~~~~~~~~~~

* link:doc/1_firstbot.md[Create Telegram Bot with botfather]
* link:doc/2_usage.md[Getting Started]
** Managing your Bot
** Recieve data
** Send Messages
** Send files, location etc.
* link:doc/3_advanced.md[Advanced Features]
** Access Control
** Interactive Chats
** Background Jobs
** Inline queries
* link:doc/4_expert.md[Expert Use]
** Handling UTF-8
** Run as other user or system service
** Scedule bashbot from Cron
* link:doc/5_practice.md[Best Practices]
** Customizing commands.sh
** Seperate Bot logic from command
** Test your Bot with shellcheck
* link:doc/6_reference.md[Bashbot functions reference]

Note on Keyboards
~~~~~~~~~~~~~~~~~

To make use of Keyboards easier the keybord format for `send_keyboard`
and `send_message "mykeyboardstartshere ..."` was changed. Keybords are
now defined in an JSON Array notation e.g. "[ \"yes\" , \"no\" ]". This
has the advantage that you can create any type of keyboard supported by
Telegram. *This is an incompatible change for keyboards used in older
bashbot versions.*

_Example Keyboards_:

* yes no in one row
** OLD format: "yes" "no" (two strings)
** NEW format: "[ \"yes\" , \"no\" ]" (string containing an array)
* new keybord layouts, no possible with old format:
** Yes No in two rows: "[ \"yes\" ] , [ \"no\" ]"
** numpad style keyboard: "[ \"1\" , \"2\" , \"3\" ] , [ \"4\" , \"5\" ,
\"6\" ] , [ \"7\" , \"8\" , \"9\" ] , [ \"0\" ]"

Security Considerations
~~~~~~~~~~~~~~~~~~~~~~~

Running a Telegram Bot means it is connected to the public and you never
know whats send to your Bot.

Bash scripts in general are not designed to be bullet proof, so consider
this Bot as a proof of concept. More concret examples of security
problems are bash's 'quoting hell' and globbing.
https://unix.stackexchange.com/questions/171346/security-implications-of-forgetting-to-quote-a-variable-in-bash-posix-shells[Implications
of wrong quoting]

Whenever you are processing input from from untrusted sources (messages,
files, network) you must be as carefull as possible, e.g. disable
globbing (set -f) and quote everthing.

A powerful tool to improve your scripts robustness is `shellcheck`. You
can https://www.shellcheck.net/[use it online] or
https://github.com/koalaman/shellcheck#installing[install shellcheck
locally]. All bashbot scripts are checked by shellcheck.

Run your Bot as a restricted user
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

*It's important to run your bot as a user, with almost no access
rights.*

All files your Bot have write access to are in danger to be
overwritten/deleted if your bot is hacked. For the same reason ervery
file your Bot can read is in danger of being disclosed. So please
restict your Bots access rigths to the absolute minimum.

*Never run your Bot as root, this is the most dangerous you can do!*
Usually the user 'nobody' has almost no rights on Unix/Linux systems.
See Expert use on how to run your Bot as an other user.

Secure your Bot installation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

*Your Bot configuration should not be readable from other users.* If
someone can read your Bots token he can act as your Bot and has access
to all chats you Bot is in!

Everyone with read access to your Bot files can extract your Bots data.
Especially your Bot Token in `token` must be protected against other
users. No one exept you should have write access to the Bot files. The
Bot must be restricted to have write access to `count` and
`tmp-bot-bash` only, all other files should be write protected.

To set access rights for your telegram-bot-bash directory to reasonable
default values you must run `sudo ./bashbot.sh init` after every update
or change to your installation directory.

Is this Bot insecure?
^^^^^^^^^^^^^^^^^^^^^

Bashbot is no more (in)secure as any other Bot written in any other
language. But since YOU are responsible for your bots commands and run
the Bot, you should know about the implications ...

That's it!
~~~~~~~~~~

If you feel that there's something missing or if you found a bug, feel
free to submit a pull request!

latexmath:[\[VERSION\]] v0.60-rc2-4-g1bf26b9
++++++++++++++++++++++++++++++++++++++++++++
