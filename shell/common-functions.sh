#!/bin/bash


############### CONSTANTS ##################### ignore this
YES="1"
NO="2"

NONE="2"
ALL="3"
SELECT="4"

### ignore everything under this line 

##################### Text color variables ######## ignore this
txtund=$(tput sgr 0 1)          # Underline
txtbld=$(tput bold)             # Bold
txtred=${txtbld}$(tput setaf 1) #  red
txtgreen=${txtbld}$(tput setaf 2) #  blue
txtblue=${txtbld}$(tput setaf 4) #  green
txtwhite=${txtbld}$(tput setaf 7) #  white
txtreset=$(tput sgr0)             # Reset



##############LOCAL VARIABLES and SCRIPTS ##########
PHP="/usr/local/zend/bin/php"
GIT="/usr/bin/git"
TOUCH="/bin/touch"
RM="/bin/rm"
RSYNC="/usr/bin/rsync"
CURL="/usr/bin/curl"
MYSQL="/usr/bin/mysql"
GZIP="/bin/gzip"
MYSQLDUMP="/usr/bin/mysqldump"
TAR="/bin/tar"


################################
##functions definition

echoUnknownOption(){
	echo "${txtred}ERROR:${txtreset} unknown option..."
}


confirmMessage(){
	echo $1
	PS3="Please, select an option:"
	select confirm in Yes No
	do
		case $REPLY in
		
		1)
			return "$YES"
			;;
		2)
			return "$NO"
			;;
		*)
			echoUnknownOption 
			;;
		esac
	done
}

confirmGroupMessage(){
	echo $1
	PS3="Please, select an option: "
	select confirm in Select None All
	do
		case $REPLY in
		
		1)
			return "$SELECT"
			;;
		2)
			return "$NONE"
			;;
		3)
			return "$ALL"
			;;
		*)
			echoUnkownOption
			;;
		esac
	done	
}


chooseOption(){
	echo ""
	echo $1
	PS3='Please select: '
	select confirm in $2 $3 $4 $5 $6
	do
		case $REPLY in
			1) 
			if [ "$2" != "" ]; 
			then 
				return "$REPLY"
			fi 
			;;
				
			2) 	
			if [ "$3" != "" ]; 
			then 
				return "$REPLY" 
			fi 
			;;
				
			3) 	
			if [ "$4" != "" ]; 
			then 
				return "$REPLY" 
			fi 
			;;				

			4) 	
			if [ "$5" != "" ]; 
			then 
				return "$REPLY" 
			fi 
			;;
				
			5) 	
			if [ "$6" != "" ]; 
			then 
				return "$REPLY" 
			fi 
			;;
			*)
			echoUnkownOption
		esac	
	done
}




shouldIStop(){
	if [ "$FORCE_MODE" -eq "$YES" ];
	then
		doExit
	fi
	
	confirmMessage "There has been an error. Do you want to ${txtwhite}exit now?${txtreset}?"
	exitNow=$?
	if [ "$exitNow" -eq "$YES" ];
	then
		if [ -f $MAGENTO_ROOT_DIR/maintenance.flag ]; 
		then
			confirmMessage "Do you want to remove '$MAGENTO_ROOT_DIR/maintenance.flag' and  open the website?"
			openWebsite=$?
			if [ "$openWebsite" -eq "$YES" ];
			then
				$RM $MAGENTO_ROOT_DIR/maintenance.flag
			fi	
		fi
		doExit
	fi
}

doExit(){
	doReleaseLock
	END_DATE=`date`
	echo ""
	echo "$DATE : ${txtred}Program exited abnormally... Good luck fixing that!${txtreset}"
	echo ""
	exit
}

echoStatus(){
	if [ "$?" -ne "0" ];
	then
		echoERROR $1
		shouldIStop 
	else
		echoOK
		return $?
	fi
}

echoOK(){
	echo "[${txtgreen}OK${txtreset}] $1"
}

echoERROR(){
	echo "[${txtred}ERROR${txtreset}] $1"
}


silentExit(){
	DATE_END=`date`
	echo ""
	echo "Exit at $DATE_END"
	echo ""
	exit
}


doExitSuccess(){
	DATE_END=`date`
	echo ""
	echo ""
	echo "$DATE_END : ${txtgreen}Successful${txtreset} deployment! have a nice day!"
	echo ""
	echo ""
	exit
}




doGetLock(){
	if [ -f $LOCK_FILE ];
	then
		echo ""
		echo ""
		echo "Another forced deployment process running..."
		echo "Exit now..."
		echo ""
		exit
	fi
	$TOUCH $LOCK_FILE
}


doReleaseLock(){
	if [ -f $LOCK_FILE ];
	then
		$RM $LOCK_FILE
	fi
}
	
	
	
printHelp(){
	less $HELP_FILE
}
