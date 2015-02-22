#!/bin/bash

exec 6>&1 # Save stdout.

echo "Reading config.cfg..."
. config.cfg

cd $main_repo

echo "Create new result directory..."
experiment=$(date +%Y-%m-%d_%H:%M:%S)
output_dir=$main_repo'/'$experiment
mkdir $output_dir
echo $output_dir

cd $output_dir

echo "Create info file"
touch 'info'

echo "Copy config file..."
cp $fmd_config $output_dir

echo "Copy dataset..."
cp -rf $fmd_dataset $output_dir

echo "Copy fmd executable..."
cp $fmd_executable $output_dir

cd $axiomlib
axiomlib_hash=`git rev-parse HEAD`

echo "Write axiomlib hash into info file: $axiomlib_hash"
cd $output_dir
printf "Axiomlib hash: $axiomlib_hash\n" >> 'info'

dataset_name=$(basename "$fmd_dataset")
dataset_dir=$(dirname "$fmd_dataset")

mkdir "axiomsets"

echo "Running $fmd_executable"

start_time=`date +%Y-%m-%d_%H:%M:%S`
printf "Start time: $start_time\n" >> 'info'

exec > "out"

$fmd_executable 'ConfigFile' "$fmd_config" 'BaseDataSetDir' "$dataset_dir" 'DataSet' "$dataset_name"

error=0
if [ $? -ne 0 ]
then
	error=1
fi

exec 1>&6 6>&- # restore stdout

finis_time=`date +%Y-%m-%d_%H:%M:%S`
printf "Finish time: %s" "$finis_time" >> 'info'

if [ $error -ne 0 ]
then
	echo "Error while executing fmd"
	exit error
fi

results=`grep 'stageThree_.*\s*\d*\s*\(\d*, \d*\)' out`

echo "$results" >> 'result'
echo "$results"

read -p "Commit and push? (Y\n)" -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
    cd $main_repo
    git add .
    git commit -m "$experiment"
    git push
fi

echo "Finish"