#!/bin/bash

##################
# this script splits the content of a large directory into 5 batches. This is useful to
# split a large dataset into batches. It takes the directory which it will divide as input
##################

current_dir=$PWD

mkdir -p BATCH-1 BATCH-2 BATCH-3 BATCH-4 BATCH-5

x=("$current_dir/BATCH-1" "$current_dir/BATCH-2" "$current_dir/BATCH-3" "$current_dir/BATCH-4" "$current_dir/BATCH-5")

c=0
for f in $(ls $1)
do
    mv $1"/"$f "${x[c]}"
    c=$(( (c+1)%5 ))
done