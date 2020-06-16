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

TIMEFORMAT=%R

if [[ ! -e TestRunner.java ]]; then
	echo "No test runner found in this directory"
	echo "Copy TestRunner.java here and rerun the script"
fi

if [[ ! -e GenerateClassPath.java ]]; then
	echo "No ClassPathGenerator found in this directory"
	echo "Copy GenerateClassPath.java here and rerun the script"
fi


if [[ ! -e $CLASSPATH_FILE ]]; then
    echo " ***** No classpath txt in this directory *****"
    echo " ***** Place classpath.txt in this folder and rerun *****"    
    exit 1
fi

javac GenerateClassPath.java


CLASSPATH=$(java -cp . GenerateClassPath /home/maruf/bucket4j)

#compile testrunner
javac -cp $CLASSPATH TestRunner.java


ERROR_TEST_RUN_ISOLATION=$LOG_DIRECTORY"/ERROR_TEST_RUN_ISOLATION.csv"

echo " Project, Test, Time (sec), Success ? , Log" > $ERROR_TEST_RUN_ISOLATION


while read -r line; 
do	
	status=FAILURE
	echo "~~ RUNNING "$line" ~~"	
	echo " "

	result=$(java -cp $CLASSPATH TestRunner $line)

#	TIME=$((result=$(time java -cp $CLASSPATH TestRunner $line) >/dev/null) 2>&1)
	echo $result
 	if grep "$result" <<< "SUCCESSFUL" ; 
	then 
		echo "***** HEREHE +++++++"
 		status="SUCCESSFUL"
 	else
 		status="FAILURE/ERROR"
	fi
	
	echo "***********************************************************"

	SAVEIFS=$IFS   
	IFS=$'\n'      
	names=($result) 
	IFS=$SAVEIFS   

	length=0

	for (( i=0; i<${#names[@]}; i++ ))
	do
	    length=$(( length+1 ))	
	done


	echo "${names[0]}""+++++++++++++++++++++ 0 "
	echo "${names[1]}""+++++++++++++++++++++ 1 "
	echo "${names[2]}""+++++++++++++++++++++ 2 "

	if [ $length -eq 2 ] ; then
    	echo $PROJECT_NAME" , "$line" , "${names[0]}" , "$status" , "${names[1]} #>> $ERROR_TEST_RUN_ISOLATION
	else
		#echo $PROJECT_NAME" , "$line" , "$TIME" , "$status #>> $ERROR_TEST_RUN_ISOLATION
	    echo $PROJECT_NAME" , "$line" , "${names[1]}" , "$status" , "${names[2]} #>> $ERROR_TEST_RUN_ISOLATION
	fi

	echo "***********************************************************"

done < "$ERROR_LOG"


