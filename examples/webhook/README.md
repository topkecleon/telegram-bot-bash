#### [Examples](../README.md)

## Bashtbot webhook example

### Webhooks

Bashbot default mode is to poll Telegram server for updates but Telegram offers webhook
as a more efficient method to deliver updates.
If your server is reachable from the Internet you can use the methods described here.

You need a valid SSL certificate or Telegram will refuse to deliever update via webhook.
A self signed certificate will not be sufficient.


#### Setup Apache webhook

Prerequisite: An Apache webserver with a valid SLL certificate chain and php enabled.

Prepare Apache to forward webhook to Bashbot: 

- install bashbot as described in [Bashbot Installation](../../doc/0_install.md)
- create file `data-bot-bash/webhook-fifo-<botname>` (_<botname> as in `botconfig.jssh`_)
- run `bashbot.sh init` to setup bashbot to run as same user as Apache (_e.g. www_)
- go to apache web root and create directory `telegram/<your_bot_token>`
- copy all files from `examples/webhook` to new directory and change to it
- write bashbot installation directory as first line to file `BASHBOT_HOME`
- execute `php index.php`

Every call to webhook `https://<yourservername>/telegram/<your_bot_token>/` will execute
`index.php` and write received JSON to file `data-bot-bash/webhook-fifo-botname`.
E.g. the URL `https://<yourservername>/telegram/<your_bot_token>/?json={"test":"me"}`
will append `{"test":"me"}` to the file `data-bot-bash/webhook-fifo-<botname>`.

Now your Apache is ready to forward data to Bashbot. 


#### Webhook update processing for Bashbot

To enable update processing delete the file `data-bot-bash/webhook-fifo-<botname>` after your webhook is working manually.
All webhook calls are now forwarded to `bin/process_update.sh` for processing.

Every incoming Telegram update load Bashbot once for processing one command. Even it seems overkill to load
Bashbot on every incoming update, it's more responsive and create less server load than polling Telegram


Webhook works without running Bashbot and thus has the following limitations:
 - no startup actions
 - no background and interactive jobs
 - `addons` and `TIMER_EVENTS` are not working

To run startup actions and `TIMER_EVENTS` run Bashbot with `./bashbot start` even not needed with webhook.

Workaround for running new background jobs is to execute `./bashbot.sh restartback` on the command line after starting a new background job.


#### Enable webhook on Telegram side

To get updates via webhook your server must be reachable from the internet and you must
instruct Telegram where to deliver updates, this is done by calling bashbot function `set_webhook`.

*Example:*

```bash
bin/any_command.sh set_webhook "https://myserver.com/telegram"
```

instruct Telegram to use the URL `https://myserver.com/telegram/<your_bot_token>/` to deliver updates.
After you enable webhook to deliver Telegram updates it's no more possible to poll updates with `bashbot.sh start`.

To stop delivering of Telegram updates via webhook run `bin/any_command.sh delete_webhook`.

**Important**: Telegram will refuse to deliver updates if your webhook has no valid SSL certificate chain.


#### Bash webhook

A pure bash webhook implementaition is not possible without additional software because Telegram deliver
updates only over secure TLS connections and if a valid SSL certificate chain exists.

`socat` looks like a tool we can use to listen for Telegram updates from bash scripts, let's see ...


#### High traffic processing?

Initially I planned to implement a mode for `High traffic update processing` where Bashbot is started once
and read updates from the named pipe `data-bot-bash/webhook-fifo-<botname>`, similar like polling from Telegram.

But the default webhook method is so convincing and responsive that a special high traffic mode is not necessary.


#### $$VERSION$$ v1.45-dev-47-gf4323e4

