#### [Home](../README.md)

## Bashbot examples

### bashbot.cron
An example crontab is provided in ```examples/bashbot.cron```, see [Expert use](../doc/4_expert.md#Scedule-bashbot-from-Cron)


### Interactive chat examples
Two examples for interactive scripts are provided as 'calc.sh' and 'question.sh', see [Advanced use](../doc/3_advanced.md#Interactive-Chats)

### Background jobs

Background jobs are an easy way to provide sceduled messages or alerts if something happens.

'notify.sh' shows you a simple examples to send a message ervery x seonds, e.g. actual time.

'background-scripts' contains a more complex example on how to start and kill many scripts sending messages to a chat.

```
    mycommands.sh - /run_xxx and /kill-xxx wil start any script named run_xxx.sh

    run_diskusage.sh - shows disk usage every 100 seconds
    run_filename.sh	- shown the namei of new files in a named dir
    run_filecontent.sh	- shown the content of new files in a named dir
    run_notify.sh - same as notify.sh
```

### Use bashbot from external scripts

In 'external-use' you will find some examples on how to send messages from external scripts to send messages to Telegram chats or users.

#### $$VERSION$$ v0.7-pre2-1-g4b83377


