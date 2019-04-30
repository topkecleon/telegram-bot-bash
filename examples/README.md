#### [Home](../README.md)

## Bashbot examples

### bashbot.cron
An example crontab is provided in ```examples/bashbot.cron```, see [Expert use](../doc/4_expert.md#Scedule-bashbot-from-Cron)


### Interactive chats
Two examples for interactive scripts are provided as **calc.sh** and **question.sh**, see [Advanced use](../doc/3_advanced.md#Interactive-Chats)

### Background jobs

Background jobs are an easy way to provide sceduled messages or alerts if something happens.

**notify.sh** is a simple example on how to send a message every x seonds, e.g. current time.

**background-scripts** contains a more concrete example on how to start and stop different scripts plus some example backgound scripts.

```
    mycommands.sh - /run_xxx and /kill-xxx wil start any script named run_xxx.sh

    run_diskusage.sh - shows disk usage every 100 seconds
    run_filename.sh	- shown the name of new files in a named dir
    run_filecontent.sh	- shown the content of new files in a named dir
    run_notify.sh - same as notify.sh
```
**Note:** Output of system commands often contains newlines, each newline results in a telegram message, the function 'send_telegram' in
mycommands.sh avoids this by converting each newline to ' mynewlinestartshere ' before output the string.

### Use bashbot from external scripts

**external-use** will contain some examples on how to send messages from external scripts to Telegram chats or users.

#### $$VERSION$$ v0.7-pre2-3-ge0a6d38


