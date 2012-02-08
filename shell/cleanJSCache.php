<?php 

// make a request to clean magento cache
date_default_timezone_set("Europe/Madrid");
echo "Start Cleaning JS cache at ... " . date("Y-m-d H:i:s")."\n";
ini_set("display_errors",1);
$scriptPath = substr($_SERVER["PHP_SELF"], 0, strrpos($_SERVER["PHP_SELF"], "/") );
require $scriptPath . '/../app/Mage.php';
Mage::app('admin')->setUseSessionInUrl(false);
Mage::getConfig()->init();


try {
	echo "Cleaning merged JS/CSS...";
	flush();
	Mage::getModel('core/design_package')->cleanMergedJsCss();
	Mage::dispatchEvent('clean_media_cache_after');
	echo "[OK]\n";
}catch (Exception $e) {
	die ("[ERROR:" . $e->getMessage() ."]");
}

