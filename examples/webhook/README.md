#### [Examples](../README.md)

## Bashtbot webhook example

### Webhook

Bashbot default mode is to poll Telegram server for updates but Telegram offers webhook as a more efficient method to deliver updates.
If your server is reachable from the Internet its possible to use the methods described here.

Prerequisite for receiving Telegram unpdates with webhook is a valid SSL certificate, a self signed certificate will not be sufficient.

*Note:* You need at least sudo rights to setup webhook.


#### Setup Apache webhook

Prerequisite: An Apache webserver with a valid SLL certificate chain and php enabled.
Other webserver should work also but they are not testet. 

Prepare Apache to forward webhook to Bashbot: 

- install bashbot as described in [Bashbot Installation](../../doc/0_install.md)
- create file `data-bot-bash/webhook-fifo-<botname>` (_\<botname\> as in `botconfig.jssh`_)
- run `sudo bashbot.sh init` to setup bashbot to run as same user as Apache (_e.g. www_)
- go to apache web root and create the directory `telegram/<your_bot_token>`
- change to the new directory and copy all files from `examples/webhook` to it
- edit file `BASHBOT_HOME` to contain Bashbot installation directory as first line
- execute `php index.php` as first test

From now on every call to `https://<yourservername>/telegram/<your_bot_token>/` will execute
`index.php` and write received JSON to the file `data-bot-bash/webhook-fifo-<botname>`.
E.g. the URL `https://<yourservername>/telegram/<your_bot_token>/?json={"test":"me"}`
will append `{"test":"me"}` to the file `data-bot-bash/webhook-fifo-<botname>`.

Now your Server is ready to receive updates from Telegram. 


#### Default webhook processing

This is the testet and supported default method for receiving and processing Telegram updates over webhook.

To enable update processing delete the file `data-bot-bash/webhook-fifo-<botname>` after your webhook is working as described above.
Incoming Telegram updates are now forwarded to the script `bin/process_update.sh` for processing.

On every incoming Telegram update the script calls Bashbot once for processing the update. Even it seems overkill to load
Bashbot on every incoming update, it's more responsive and create less server load than polling Telegram.

Nevertheles this has some limitations compared to run bashbot in background:
 - no startup actions
 - no background and interactive jobs
 - `addons` and `TIMER_EVENTS` are not working

Workaround for running new background jobs is to execute `./bashbot.sh resumeback` after starting a new background job.

#### Full webhook processing

Full webhook processing use an external script to run Bashbot similar like for polling Telegram updates.
There is no support for running as support for running the script in background, as a service or an other user.

1. Default webook method must work first!
2. run `bashbot.sh` to setup bashbot to run with your user id
2. Create fifo: `mkfifo data-bot-bash/webhook-fifo-botname` and give apache server write access to it
3. Start script for Bashbot batch mode:\
`bin/process-batch.sh --startbot --watch data-bot-bash/webhook-fifo-<botname>`

In batch mode Bashbot read updates from given file instead from Telegram server. `--startbot` run Bashbot staturaup actionsi
(_e.g. load addons, start TIMER, trigger first run_). `--watch` mean to wait for new updates instead to exit on end of file.

To switch back to default processing delete fifo `data-bot-bash/webhook-fifo-<botname>` and kill `bin/process-batch.sh`.

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


#### $$VERSION$$ v1.45-dev-56-g0859354

