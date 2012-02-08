#!/bin/bash


# apache directory root
MAGE_ROOT_DIR="/var/www/html/bluejaylabs.com"

# folder containing local git repository
LOCAL_GIT_REPO_DIR="/root/bluejaylabs_gitRepo"

# apache user, for file permissions
APACHE_USER="apache"
APACHE_GROUP="apache"

# user for git 
LOCAL_GIT_USER="root"

# default options for rsync
# --del => Remove deleted files
# -r => recursive
# -z => compress data
# -p => preserve permissions
# -g => preserve group
# -v => verbose mode
RSYNC_DEFAULT_OPTIONS="--del -rzpgvt"

# default assignment , don't touch
RSYNC_OPTIONS=$RSYNC_DEFAULT_OPTIONS

# name of the script used to clean zend optimizer
SCRIPT_TO_CLEAN_ZEND_OPTIMIZER="shell/cleanOptimizer.php"

# application host name
APP_HOST_NAME="bluejaylabs.com"

# front servers address pool separated by blank space
APP_WEB_SERVERS="www1.bluejaylabs.com www2.bluejaylabs.com"

# Lock file
LOCK_FILE="/tmp/deployment.lock"

# Help file
HELP_FILE="deploy-help.txt"




