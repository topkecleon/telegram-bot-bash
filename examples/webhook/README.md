#### [Examples](../README.md)

## Bashtbot webhook examples

### webhooks

Bashbot default mode is to poll Telegram server for updates. Telegram offers the more efficient webhook method to deliver updates.
If your server is reachable from the Internet, you can use the webhook method described here (experimental), instead of running bashbot
with `bashbot.sh start`

#### Setup webhook

To get updates with webhooks your server must be reachable from the internet and you must inform Telegram about where to deliver updates,
this will be done by calling `set_webhook URL`.  For security reasons bashbot adds you bottoken to the URL.

*Example:*

```bash
bin/any_command.sh set_webhook "https://myserver.com/telegram"
```

will instruct Telegram to use the URL `https://myserver.com/telegram/<your_bot_token>/` to deliver updates.
After you setup webhook to deliver updates it's no more possible to poll updates with `bashbot.sh start`.

To stop delivering of updates with webhook run `bin/any_command.sh delete_webhook`


**Important**: Only https connections with a valid certificate chain are allowed as endpoint for webhook.

#### Using Apache with php enabled

If you have an Apache webserver with a valid SLL certificate chain and php running you can use it as webhook endpoint:

- setup bashbot to run as the same user as your web server (_`bashbot.sh init`_)
- create the directory `telegram/<your_bot_token>` in apache web root
- copy files all files form here into new directory and change to it
- edit `BASHBOT_HOME` to point to your bashbot installation directory
- setup webhook for your server (_e.g. `bin/any_command.sh set_webhook "https://myserver.com/telegram`_)
- send a command to your bot (_e.g. `/start`_) to check correct setup 

*Example minimal index.php*, see [index.php](index.php) for complete implementation.

```php
<?php
// bashbot home
$BASHBOT_HOME='/usr/local/telegram-bot-bash';
$cmd=$BASHBOT_HOME.'/bin/process_update.sh';

// save server context and webhook JSON
$json = file_get_contents("php://input");

// process teegram update
chdir($BASHBOT_HOME);
$handle = popen( $cmd, 'w' );
fwrite( $handle, $json.'\n' );
pclose($handle);
?>
```

#### $$VERSION$$ v1.40-dev-20-ga7c98d7


