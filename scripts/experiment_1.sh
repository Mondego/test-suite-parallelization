#!/bin/bash

##################################################################
# This script runs the experiment 1. This script must be situated
# with the projects folder.
##################################################################

parallel=("methods" "classes" "classesAndMethods" "both" "suitesAndClasses" "suitesAndMethods" "suites")
PROJECTS="projects"
fork=1
thread=1

while [ $fork -le 110 ];
do
	while [ $thread -le 21 ];
	do
		for i in {0..6};
		do
			./run_parallel.sh $PROJECTS $fork $thread true ${parallel[$i]}
		done
		thread=$(( thread+5 ))	
	done
	fork=$(( fork+10 ))	
done