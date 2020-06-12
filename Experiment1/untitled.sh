./bucket4j.sh bucket4j /home/maruf /home/maruf/Experiment1/LOG/04-30-13-42-28/bucket4j/1-16-suitesAndClasses/ERROR.txt

#!/bin/bash

##################################################################
# This script runs the experiment 1. This script must be situated
# with the `projects\` folder and in the same directory as surefirereportparser
##################################################################
BASE_DIRECTORY=$PWD

DATASET_DIRECTORY=$BASE_DIRECTORY"/projects"
if [[ ! -e $DATASET_DIRECTORY ]]; then
    echo " ***** No test projects in this directory *****"
    echo " ***** Place the test projects inside a folder named 'projects' and rerun *****"    
    exit 1
fi

#Directory of the neseccary tools
MAVEN_POM_PROCESSOR=$BASE_DIRECTORY"/MavenPOMProcessor"
SUREFIRE_REPORT_PARSER=$BASE_DIRECTORY"/surefirereportparser"

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

# All possible type of parallelism
parallel=("methods" "classes" "classesAndMethods" "suites" "suitesAndClasses" "suitesAndMethods")

# Skip all optional plugins, extensions
MAVEN_SKIPS="-Drat.skip=true -Dmaven.javadoc.skip=true \
             -Djacoco.skip=true -Dcheckstyle.skip=true \
             -Dfindbugs.skip=true -Dcobertura.skip=true \
             -Dpmd.skip=true -Dcpd.skip=true \
             -Dmaven.test.failure.ignore=true"

# Get current time stamp
DATE_WITH_TIME=`date "+%m-%d-%H-%M-%S"`
LOG_DIRECTORY=$BASE_DIRECTORY"/LOG/"$DATE_WITH_TIME
COMPLETED_DIRECTORY=$BASE_DIRECTORY"/LOG/COMPLETED"

# Create Log directory and Completion directory
mkdir -p $LOG_DIRECTORY
mkdir -p $COMPLETED_DIRECTORY

SUMMARY_LOG=$BASE_DIRECTORY"/LOG/SUMMARY.csv"
COMPLETION_LOG=$BASE_DIRECTORY"/LOG/COMPLETED_PROJECTS.txt"
TIMEOUT_LOG=$LOG_DIRECTORY"/TIMEOUT.csv"
touch $COMPLETION_LOG #initialize it
touch $TIMEOUT_LOG #initialize it
touch $SUMMARY_LOG #initialize it
#initialize summary header
echo " project, status, time (sec), success, error, failure, skipped, date, forkCount, threadCount, reuseForks, parallel" > $SUMMARY_LOG

# For each project run the experiment
for project in $(ls $DATASET_DIRECTORY); 
do
	echo "*****************  "$project"  *****************"
	project_directory=$DATASET_DIRECTORY'/'$project

	COMPLETED_CONFIGS_LOG=$COMPLETED_DIRECTORY"/"$project"_completed_config.txt"
	touch $COMPLETED_CONFIGS_LOG #initialize it

	# If the project has been run for all configs then skip it. 
	completion_status=$(cat $COMPLETION_LOG)
	if [[ "$completion_status" == *"$project"* ]]; 
 	then 
 		echo "Project : "$project" has been analyzed already"
 		continue
 	fi

 	# If the project has been timed out before then skip it too.
 	timeout_status=$(cat $TIMEOUT_LOG)
	if [[ "$timeout_status" == *"$project"* ]]; 
 	then 
 		echo "Project : "$project" had timed out before"
 		continue
 	fi

	# This line changes surefire version to make the project compatible.
    cd $MAVEN_POM_PROCESSOR
    mvn -q compile exec:java -Dexec.args="$project_directory maven-surefire-plugin 2.19.1"
    cd $project_directory

 	# Now run tests for all combination of configurations
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
					config_status=$project"sequential"
				else 
					CONFIGURATION_LOG_DIR=$fork'-'$thread'-'$parallel_type
					CONFIGURATION='-DforkCount='$fork' -DthreadCount='$thread' -DreuseForks=true -Dparallel='$parallel_type
					config_status=$project""$CONFIGURATION
				fi

				# If this config has been done before then skip it too.
			 	read_status=$(cat $COMPLETED_CONFIGS_LOG)
				if grep "$config_status" <<< "$read_status" ; 
			 	then 
			 		echo "Project : "$project" Config : "$config_status" had done before"
			 		continue
			 	fi

				project_log_directory=$LOG_DIRECTORY'/'$project'/'$CONFIGURATION_LOG_DIR
				mkdir -p $project_log_directory

			    # run test based on the config with a time of 60 minutes
				echo "******* "$CONFIGURATION" *******"
				result=$(timeout -s SIGKILL 60m mvn test $CONFIGURATION $MAVEN_SKIPS -fae)

				# If timeout happened then skip this iteration
				if [ "$?" -eq 137 ]; 
			 	then
			 		echo $project" , TIMEOUT , - , - , - , -, - , - , "$fork" , "$thread" , true , "$parallel_type"" >> $SUMMARY_LOG
			 		echo $project"" >> $TIMEOUT_LOG
			 		continue
			 	fi

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

			 	if [[ "$result" == *"[INFO] BUILD FAILURE"* ]]; 
			 	then
			 		build_status="ERROR"			 	
			 	else
			 		build_status="SUCCESS"			 	
			 	fi

			 	echo $project" , "$build_status" , "${time[3]}" , "$numbers" , "$DATE_WITH_TIME" , "$fork" , "$thread" , true , "$parallel_type"" >> $SUMMARY_LOG

			 	# Log particular tests that failed and errored. These tests will have to be run separately then.
			 	cd $SUREFIRE_REPORT_PARSER 
				mvn -q exec:java@xml-cli -Dexec.args="$project_directory $project_log_directory'/ERROR.txt' $project_log_directory'/FAILURE.txt' $project_log_directory'/SKIPPED.txt'"
			 	cd $project_directory

			 	# Log the completed config to a file. So that the same config is not run again
			 	echo $config_status >> $COMPLETED_CONFIGS_LOG
			done
			thread=$(( thread+5 ))	
		done
		fork=$(( fork+20 ))	
	done

	echo $project"" >> $COMPLETION_LOG 
done

