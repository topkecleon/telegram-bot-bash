#### [Home](../README.md)
## Customize bashbots environment
This section describe how you can customize bashbot to your needs by setting environment variables. 


### Change file locations
In standard setup bashbot is self containing, this means you can place 'telegram-bot-bash'  any location
and run it from there. All files - programm, config, data etc - will reside in 'telegram-bot-bash'.

If you want to have other locations for config, data etc,  define and export the following environment variables.
**Note: all specified directories and files must exist or running 'bashbot.sh' will fail.**

#### BASHBOT_ETC
Location of the config files 'token', 'botadmin', 'botacl' ...
```bash
  unset  BASHBOT_ETC     # keep in telegram-bot-bash (default)
  export BASHBOT_ETC ""  # keep in telegram-bot-bash

  export BASHBOT_ETC "/etc/bashbot"  # unix like config location

  export BASHBOT_ETC "/etc/bashbot/bot1"  # multibot configuration bot 1
  export BASHBOT_ETC "/etc/bashbot/bot2"  # multibot configuration bot 2
```

 e.g. /etc/bashbot

#### BASHBOT_VAR
Location of runtime data files 'data-bot-bash', 'count', downloaded files ...
```bash
  unset  BASHBOT_VAR     # keep in telegram-bot-bash (default)
  export BASHBOT_VAR ""  # keep in telegram-bot-bash

  export BASHBOT_VAR "/var/spool/bashbot"  # unix like config location

  export BASHBOT_VAR "/var/spool/bashbot/bot1"  # multibot configuration bot 1
  export BASHBOT_VAR "/var/spool/bashbot/bot2"  # multibot configuration bot 2
```

#### BASHBOT_COMMANDS
Full path to bash script containing your commands, default: './commands.sh'
```bash
  unset  BASHBOT_COMMANDS     # telegram-bot-bash/commands.sh (default)
  export BASHBOT_COMMANDS ""  # telegram-bot-bash/commands.sh

  export BASHBOT_COMMANDS "/etc/bashbot/commands.sh"  # unix like config location

  export BASHBOT_COMMANDS "/etc/bashbot/bot1/commands.sh"  # multibot configuration bot 1
  export BASHBOT_COMMANDS "/etc/bashbot/bot2/commands.sh"  # multibot configuration bot 2
```
#### BASHBOT_JSONSH
Full path to JSON.sh script, default: './JSON.sh/JSON.sh'
```bash
  unset  BASHBOT_JSONSH     # telegram-bot-bash/JSON.sh/JSON.sh (default)
  export BASHBOT_JSONSH ""  # telegram-bot-bash/JSON.sh/JSON.sh

  export BASHBOT_JSONSH "/usr/local/bin/JSON.sh"  # installed in /usr/local/bin

```

### Change config values

#### BASHBOT_DECODE
Bashbot offers two variants for decoding JSON UTF format to UTF-8. By default bashbot uses 'json.encode' if python is installed.
If 'BASHBOT_DECODE' is set to any value (not undefined or not empty) the bash only implementation will be used.  
```bash
  unset  BASHBOT_DECODE       # autodetect python (default)
  export BASHBOT_DECODE ""    # autodetect python

  export BASHBOT_DECODE "yes" # force internal
  export BASHBOT_DECODE "no"  # also force internal!
```


#### BASHBOT_SLEEP
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

### Testet location configs
**Note: Environment variables are not stored, you must setup them before every call to bashbot.sh, e.g. from a script.**

#### simple Unix like config, mainly for one bot. bashbot is in '/usr/local/telegram-bot-bash'
```bash
  # Note: all dirs and files must exist!
  export BASHBOT_ETC "/etc/bashbot"
  export BASHBOT_VAR "/var/spool/bashbot"

  /usr/local/telegram-bot-bash/bashbot.sh start
```

#### Unix like config, mainly for one bot. bashbot.sh is in '/usr/bin'
```bash
  # Note: all dirs and files must exist!
  export BASHBOT_ETC "/etc/bashbot"
  export BASHBOT_VAR "/var/spool/bashbot"
  export BASHBOT_JSONSH "/var/spool/bashbot"
  export BASHBOT_COMMANDS "/etc/bashbot/commands.sh

  /usr/local/bin/bashbot.sh start
```

#### simple multibot config bashbot is in '/usr/local/telegram-bot-bash'
```bash
  # config for running Bot 1
  # Note: all dirs and files must exist!
  export BASHBOT_ETC "./mybot1"
  export BASHBOT_VAR "./mybot1"
  export BASHBOT_COMMANDS "./mybot1/commands.sh

  /usr/local/telegram-bot-bash/bashbot.sh start
```

```bash
  # config for running Bot 2
  # Note: all dirs and files must exist!
  export BASHBOT_ETC "./mybot2"
  export BASHBOT_VAR "./mybot2"
  export BASHBOT_COMMANDS "./mybot2/commands.sh

  /usr/local/telegram-bot-bash/bashbot.sh start
```

#### [Prev Notes for Developers](7_develop.md)

#### $$VERSION$$ v0.70-dev2-8-gf412a29

