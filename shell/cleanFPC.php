<?php 
date_default_timezone_set("Europe/Madrid");
echo "Start Cleaning FPC cache at ... " . date("Y-m-d H:i:s")."\n";
ini_set("display_errors",1);
$scriptPath = substr($_SERVER["PHP_SELF"], 0, strrpos($_SERVER["PHP_SELF"], "/") );
require $scriptPath . '/../app/Mage.php';

Mage::app("admin");

try{
	echo "Cleaning FPC... ";
	flush();
    Enterprise_PageCache_Model_Cache::getCacheInstance()->clean(Enterprise_PageCache_Model_Processor::CACHE_TAG);
	echo "[OK]\n";
} catch(exception $e){
	die("[ERROR:". $e->getMessage() ."]");
}


