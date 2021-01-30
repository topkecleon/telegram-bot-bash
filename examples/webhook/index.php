<?php
// where bashbot is installed
$BASHBOT_HOME='/usr/local/telegram-bot-bash';
$cmd=$BASHBOT_HOME.'/bin/process_update.sh';

// save server context and webhook JSON
file_put_contents('server.txt', print_r($_SERVER, TRUE));
if($json = file_get_contents("php://input")) {
     $data = $json;
 } else {
     $data = $_POST;
 }
file_put_contents('json.txt', $data);

// process teegram update
chdir($BASHBOT_HOME);
$handle = popen( $cmd.' debug', 'w' );
fwrite( $handle, $data.'\n' );
?>
