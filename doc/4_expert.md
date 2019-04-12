## Expert Use

### Handling UTF-8 character sets
#### Setting up your Environment
In general ```bash``` and ```GNU``` utitities are UTF-8 aware, but you have to setup your environment
and your scripts accordingly:

1. Your Terminal and Editor must support UTF-8:
   Set Terminal and Editor locale to UTF-8, eg. in ```Settings/Configuration``` select UTF-8 (Unicode) as Charset.

2. Set ```Shell``` environment to UTF-8 in your  ```.profile``` and your scripts. The usual settings are:

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
export 'LANGUAGE=den_US.UTF-8'
```
3. make shure your bot scripts use the correct  settings, eg. include the lines above at the beginning of your scripts

To display all availible locales on your system run ```locale -a | more```. [Gentoo Wiki](https://wiki.gentoo.org/wiki/UTF-8)

#### UTF-8 in Telegram
```UTF-8``` is a variable length encoding of Unicode. UTF-8 is recommended as the default encoding in JSON, XML and HTML, also Telegram make use of it.

The first 128 characters are regular ASCII, so it's a superset of and compatible with ASCII environments. The next 1,920 characters need
two bytes for encoding and covers almost all ```Latin``` alphabets, also ```Greek```, ```Cyrillic```,
```Hebrew```, ```Arabic``` and more. See [Wikipedia](https://en.wikipedia.org/wiki/UTF-8) for more deatils.

Telegram send Messages with all characters not fitting in one byte (256 bit) escaped as sequences of ```\uxxxx``` to be regular one byte ASCII (incl. iso-xxx-x), e.g. Emoticons and Arabic characters.
E.g. the Emoticons ``` 😁 😘 ❤️ 😊 👍 ``` are encoded as:
```
\uD83D\uDE01 \uD83D\uDE18 \u2764\uFE0F \uD83D\uDE0A \uD83D\uDC4D
```

'\uXXXX' and '\UXXXXXXXX' escaped endocings are supported by zsh, bash, ksh93, mksh and FreeBSD sh, GNU 'printf' and GNU 'echo -e', see [this Stackexchange Answer](https://unix.stackexchange.com/questions/252286/how-to-convert-an-emoticon-specified-by-a-uxxxxx-code-to-utf-8/252295#252295) for more information.



### Run as other user or system service
Bashbot is desingned to run manually by the user who installed it. Nevertheless it's possible to run it by an other user-ID, as a system service or sceduled from cron. This is onyl recommended for experiend linux users.

####Running bashbot as an other user is only possible with sudo rigths.

Setup the environment for the user you want to run bashbot and enter desired username, e.g. nobody :
```bash
sudo ./bashbot.sh init
```

Edit the file ```bashbot.rc``` and edit the following lines to fit your configuration:
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
From now on always use bashbot.rc to start/stop your bot: 
```bash
sudo ./bashbot.rc start
```
Type ```ps -ef | grep bashbot``` to verify your Bot is running as the desired user.

If you started bashbot by bashbot.rc you must use bashbot.rc also to manage your Bot! The following commands are availible:
```bash
sudo ./bashbot.rc start
sudo ./bashbot.rc stop
sudo ./bashbot.rc status
sudo ./bashbot.rc suspendback
sudo ./bashbot.rc resumeback
sudo ./bashbot.rc killback
```
To change back the environment to your user-ID run ```sudo ./bashbot.sh init``` again and enter your user name.

To use bashbot as a system servive include a working ```bashbot.rc``` in your init system (systemd, /etc/init.d).

### Scedule bashbot from Cron
An example crontab is provided in ```bashbot.cron```.

- If you are running bashbot with your user-ID, copy the examples lines to your crontab and remove username ```nobody```.
- if you run bashbot as an other user or a system service edit ```bashbot.cron``` to fit your needs and replace username```nobody``` with the username you want to run bashbot. copy the modified file to ```/etc/cron.d/bashbot```


#### $$VERSION$$ v0.52-0-gdb7b19f

