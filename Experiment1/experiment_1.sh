#!/bin/bash

##################################################################
# This script runs the experiment 1. This script must be situated
# with the `projects\` folder.
##################################################################
BASE_DIRECTORY=$PWD
MAVEN_POM_PROCESSOR=$PWD"/MavenPOMProcessor"
SUREFIRE_REPORT_PARSER=$PWD"/surefirereportparser"

# Compile the tools
cd $MAVEN_POM_PROCESSOR
mvn -q compile
cd $SUREFIRE_REPORT_PARSER
mvn -q compile
cd $BASE_DIRECTORY

parallel=("methods" "classes" "classesAndMethods" "suitesAndClasses" "suitesAndMethods" "suites")
PROJECTS="projects"
fork=1

while [ $fork -le 81 ];
do
	thread=1
	while [ $thread -le 10 ];
	do
		for i in {0..5};
		do
			./run_parallel.sh $PROJECTS $fork $thread true ${parallel[$i]}
		done
		thread=$(( thread+3 ))	
	done
	fork=$(( fork+16 ))	
done

