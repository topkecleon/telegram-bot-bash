bashbot
-------

A Telegram bot written in bash.

Written by Drew (@topkecleon), Daniil Gentili (@danogentili), and Kay M
(@gnadelwartz).

Contributions by JuanPotato, BigNerd95, TiagoDanin, and iicc1.

Released to the public domain wherever applicable. Elsewhere, consider
it released under the http://www.wtfpl.net/txt/copying/[WTFPLv2].

Prerequisites
~~~~~~~~~~~~~

Depends on http://github.com/tmux/tmux[tmux]. Uses
http://github.com/dominictarr/JSON.sh[JSON.sh].

Most complete link:doc/4_expert.md#Bashbot-UTF-8-Support[UTF-8 support
for bashbot] is availible if phyton is installed (optional).

Bashbot https://github.com/topkecleon/telegram-bot-bash[Documentation]
and https://github.com/topkecleon/telegram-bot-bash/releases[Downloads]
are availible on www.github.com

Documentation
~~~~~~~~~~~~~

* link:doc/0_install.md[Install Bashbot]
** Install release
** Install from githup
** Update Bashbot
** Notes on Updates
* link:doc/1_firstbot.md[Create a new Telegram Bot with botfather]
* link:doc/2_usage.md[Getting Started]
** Managing your Bot
** Recieve data
** Send messages
** Send files, locations, keyboards
* link:doc/3_advanced.md[Advanced Features]
** Access Control
** Interactive Chats
** Background Jobs
** Inline queries
* link:doc/4_expert.md[Expert Use]
** Handling UTF-8 character sets
** Run as other user or system service
** Scedule bashbot from Cron
* link:doc/5_practice.md[Best Practices]
** Customize commands.sh
** Seperate logic from commands
** Test your Bot with shellcheck
* link:doc/6_reference.md[Bashbot function reference]
* link:doc/7_develop.md[Notes for bashbot developers]
* link:doc/8_customize.md[Customize bashbot environment]

Security Considerations
~~~~~~~~~~~~~~~~~~~~~~~

Running a Telegram Bot means it is connected to the public and you never
know whats send to your Bot.

Bash scripts in general are not designed to be bullet proof, so consider
this Bot as a proof of concept. More concret examples of security
problems are: bash's 'quoting hell' and globbing.
https://unix.stackexchange.com/questions/171346/security-implications-of-forgetting-to-quote-a-variable-in-bash-posix-shells[Implications
of wrong quoting]

Whenever you are processing input from from untrusted sources (messages,
files, network) you must be as carefull as possible, e.g. set IFS
appropriate, disable globbing (set -f) and quote everthing. In addition
disable not used Bot commands and delete unused scripts from your Bot,
e.g. example scripts 'notify', 'calc', 'question',

A powerful tool to improve your scripts robustness is `shellcheck`. You
can https://www.shellcheck.net/[use it online] or
https://github.com/koalaman/shellcheck#installing[install shellcheck
locally]. All bashbot scripts are checked by shellcheck.

Run your Bot as a restricted user
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

*I recommend to run your bot as a user, with almost no access rights.*
All files your Bot have write access to are in danger to be
overwritten/deleted if your bot is hacked. For the same reason ervery
file your Bot can read is in danger to be disclosed. Restict your Bots
access rigths to the absolute minimum.

*Never run your Bot as root, this is the most dangerous you can do!*
Usually the user 'nobody' has almost no rights on Unix/Linux systems.
See link:doc/4_expert.md[Expert use] on how to run your Bot as an other
user.

Secure your Bot installation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

*Your Bot configuration must no be readable from other users.* Everyone
who can read your Bots token can act as your Bot and has access to all
chats your Bot is in!

Everyone with read access to your Bot files can extract your Bots data.
Especially your Bot Token in `token` must be protected against other
users. No one exept you must have write access to the Bot files. The Bot
must be restricted to have write access to `count` and `tmp-bot-bash`
only, all other files must be write protected.

To set access rights for your bashbot installation to a reasonable
default run `sudo ./bashbot.sh init` after every update or change to
your installation directory.

Is this Bot insecure?
^^^^^^^^^^^^^^^^^^^^^

Bashbot is not more (in)secure as any other Bot written in any other
language, we have done our best to make it as secure as possible. But
YOU are responsible for the bot commands you wrote and you should know
about the risks ...

That's it!
~~~~~~~~~~

If you feel that there's something missing or if you found a bug, feel
free to submit a pull request!

latexmath:[\[VERSION\]] v0.70-dev2-25-gd55d311
++++++++++++++++++++++++++++++++++++++++++++++
