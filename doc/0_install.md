#### [Home](../README.md)

## Check bash installation

There may systems where bash seems to be installed but it is not (_e.g. embedded systems_) or where bash is to old.
Bashbot has some builtin checks but it may better to check before installing bashbot.

Run the following commands to see if your bash looks ok ...

```bash
# system say bash is there?
if which bash; then echo "bash seems available..."; else echo "NO bash"; fi

# real bash supports ARRAY
bash -c 'if eval "a[1]=1"; then echo "Shell support arrays..."; else echo "Shell has NO arrays"; fi'

# check for bash version by feature
bash -c 'if [ "$(LANG=C.UTF-8 echo -e "\u1111")" != "\u1111" ]; then echo "Bash version ok ..."; else echo "Bash version may to old ..."; fi'

# display bash version, must be greater than 4.3
bash --version | grep "bash"
```

## Install bashbot

Installing bashbot is very simple: Download and extract the installation archive.

1. Choose a directory to install bashbot (_e.g.your HOME or /usr/local_)
2. Download [latest release zip / tar archive](https://github.com/topkecleon/telegram-bot-bash/releases/latest) and extract all files. 
3. Change into the directory `telegram-bot-bash`
4. Copy `mycommands.conf.dist` `mycommands.conf`
4. Copy `mycommands.sh.dist` or `mycommands.sh.clean` to `mycommands.sh`
5. Run `./bashbot.sh init`\* to setup the environment and enter your Bots token given by botfather.

Edit config in `mycommands.conf` and commands in `mycommands.sh` to fit your need.
Now your Bot is ready to start ...

*If you are new to Bot development read [Bots: An introduction for developers](https://core.telegram.org/bots)*

\* _Run with sudo if you want to run bashbot from different user, e.g. from `bashbot.rc`._

### Update bashbot

Update bashbot is almost identical to installing bashbot: Download and extract the installation archive.

**Important: All files may overwritten, make a backup!**

1. Go to the directory where bashbot is installed (_e.g.$HOME/telegram-bot-bash or /usr/local/telegram-bot-bash_)
2. Download [latest release zip / tar archive](https://github.com/topkecleon/telegram-bot-bash/releases/latest)
3. Stop all running instances of bashbot `./bashbot.sh stop`
4. Change to parent directory of bashbot installation and extract all files from archive.
5. Run `./bashbot.sh init`\* to setup your environment after the update
6. Restart your bot `./bashbot.sh start`

`mycommands.conf` and `mycommands.sh` will not overwritten, this avoids losing your bot config and commands on updates.

*Note*: If you are updating from a pre-1.0 version, update to [Version 1.20](https://github.com/topkecleon/telegram-bot-bash/releases/tags/v1.20) first!

### Use JSON.awk

[JSON.awk](https://github.com/step-/JSON.awk) is an awk port of `JSON.sh`, it provides the same functionality but is 5 times faster.
On most systems you can use `JSON.awk` with system default awk installation.
( [gnu awk, posix awk, mawk, busybox akw](https://github.com/step-/JSON.awk#compatibility-with-awk-implementations) ).

After you have checked that `JSON.awk.dist` is working on your system copy it to `JSON.awk` and (re)start bashbot.

BSD and MacOS users must install `gnu awk` and adjust the shebang, see below

*Note*: To install or update `JSON.awk` manually execute the following commands in the directory `JSON.sh/`:

	wget https://cdn.jsdelivr.net/gh/step-/JSON.awk/JSON.awk 
	wget https://cdn.jsdelivr.net/gh/step-/JSON.awk/tool/patch-for-busybox-awk.sh
	bash patch-for-busybox-awk.sh
	chmod +x JSON.awk


### Install bashbot from git repo

Installation and updates should be done using the zip / tar archives provided on github to avoid
problems and not overwriting your bot config and `mycommands.sh`.

Nevertheless you can install or update bashbot from a git repo, see next chapter ...


### Create Installation / Update archives

To install or update bashbot from git repo execute `dev/make-distribution.sh`.
This creates the installation archives in `DIST/` and a ready to run test installation in `DIST/telegram.bot-bash`.

*Note:* You should be familiar with `git`.

1. Run `git clone https://github.com/topkecleon/telegram-bot-bash.git`
2. Change into the directory `telegram-bot-bash`
3. Optional: Run ` git checkout develop` for latest develop version
4. Run ` dev/make-distribution.sh` (_add --notest to skip tests_)
5. Change to dir `DIST/`

Use the installation archives to install or update bashbot as described above.

To run a test bot, e.g. while development or testing latest changes, you can use the bashbot installation provided in `DIST/telegram-bot-bash`.
To update the test installation (_after git pull, local changes or switch master/develop_) run `dev/make-distribution.sh` again.


### Note for BSD and MacOS

**On MacOS** you must install a more recent version of bash, as the default bash is way to old,
see e.g. [Install Bash on Mac](http://macappstore.org/bash/)

**On BSD and MacOS** I recommend to install gnu coreutils and include them in your PATH
environment variable before running bashbot, e.g. the gnu versions of sed, grep, find, awk ...

On BSD and MacOS you must adjust the shebang line of the scripts `bashbot.sh` and `json.sh` to point to to the correct bash
or use the script: `examples/bash2env *.sh */*.sh` to convert them for you.

Bashbot will stay with `#!/bin/bash` shebang, as using a fixed path is IMHO more secure than the portable '!/usr/bin/env bash` variant.

Compatibility with BSD/MacOS will result in a rewrite of all grep/sed commands with an uncertain outcome,
see [BSD/MacOS vs. GNU sed](https://riptutorial.com/sed/topic/9436/bsd-macos-sed-vs--gnu-sed-vs--the-posix-sed-specification)
to get an impression how different they are.


### Notes on Changes

#### Config moved to mycommands.conf

From Version 1.30 on config for new bots is moved to `mycommands.conf`.

#### Support for update from pre-1.0 removed

From Version 1.21 on updating from a pre-1.0 version (_no \*.jssh config_) is no more supported!
You must update to [Version 1.20](https://github.com/topkecleon/telegram-bot-bash/releases/tags/v1.20) first!

#### [Next Create Bot](1_firstbot.md)

#### $$VERSION$$ v1.51-0-g6e66a28

