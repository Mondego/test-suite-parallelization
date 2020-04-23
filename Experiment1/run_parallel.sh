#!/bin/bash

#####################################################################################
# This script runs the entire test suite of all the projects in a dataset           #
# one by one. The script must be in the same directory as surefirereportparser 		#
# It takes the following arguments - 												#
#		i. directory of the dataset (mandatory)										#
#		ii. Fork Count (optional)													#
#		iii. Thread Count (optional)												#
#		iv.	Reuse Forks (optional and boolean)										#	
#		v. parallel (optional, can have values -- methods, classes, both, suites, 	#
#			suitesAndClasses, suitesAndMethods, classesAndMethods, or all)			#
# Example: ./run_parallel.sh projects/ 45 10 true classes                           #
#####################################################################################

BASE_DIRECTORY=$PWD
DATASET_DIRECTORY=$PWD"/"$1
LOG_DIRECTORY=$PWD"/LOG"
MAVEN_POM_PROCESSOR=$PWD"/MavenPOMProcessor"
SUREFIRE_REPORT_PARSER=$PWD"/surefirereportparser"

# Skip all optional plugins, extensions
MAVEN_SKIPS="-Drat.skip=true -Dmaven.javadoc.skip=true \
             -Djacoco.skip=true -Dcheckstyle.skip=true \
             -Dfindbugs.skip=true -Dcobertura.skip=true \
             -Dpmd.skip=true -Dcpd.skip=true \
             -Dmaven.test.failure.ignore=true"

# Get current time stamp
DATE_WITH_TIME=`date "+%m-%d-%H-%M-%S"`

# If no configuration information is passed then the experiment is only sequential 'retest'
if [ $# -eq 5 ]; 
then
	CONFIGURATION_LOG_DIR=$2'-'$3'-'$4'-'$5
else 
	CONFIGURATION_LOG_DIR="retest"
fi

# Create Log directory and Summary CSV file header
mkdir -p $LOG_DIRECTORY
SUMMARY_LOG=$LOG_DIRECTORY"/SUMMARY.csv"
if [[ ! -f "$SUMMARY_LOG" ]]; then
    echo " project, status, time (sec), success, error, failure, skipped, date, forkCount, threadCount, reuseForks, parallel" > $SUMMARY_LOG
fi

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

# For each project run the experiment
for project in $(ls $DATASET_DIRECTORY); do
	
	echo "*****************  "$project"  *****************"
	project_directory=$DATASET_DIRECTORY'/'$project

	project_log_directory=$LOG_DIRECTORY'/'$project'/'$CONFIGURATION_LOG_DIR'/'$DATE_WITH_TIME
	mkdir -p $project_log_directory

	# This line changes surefire version to make the project compatible.
    cd $MAVEN_POM_PROCESSOR
    mvn -q compile exec:java -Dexec.args="$project_directory maven-surefire-plugin 2.19.1"
    cd $project_directory

	# run test based on the param
	result=$(mvn test $CONFIGURATION $MAVEN_SKIPS -fae)
	echo "$result"

	# Grather surefire report and transfer each report to the Log directory.
	# For multimodule projects multiple surefire reports are being generated.
	# That's why we have to enumerate them.
	mvn surefire-report:report-only $MAVEN_SKIPS
	num=1
 	for surefire_report in $( find . -name surefire-report.html );
 	do
 		report=$project_log_directory'/report_'$num'.html'
		cat $surefire_report >> $report
		(( num++ ))	
 	done

 	# Parse surefire reports to get the number of success, failure, skip, and error
 	cd $SUREFIRE_REPORT_PARSER
 	numbers=$(mvn -q compile exec:java -Dexec.args="$project_log_directory")
	cd $project_directory
 	
 	time=( $(echo "$result" | grep --text "\[INFO\] Total time:" | tail -n 1) )
 	
 	if [[ "$r" == *"[ERROR]"* ]]; 
 	then 
 		echo $project" , ERROR , "${time[3]}" , "$numbers" , "$DATE_WITH_TIME" , "$2" , "$3" , "$4" , "$5"" >> $SUMMARY_LOG
 	else
 		echo $project" , SUCCESS , "${time[3]}" , "$numbers" , "$DATE_WITH_TIME" , "$2" , "$3" , "$4" , "$5"" >> $SUMMARY_LOG
 	fi

 	cd $DATASET_DIRECTORY
done
