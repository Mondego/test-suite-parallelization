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
PROJECT_DIRECTORY=$4

CLASSPATH_FILE=$LOG_DIRECTORY"/"$PROJECT_NAME".txt"

TIMEFORMAT=%R

CLASSPATH=$(java -cp . GenerateClassPath $PROJECT_DIRECTORY)

ERROR_TEST_RUN_ISOLATION=$LOG_DIRECTORY"/FAIL_TEST_RUN_ISOLATION.csv"

echo " Project, Test, Success ?, Time (sec), Log" > $ERROR_TEST_RUN_ISOLATION

while read -r line; 
do	
	status=FAILURE
	echo "~~ RUNNING "$line" ~~"	
	echo " "

	result=$(java -cp $CLASSPATH TestRunner $line)
	
	echo "***********************************************************"

	SAVEIFS=$IFS   
	IFS=$'\n'      
	names=($result) 
	IFS=$SAVEIFS   

	length=0

	for (( i=0; i<${#names[@]}; i++ ))
	do
	    length=$(( length+1 ))	
	    echo $length"	*********	"${names[$i]}	
	done

	echo $PROJECT_NAME" , "$line" , "${names[$length - 3]}" , "${names[$length - 2]}" , "${names[$length - 1]} >> $ERROR_TEST_RUN_ISOLATION

	echo "***********************************************************"

done < "$ERROR_LOG"