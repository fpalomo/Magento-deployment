<?php

// make a request to clean magento cache


ini_set("display_errors", 1);
date_default_timezone_set("Europe/Madrid");

require './app/Mage.php';

$LOCK_FILE = "/tmp/crawler.lock";

function getLock ($lockFile)
{
    $f = fopen($lockFile, 'x');
    if ($f) {
        $me = getmypid();
        $now = date('Y-m-d H:i:s');
        fwrite($f, "Locked by $me at $now\n");
        fclose($f);
        return true;
    } else {
        echo "File is locked: " . file_get_contents("lockFile.txt");
        return false;
    }

}

function releaseLock ($lockFile)
{
    unlink($lockFile); // unlock
}

Mage::app('admin');

try {
    if (! getLock($LOCK_FILE)) {
        throw new exception("can't get lock on file $LOCK_FILE");
    }
    echo "Start crawling at " . date("Y-m-d H:i:s") . " ... ";
    $crawler = Mage::getSingleton('enterprise_pagecache/crawler');
    $crawler->crawl();
    echo "End at " . date("Y-m-d H:i:s") . "... [OK]";
    releaseLock();
} catch (Exception $e) {
    echo "End at " . date("Y-m-d H:i:s") . " ... [ERROR:" . $e->getMessage() .
     "]\n";
}
