<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE,HEAD, OPTIONS');
	if(isset($_GET['symbol'])){
		$symbol=$_GET['symbol'];
		$moreinfoURL="http://dev.markitondemand.com/MODApis/Api/v2/Quote/json?symbol=".urlencode($symbol);
		//$moreinfoURL=$moreinfoURL.urlencode($symbol);
		date_default_timezone_set("America/Los_Angeles");
		$json=file_get_contents($moreinfoURL);
		echo $json;
	}
	
	if(isset($_GET['input'])){
		$input=$_GET['input'];
		$moreinfoURL="http://dev.markitondemand.com/MODApis/Api/v2/Lookup/json?input=".urlencode($input);
		//$moreinfoURL=$moreinfoURL.urlencode($input);
		$json=file_get_contents($moreinfoURL);
		echo $json;
	}
	
?>	
