#!/bin/bash

#This script deletes the projects that does not have a test suite.
#This script expects the following things in the same directory - 
# --
# --- data_clean.sh
# --- projects/
##################
base_dir=$PWD
all_project_dir=$base_dir"/projects"

cd $all_project_dir

for project in $(ls);
do
	echo '************* '$project' *************'
	cd $project
	if mvn -q test -Drat.skip=true -Dmaven.test.failure.ignore=true -Dcheckstyle.skip; then
		echo '************* contains test *************'
		cd ..
	else
		echo '************* does not contains test *************'
		cd ..
		rm -rf $project
	fi
done
