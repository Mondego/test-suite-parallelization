#!/bin/bash

#####################################################################################
# This script runs the entire test suite of all the projects in a dataset           #
# one by one. It takes the following arguments - 									#
#		i. directory of the dataset (mandatory)										#
#		ii. Configuration (optional)												#
#		iii. Fork Count (optional)													#
#		iv. Thread Count (optional)													#
# Example: ./run_parallel.sh \														#
#			projects/ \																#
#			"-DforkCount=45 -DreuseForks=true -Dparallel=classes -DthreadCount=10" \#
#			45 \																	#
#			10 																		#	
#####################################################################################


BASE_DIRECTORY=$PWD
DATASET_DIRECTORY=$PWD"/"$1
LOG_DIRECTORY=$PWD"/LOG"

MAVEN_SKIPS="-Drat.skip=true -Dmaven.javadoc.skip=true \
             -Djacoco.skip=true -Dcheckstyle.skip=true \
             -Dfindbugs.skip=true -Dcobertura.skip=true \
             -Dpmd.skip=true -Dcpd.skip=true \
             -Dmaven.test.failure.ignore=true"

DATE_WITH_TIME=`date "+%m-%d-%H-%M-%S"`

if [ $# -eq 4 ]; 
then
	CONFIGURATION=$2
	CONFIGURATION_LOG_DIR=$3'-'$4
else 
	CONFIGURATION_LOG_DIR="1-1"
fi

mkdir -p $LOG_DIRECTORY
SUMMARY_LOG=$LOG_DIRECTORY"/SUMMARY.csv"

# Create Summary CSV file header
if [[ ! -f "$SUMMARY_LOG" ]]; then
    echo " project, status, date" > $SUMMARY_LOG
fi

for project in $(ls $DATASET_DIRECTORY); do
	echo "*****************  "$project"  *****************"
	
	project_log_directory=$LOG_DIRECTORY'/'$project'/'$CONFIGURATION_LOG_DIR'/'$DATE_WITH_TIME
	mkdir -p $project_log_directory
	
	cd $DATASET_DIRECTORY'/'$project
	result=$(mvn test $CONFIGURATION $MAVEN_SKIPS -fae)

	mvn surefire-report:report-only $MAVEN_SKIPS

	num=1
 	for surefire_report in $( find . -name surefire-report.html );
 	do
 		report=$project_log_directory'/'$project'_'$num'.html'
		cat $surefire_report >> $report
		(( num++ ))	
 	done

 	if [[ "$r" == *"[ERROR]"* ]]; 
 	then 
 		echo $project", ERROR ," $DATE_WITH_TIME; 
 	else
 		echo $project", SUCCESS ," $DATE_WITH_TIME;
 	fi

 	cd $DATASET_DIRECTORY
done
