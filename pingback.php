<?php
//from https://github.com/w3c/webmention/blob/master/pingback.php
$body = trim(file_get_contents('php://input'));

if (!file_exists('/tmp/.incoming_http_hosts/')) {
    mkdir('/tmp/.incoming_http_hosts/', 0777, true);
}
file_put_contents("/tmp/.incoming_http_hosts/".$_SERVER["HTTP_HOST"])

if(!$body) {
  header('HTTP/1.1 405 Method Not Allowed');
  header('Content-type: text/plain');
  echo "This is the Pingback endpoint for the Webmention spec. Pingback endpoints only accept POST requests.\n";
  die();
}

$rpc = xmlrpc_decode($body);

if($rpc && is_array($rpc) && count($rpc) == 2) {
  $source = $rpc[0];
  $target = $rpc[1];

  // Forward to internal proxy so we see it in the logs
  $ch = curl_init('http://127.0.0.1:8080/webmentions/receive');
  curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
  curl_setopt($ch, CURLOPT_POSTFIELDS, http_build_query([
    'source' => $source,
    'target' => $target
  ]));
  curl_exec($ch);

  header('Content-type: text/xml');
  echo xmlrpc_encode('pingback_accepted');
} else {
  header('HTTP/1.1 400 Bad Request');
}
