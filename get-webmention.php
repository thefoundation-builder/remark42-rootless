<?php

function isJson($string) {
   json_decode($string);
   return json_last_error() === JSON_ERROR_NONE;
}

function getCurlFile($url) {
    //$fp = fopen ('img/favicons/'.$saveFileName.'.png', 'w+');
$ch = curl_init($url);
curl_setopt($ch, CURLOPT_TIMEOUT, 23);
///* Save the returned data to a file */
//curl_setopt($ch, CURLOPT_FILE, $fp);
curl_setopt($ch, CURLOPT_FOLLOWLOCATION, true);

//curl_exec($ch);

curl_setopt($ch, CURLOPT_HEADER, 0);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_BINARYTRANSFER, 1);
$output = curl_exec($ch);
// close curl resource, and free up system resources
curl_close($ch);
//fclose($fp);
return $output;

}
function getCurl($url) {
    //$fp = fopen ('img/favicons/'.$saveFileName.'.png', 'w+');
$ch = curl_init($url);
curl_setopt($ch, CURLOPT_TIMEOUT, 6);
///* Save the returned data to a file */
//curl_setopt($ch, CURLOPT_FILE, $fp);
curl_setopt($ch, CURLOPT_FOLLOWLOCATION, true);

//curl_exec($ch);

curl_setopt($ch, CURLOPT_HEADER, 0);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
$output = curl_exec($ch);
// close curl resource, and free up system resources
curl_close($ch);
//fclose($fp);
return $output;

}
function website_title($url) {

try {
   $ch = curl_init();
   curl_setopt($ch, CURLOPT_URL, $url);
   curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
   // some websites like Facebook need a user agent to be set.
   curl_setopt($ch, CURLOPT_USERAGENT, 'Mozilla/5.0 (Windows NT 6.2; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/27.0.1453.94 Safari/537.36');
   $html = curl_exec($ch);
   curl_close($ch);

   $dom  = new DOMDocument;
   @$dom->loadHTML($html);

   $title = $dom->getElementsByTagName('title')->item('0')->nodeValue;
} catch (Error $e) {
       $title="";
   }
   return $title;
}
//$target="https://mytest.lan/mypost/";
$target=$_GET["target"];

//$webmentiond_target="https://my.webmention.d/webmentions/get?target=".$target;
$webmentiond_target="http://127.0.0.1:8023/get?target=".$target;

//https://t1.gstatic.com/faviconV2?client=SOCIAL&type=FAVICON&fallback_opts=TYPE,SIZE,URL&url=http://www.apple.com&size=256
//https://t2.gstatic.com/faviconV2?client=SOCIAL&type=FAVICON&fallback_opts=TYPE,SIZE,URL&url=http://www.apple.com&size=256
//https://services.keeweb.info/favicon/apple.com
//https:/favicon.yandex.net/favicon/apple.com

//https://t1.gstatic.com/faviconV2?client=SOCIAL&type=FAVICON&fallback_opts=TYPE,SIZE,URL&size=256&url=https://'.$url
$mentionjson=getCurl($webmentiond_target);
//print("GET ".$webmentiond_target);
//print("GOT ".$mentionjson);
$svg_pingback="data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iaXNvLTg4NTktMSI/Pg0KPCEtLSBVcGxvYWRlZCB0bzogU1ZHIFJlcG8sIHd3dy5zdmdyZXBvLmNvbSwgR2VuZXJhdG9yOiBTVkcgUmVwbyBNaXhlciBUb29scyAtLT4NCjwhRE9DVFlQRSBzdmcgUFVCTElDICItLy9XM0MvL0RURCBTVkcgMS4xLy9FTiIgImh0dHA6Ly93d3cudzMub3JnL0dyYXBoaWNzL1NWRy8xLjEvRFREL3N2ZzExLmR0ZCI+DQo8c3ZnIGZpbGw9IiMwMDAwMDAiIHZlcnNpb249IjEuMSIgaWQ9IkNhcGFfMSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB4bWxuczp4bGluaz0iaHR0cDovL3d3dy53My5vcmcvMTk5OS94bGluayIgDQoJIHdpZHRoPSI4MDBweCIgaGVpZ2h0PSI4MDBweCIgdmlld0JveD0iMCAwIDc0LjM3IDc0LjM2OSINCgkgeG1sOnNwYWNlPSJwcmVzZXJ2ZSI+DQo8Zz4NCgk8Zz4NCgkJPHBhdGggZD0iTTcwLjc4NSwwSDQwLjc2OGMtMi4wMTYsMC0zLjU4MywxLjU2OC0zLjU4MywzLjU4NHYzMC4yNDJjMCwyLjAxNiwxLjU2OCwzLjU4NCwzLjU4MywzLjU4NGgzMC4wMTgNCgkJCWMyLjAxNywwLDMuNTgzLTEuNTY4LDMuNTgzLTMuNTg0VjMuNTgzQzc0LjM2OCwxLjU2OCw3Mi44LDAsNzAuNzg1LDB6IE01MC4xNzYsMi40NjRjMC42NzIsMCwxLjM0NCwwLjY3MiwxLjM0NCwxLjM0NA0KCQkJYzAsMC42NzItMC42NzIsMS4zNDQtMS4zNDQsMS4zNDRzLTEuMzQ0LTAuNjcyLTEuMzQ0LTEuMzQ0QzQ4LjgzMywzLjEzNiw0OS4yOCwyLjQ2NCw1MC4xNzYsMi40NjR6IE00Ni4zNjksMi40NjQNCgkJCWMwLjY3MiwwLDEuMzQ0LDAuNjcyLDEuMzQ0LDEuMzQ0YzAsMC42NzItMC42NzIsMS4zNDQtMS4zNDQsMS4zNDRjLTAuNjczLDAtMS4zNDUtMC42NzItMS4zNDUtMS4zNDQNCgkJCUM0NS4wMjQsMy4xMzYsNDUuNDczLDIuNDY0LDQ2LjM2OSwyLjQ2NHogTTQyLjMzNiwyLjQ2NGMwLjY3MiwwLDEuMzQ0LDAuNjcyLDEuMzQ0LDEuMzQ0YzAsMC42NzItMC42NzIsMS4zNDQtMS4zNDQsMS4zNDQNCgkJCXMtMS4zNDQtMC42NzItMS4zNDQtMS4zNDRDNDAuOTkzLDMuMTM2LDQxLjY2NSwyLjQ2NCw0Mi4zMzYsMi40NjR6IE03MC4zMzYsMzAuOTE0YzAsMS4zNDQtMS4xMiwyLjIzOC0yLjI0LDIuMjM4SDQzLjQ1Ng0KCQkJYy0xLjM0NiwwLTIuMjM5LTEuMTE5LTIuMjM5LTIuMjM4VjEwLjA4YzAtMS4zNDQsMS4xMi0yLjIzOSwyLjIzOS0yLjIzOWg5Ljg1NWMyLjIzOSwwLDIuMjM5LDAsMi4yMzktMS4xMg0KCQkJYzAtMS4zNDQsMS4xMi0yLjI0LDIuMjM5LTIuMjRoOS44NTVjMS4zNDYsMCwyLjIzOSwxLjEyLDIuMjM5LDIuMjRMNzAuMzM2LDMwLjkxNEw3MC4zMzYsMzAuOTE0eiIvPg0KCQk8cGF0aCBkPSJNMzMuNjAxLDM3LjE4NEgzLjU4NEMxLjU2NiwzNy4xODQsMCwzOC43NTEsMCw0MC43Njh2MzAuMDE4YzAsMi4wMTcsMS41NjYsMy41ODQsMy41ODQsMy41ODRoMzAuMjQNCgkJCWMyLjAxNiwwLDMuNTg0LTEuNTY3LDMuNTg0LTMuNTg0VjQwLjc2OEMzNy4xODUsMzguNzUzLDM1LjYxOCwzNy4xODQsMzMuNjAxLDM3LjE4NHogTTEyLjk5NCwzOS42NDgNCgkJCWMwLjY3MiwwLDEuMzQ0LDAuNjcyLDEuMzQ0LDEuMzQ2YzAsMC42NzItMC42NzIsMS4zNDQtMS4zNDQsMS4zNDRjLTAuNjcyLDAtMS4zNDYtMC42NzItMS4zNDYtMS4zNDQNCgkJCUMxMS42NDcsNDAuMzIsMTIuMzIxLDM5LjY0OCwxMi45OTQsMzkuNjQ4eiBNOS4xODUsMzkuNjQ4YzAuNjcyLDAsMS4zNDYsMC42NzIsMS4zNDYsMS4zNDZjMCwwLjY3Mi0wLjY3NCwxLjM0NC0xLjM0NiwxLjM0NA0KCQkJUzcuODQsNDEuNjY2LDcuODQsNDAuOTk0QzcuODQsNDAuMzIsOC41MTMsMzkuNjQ4LDkuMTg1LDM5LjY0OHogTTUuMzc2LDM5LjY0OGMwLjY3MiwwLDEuMzQ0LDAuNjcyLDEuMzQ0LDEuMzQ2DQoJCQljMCwwLjY3Mi0wLjY3MiwxLjM0NC0xLjM0NCwxLjM0NHMtMS4zNDQtMC42NzItMS4zNDQtMS4zNDRDNC4wMzQsNDAuMzIsNC40NzksMzkuNjQ4LDUuMzc2LDM5LjY0OHogTTMzLjE1MSw2Ny44NzMNCgkJCWMwLDEuMzQ1LTEuMTE4LDIuMjQtMi4yMzgsMi4yNEg2LjQ5OGMtMS4zNDYsMC0yLjI0LTEuMTE5LTIuMjQtMi4yNFY0Ny4wNDFjMC0xLjM0NCwxLjEyLTIuMjM5LDIuMjQtMi4yMzloOS44NTQNCgkJCWMyLjI0LDAsMi4yNCwwLDIuMjQtMS4xMmMwLTEuMzQ0LDEuMTItMi4yNCwyLjI0LTIuMjRoOS44NTRjMS4zNDYsMCwyLjI0LDEuMTIxLDIuMjQsMi4yNEwzMy4xNTEsNjcuODczTDMzLjE1MSw2Ny44NzN6Ii8+DQoJCTxwb2x5Z29uIHBvaW50cz0iMTQuMTEzLDMwLjQ2NCAyNC42NDEsMTkuOTM2IDI4LDIzLjA3NCAzMC40NjQsMTEuODczIDE5LjA0MSwxNC4zMzUgMjIuMzk5LDE3LjY5NyAxMS44NzMsMjguMjI0IAkJIi8+DQoJCTxwb2x5Z29uIHBvaW50cz0iNjAuMjU2LDQzLjkwNiA0OS43MjksNTQuNDMyIDQ2LjM2OSw1MS4yOTYgNDMuOTA1LDYyLjQ5OCA1NS4zMyw2MC4wMzMgNTEuOTY4LDU2LjY3MyA2Mi40OTcsNDYuMTQ1IAkJIi8+DQoJPC9nPg0KPC9nPg0KPC9zdmc+";
$svg_webmention='data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBzdGFuZGFsb25lPSJubyI/Pgo8IURPQ1RZUEUgc3ZnIFBVQkxJQyAiLS8vVzNDLy9EVEQgU1ZHIDEuMS8vRU4iICJodHRwOi8vd3d3LnczLm9yZy9HcmFwaGljcy9TVkcvMS4xL0RURC9zdmcxMS5kdGQiID4KPCEtLSBVcGxvYWRlZCB0bzogU1ZHIFJlcG8sIHd3dy5zdmdyZXBvLmNvbSwgR2VuZXJhdG9yOiBTVkcgUmVwbyBNaXhlciBUb29scyAtLT4KPHN2ZyB3aWR0aD0iODAwcHgiIGhlaWdodD0iODAwcHgiIHZpZXdCb3g9Ii0xMCAtNSAxMDM0IDEwMzQiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyIgeG1sbnM6eGxpbms9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkveGxpbmsiIHZlcnNpb249IjEuMSI+CiAgIDxwYXRoIGZpbGw9IiMwMDAwMDAiCmQ9Ik04NTcgMjE2bC0yMzAgMjE0aDExMWwtODUgMzY4aC0ybC0xMjAgLTM2OGgtMTQ0bC0xMjEgMzYyaC0ybC0xMTEgLTQ3NmgtMTUzbDE4NSA3MDBoMTU1bDExNyAtMzYzaDJsMTE4IDM2M2gxNTNsMTU3IC01ODZoMTEzeiIgLz4KPC9zdmc+';
// atom parser needs only one " HERE

$sendout=array();

if(isJson($mentionjson) ) {
    $decoded=json_decode($mentionjson, $associative = true);
    if(is_array($decoded)) {
        foreach ( $decoded as $elem ) {
            //print_r($elem);
            if(isset($elem["source"])) {
                $parse = parse_url($elem["source"]);
                $domain=$parse['host'];
                if ($domain != "") {
                     if(file_exists("/tmp/.favicon.cached.".$domain)) {
                         //$outFavicon=base64_encode(file_get_contents("/tmp/.favicon.cached.".$domain));
                         $outFavicon=file_get_contents("/tmp/.favicon.cached.".$domain);
                          } else {
                            if(isset($elem["type"]) && $elem["type"]=="pingback" ) {
                                $outFavicon=$svg_pingback;
                            } else {
                                $outFavicon=$svg_webmention;
                            } // end type check
                           //print("get ".$domain);
                           $googleFavicon=getCurlFile("https://t1.gstatic.com/faviconV2?client=SOCIAL&type=FAVICON&fallback_opts=TYPE,SIZE,URL&size=256&url=https://".$domain );
                           //print(md5($googleFavicon));
                           // not default and not "No favicon"
                           if(md5($googleFavicon) != "b8a0bf372c762e966cc99ede8682bc71" && $googleFavicon != "No favicon" ) {
                               $outFavicon="data:image/png;base64,".base64_encode($googleFavicon);
                               } else {
                                    $keewebFavicon=getCurlFile("https://services.keeweb.info/favicon/".$domain );
                                   if(md5($keewebFavicon) != "b8a0bf372c762e966cc99ede8682bc71" && $keewebFavicon != "No favicon" ) {
                                    $outFavicon="data:image/png;base64,".base64_encode($keewebFavicon);
                                     } // end keyweb default
                                   } // end if md5 google default
                           } // end if domain empty
                         // Write the contents back to the file
                         file_put_contents("/tmp/.favicon.cached.".$domain, $outFavicon);
                    } // end else file cached
            $sendelem=array();
            $sitemeta=get_meta_tags($elem["source"]);
            ///// Notice how the keys are all lowercase now, and
            ///// how . was replaced by _ in the key.
            ///echo $tags['author'];       // name
            ///echo $tags['keywords'];     // php documentation
            ///echo $tags['description'];  // a php manual
            ///echo $tags['geo_position']; // 49.33;-86.59;
            //$sendelem=array_merge($sitemeta,$elem);
            $sendelem=$sitemeta+$elem;
            $site_title=website_title($elem["source"]);
             if($site_title != "") {
                $sendelem["title"]=$site_title;
                }
             $sendelem["target"]=$target;
             $sendelem["url"]=$elem["source"];
             $sendelem["id"]=$elem["id"];
             $sendelem["favicon"]=$outFavicon;
             array_push($sendout,$sendelem);
            } // end if isset source
    } // end foreach elemend
  } // end is_array
}
//print_r($sendout);
header('Content-Type: application/json; charset=utf-8');
print(json_encode($sendout));
