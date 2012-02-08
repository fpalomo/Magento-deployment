<?php 
date_default_timezone_set("Europe/Madrid");
ini_set("display_errors",1);
echo "Start Cleaning content cache at ... " . date("Y-m-d H:i:s")."\n";

$scriptPath = substr($_SERVER["PHP_SELF"], 0, strrpos($_SERVER["PHP_SELF"], "/") );
$mage =  $scriptPath . '/../app/Mage.php';
echo "including $mage...\n";
require $mage;

$types = Mage::app()->getCacheInstance()->getTypes();

unset($types["full_page"]);

try{
	echo "Cleaning data cache (not FPC)... ";
	foreach($types as $type => $data){
		echo "Removing $type ... ";
		echo Mage::app()->getCacheInstance()->clean($data["tags"])? "[OK]" : "[ERROR]";
		echo "\n";
	}
} catch(exception $e){
	die("[ERROR:". $e->getMessage() ."]");
}


