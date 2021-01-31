#### [Examples](../README.md)

## Bashtbot webhook example

### Webhooks

Bashbot default mode is to poll Telegram server for updates but Telegram offers also webhook
as a more efficient method to deliver updates.
If your server is reachable from the Internet you can use the webhook method described here.


#### Setup Apache webhook

Prerequisite: An Apache webserver with a valid SLL certificate chain and php enabled.

Prepare Apache to forward webhook to Bashbot: 

- install bashbot as described in [Bashbot Installation](../../doc/0_install.md)
- create file `data-bot-bash/webhook-fifo`
- run `bashbot.sh init` to setup bashbot to run as same user as Apache (_e.g. www_)
- go to apache web root and create directory `telegram/<your_bot_token>`
- copy all files from `examples/webhook` to new directory and change to it
- write bashbot installation directory as first line to file `BASHBOT_HOME`
- execute `php index.php`

Every call to webhook `https://<yourservername>/telegram/<your_bot_token>/` will execute
`index.php` and write received JSON to file `data-bot-bash/webhook-fifo`.
E.g. the URL `https://<yourservername>/telegram/<your_bot_token>/?json={"test":"me"}`
will append `{"test":"me"}` to the file `data-bot-bash/webhook-fifo`.

Now your Apache is ready to forward data to Bashbot. 


#### Simple update processing

To configure simple update processing delete file `data-bot-bash/webhook-fifo` after your webhook is working.
Every webhook call now forwards incoming Telegram updates to the named pipe `data-bot-bash/webhook-fifo`

Now enable webhook on Telegram (_see below_).

Every incoming Telegram update load Bashbot once for processing one command. Even it seems overkill to load
Bashbot on every update, it's more responsive and create less server load for a low traffic bot.

*Note:* You must NOT start bashbot when simple update processing is enabled.


#### High traffic processing

High traffic processing writes Telegram updates to the named pipe `data-bot-bash/webhook-fifo`
and Bashbot poll them, this is much more efficient than polling Telegram server.

To switch from `Simple processing` to `High traffic processing` start bashbot as `bashbot.sh start-hook`.
Stop bashbot with `bashbot.sh stop` to switch back to `Simple processing`


#### Enable webhook on Telegram

To get updates via webhook your server must be reachable from the internet and you must
instruct Telegram where to deliver updates, this is done by calling bashbot function `set_webhook`.

*Example:*

```bash
bin/any_command.sh set_webhook "https://myserver.com/telegram"
```

instruct Telegram to use the URL `https://myserver.com/telegram/<your_bot_token>/` to deliver updates.
After you enable webhook to deliver Telegram updates it's no more possible to poll updates with `bashbot.sh start`.

To stop delivering of Telegram updates via webhook run `bin/any_command.sh delete_webhook`.

**Important**: Only https connections with a valid certificate chain are allowed as endpoint for webhook.


#### $$VERSION$$ v1.40-dev-22-g6754273

