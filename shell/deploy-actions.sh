#!/bin/bash


doDeployFiles(){
	echo ""
	echo -n "  >> Start deploying files..."
	RSYNC_OPTIONS=$RSYNC_OPTIONS$1
	$RSYNC $RSYNC_OPTIONS --exclude "*~" --exclude "local.xml" --exclude ".git" --exclude ".gitignore" --exclude "/var/*" --exclude="/media/*"  --exclude="use_cache.ser"  $LOCAL_GIT_REPO_DIR/ $MAGE_ROOT_DIR --no-owner --no-group  
	echoStatus "Error deploying files"
}

# /* define how to flush the cache on every server */
doFlushDataCache(){
	echo ""
	echo -n "  >> Flushing data cache..."
	cd $MAGE_ROOT_DIR && $PHP $MAGE_ROOT_DIR/shell/cleanContentCache.php >> $MAGE_ROOT_DIR/var/log/cache.log
	echoStatus "Failed flushing data cache"
	echo ""
	echo -n "  >> Flushing JS/CSS cache..."
	cd $MAGE_ROOT_DIR && $PHP $MAGE_ROOT_DIR/shell/cleanJSCache.php >> $MAGE_ROOT_DIR/var/log/cache.log
	echoStatus "Failed flushing css/js cache"
}

# /** FLUSH MAGENTO FPC , if exists.. */
doFlushFPC(){
	echo ""
	echo -n "  >> Flushing FPC..."
	$PHP $MAGE_ROOT_DIR/shell/cleanFPC.php >> $MAGE_ROOT_DIR/var/log/cache.log
	echoStatus
}

#Ê/** enable magento maintenance page */
doCloseWebsite(){
	echo ""
	echo -n "  >> Closing website..."
	$TOUCH $MAGE_ROOT_DIR/maintenance.flag
	if [ "$?" -eq "0" ];
	then
		echoOK
	else
		echoERROR
	fi
}

# /** update your local repository */
doUpdateRepository(){
	echo ""
	echo -n "  >> Updating code from repository ..."
	# reset repository
	cd $LOCAL_GIT_REPO_DIR && $GIT reset --hard HEAD
	# update repository
	cd $LOCAL_GIT_REPO_DIR && $GIT pull
	echo ""
    echo -n "  >> Downloaded latest repository code..."
    echoStatus "Something went really wrong downloading the latest code from the repository!!";
}

# /** fake disable magento compilation, just check if the script exists */
doDryRunDisableCompilation(){
	echo ""
	echo -n "  >> Disabling Magento code compilation(dry-run)..."
	if [ -f  "$MAGE_ROOT_DIR/shell/compiler.php" ];
	then
		echoOK
	else
		echoERROR "can't find compiler.php"
	fi 
}

# /** disable magento compilation */
doDisableCompilation(){
	echo ""
	echo -n "  >> Disabling Magento code compilation..."
	cd $MAGENTO_ROOT_DIR && $PHP $MAGE_ROOT_DIR/shell/compiler.php clear > /dev/null
	echoStatus "Compilation not disabled"
}

# /** reset all files permission to a standard state */
doResetPermissions(){
	echo ""
	DIR="$LOCAL_GIT_REPO_DIR"
	PATH_TO_SET_ALL_WRITE_PERMISSIONS=" $DIR/media $DIR/var $DIR/includes $DIR/includes/config.php "

	echo -n "  >> chmod 0664 to every file..."
	find $DIR -type f -exec chmod 664 {} \;
	echoStatus
	echo -n "  >> chmod 0775 to every .sh file..."
	find $DIR -type f -iname "*.sh" -exec chmod 0775 {} \;
	echoStatus
	echo -n "  >> chmod 0775 to every directory..."
	find $DIR -type d -exec chmod 775 {} \;
	echoStatus
	for i in $PATH_TO_SET_ALL_WRITE_PERMISSIONS; do
		echo -n "  >> chmod 0777 $i ... "
		chmod -R a+w $PATH_TO_SET_ALL_WRITE_PERMISSIONS
		echoStatus
	done
	return 1
}

# /** fake enable compilation, just check if the file exists  */
doDryRunEnableCompilation(){
	echo ""
	echo -n "  >> Enabling Magento code compilation(dry-run)..."
	if [ -f  "$MAGE_ROOT_DIR/shell/compiler.php" ];
	then
		echoOK
	else
		echoERROR "can't find compiler.php"
	fi 
}

# /** enable magento code compilation */
doEnableCompilation(){
	echo ""
	echo -n "  >> Enabling Magento code compilation..."
	cd $MAGENTO_ROOT_DIR && $PHP $MAGE_ROOT_DIR/shell/enableCompiler.php > /dev/null
	echoStatus "Compilation Failed"
}

# /** throw a hit to the website, in this host */
do1stHit(){
	echo ""
	echo -n "  >> Hitting website..."
	$CURL -s -H "Host:$APP_HOST_NAME" 127.0.0.1 > /dev/null
	echoStatus
}

# /** launch the Full Page Cache warm up process */
doFPCWarmup(){
	echo ""
	echo -n "  >> Running FPC warm up..."
	$PHP $MAGE_ROOT_DIR/shell/launchCrawler.php >> $MAGE_ROOT_DIR/var/log/crawler.log &
	echoStatus
}

# /** remove the maintenance flag and open our site! */
doOpenWebsite(){
	echo ""
	echo -n "  >> opening website..."
	$RM -f maintenance.flag
	echoStatus
}



doCleanZendOptimizer(){
	echo ""
	for i in $APP_WEB_SERVERS; 
	do
		echo -n "  >> Cleaning Zend Optimizer+ cache in $i ..."
		$CURL -H "Host:$i" $i/$SCRIPT_TO_CLEAN_ZEND_OPTIMIZER 
		echoStatus
	done
}


doShowStartMsg(){
	echo ""
	echo "Magento Deployment Script. Started at $DATE"
	echo ""
	
}


