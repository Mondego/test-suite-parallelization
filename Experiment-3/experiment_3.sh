#!/bin/bash

##################################################################
# This script runs the experiment 2. This script must be situated
# with the `projects\` folder and in the same directory as surefirereportparser
##################################################################

BASE_DIRECTORY=$PWD

DATASET_DIRECTORY=$BASE_DIRECTORY"/projects"

# Skip all optional plugins, extensions
MAVEN_SKIPS="-Drat.skip=true -Dmaven.javadoc.skip=true \
             -Djacoco.skip=true -Dcheckstyle.skip=true \
             -Dfindbugs.skip=true -Dcobertura.skip=true \
             -Dpmd.skip=true -Dcpd.skip=true \
             -Dmaven.test.failure.ignore=true\
             -fae"

SUREFIRE_REPORT_PARSER=$BASE_DIRECTORY"/surefirereportparser"

# Download this project from GitHub. This simple maven project parses the number of 
# successful, failed, skipped, and errored tests.
if [[ ! -e $SUREFIRE_REPORT_PARSER ]]; then
    echo " ***** Need surefirereportparser in this directory *****"
    exit 1
fi

cd $SUREFIRE_REPORT_PARSER
mvn -q compile

if [[ ! -e $DATASET_DIRECTORY ]]; then
    echo " ***** No test projects in this directory *****"
    echo " ***** Place the test projects inside a folder named 'projects' and rerun *****"    
    exit 1
fi

LOG_DIRECTORY=$BASE_DIRECTORY"/LOG"
if [[ ! -e $LOG_DIRECTORY ]]; then
    echo " ***** No LOG of projects in this directory *****"
    echo " ***** Place the projects LOGs inside a folder named 'LOG' and rerun *****"    
    exit 1
fi

if [[ ! -e GenerateMavenTestConfig.java ]]; then
	echo "No GenerateMavenTestConfig.java in this directory"
	echo "Copy GenerateMavenTestConfig.java here and rerun the script"
fi


# All possible type of parallelism
parallel=("methods" "classes" "classesAndMethods" "suites" "suitesAndClasses" "suitesAndMethods")

# For each project run the experiment
for project in $(ls $LOG_DIRECTORY); 
do
	echo "*****************  "$project"  *****************"
	
	project_directory=$DATASET_DIRECTORY'/'$project

 	fork=1	
	while [ $fork -le 100 ];
	do
		thread=1
		while [ $thread -le 16 ];
		do
			for i in {0..5};
			do
				CONFIGURATION=""
				parallel_type=${parallel[$i]}

				# In the beginning it is just sequential retest, thus no config param at all.
				if [ "$fork" -eq 1 ] && [ "$thread" -eq 1 ]; 
				then
					CONFIGURATION_LOG_DIR="sequential"
				else 
					CONFIGURATION_LOG_DIR=$fork'-'$thread'-'$parallel_type
				fi

				project_log_directory=$LOG_DIRECTORY'/'$project'/'$CONFIGURATION_LOG_DIR
				
				if [[ ! -e $project_log_directory ]]; then
				    echo "Project log directory does not exist"
				    continue
				fi
			 	
			 	cd $BASE_DIRECTORY
			 	
			 	Dtest_failure=$(java -cp . GenerateMavenTestConfig $project_log_directory'/FAILURE.txt')
			 	Dtest_error=$(java -cp . GenerateMavenTestConfig $project_log_directory'/ERROR.txt')
			 	Dtest=$Dtest_error$Dtest_failure

			 	cd $project_directory
			 	mvn clean compile $MAVEN_SKIPS
			 	
			 	result=$(mvn test -Dtest=$Dtest $MAVEN_SKIPS)

				time=( $(echo "$result" | grep --text "\[INFO\] Total time:" | tail -n 1) )

			 	project_log_directory_maven_sequential=$project_log_directory"/SEQUENTIAL_RUN_BY_MAVEN/"
			 	mkdir -p $project_log_directory_maven_sequential

				mvn surefire-report:report-only $MAVEN_SKIPS
				num=1
			 	for surefire_report in $( find . -name surefire-report.html );
			 	do
			 		report=$project_log_directory_maven_sequential'/report_'$num'.html'
					cat $surefire_report >> $report
					(( num++ ))	
			 	done

			 	# Parse surefire reports to get the number of success, failure, skip, and error
			 	cd $SUREFIRE_REPORT_PARSER
			 	numbers=$(mvn -q compile exec:java -Dexec.args="$project_log_directory")
				cd $project_directory


				echo $project, $CONFIGURATION_LOG_DIR, $time, $numbers >> $LOG_DIRECTORY'/'$project'/FAIL_TEST_SEQ_RUN_BY_MAVEN.csv'


			done
			thread=$(( thread+5 ))	
		done
		fork=$(( fork+20 ))	
	done
done
