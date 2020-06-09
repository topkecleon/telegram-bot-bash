#### [Home](../README.md)

## Notes for bashbot developers
This section is about help and best practices for new bashbot developers. The main focus on is creating new versions of bashbot, modules and addons, not on develop your individual bot. Nevertheless the information provided here should help your bot development also.

If you want to provide fixes or new features [fork bashbot on githup](https://help.github.com/en/articles/fork-a-repo) and provide changes as [pull request on github](https://help.github.com/en/articles/creating-a-pull-request).

### Debugging Bashbot
Usually all bashbot output is discarded.
If you want to get error messages (and more) start bashbot  ```./bashbot.sh startbot debug```.
you can the change the level of verbosity of the debug argument: 

```
	"debug"		all output is redirected to "DEBUG.log", in addtion every incomming message is logged in "MESSAGE.log" and "INLINE.log"
	"xdebug"	same as debug plus set bash option '-x' to log any executed command in "DEBUG.log"

	use the command tail to watch your bot live, e.g. "tail -f DEBUG.log", to obtain more information place set -x; set +x in your code.
```

```
	sometimes its useful to watch the bot live in the terminal:

	"debugx"	debug output and errors are sent to terminal
        "xdebugx"       same as debugx plus set bash option '-x' to show any executed command

```


### Modules and Addons
**Modules** resides in ```modules/*.sh``` and are colletions of optional bashbot functions grouped by functionality. Main reason for creating modules was
to keep 'bashbot.sh' small, while extending functionality. In addition not every funtion is needed by all bots, so you can
disable modules, e.g. by rename the respective module file to 'module.sh.off'.

Modules must use functions provided by 'bahsbot.sh' or the module itself and sould not depend on other modules or addons.
The only mandatory module is 'module/sendMessage.sh'.

If a not mandatory module is used in 'bashbot.sh' or 'commands.sh', the use of ```_is_function``` or
```_execute_if_function``` is mandatory to catch absense of the module.

**Addons** resides in ```addons/*.sh.dist``` and are not endabled by default. To activate an addon rename it to end with '.sh', e.g. by
```cp addons/example.sh.dist addons/example.sh```. 

Addons must register themself to BASHBOT_EVENTS at startup, e.g. to call a function everytime a message is recieved.
Addons works similar as 'commands.sh' and 'mycommands.sh' but are much more flexible on when functions/commands are triggered.

Another major difference is: **Addons are executed in the context of the main script**, while 'commands.sh' and 'macommands.sh' are executed as a seperate process.
This is why event functions are time critical and must return as fast as possible.

#### Bashbot Events
Addons must register functions to bashbot events by providing their name, and internal identifier and a callback function.
If an event occours each registered function for the event is called.

Registered functions run in the same process as bashbot, not as a sub process, so variables set here are persistent as long bashbot is running.

Note: For the same reason event function MUST return immediately! Time consuming tasks must be run as a background process, e.g. "long running &"

##### MESSAGE events (all iQuery and/or Message variables are avalible):

* BASHBOT_EVENT_INLINE		an inline query is received

* BASHBOT_EVENT_MESSAGE		any of the following message types is received
    * BASHBOT_EVENT_TEXT	a message containing text is recieved
    * BASHBOT_EVENT_CMD		a message containing a command is recieved (starts with /)
    * BASHBOT_EVENT_REPLYTO	a reply to a message is received
    * BASHBOT_EVENT_FORWARD	a forwarded message is received
    * BASHBOT_EVENT_CONTACT	a contact is received
    * BASHBOT_EVENT_LOCATION	a location or a venue is received
    * BASHBOT_EVENT_FILE	a file is received

*usage*: BASHBOT_EVENT_xxx[ "unique-name" ]="callback"

"unique-name" can be every alphanumeric string incl. '-' and '_'. Per convention the name of the addon followed by an internal identyfier should be used.

"callback" is called as the the parameters "event" "unique-name" "debug", where "event" is the event name in lower case, e.g. inline, messagei, text ... ,
and "unique-name" is the name provided when registering the event. 

*Example:* Register a function to echo to any Text sent to the bot
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

##### Other types of events

* BAHSBOT_EVENT_TIMER		executed every minute and can be used in 3 variants: oneshot, once a minute, every X minutes.

Registering to BASHBOT_EVENT_TIMER works similar as for message events, but you must add a timing argument to the name.
EVENT_TIMER is triggered every 60s and waits until the current running command is finished, so ist not excactly every
minute, but once a minute.

Every time EVENT_TIMER is triggered the variable "EVENT_TIMER" is increased. each callback is executed if ```EVENT_TIMER % time``` is '0' (true).
This means if you register an every 5 minutes callback first execution may < 5 Minutes, all subsequent executions are once every 5. Minute.

*usage:* BAHSBOT_EVENT_TIMER[ "name" , "time" ], where time is:

    * 0	ignored
    * 1	execute once every minute
    * x	execute every x minutes
    * -x execute ONCE in (next) x minutes *

*\* if you really want "in x minutes" you must use ```-(EVENT_TIMER+x)```* 

*Example:*
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

* BASHBOT_EVENT_SEND	is exceuted if data is send or uploaded to Telegram server

In contrast to other events, BASHBOT_EVENT_SEND is excecuted in a subshell, so there is no need to spawn
a background process for longer running commands and changes to variables are not persistent!

BASHBOT_EVENT_SEND is for logging purposes, you must not send messages while processing this event.
To avoid wrong use of EVENT_SEND, e.g. fork bomb, event processing is suspended if recursion is detected.

*usage*: BASHBOT_EVENT_SEND[ "unique-name" ]="callback"

"callback" is called with paramter "send"  or "upload", followed by the arguments used for 'sendJson' or 'upload' functions.

*Example:*
```bash
# register callback:
BAHSBOT_EVENT_SEND["example_log","1"]="example_log"
EXAMPLE_LOG="${BASHBOT_ETC:-.}/addons/${EXAMPLE_ME}.log"

# Note: do not call any send message functions from EVENT_SEND!
example_log(){
	local send="$1"; shift
	echo "$(date): Type: ${send} Args: $*" >>"${EXAMPLE_LOG}"
}

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

#### $$VERSION$$ v0.96-dev-7-g0153928

