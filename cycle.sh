#!/bin/bash

main_repo="/home/bilalov/study/experiments"
generator="/home/bilalov/study/time-series-generator"

START=0
END=50
PREFIX=$1

if [ $# -eq 0 ]
then 
	PREFIX=''
fi

for ((i=START; i<END; i++))
do
	dataset=$PREFIX'dataset'$i
	echo 'create '$dataset
	cd $generator
	$generator/generate_axiomlib.sh "$dataset"
	cd $main_repo
	echo 'run clust simple'
	./run_experiment.sh config.clust.simple.cfg	$generator/"$dataset"
	echo 'run clust genetic'
	./run_experiment.sh config.clust.genetic.cfg $generator/"$dataset"	
	echo 'run simple genetic'
	./run_experiment.sh config.simple.genetic.cfg $generator/"$dataset"	
	echo 'run simple simple'
	./run_experiment.sh config.simple.simple.cfg $generator/"$dataset"	
done
