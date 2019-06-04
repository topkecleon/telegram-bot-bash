#### [Home](../README.md)

## Notes for bashbot developers
This section is about help and best practices for new bashbot developers. The main focus on is creating new versions of bashbot, not on develop your individual bot. Nevertheless the rules and tools described here can also help you with your bot development.

bashbot development is done on github. If you want to provide fixes or new features [fork bashbot on githup](https://help.github.com/en/articles/fork-a-repo) and provide changes as [pull request on github](https://help.github.com/en/articles/creating-a-pull-request).

### Debugging Bashbot
In normal mode of operation all bashbot output is discarded.
To get these messages (and more) you can start bashbot in the current shell with ```./bashbot.sh startbot &```.
Now you can see all output or erros from bashbot.
In addition you can change the change the level of verbosity by adding a third argument after startbot.
```
	"debug"		redirects all output to "DEBUG.log", in addtion every update is logged in "MESSAGE.LOG" and "INLINE.log"
	"debugterm"	same as debug but output and errors are sent to terminal

	"xdebug"	same as debug plus set bash option '-x' to log any executed command
	"xdebugterm"	same as xdebug but output and errors are sent to terminal
```

To stop bashhbot in debugging mode run ```ps -uf | grep debug``` and use 'kill -9' to kill all processes shwon.

### Modules and Addons
**Modules** live in ```modules/*.sh``` and are bashbot functions factored out in seperate files, gouped by functionality. Main reason for creating modules was
to keep 'bashbot.sh' small, while extending functionality. In addition not every functionality is needed by a bot, so you can
disable modules by removing them, e.g. rename the respective module files to 'module.sh.off'.

Modules must use only functions provided by 'bahsbot.sh' or the module itself, no depedencies to other modules or addons must exist.
If a module function is called from 'bashbot.sh', bashbot must work if the module is disabled, so the use of ```_is_function``` and
```_execute_if_function``` is mandatory.

**Addons** live in ```addons/*.sh.dist``` and are disabled by default. To activate an addon remove '.dist' from the filename, e.g.
```cp addons/example.sh.dist addons/example.sh```. Addons must register to BASHBOT_EVENTS at startup, e.g. to call a function everytime a message is recieved.
Registering to EVENTS is similar on how 'commands.sh' is executed, but more flexible and one major difference:
**Addons are executed in the context of the main script**, while 'commands.sh' is executed as a seperate process.

This is why event functions are time critical and must return as fast as possible. Spawn actions as a seperate process or function with '&', e.g.
send a message as respone from an addon: ```send_message "${CHAT[ID]}" "Message to send ..." &```.

#### Bashbot Events
Addons must register functions to bashbot events at startup by providing their name and a callback function.
If an event occours each registered function for the event is called.

Events run in the same context as the main bashbot loop, so variables set here are persistent as long bashbot is running.

Note: For the same reason event function MUST return imideatly!  Time consuming tasks must be run in background or as a subshell, e.g. "long running &"

Availible events:

* BASHBOT_EVENT_INLINE		an inline query is received
* BASHBOT_EVENT_MESSAGE		any type of message is received
* BASHBOT_EVENT_TEXT		a message containing text is recieved
* BASHBOT_EVENT_CMD		a command is recieved (fist word starts with /)
* BASHBOT_EVENT_REPLYTO		a reply to a message is received
* BASHBOT_EVENT_FORWARD		a forwarded message is received
* BASHBOT_EVENT_CONTACT		a contact is received
* BASHBOT_EVENT_LOCATION	a location or a venue is received
* BASHBOT_EVENT_FILE		a file is received

*usage*: BASHBOT_EVENT_xxx[ "uniqe-name" ]="callback"

"unique-name" can be every alphanumeric string incl. '-' and '_'. Per convention it is the name of the addon followed by an internal identyfier.

"callback" is called as ```callback "event" "unique-name" "debug"``` where "event" is the event name in lower case, e.g. inline, message ... ,
and "unique-name" is the key you provided when registering the event. 

*Example:* Register a function to echo to any Text send to the bot
```bash
# register callback:
BASHBOT_EVENT_TEXT["example_1"]="example_echo"

# function called if a text is received
example_echo() {
	local event="$1" key="$2"
	# all availible bashbot functions and variables can be used
	send_normal_message "${CHAT[ID]}" "Event: ${event} Key: ${key} : ${MESSAGE[0]}" & # note the &!
}
```
* BAHSBOT_EVENT_TIMER		is executed every minute and can be used in 3 variants: oneshot, every minute, every X minutes.

Registering to BASHBOT_EVENT_TIMER works isimilar as for message events, but you must add a timing argument to the index name.
Timer counts minutes since last (re)start in 'EVENT_TIMER', next execution of 'x' is sceduled if ```EVENT_TIMER % x``` is '0' (true).
This means if you register a every 5 Minutes event its first execution may < 5 Minutes after registration. 

*usage:* BAHSBOT_EVENT_TIMER[ "name" , "time" ], where time is:

    * 0	ignored
    * 1	execute every minute
    * x	execute every x minutes
    * -x execute ONCE in x minutes*\**

*\* if you really want "in x minutes" you must use ```-(EVENT_TIMER+x)```* 

*Examples:*
```bash
# register callback:
BAHSBOT_EVENT_TIMER["example_every","1"]="example_everymin"

# function called every minute
example_everymin() {
	# timer events has no chat id, so send to yourself
	send_normal_message "$(< "${BOTADMIN})" "$(date)" & # note the &!
}

# register other callback:
BAHSBOT_EVENT_TIMER["example_every5","5"]="example_every5min"

# execute once in the next 10 minutes
BAHSBOT_EVENT_TIMER["example_10min","-10"]="example_in10min"

# once in 10 minutes
BAHSBOT_EVENT_TIMER["example_10min","$(( (EVENT_TIMER+10) * -1 ))"]="example_in10min"

```

----

#### Create a stripped down Version of your Bot
Currently bashbot is more a bot development environment than a bot, containing examples, developer scripts, modules, documentation and more.
You don't need all these files after you're finished with your cool new bot.

Let's create a stripped down version:

- delete all modules you do not need from 'modules', e.g. 'modules/inline.sh' if you don't use inline queries
- delete not needed standard commands and messages from 'commands.sh'
- delete not needed commands and functions from 'mycommands.sh'
- run ```dev/make-standalone.sh``` to create a a stripped down version of your bo

Now have a look at the directory 'standalone', here you find the files 'bashbot.sh' and 'commands.sh' containing everything to run your bot.
[Download make-standalone.sh](https://github.com/topkecleon/telegram-bot-bash/blob/master/dev/make-standalone.sh) from github.

### Setup your develop environment

1. install git, install [shellcheck](5_practice.md#Test-your-Bot-with-shellcheck)
2. setup your [environment for UTF-8](4_expert.md#Setting-up-your-Environment)
3. clone your bashbot fork to a new directory ```git clone https://github.com/<YOURNAME>/telegram-bot-bash.git```, replace ```<YOURNAME>``` with your username on github
4. create and change to your develop branch ```git checkout -b <YOURBRANCH>```, replace ```<YOURBRANCH>``` with the name you want to name it, e.g. 'develop'
5. give your (dev) fork a new version tag: ```git tag vx.xx```(optional) 
6. setup github hooks by running ```dev/install-hooks.sh``` (optional)

#### Test, Add, Push changes
A typical bashbot develop loop looks as follow:

1. start developing - *change, copy, edit bashbot files ...*
2. after changing a bash sript: ```shellcheck -x scipt.sh```
3. ```dev/all-tests.sh``` - *in case if errors back to 2.*
4. ```dev/git-add.sh``` - *check for changed files, update version string, run git add*
5. ```git commit -m "COMMIT MESSAGE"; git push```


**If you setup your dev environment with hooks and use the scripts above, versioning, addding and testing is done automatically.**

#### common commands
We state bashbot is a bash only bot, but this is not true. bashbot is a bash script using bash features PLUS external commands.
Usually bash is used in a unix/linux environment where many (GNU) commands are availible, but if commands are missing, bashbot may not work.

To avoid this and make bashbot working on as many platforms as possible - from embedded linux to mainframe - I recommed to restrict
ourself to the common commands provided by bash and coreutils/busybox/toybox.
See [Bash Builtins](https://www.gnu.org/software/bash/manual/html_node/Shell-Builtin-Commands.html),
[coreutils](https://en.wikipedia.org/wiki/List_of_GNU_Core_Utilities_commands),
[busybox](https://en.wikipedia.org/wiki/BusyBox#Commands) and [toybox](https://landley.net/toybox/help.html)

Availible commands in bash, coreutils, busybox and toybox. Do you find curl on the list?
```bash
	.*, [*, [[*, basename, break, builtin*, bzcat, caller*, cat, cd*, chattr,
	chgrp, chmod, chown, clear, command*, continue *, cp, cut, date, declare*,
	dc, dd, df, diff, dirname, du, echo*, eval*, exec*, exit *, expr*, find,
	fuser, getopt*, grep, hash*, head, hexdump, id, kill, killall, last, length,
	less, let*, ln, local*, logname, ls, lsattr, lsmod, man, mapfile*, md5sum, mkdir,
	mkfifo, mknod, more, mv, nice, nohup, passwd, patch, printf*, ps, pwd*, read*,
	readarray*, readonly* return*, rm, rmdir, sed, seq, sha1sum, shift*, sleep,
	source*, sort, split, stat, strings, su, sync, tail, tar, tee, test,
	time, times*, timeout, touch, tr, trap*, true, umask*, usleep, uudecode,
	uuencode, wc, wget, which, who, whoami, xargs, yes
```
commands marked with \* are bash builtins, all others are external programms. Calling an external programm is more expensive then using bulitins
or using an internal replacement. Here are some examples of internal replacement for external commands:
```bash
HOST="$(hostname)" -> HOST="$HOSTNAME"

seq 1 100 -> {0..100}

data="$(cat file)" -> data="$(<"file")"

DIR="$(dirname $0) -> DIR=""${0%/*}/""

IAM="($basename $0)" -> IAM="${0##*/}*

VAR="$(( 1 + 2 ))" -> (( var=1+2 ))

INDEX="$(( ${INDEX} + 1 ))" -> (( INDEX++ ))

```
For more examples see [Pure bash bible](https://github.com/dylanaraps/pure-bash-bible)

#### Prepare a new version
After some development it may time to create a new version for the users. a new version can be in sub version upgrade, e.g. for fixes and smaller additions or
a new release version for new features. To mark a new version use ```git tag NEWVERSION``` and run ```dev/version.sh``` to update all version strings.

Usually I start with pre versions and when everything looks good I push out a release candidate (rc) and finally the new version.
```
 v0.x-devx -> v0.x-prex -> v0.x-rc -> v0.x  ... 0.x+1-dev ...
```

If you release a new Version run ```dev/make-distribution.sh``` to create the zip and tar.gz archives in the dist directory and attach them to the github release. Do not forget to delete directory dist afterwards.

#### Versioning

Bashbot is tagged with version numbers. If you start a new development cycle you can tag your fork with a version higher than the current version.
E.g. if you fork 'v0.60' the next develop version should tagged as ```git tag "v0.61-dev"``` for fixes or ```git tag "v0.70-dev"``` for new features.

To get the current version name of your develepment fork run ```git describe --tags```. The output looks like ```v0.70-dev-6-g3fb7796``` where your version tag is followed by the number of commits since you tag your branch and followed by the latest commit hash. see also [comments in version.sh](../dev/version.sh)

To update the Version Number in files run ```dev/version.sh files```, it will update the line '#### $$VERSION$$ ###' in all files to the current version name.
To update version in all files run 'dev/version.sh' without parameter.


#### Shellcheck

For a shell script running as a service it's important to be paranoid about quoting, globbing and other common problems. So it's a must to run shellchek on all shell scripts before you commit a change. this is automated by a git hook activated in Setup step 6.

To run shellcheck for a single script run ```shellcheck -x script.sh```, to check all schripts run ```dev/hooks/pre-commit.sh```.


### bashbot tests
Starting with version 0.70 bashbot has a test suite. To start testsuite run ```dev/all-tests.sh```. all-tests.sh will return 'SUCCESS' only if all tests pass.

#### enabling / disabling tests

All tests are placed in the directory  ```test```. To disable a test remove the execute flag from the '*-test.sh' script, to (re)enable a test make the script executable again.


#### creating new tests
To create a new test run ```test/ADD-test-new.sh``` and answer the questions, it will create the usually needed files and dirs:

Each test consists of a script script named after ```p-name-test.sh``` *(where p is test pass 'a-z' and name the name
of your test)* and an optional dir ```p-name-test/``` *(script name minus '.sh')* for additional files.

Tests with no dependency to other tests will run in pass 'a', tests which need an initialized bahsbot environment must run in pass 'd' or later. 
A temporary test environment is created when 'ALL-tests.sh' starts and deleted after all tests are finished.

The file ```ALL-tests.inc.sh``` must be included from all tests and provide the test environment as shell variables:
```bash
# Test Evironment
 TESTME="$(basename "$0")"
 DIRME="$(pwd)"
 TESTDIR="$1"
 LOGFILE="${TESTDIR}/${TESTME}.log"
 REFDIR="${TESTME%.sh}"
 TESTNAME="${REFDIR//-/ }"

# common filenames
 TOKENFILE="token"
 ACLFILE="botacl"
 COUNTFILE="count"
 ADMINFILE="botadmin"
 DATADIR="data-bot-bash"

# SUCCESS NOSUCCES -> echo "${SUCCESS}" or echo "${NOSUCCESS}" 
 SUCCESS="   OK"
 NOSUCCESS="   FAILED!"

# default input, reference and output files
 INPUTFILE="${DIRME}/${REFDIR}/${REFDIR}.input"
 REFFILE="${DIRME}/${REFDIR}/${REFDIR}.result"
 OUTPUTFILE="${TESTDIR}/${REFDIR}.out"
```

Example test
```bash
#!/usr/bin/env bash
# file: b-example-test.sh

# include common functions and definitions
# shellcheck source=test/ALL-tests.inc.sh
source "./ALL-tests.inc.sh"

if [ -f "${TESTDIR}/bashbot.sh" ]; then
	echo "${SUCCESS} bashbot.sh exist!"
	exit 0
else
	echo "${NOSUCCESS} ${TESTDIR}/bashbot.sh missing!"
	exit 1
fi
```

#### [Prev Function Reference](6_reference.md)

#### $$VERSION$$ v0.91-1-gdb03e23

