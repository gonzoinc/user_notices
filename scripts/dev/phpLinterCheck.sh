#!/bin/bash

D=`pwd`
cd $1
APP_PATH=`pwd`
V=$APP_PATH/vendor

# Handles all behavior associated with failure
function fail {
    if [ "$1" ]
    then
        echo $1
    fi

    echo
	echo "Use the '--no-verify' option to bypass. You break it, your problem!"
    echo

    cd $D

    exit 1
}


# Has Composer Been Installed
if [ ! -d "$V" ]
then
    fail "$V doesn't exist. Have you run Composer install?"
fi

# Check for un-staged files
S=`git status --porcelain | egrep "^AM" | cut -c 4- | egrep ".php$"`

if [ "$S" != "" ]
then
    printf "Un-staged Files found!"
    fail "Checks would be run against the un-staged files which is bad."
fi


# Determine if a file list was passed in
STAGED_FILES=`git diff --name-only --cached --diff-filter=d | egrep ".php$"`

if [ "$#" -eq 2 ]
then
    oIFS=$IFS
    IFS='
    '
    SFILES="$2"
    IFS=$oIFS
fi


# Check for syntax errors in staged files
SFILES=${SFILES:-$STAGED_FILES}

printf "\nRunning PHP Linter...\n"
for FILE in $SFILES
do
    php -l -d display_errors=0 $APP_PATH/$FILE
    if [ $? != 0 ]
    then
        fail "You must fix errors before committing"
    fi
    FILES="$FILES $APP_PATH/$FILE"
    printf "\nPHP Lint Check Completed\n\n\n"
done 

# Run CodeSniffer against PHP staged files only looking for errors
CSF=`git status --porcelain | grep "^A" | cut -c 4- | egrep ".php$"  | egrep -v "/req/"`

if [ "$CSF" != "" ]
then
    printf "\n\nRunning Code Sniffer...\n"
    $V/bin/phpcs  $CSF
    if [ $? != 0 ]
    then
        fail "Fix standards violations before committing"
    fi
fi

# Run CodeSniffer using the settings in its config file
$V/bin/phpcs $APP_PATH
if [ $? != 0 ]
then
    fail "Fix standards violations before committing. Check the codeSniffReport in the logs directory for more information"
fi

cd $D

exit $?
