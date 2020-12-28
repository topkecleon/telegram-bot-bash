#### [Home](../README.md)

## Check bash installation

There may systems where bash seems to be installed but it is not, e.g. embedded systems, or where bash is to old.
Bashbot has some builtin checks but it may better to check before installing bashbot.

Run the following commands to see if your bash looks ok ...

```bash
# system say bash is there?
if which bash; then echo "bash seems available..."; else echo "NO bash"; fi

# real bash supports ARRAY
bash -c 'if eval "a[1]=1"; then echo "Shell support arrays..."; else echo "Shell has NO arrays"; fi'

# check for bash version by feature
bash -c 'if [ "$(echo -e "\u1111")" != "\u1111" ]; then echo "Bash version ok ..."; else echo "Bash version may to old ..."; fi'

# display bash version, must be greater than 4.3
bash --version | grep "bash"
```

## Install bashbot

1. Go to the directory you want to install bashbot, e.g.
    * your $HOME directory (install and run with your user-ID)
    * /usr/local if you want to run as service
2. [Download latest release zip / tar archive from github](https://github.com/topkecleon/telegram-bot-bash/releases/latest) and extract all files. 
3. Change into the directory `telegram-bot-bash`
4. Copy `mycommands.sh.dist` or `mycommands.sh.clean` to `mycommands.sh`
5. Run `./bashbot.sh init` to setup the environment and enter your Bots token given by botfather.

Edit `mycommands.sh` to fit your needs.
Now your Bot is ready to start ...

**If you are new to Bot development read [Bots: An introduction for developers](https://core.telegram.org/bots)**


### Update bashbot

**Important: all files including `mycommands.sh` may overwritten, make a backup!**

1. Go to the directory where you have installed bashbot, e.g.
    * your $HOME directory
    * /usr/local
2. [Download latest release zip / tar archive from github](https://github.com/topkecleon/telegram-bot-bash/releases/latest)
3. Stop all running instances of bashbot `./bashbot.sh stop`
4. Extract all files to your existing bashbot dir 
5. Run `sudo ./bashbot.sh init` to setup your environment after the update

If you modified `commands.sh` move your changes to `mycommands.sh`, this avoids overwriting your commands on every update.

Now you can restart your bashbot instances.

*Note*: If you are updating from a pre-1.0 version, update to [Version 1.20](https://github.com/topkecleon/telegram-bot-bash/releases/tags/v1.20) first!

### Use JSON.awk (beta)

[JSON.awk](https://github.com/step-/JSON.awk) is an awk port of `JSON.sh`, it provides the same functionality but is 5 times faster.
Most systems with awk can use `JSON.awk` as drop in replacement
( [gnu awk, posix awk, mawk, busybox akw](https://github.com/step-/JSON.awk#compatibility-with-awk-implementations) ).

BSD and MacOS users must install `gnu awk` and adjust the shebang, see below

After you have checked that 'JSON.awk.dist' is working correct on your system copy it to `JSON.awk` and (re)start bashbot.

Note: If you are not using the zip / tar archive, you must install `JSON.awk` manually into the same directory as 'JSON.sh`:

	wget https://cdn.jsdelivr.net/gh/step-/JSON.awk/JSON.awk 
	wget https://cdn.jsdelivr.net/gh/step-/JSON.awk/tool/patch-for-busybox-awk.sh
	bash patch-for-busybox-awk.sh


### Install bashbot from git repo

Installation and Updates should be done using the zip / tar archives provided on github to avoid
problems and not overwriting your bot config and `mycommands.sh`.

Nevertheless you can install or update bashbot from a git repo, see next chapter ...


### Create Installation / Update archives yourself

To install or update bashbot from a git repo you must create the archives yourself.

1. Run `git clone https://github.com/topkecleon/telegram-bot-bash.git`
2. Change into the directory `telegram-bot-bash`
3. Run ` git checkout develop` (_otional, for latest dev version_)
4. Run ` dev/make-distribution.sh` (_add option --notest to skip tests_)
5. You'll find archives and a bashbot installation in directory DIST
6. install or update abshbot using one of the archives (optional)

*Note*: You can update the basbot installation in `DIST/telegram-bot-bash` with `git pull; dev/make-distrubition.sh --notest` to get the latest updates.


### Note for BSD and MacOS

**On MacOS** you must install a more recent version of bash, as the default bash is way to old,
see e.g. [Install Bash on Mac](http://macappstore.org/bash/)

**On BSD and MacOS** I recommend to install gnu coreutils and include them in your PATH
environment variable before running bashbot, e.g. the gnu versions of sed, grep, find ...

On BSD and MacOS you must adjust the shebang line of the scripts ```bashbot.sh``` and ```json.sh``` to point to to the correct bash
or use the script: ```examples/bash2env *.sh */*.sh``` to convert them for you.

Bashbot will stay with /bin/bash shebang, as using a fixed path is more secure than the portable /usr/bin/env variant, see
[Security Considerations](../README.md#Security-Considerations)

I considered to make bashbot BSD sed compatible, but much of the bashbot "magic" relies on
(gnu) sed features, e.g. alternation ```|```, non printables ```\n\t\<``` or repeat ```?+``` pattern, not supported by BSD sed.

BSD/MacOS sed compatibility will result in a rewrite of all grep/sed commands with an uncertain outcome,
see [BSD/MacOS vs. GNU sed](https://riptutorial.com/sed/topic/9436/bsd-macos-sed-vs--gnu-sed-vs--the-posix-sed-specification)
to get an impression how different they are.


### Notes on Changes

#### Support for update from pre-1.0 removed

From Version 1.21 on updating from a pre-1.0 version is no more supported!
You must update to [Version 1.20](https://github.com/topkecleon/telegram-bot-bash/releases/tags/v1.20) first!



#### [Next Create Bot](1_firstbot.md)

#### $$VERSION$$ v1.21-dev-22-ga3efcd2

