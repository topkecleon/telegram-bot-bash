#### [Home](../README.md)
## Expert Use

### Handling UTF-8 character sets
UTF-8 is a variable length encoding of Unicode. UTF-8 is recommended as the default encoding in JSON, XML and HTML, also Telegram make use of it.

The first 128 characters are regular ASCII, so it's a superset of and compatible with ASCII environments. The next 1,920 characters need
two bytes for encoding and covers almost all `Latin` alphabets, also `Greek`, `Cyrillic`,
`Hebrew`, `Arabic` and more. See [Wikipedia](https://en.wikipedia.org/wiki/UTF-8) for more details.

#### Setting up your Environment
In general `bash` and `GNU` utitities are UTF-8 aware if you to setup your environment
and your scripts accordingly (_locale setting_):

1. Your Terminal and Editor must support UTF-8:
   Set Terminal and Editor locale to UTF-8, eg. in `Settings/Configuration` select UTF-8 (Unicode) as Charset.

2. Set `Shell` locale environment to UTF-8 in your  `.profile` and your scripts. The usual settings are:

```bash
export 'LC_ALL=C.UTF-8'
export 'LANG=C.UTF-8'
export 'LANGUAGE=C.UTF-8'
```
   If you use other languages, eg. german or US english, change the shell settings to:
```bash
export 'LC_ALL=de_DE.UTF-8'
export 'LANG=de_DE.UTF-8'
export 'LANGUAGE=de_DE.UTF-8'
```
```bash
export 'LC_ALL=en_US.UTF-8'
export 'LANG=de_en_US.UTF-8'
export 'LANGUAGE=en_US.UTF-8'
```
3. make sure your bot scripts use the correct settings, eg. include the lines above at the beginning of your scripts


#### Known locale pitfalls

##### Missing C locale

Even required by POSIX standard some systems (e.g. Manjaro Linux) has `C` and `C.UTF-8` locale not installed.
If bashbot display a warning about missing locale you must install `C` and `C.UTF-8` locale.

If you don't know what locales are installed on your sytsem use `locale -a` to display them.
[Gentoo Wiki](https://wiki.gentoo.org/wiki/UTF-8).


##### Character classes

In ASCII times it was clear `[:lower:]` and `[a-z]` means ONLY the lowercase letters `[abcd...xyz]`.
With the introduction of locales, character classes and ranges now contain all characters fitting the class definition.

This means with a Latin UTF-8 locale `[:lower:]` and `[a-z]` contains also e.g. `á ø ü` etc,
see [Unicode Latin lowercase letters](https://www.fileformat.info/info/unicode/category/Ll/list.htm)

If that's ok for your script you're fine, but many scripts rely on the idea of ASCII ranges and may produce undesired results.

```bash
# try with different locales ...
# new bash to not change your current locale!
bash
lower="abcö"

echo "$LC_ALL $LC_COLLATE"
[[ "$lower" =~ ^[a-z]+$ ]] && echo "Ups, $lower is all lower case!" || echo "OK, not lower case"

LC_ALL="en_US.UTF-8"
[[ "$lower" =~ ^[a-z]+$ ]] && echo "Ups, $lower is all lower case!" || echo "OK, not lower case"

LC_ALL="C"
[[ "$lower" =~ ^[a-z]+$ ]] && echo "Ups, $lower is all lower case!" || echo "OK, not lower case"
```

There are three solutions:

1. list exactly the characters you want: `[abcd...]`
2. instruct bash to use `C` locale for ranges: `shopt -s "globasciiranges"`
3. use `LC_COLLATE` to change behavior of all programs: `export LC_COLLATE=C`


To work independent of language and bash settings bashbot uses solution 1.: Own "ranges" if an exact match is mandatory:

```bash
azazaz='abcdefghijklmnopqrstuvwxyz'	# a-z   :lower:
AZAZAZ='ABCDEFGHIJKLMNOPQRSTUVWXYZ'	# A-Z   :upper:
o9o9o9='0123456789'			# 0-9   :digit:
azAZaz="${azazaz}${AZAZAZ}"	# a-zA-Z	:alpha:
azAZo9="${azAZaz}${o9o9o9}"	# a-zA-z0-9	:alnum:

# e.g. characters allowed for key in key/value pairs
JSSH_KEYOK="[-${azAZo9},._]"
```

#### Bashbot UTF-8 Support
Bashbot handles all messages transparently, regardless of the charset in use. The only exception is when converting from JSON data to strings.

Telegram use JSON to send / receive data. JSON encodes strings as follow: Characters not ASCII *(>127)* are escaped as sequences of `\uxxxx` to be regular ASCII. In addition multibyte characters, *e.g. Emoticons or Arabic characters*, are send in double byte UTF-16 notation.
The Emoticons ` 😁 😘 ❤️ 😊 👍 ` are encoded as: ` \uD83D\uDE01 \uD83D\uDE18 \u2764\uFE0F \uD83D\uDE0A \uD83D\uDC4D `

**This "mixed" JSON encoding needs special handling and can not decoded from** `echo -e` or `printf '%s\\n'`

Bashbot uses an internal, pure bash implementation which is well tested now, even there may some corner cases*.


### Run as other user or system service
Bashbot is designed to run manually by the user who installed it. Nevertheless it's possible to run it by an other user-ID, as a system service or scheduled from cron. This is recommended if you want to bashbot run as a service.

Setup the environment for the user you want to run bashbot and enter desired username, e.g. nobody :
```bash
sudo ./bashbot.sh init
```

Edit the file `bashbot.rc` and change the following lines to fit your configuration:
```bash
#######################
# Configuration Section

# edit the next line to fit the user you want to run bashbot, e.g. nobody:
runas="nobody" 

# uncomment one of the following lines 
# runcmd="su $runas -s /bin/bash -c "      # runasuser with su
# runcmd="runuser $runas -s /bin/bash -c " # runasuser with runuser

# edit the values of the following lines to fit your config:
start="/usr/local/telegram-bot-bash/bashbot.sh"	# location of your bashbot.sh script
name=''   # your bot name as given to botfather, e.g. mysomething_bot

# END Configuration
#######################
```
From now on use 'bashbot.rc' to manage your bot: 
```bash
sudo ./bashbot.rc start
```
Type `ps -ef | grep bashbot` to verify your Bot is running as the desired user.

If your  Bot is started by 'bashbot.rc', you must use 'bashbot.rc' also to manage your Bot! The following commands are available:
```bash
sudo ./bashbot.rc start
sudo ./bashbot.rc stop
sudo ./bashbot.rc status
sudo ./bashbot.rc suspendback
sudo ./bashbot.rc resumeback
sudo ./bashbot.rc killback
```
To change back the environment to your user-ID run `sudo ./bashbot.sh init` again and enter your user name.

To use bashbot as a system service include a working `bashbot.rc` in your init system (systemd, /etc/init.d).

### Schedule bashbot from Cron
An example crontab is provided in `examples/bashbot.cron`.

- If you are running bashbot with your user-ID, copy the examples lines to your crontab and remove username `nobody`.
- if you run bashbot as an other user or a system service edit `examples/bashbot.cron` to fit your needs and replace username `nobody` with the username you want to run bashbot. Copy the modified file to `/etc/cron.d/bashbot`


### Use bashbot from CLI and scripts
You can use bashbot to send *messages*, *locations*, *venues*, *pictures* etc. from command line and scripts
by sourcing it:

*usage:* .  bashbot.sh source

Before sourcing 'bashbot.sh' for interactive and script use, you should export and set BASHBOT_HOME to bashbots installation dir,
e.g. '/usr/local/telegram-bot-bash'. see [Bashbot Environment](#Bashbot-environment)

**Note:** *If you don't set BASHBOT_HOME bashbot will use the actual directory as NEW home directory
which means it will create all needed files and ask for bot token and botadmin if you are not in the real bot home!*

*Examples:*
```bash
# if you are in the bashbot directory
.  bashbot.sh source

# same, but more readable in scripts
source ./bashbot.sh source

# use bashbot config in BASHBOT_HOME from any directory
export BASHBOT_HOME=/usr/local/telegram-bot-bash
source ${BASHBOT_HOME}/bashbot.sh source

# use / create new config in current directory
unset  BASHBOT_HOME
source /path/to/bashbot.sh source

```

#### Environment variable exported from bashbot
If you have sourced 'bashbot.sh' you have the following bashot internal variables available:
```bash
COMMANDS	# default: ./commands.sh"
MODULEDIR	# default: ./modules"
BOTACL		# default: ./botacl"
TMPDIR		# default: ./data-bot-bash"
COUNTFILE	# default: ./count" (jsonDB file)

BOTTOKEN	# your token read from bot config
URL		# telegram api URL - default: https://api.telegram.org/bot${BOTTOKEN}"
```

#### Interactive use
For testing your setup or sending messages yourself its possible to  use bashbot functions from command line:
```bash
# are we running bash?
echo $SHELL
/bin/bash

# source bashbot.sh WITHOUT BASHBOT_HOME set
source ./bashbot.sh source

# output bashbot internal variables
echo $COMMANDS $MODULEDIR  $BOTACL $TMPDIR $COUNTFILE
./commands.sh ./modules  ./botacl ./data-bot-bash ./count


# source bashbot.sh WITH BASHBOT_HOME set
export BASHBOT_HOME=/usr/local/telegram-bot-bash
source ./bashbot.sh source

# output bashbot internal variables
echo $COMMANDS $MODULEDIR $BOTACL $TMPDIR $COUNTFILE
/usr/local/telegram-bot-bash/commands.sh /usr/local/telegram-bot-bash/modules 
/usr/local/telegram-bot-bash/botacl /usr/local/telegram-bot-bash/data-bot-bash
/usr/local/telegram-bot-bash/count

``` 
After sourcing you can use bashbot functions to send Messages, Locations, Pictures etc. to any Telegram
User or Chat you are in. See [Send Messages](2_usage.md#sending-messages).

*Examples:* You can test this by sending messages to yourself:
```bash
# first Hello World
send_normal_message "$(getConfigKey "botadmin")"  "Hello World! This is my first message"

# now with some markdown and HTML
send_markdown_message 	"$(getConfigKey "botadmin")"  '*Hello World!* _This is my first markdown message_'
send_html_message	"$(getConfigKey "botadmin")"  '<b>Hello World!</b> <em>This is my first HTML message</em>'
send_keyboard "$(getConfigKey "botadmin")"  'Do you like it?' '[ "Yep" , "No" ]'
```
Now something more useful ...
```bash
# sending output from system commands:
send_normal_message	"$(getConfigKey "botadmin")"  "$(date)"

send_normal_message	"$(getConfigKey "botadmin")"  "$(uptime)"

send_normal_message       "$(getConfigKey "botadmin")"  '`'$(free)'`'

# same but markdown style 'code' (monospaced)
send_markdown_message	"$(getConfigKey "botadmin")"  "\`$(free)\`"
```


### Bashbot environment
This section describe how you can customize bashbot to your needs by setting environment variables. 


#### Change file locations
In standard setup bashbot is self containing, this means you can place 'telegram-bot-bash' any location
and run it from there. All files - program, config, data etc - will reside in 'telegram-bot-bash'.

If you want to have other locations for config, data etc, define and export the following environment variables.
**Note: all specified directories and files must exist or running 'bashbot.sh' will fail.**

##### BASHBOT_ETC
Location of the files `commands.sh`, `mycommands.sh`, `botconfig.jssh`, `botacl` ...
```bash
  unset  BASHBOT_ETC     # keep in telegram-bot-bash (default)
  export BASHBOT_ETC ""  # keep in telegram-bot-bash

  export BASHBOT_ETC "/etc/bashbot"  # Unix-like config location

  export BASHBOT_ETC "/etc/bashbot/bot1"  # multibot configuration bot 1
  export BASHBOT_ETC "/etc/bashbot/bot2"  # multibot configuration bot 2
```

 e.g. /etc/bashbot

##### BASHBOT_VAR
Location of runtime data `data-bot-bash`, `count.jssh` 
```bash
  unset  BASHBOT_VAR     # keep in telegram-bot-bash (default)
  export BASHBOT_VAR ""  # keep in telegram-bot-bash

  export BASHBOT_VAR "/var/spool/bashbot"  # Unix-like config location

  export BASHBOT_VAR "/var/spool/bashbot/bot1"  # multibot configuration bot 1
  export BASHBOT_VAR "/var/spool/bashbot/bot2"  # multibot configuration bot 2
```

##### BASHBOT_JSONSH
Full path to JSON.sh script, default: './JSON.sh/JSON.sh', must end with '/JSON.sh'.
```bash
  unset  BASHBOT_JSONSH     # telegram-bot-bash/JSON.sh/JSON.sh (default)
  export BASHBOT_JSONSH ""  # telegram-bot-bash/JSON.sh/JSON.sh

  export BASHBOT_JSONSH "/usr/local/bin/JSON.sh"  # installed in /usr/local/bin

```

##### BASHBOT_HOME
Set bashbot home directory, where bashot will look for additional files.
If BASHBOT_ETC, BASHBOT_VAR or BASHBOT_JSONSH are set the have precedence over BASHBOT_HOME.

This is also useful if you want to force bashbot to always use full pathnames instead of relative ones.
```bash
  unset  BASHBOT_HOME     # autodetection (default)
  export BASHBOT_HOME ""  # autodetection

  export BASHBOT_HOME "/usr/local/telegram-bot-bash"	# Unix-like location
  export BASHBOT_HOME "/usr/local/bin"	# Note: you MUST set ETC, VAR and JSONSH to other locations to make this work!
```

----

#### Change config values

##### BASHBOT_URL
Uses given URL instead of official Telegram API URL, useful if you have your own telegram server or for testing.

```bash
  unset  BASHBOT_URL       # use Telegram URL https://api.telegram.org/bot<token> (default)

  export BASHBOT_URL ""    # use use Telegram https://api.telegram.org/bot<token>

  export BASHBOT_URL "https://my.url.com/bot" # use your URL https://my.url.com/bot<token>

```

##### BASHBOT_TOKEN
If BASHBOT_TOKEN is set, bashbot assumes you know what you are doing and skips environment validation and
uses the value of BASHBOT_TOKEN as bot token.

I recommend to run 'bashbot.sh init' at least one time without BASHBOT_TOKEN set to validate and setup
the environment. Afterwards you can delete the token file and provide the bot token in BASHBOT_TOKEN.

##### BASHBOT_CURL_ARGS
The value of BASHBOT_CURL_ARGS is passed to every curl execution.
```bash
  # use socks gateway on localhost
  export BASHBOT_CURL_ARGS="--socks5-hostname localhost"
```

##### BASHBOT_CURL
If BASHBOT_CURL is not set your systems default curl is used. If you want to use an alternative curl executable
set BASHBOT_CURL to point to it.
```bash
  # use curl from /usr/local/bin
  export BASHBOT_CURL="/usr/local/bin/mycurl"
```

##### BASHBOT_WGET
Bashbot uses `curl` to communicate with telegram server. if `curl` is not available `wget` is used.
If 'BASHBOT_WGET' is set to any value (not undefined or not empty) wget is used even is curl is available.  
```bash
  unset  BASHBOT_WGET       # use curl (default)
  export BASHBOT_WGET ""    # use curl 

  export BASHBOT_WGET "yes" # use wget
  export BASHBOT_WGET "no"  # use wget!

```

##### BASHBOT_TIMEOUT
Bashbot uses a default timeout of 20 seconds for curl and wget. If you want a different timeout, set
BASHBOT_TIMEOUT to a numeric value between 1 and 999. Any non numeric or negative value is ignored. 
```bash
  # set timeout to 100 seconds
  export BASHBOT_TIMEOUT="100"

  # 100s is not a numbers
  export BASHBOT_TIMEOUT="100s" # wrong, default timeout is used

  # -100 is not between 1 and 999s
  export BASHBOT_TIMEOUT="-100" # wrong, default timeout is used
```

##### BASHBOT_SLEEP
Instead of polling permanently or with a fixed delay, bashbot offers a simple adaptive polling.
If messages are received bashbot polls with no delay. If no messages are available bashbot add 100ms delay
for every poll until the maximum of BASHBOT_SLEEP ms.
```bash
  unset  BASHBOT_SLEEP       # 5000ms (default)
  export BASHBOT_SLEEP ""    # 5000ms 

  export BASHBOT_SLEEP "1000"     # 1s maximum sleep 
  export BASHBOT_SLEEP "10000"    # 10s maximum sleep
  export BASHBOT_SLEEP "1"        # values < 1000 disables sleep (not recommended) 
  
```

#### Tested configs as of v0.90 release

##### simple Unix like config, for one bot. bashbot is installed in '/usr/local/telegram-bot-bash'
```bash
  # Note: all dirs and files must exist!
  export BASHBOT_ETC "/etc/bashbot"
  export BASHBOT_VAR "/var/spool/bashbot"

  /usr/local/telegram-bot-bash/bashbot.sh start
```

##### Unix like config for one bot. bashbot.sh is installed in '/usr/bin'
```bash
  # Note: all dirs and files must exist!
  export BASHBOT_ETC "/etc/bashbot"
  export BASHBOT_VAR "/var/spool/bashbot"
  export BASHBOT_JSONSH "/var/spool/bashbot"

  /usr/local/bin/bashbot.sh start
```

##### simple multibot config, everything is kept inside 'telegram-bot-bash' dir
```bash
  # config for running Bot 1
  # Note: all dirs and files must exist!
  export BASHBOT_ETC "./mybot1"
  export BASHBOT_VAR "./mybot1"

  /usr/local/telegram-bot-bash/bashbot.sh start
```

```bash
  # config for running Bot 2
  # Note: all dirs and files must exist!
  export BASHBOT_ETC "./mybot2"
  export BASHBOT_VAR "./mybot2"

  /usr/local/telegram-bot-bash/bashbot.sh start
```

#### [Prev Advanced Use](3_advanced.md)
#### [Next Best Practice](5_practice.md)

#### $$VERSION$$ v1.51-0-g6e66a28

