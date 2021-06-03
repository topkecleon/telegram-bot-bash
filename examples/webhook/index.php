<?php
/************************************************************
 * @file        examples/webhook/index.php
 * @description example webhook implementation for apache
 *              write to fifo/file if writeable, else pipe to command 
 *
 *             first line of BASHBOT_HOME is used as bot home (optional)  
 *             must start with /, not contain /. and min 20 characters long
 *
 * @author     KayM (gnadelwartz), kay@rrr.de
 * @license    http://www.wtfpl.net/txt/copying/ WTFPLv2
 * @since      30.01.2021 20:24
 *
#### $$VERSION$$ v1.51-0-g6e66a28
 ***********************************************************/

 // bashbot home dir
 $CONFIG_HOME='BASHBOT_HOME';
 $BASHBOT_HOME='/usr/local/telegram-bot-bash';
 // read from config file
 if (file_exists($CONFIG_HOME)) { 
	$tmp = trim(fgets(fopen($CONFIG_HOME, 'r')));
	// start with '/', not '/.', min 20 chars
	if (substr($tmp,0,1) == '/' && strlen($tmp) >= 20 && strpos($tmp, '/.') === false) {
		$BASHBOT_HOME=$tmp;
	}
 } 

 // bashbot config file
 $CONFIG=$BASHBOT_HOME.'/botconfig.jssh';
 // set botname here or read botname from config file if unknown
 $botname="unknown";
 if ($botname == "unknown" && file_exists($CONFIG)) { 
	$prefix='["botname"]	"';
	$len=strlen($prefix);
	$arr = file($CONFIG, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
	foreach ($arr as $line) {
		if(substr($line, 0, $len) == $prefix) {
			$botname=substr($line, $len, strlen($line)-$len-1);
		}
	}

 } 

 // script endpoint
 $cmd=$BASHBOT_HOME.'/bin/process_update.sh';
 // default fifo endpoint
 $fifo=$BASHBOT_HOME.'/data-bot-bash/webhook-fifo-'.$botname;

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
	if ($data == '') { $data = implode(" ",$_GET); }
 }
 // uncomment to save last received JSON
 // file_put_contents($json_file, str_replace(array("\n", "\r"), '',$data). PHP_EOL));

 // prepare for writing
 if ($data == '') {
	error_response(400, "No data received");
 }
 if (! chdir($BASHBOT_HOME)) {
	error_response(403, "No route to bot home");
 }

 // fifo or command? 
 if (! is_writeable($fifo)) {
     // pipe to command
     if (! file_exists($cmd)) {
	error_response(502, "Webhook endpoint not found");
     }
     if (! $handle = popen( $cmd.' debug', 'w' )) {
	error_response(503, "Can't open webhook command endpoint");
     }
 } else  {
	// write to fifo
	if (! $handle = fopen( $fifo, 'a' )) {
		error_response(503, "Can't open webhook file endpoint");
	}
	flock($handle, LOCK_EX);
 }
 if (fwrite( $handle, str_replace(array("\n", "\r"), '',$data). PHP_EOL) === false) {
	error_response(504, "Write to webhook failed");
 }
 flock($handle, LOCK_UN);
 pclose($handle);
/**/

 function error_response($code, $msg) {
    $api = substr(php_sapi_name(), 0, 3);
    if ($api == 'cgi' || $api == 'fpm') {
 	header('Status: '.$code.' '.$msg);
    } else {
	$protocol = isset($_SERVER['SERVER_PROTOCOL']) ? $_SERVER['SERVER_PROTOCOL'] : 'HTTP/1.0';
	header($protocol.' '.$code.' '.$msg);
    }
    exit('Error '.$code.': '.$msg. PHP_EOL);
 }
?>
