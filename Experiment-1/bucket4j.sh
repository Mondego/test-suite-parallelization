#!/bin/bash

##################################################################
# This script runs a single test and captures whether it was successful or not
# and how much time it took. This script takes three arguments- project name,
# log directory, and error log file directory. This script must be situated
# with the `projects\` folder and in the same directory as surefirereportparser
##################################################################
BASE_DIRECTORY=$PWD
PROJECT_NAME=$1
LOG_DIRECTORY=$2
ERROR_LOG=$3
DATASET_DIRECTORY=$BASE_DIRECTORY"/projects"
PROJECT_DIRECTORY=$DATASET_DIRECTORY'/'$PROJECT_NAME
CLASSPATH_FILE=$BASE_DIRECTORY"/classpath.txt"

if [[ ! -e TestRunner.java]]; then
	echo "No test runner found in this directory"
	echo "Copy TestRunner.java here and rerun the script"

if [[ ! -e $DATASET_DIRECTORY ]]; then
    echo " ***** No test projects in this directory *****"
    echo " ***** Place the test projects inside a folder named 'projects' and rerun *****"    
    exit 1
fi


CLASSPATH=$(cat $CLASSPATH_FILE)

#compile testrunner
javac -cp $CLASSPATH TestRunner.java


ERROR_TEST_RUN_ISOLATION=$LOG_DIRECTORY"/ERROR_TEST_RUN_ISOLATION.csv"

echo " project, test, time (sec), success ? " > $ERROR_TEST_RUN_ISOLATION


while read -r line; 
do	
	echo "***************** RUNNING "$line" in isolation *****************"	

	TIME=$((result=$(time java -cp $CLASSPATH TestRunner $line) >/dev/null) 2>&1)
	
 	if grep "$result" <<< "SUCCESSFUL" ; 
	then 
 		status="SUCCESSFUL"
 	else
 		status="FAILURE/ERROR"
	fi

 	echo $PROJECT_NAME" , "$line" , "$TIME" , "$status >> $ERROR_TEST_RUN_ISOLATION

done < "$ERROR_LOG"