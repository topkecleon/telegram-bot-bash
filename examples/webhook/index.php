<?php
/************************************************************
 * @file        examples/webhook/index.php
 * @description example webhook implementation for apache
 *
 * @author     KayM (gnadelwartz), kay@rrr.de
 * @license    http://www.wtfpl.net/txt/copying/ WTFPLv2
 * @since      30.01.2021 20:24
 *
#### $$VERSION$$ v1.40-dev-13-g2a3663a
 ***********************************************************/

 // bashbot home dir
 $BASHBOT_HOME='/usr/local/telegram-bot-bash';
 // webhook endpoint
 $cmd=$BASHBOT_HOME.'/bin/process_update.sh';

 // prepeare read, e.g. run from CLI
 $data='';
 $input="php://input";
 $json_file="json.txt";
 if (php_sapi_name() == "cli") {
	if(is_readable($json_file)) {
		$input=$json_file;
	} else {
		$input="php://stdin";
	}
 }
 // read request data
 if($json = file_get_contents($input)) { 
	$data = $json;
 } else {
	$data = implode(" ",$_POST);
 }
 // file_put_contents('server.txt', print_r($_SERVER, TRUE));
 // file_put_contents($json_file, $data);

 // process telegram update
 if ($data == '') {
	error_response(400, "No data received");
 }
 if (! chdir($BASHBOT_HOME)) {
	error_response(403, "No route to bot home");
 }
 if (! is_executable($cmd)) {
	error_response(502, "Webhook endpoint not found");
 }

 if (! $handle = popen( $cmd.' debug', 'w' )) {
	error_response(503, "Can't open webhook endpoint");
 }
 if (fwrite( $handle, $data.'\n') === false) {
	error_response(504, "Write to webhook failed");
 }
 pclose($handle);


 function error_response($code, $msg) {
    $api = substr(php_sapi_name(), 0, 3);
    if ($api == 'cgi' || $api == 'fpm') {
 	header('Status: '.$code.' '.$msg);
    } else {
	$protocol = isset($_SERVER['SERVER_PROTOCOL']) ? $_SERVER['SERVER_PROTOCOL'] : 'HTTP/1.0';
	header($protocol.' '.$code.' '.$msg);
    }
    exit('Error '.$code.': '.$msg);
 }
?>
