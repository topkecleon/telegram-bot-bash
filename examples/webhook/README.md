#### [Examples](../README.md)

## Bashtbot webhook examples

### webhooks

Bashbot default mode is to poll Telegram server for updates. Telegram offers the more efficiemt webhook method to deliver updates.
Instead of running bashbot with `bashbot.sh start` permanently you can use the webhook method described here (experimental)

#### Setup webhook

To get updates with webhooks you must inform Telegram about where to deliver updates, this will be done with `set_webhook`.
For security reasons bashbot adds you bottoken to the path.

*Example:*

```bash
bin/any_command.sh set_webhook "https://myserver.com/telegram"
```

will instruct Telegram to use the URL `https://myserver.com/telegram/<your_bot_token>/` to deliver updates.
After you setup webhook to deliver updates it'sno more possible to poll updates with `bashbot.sh start`.

To stop delivering of updates with webhook run `bin/any_command.sh delete_webhook`


**Important**: Only https connections with a valid certificate chain are allowed as endpoint for webhook.

#### Using Apache with php enabled

If you have an Apache webserver with a valid SLL certificate chain and php running you can use it as webhook endpoint:

- setup bashbot to run as the same user as your web server (_`bashbot.sh init`_)
- create the directory `telegram/<your_bot_token>` in webserver root
- copy `index.php` into new directory
- edit `index.php` to point to your bashbot installation
- setup webhook for your server (_e.g. `bin/any_command.sh set_webhook "https://myserver.com/telegram`_)


#### $$VERSION$$ v1.40-dev-10-gc0f1af5


