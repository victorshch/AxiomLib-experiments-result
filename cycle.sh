#!/bin/bash

main_repo="/home/bilalov/study/experiments"
generator="/home/bilalov/study/time-series-generator"

START=$1
END=100
PREFIX=$2

if [ $# -eq 0 ]
then 
	START=0
	PREFIX=''
fi

for ((i=START; i<END; i++))
do
	echo 'create dataset'$i
	cd $generator
	$generator/generate_axiomlib.sh $PREFIXdataset$i
	cd $main_repo
	echo 'run clust simple'
	./run_experiment.sh config.clust.simple.cfg	$generator/$PREFIXdataset$i
	echo 'run clust genetic'
	./run_experiment.sh config.clust.genetic.cfg $generator/$PREFIXdataset$i	
	echo 'run simple genetic'
	./run_experiment.sh config.simple.genetic.cfg $generator/$PREFIXdataset$i	
	echo 'run simple simple'
	./run_experiment.sh config.simple.simple.cfg $generator/$PREFIXdataset$i	
done
