#!/bin/bash


source ./common-functions.sh
source ./deploy-config.sh
source ./deploy-actions.sh

DATE=`date`

echo "Deployment script started at $DATE"

##############################################################################
# Generic Magento Deployment script
#
#This script will download the latest code from a github repository 
# and will sinchronyze changes with the folder containing magento files
# it also performs a serie of different actions
# Please configure all parameters in deploy-config-sh
#
# ABOUT THIS SCRIPT:
# - It assumes you are using zend server 
#Ê- It assumes you have any kind of full page cache engine

# forced mode is a quick way to deploy your code
FORCE_MODE="$NO"


##Â print help 
if [ "$1" == "-help" ];
then
	printHelp
	silentExit
fi

## in case of forcing deployment...
## you might use this mode in a cron job
if [ "$1" == "-force" ];
then
	FORCE_MODE="$YES"
	doShowStartMsg
	doGetLock
	doUpdateRepository
	doResetPermissions
	doCloseWebsite
##Ê"forced" mode will not compile magento code
#	doDisableCompilation
	doDeployFiles 
#	doDeployFiles -q
	# add "q" for silent deployment
	
	doFlushDataCache
	doFlushFPC
	doEnableCompilation
	doCleanZendOptimizer
	do1stHit
## "forced" mode will not launch fpc warmup or code compilation
#	doFPCWarmup 
#	doOpenWebsite
	doReleaseLock
	doExitSuccess

fi

#flush magento data cache
if [ "$1" == "-flushCache" ];
then
	doFlushDataCache
fi

# flush full page cache
if [ "$1" == "-flushFPC" ];
then
	doFlushFPC
fi

# flush zend optimizer+ cache
if [ "$1" == "-flushZend" ];
then
	doCleanZendOptimizer
fi




############# PERFORM ACTIONS #############


# Download from your repository
confirmMessage "Do you want to ${txtbld}update local repository $LOCAL_GIT_REPO_DIR? ${txtreset}"
confirmUpdateWc=$?
if [ "$confirmUpdateWc" -eq "$YES" ];
then
	doUpdateRepository
fi


confirmMessage "Do you want to ${txtbld}reset file permissions${txtreset} in $LOCAL_GIT_REPO_DIR before deploying?";
confirmResetPerms=$?
if [ "$confirmResetPerms" -eq "$YES" ];
then
	doResetPermissions
fi




# Close website
confirmMessage "Do you want to ${txtred}close the website during the process?${txtreset}"
confirm503=$?
if [ "$confirm503" -eq "$YES" ];
then
	doCloseWebsite
fi



confirmMessage "Do you want to perform a ${txtred}dry-run${txtreset}?"
confirmDryRun=$?



if [ "$confirmDryRun" -eq "$YES" ];
then
	doDryRunDisableCompilation
	RSYNC_OPTIONS="${RSYNC_DEFAULT_OPTIONS}n"
else
        confirmMessage "Do you want to ${txtbld}disable Magento code compilation${txtreset}?"
        confirmDCompile=$?
        if [ "$confirmDCompile" -eq "$YES" ];
        then	
        	doDisableCompilation
        fi
fi

echo ""
echo "  >> Deploying files to live folder..."
confirmMessage "Start deploying new files?"
if [ "$?" -eq "$YES" ];
then
	doDeployFiles 
else
	shouldIStop
fi



# Clean Zend Optimizer+ cache
echo ""
confirmMessage "Clean Zend Optimizer+ ?"
if [ "$?" -eq "$YES" ];
then
	doCleanZendOptimizer
fi



## clean data cache
confirmMessage "Do you want to ${txtred}flush the Data Cache ${txtreset}?"
flushDataCache=$?
if [ "${flushDataCache}" -eq "$YES"  ];
then
	doFlushDataCache
else
	echo "  >> NOT flushing data cache... [skipped]"
fi

## clean FPC
confirmMessage "Do you want to ${txtred}flush the Full Page Cache ${txtreset}?"
flushFPC=$?
if [ "${flushFPC}" -eq "$YES"  ];
then
	doFlushFPC
else
	echo "  >> NOT flushing FPC... [skipped"
fi


if [ "$confirmDryRun" -eq "$YES" ];
then
	doDryRunEnableCompilation
else
        confirmMessage "Do you want to ${txtbld}Enable Magento code compilation${txtreset}?"
        confirmCompile=$?
        if [ "$confirmCompile" -eq "$YES" ];
        then
        	doEnableCompilation
		fi
fi


# Lanzar 1er hit
do1stHit


# lanzar cache warm-up en background
confirmMessage "Do you want to ${txtbld}run the Cache Preloader${txtreset}?"
confirmFPCWarmup=$?
if [ "$confirmFPCWarmup" -eq "$YES" ];
then
	doFPCWarmup
fi

# Abrir site , quitar la pagina 503
if [ "$confirm503" -eq "$YES" ];
then
	confirmMessage "Do you want to open the website now?"
	openNow=$?
	if [ "$openNow" -eq "$YES" ];
	then
		doOpenWebsite
	fi
fi

doExitSuccess
