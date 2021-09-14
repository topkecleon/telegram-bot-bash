#### [Home](../README.md)

## Bashbot examples

### bashbot multi
An example wrapper to run multiple instances of bashbot, use ```./bashbot-multi.sh botname command```

### bashbot.cron
An example crontab is provided in ```examples/bashbot.cron```, see [Expert use](../doc/4_expert.md#Scedule-bashbot-from-Cron)


### Interactive chats
Two examples for interactive scripts are provided as **calc.sh** and **question.sh**, see [Advanced use](../doc/3_advanced.md#Interactive-Chats)

### Background scripts

Background jobs are an easy way to provide sceduled messages or alerts if something happens.
**notify.sh** is a simple example on how to send a message every x seonds, e.g. current time.

**background-scripts** contains a more useful example on how to start and stop different scripts plus some example background scripts.

```
    mycommands.sh - /run_xxx and /kill-xxx will start any script named run_xxx.sh

    run_diskusage.sh - shows disk usage every 100 seconds
    run_filename.sh	- shown the name of new files in a named dir
    run_filecontent.sh	- shown the content of new files in a named dir
    run_notify.sh - same as notify.sh
```
**Note:** Output of system commands often contains newlines, each newline results in a telegram message, the function 'send_telegram' in
mycommands.sh avoids this by converting each newline to ' mynewlinestartshere ' before output the string.

### System Status

**send-system-status** contains an example for commands showing status of different subsystems. This example is adapted from
 https://github.com/RG72/telegram-bot-bash to current bashbot commands, but not fully tested. This will show how easy you can
convert existing bots.

```
    mycommands.sh - commands to show system status
    botacl - controls who can show system status

*Available commands*:
	/se *sensors*
	/smb *smbstatus*
	/free *memory status*
	/md *raid status*
	/lvm *lvm status*
	/lvsd *Datailed lvm status*
	/df *disk space*
	/ifconfig *ifconfig output*
	/smart *sda* _smart status for sda drive_
```
### jsonDB and Keyboards

**jsonDB-keybords** contains a stripped down real world example from my bot showing the usage of jsonDB to store and retrieve values
plus use of keyboards in private chats. It's an extended version of mycommands.sh.dist. Messages and help are in german.

### Webhook

**Webhook** contains instructions on how use webhook API to get updates from telegram instead polling Telegram server.

#### $$VERSION$$ v1.51-0-g6e66a28


