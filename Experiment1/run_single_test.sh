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

if [[ ! -e $DATASET_DIRECTORY ]]; then
    echo " ***** No test projects in this directory *****"
    echo " ***** Place the test projects inside a folder named 'projects' and rerun *****"    
    exit 1
fi

#Directory of the neseccary tools
MAVEN_POM_PROCESSOR=$BASE_DIRECTORY"/MavenPOMProcessor"
SUREFIRE_REPORT_PARSER=$BASE_DIRECTORY"/surefirereportparser"

# Compile the tools
cd $MAVEN_POM_PROCESSOR
mvn -q compile
cd $SUREFIRE_REPORT_PARSER
mvn -q compile
cd $BASE_DIRECTORY

# This line changes surefire version to make the project compatible.
cd $MAVEN_POM_PROCESSOR
mvn -q compile exec:java -Dexec.args="$PROJECT_DIRECTORY maven-surefire-plugin 2.19.1"
cd $project_directory

# Download this project from GitHub. This simple maven project is needed to convert 
# Surefire version 2.19.1
if [[ ! -e $MAVEN_POM_PROCESSOR ]]; then
    git clone https://github.com/marufzaber/MavenPOMProcessor
fi

# Download this project from GitHub. This simple maven project parses the number of 
# successful, failed, skipped, and errored tests.
if [[ ! -e $SUREFIRE_REPORT_PARSER ]]; then
    echo " ***** Need surefirereportparser in this directory *****"
    exit 1
fi

# Compile the tools
cd $MAVEN_POM_PROCESSOR
mvn -q compile
cd $SUREFIRE_REPORT_PARSER
mvn -q compile
cd $BASE_DIRECTORY

# Skip all optional plugins, extensions
MAVEN_SKIPS="-Drat.skip=true -Dmaven.javadoc.skip=true \
             -Djacoco.skip=true -Dcheckstyle.skip=true \
             -Dfindbugs.skip=true -Dcobertura.skip=true \
             -Dpmd.skip=true -Dcpd.skip=true \
             -Dmaven.test.failure.ignore=true \
             -DfailIfNoTests=false"

ERROR_TEST_RUN_ISOLATION=$LOG_DIRECTORY"/ERROR_TEST_RUN_ISOLATION.csv"
echo " project, test, time (sec), success ? " > $ERROR_TEST_RUN_ISOLATION


while read -r line; 
do	
	echo "***************** RUNNING "$line" in isolation *****************"	
	cd $PROJECT_DIRECTORY
	mvn clean test-compile $MAVEN_SKIPS
	
    result=$(timeout -s SIGKILL 20m mvn test -Dtest=$line $MAVEN_SKIPS -fae)
    
    # If timeout happened then skip this iteration
	if [ "$?" -eq 137 ]; 
	then
 		echo $PROJECT_NAME" , " $line ", - , TIMEOUT" >> $ERROR_TEST_RUN_ISOLATION
 		continue
	fi
	time=( $(echo "$result" | grep --text "\[INFO\] Total time:" | tail -n 1) )
	
	# Log particular tests that failed and errored. These tests will have to be run separately then.
 	cd $SUREFIRE_REPORT_PARSER 
	result=$(mvn -q exec:java@xml-cli -Dexec.args="$project_directory $line")

 	cd $PROJECT_DIRECTORY
 	if grep "$config_status" <<< "SUCCESSFUL" ; 
	then 
 		status="SUCCESSFUL"
 	else
 		status="FAILURE/ERROR"
	fi

 	echo $PROJECT_NAME" , "$line" , "${time[3]}" , "$status >> $ERROR_TEST_RUN_ISOLATION

done < "$ERROR_LOG"