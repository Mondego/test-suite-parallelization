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
             -Dmaven.test.failure.ignore=true"

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

if [[ ! -e TestRunner.java ]]; then
	echo "No test runner found in this directory"
	echo "Copy TestRunner.java here and rerun the script"
fi

if [[ ! -e GenerateClassPath.java ]]; then
	echo "No ClassPathGenerator found in this directory"
	echo "Copy GenerateClassPath.java here and rerun the script"
fi

javac GenerateClassPath.java

# All possible type of parallelism
parallel=("methods" "classes" "classesAndMethods" "suites" "suitesAndClasses" "suitesAndMethods")

# For each project run the experiment
for project in $(ls $LOG_DIRECTORY); 
do
	echo "*****************  "$project"  *****************"
	
	project_directory=$DATASET_DIRECTORY'/'$project

	CLASSPATH=$(java -cp . GenerateClassPath $project_directory)

	#compile testrunner
	javac -cp $CLASSPATH TestRunner.java

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
			 	
			 	./run_failed_tests.sh $project $project_log_directory $project_log_directory'/FAILURE.txt' $project_directory
			 	./run_failed_tests.sh $project $project_log_directory $project_log_directory'/ERROR.txt' $project_directory

			 	Dtest=$(java -cp . GenerateMavenTestConfig $project_log_directory'/FAILURE.txt')
			 	cd $project_directory
			 	mvn test -Dtest=$Dtest $MAVEN_SKIPS

			done
			thread=$(( thread+5 ))	
		done
		fork=$(( fork+20 ))	
	done
done
