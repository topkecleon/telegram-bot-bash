#### [Examples](../README.md)

## Bashbot webhook example

### Webhook

Bashbot default mode is to poll Telegram server for updates but Telegram offers webhook as a more efficient method to deliver updates.
If your server is reachable from the Internet its possible to use the method described here.

Prerequisite for receiving Telegram updates with webhook is a valid SSL certificate, a self signed certificate will not be sufficient.

Webhook processing require special setup on server and Telegram side, therefore it's implemented as separate scripts and you need at least sudo rights to setup.

#### Setup Apache webhook

Prerequisite: An Apache webserver with a valid SLL certificate chain and php enabled.\
This should work with other webservers also but it's not testet. 

Setup webhook with Apache: 

- install bashbot as described in [Bashbot Installation](../../doc/0_install.md)
- create file `data-bot-bash/webhook-fifo-<botname>` (_\<botname\> as in `botconfig.jssh`_)
- run `sudo bashbot.sh init` to setup bashbot to run as same user as web server (_e.g. www_)
- create a directory in web root: `telegram/<your_bot_token>` (_<your_bot_token> as `botconfig.jssh`_)
- give web server access to directory (_e.g.`chown www:www -R telegram`_)
- go into the new directory and copy all files from `examples/webhook` to it
- edit file `BASHBOT_HOME` to contain ithe Bashbot installation directory as first line (_other lines are ignored_)
- execute `php index.php` with user id of web server to test write access to `data-bot-bash/webhook-fifo-<botname>

Calling `https://<yourservername>/telegram/<your_bot_token>/` will execute `index.php`
thus append received data to the file `data-bot-bash/webhook-fifo-<botname>`.
E.g. `https://<yourservername>/telegram/<your_bot_token>/?json={"test":"me"}` will append `{"test":"me"}`.

Now your Server is ready to receive updates from Telegram. 


#### Default webhook processing

This is the testet and supported default method for processing Telegram updates over webhook.

To enable update processing delete the file `data-bot-bash/webhook-fifo-<botname>` if webhook is working as described above.
Incoming Telegram updates are now forwarded to the script `bin/process_update.sh` for processing.

On incoming Telegram updates the script is executed, it sources bashbot.sh and forward the update to Bashbot for processing.
Even it seems overhead to source Bashbot for every update, it's more responsive and create less load than Bashbot polling mode.

Nevertheles there are some limitations compared to polling mode:
 - no startup actions
 - `addons` and `TIMER_EVENTS` are not working

Interactive and background jobs are working as of Bashbot Version 1.51.

#### Full webhook processing

Full webhook processing use an external script to imitate Bashbot polling mode with webhook.

1. Default webook method must work first!
2. run `bashbot.sh init` to setup bashbot to run with your user id
2. Create a named pipe: `mkfifo data-bot-bash/webhook-fifo-botname` and give the web server write access to it
3. execute `php index.php` with user id of web server to test write access to `data-bot-bash/webhook-fifo-<botname>
4. Start script for Bashbot webhook polling mode:\
`bin/process-batch.sh --startbot --watch data-bot-bash/webhook-fifo-<botname>`

The script read updates from given file line by line and forward updates to Bashbot update processing. `--startbot` will run the startup actions
(_e.g. load addons, start TIMER, trigger first run_) and `--watch` will wait for new updates instead of exit on end of file.
Short form: 'bin/process-batch.sh -s -w'

If script works as expected, you may run Bashbot webook polling in background by using `./bachbot.rc starthook/stophook`.

To switch back to default processing delete fifo `data-bot-bash/webhook-fifo-<botname>` and stop `bin/process-batch.sh`.

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

A pure bash webhook implementation is not possible without extra software because Telegram delivers
webhook updates only over secure TLS connections with a valid SSL certificate chain.

`socat` looks like a tool to listen for Telegram updates from bash scripts, let's see ...


#### $$VERSION$$ v1.51-0-g6e66a28

