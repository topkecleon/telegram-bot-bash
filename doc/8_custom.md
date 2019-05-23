#### [Home](../README.md)

## Expert use

### Use bashbot from CLI and scripts
You can use bashbot to send messages, locations, venues, pictures etc from command line and scripts.

For interactive use and script use should set and export BASHBOT_HOME to bashbots installation dir,
e.g. '/usr/local/telegram-bot-bash'. see [Bashbot environemnt](#Bashbot-environment)

**Note:** If you don't set BASHBOT_HOME bashbot is expecting you are in the installation directory
of bashbot and will use relative pathnames to access ressources.

#### Environment variable exported from bashbot
If you have sourced 'bashbot.sh' you have the following bashot internal variables availible to
locate varoius ressources:
```bash
COMMANDS	# default ./commands.sh"
MODULEDIR	# default ./modules"
TOKENFILE	# default ./token"
BOTADMIN	# default ./botadmin"
BOTACL		# default ./botacl"
TMPDIR		# default ./data-bot-bash"
COUNTFILE	# default ./count"

BOTTOKEN	# default content of ${TOKENFILE}
URL		# telegram api URL -default https://api.telegram.org/bot${BOTTOKEN}"
```

#### Interacctive use
For Test purposes you can use bashbot functions from bash command line after setting BASHBOT_HOME
and sourcing 'bashbot.sh'.
```bash
# are we running bash?
echo $SHELL
/bin/bash

# source bashbot.sh WITHOUT BASHBOT_HOME set
./bashbot.sh source


# output bashbot internal variables
echo $COMMANDS $MODULEDIR $TOKENFILE $BOTADMIN $BOTACL $TMPDIR $COUNTFILE
./commands.sh ./modules ./token ./botadmin ./botacl ./data-bot-bash ./count

# source bashbot.sh WITH BASHBOT_HOME set
export BASHBOT_HOME=/usr/local/telegram-bot-bash
source ./bashbot.sh source

# output bashbot internal variables
echo $COMMANDS $MODULEDIR $TOKENFILE $BOTADMIN $BOTACL $TMPDIR $COUNTFILE
/usr/local/telegram-bot-bash/commands.sh /usr/local/telegram-bot-bash/modules /usr/local/telegram-bot-bash/token
/usr/local/telegram-bot-bash/botadmin /usr/local/telegram-bot-bash/botacl /usr/local/telegram-bot-bash/data-bot-bash
/usr/local/telegram-bot-bash/count

``` 
Now you can use the bashot 'send_xxx' functions to send Message, Locations, Pictures etc. to any Telegram
User or Chat you are in. See [Send Messages](2_usage.md#sending-messages).

*Examples:* You can test this by sending messages to yourself:
```bash
# fist Hello World
send_normal_message "$(< $BOTADMIN)"  "Hello World! This is my first message"

# now with some markdown and  HTML
send_markdown_message 	"$(< $BOTADMIN)"  '*Hello World!* _This is my first markdown message_'
send_html_message	"$(< $BOTADMIN)"  '<b>Hello World!</b> <em>This is my first HTML message</em>'
send_keyboard "$(< $BOTADMIN)"  'Do you like it?' '[ "Yep" , "No" ]'
```
Nnow something more useful ...
```bash
# sending output from system commands:
send_normal_message	"$(< $BOTADMIN)"  "$(date)"

send_normal_message	"$(< $BOTADMIN)"  "$(uptime)"

send_normal_message       "$(< $BOTADMIN)"  '`'$(free)'`'
# same but sent as monospaced text
send_markdown_message	"$(< $BOTADMIN)"  "\`$(free)\`"
```


### Bashbot environment
This section describe how you can customize bashbot to your needs by setting environment variables. 


#### Change file locations
In standard setup bashbot is self containing, this means you can place 'telegram-bot-bash'  any location
and run it from there. All files - programm, config, data etc - will reside in 'telegram-bot-bash'.

If you want to have other locations for config, data etc,  define and export the following environment variables.
**Note: all specified directories and files must exist or running 'bashbot.sh' will fail.**

##### BASHBOT_ETC
Location of the files ```commands.sh```, ```mycommands.sh```, ```token```, ```botadmin```, ```botacl``` ...
```bash
  unset  BASHBOT_ETC     # keep in telegram-bot-bash (default)
  export BASHBOT_ETC ""  # keep in telegram-bot-bash

  export BASHBOT_ETC "/etc/bashbot"  # unix like config location

  export BASHBOT_ETC "/etc/bashbot/bot1"  # multibot configuration bot 1
  export BASHBOT_ETC "/etc/bashbot/bot2"  # multibot configuration bot 2
```

 e.g. /etc/bashbot

##### BASHBOT_VAR
Location of runtime data ```data-bot-bash```, ```count``` 
```bash
  unset  BASHBOT_VAR     # keep in telegram-bot-bash (default)
  export BASHBOT_VAR ""  # keep in telegram-bot-bash

  export BASHBOT_VAR "/var/spool/bashbot"  # unix like config location

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
Bashbot Home directory (where bashbot is installed). If set bashbot autodetection of installation dir is disabled
and value of BASHBOT_HOME is used.

This is usefull if you want to force bashbot to always use full pathnames instead of relative ones or if you
want to tell your own scripts where to look for bashbot.sh.
```bash
  unset  BASHBOT_HOME     # autodetection (default)
  export BASHBOT_HOME ""  # autodetection

  export BASHBOT_HOME "/usr/local/telegram-bot-bash"	# unix like location
  export BASHBOT_HOME "/usr/local/bin"			# Note: you MUST set ETC, VAR and JSONSH correct to make this work!
```

----

#### Change config values

##### BASHBOT_URL
Uses given URL instead of offical telegram API URL, useful if you have your own telegram server or for testing.

```bash
  unset  BASHBOT_URL       # use Telegram URL https://api.telegram.org/bot<token> (default)

  export BASHBOT_URL ""    # use use Telegram https://api.telegram.org/bot<token>

  export BASHBOT_URL "https://my.url.com/bot" # use your URL https://my.url.com/bot<token>

```

##### BASHBOT_TOKEN

##### BASHBOT_WGET
Bashbot uses ```curl``` to communicate with telegram server. if ```curl``` is not availible ```wget``` is used.
If 'BASHBOT_WGET' is set to any value (not undefined or not empty) wget is used even is curl is availible.  
```bash
  unset  BASHBOT_WGET       # use curl (default)
  export BASHBOT_WGET ""    # use curl 

  export BASHBOT_WGET "yes" # use wget
  export BASHBOT_WGET "no"  # use wget!

```

##### BASHBOT_SLEEP
Instead of polling permanently or with a fixed delay, bashbot offers a simple adaptive polling.
If messages are recieved bashbot polls with no dealy. If no messages are availible bashbot add 100ms delay
for every poll until the maximum of BASHBOT_SLEEP ms.
```bash
  unset  BASHBOT_SLEEP       # 5000ms (default)
  export BASHBOT_SLEEP ""    # 5000ms 

  export BASHBOT_SLEEP "1000"     # 1s maximum sleep 
  export BASHBOT_SLEEP "10000"    # 10s maximum sleep
  export BASHBOT_SLEEP "1"        # values < 1000 disables sleep (not recommended) 
  
```

#### Testet configs as of v.07 release
**Note: Environment variables are not stored, you must setup them before every call to bashbot.sh, e.g. from a script.**

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

##### simple multibot config, everything is keept inside 'telegram-bot-bash' dir
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

#### [Prev Notes for Developers](7_develop.md)

#### $$VERSION$$ v0.90-dev-2-g51aa2ed

