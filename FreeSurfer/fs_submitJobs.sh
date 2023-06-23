#!/bin/bash
# ~/scripts/Personalized-Parkinson-Project-Motor/FreeSurfer/fs_submitJobs.sh

### Description: 
### This script submits one job per subject. Edit the 
### fs_*_processSubject.sh scripts so that it 
### runs the FS longitudinal pipeline from start to finish.

# OPTS
cross=0
base=0
long=1

# Variables that are passed to jobs
version=7.3.2
fs_dir=/project/3024006.02/Analyses/FreeSurfer_v${version}

# Submit a job for each subject
# -o -e Defines locations where log-files are written
# -N Defines the name of the job, can be viewed with 'qstat'
# -v The 'subject' variable is passed on to the submitted script
# -t The timepoints to be processed
# -l Defines the amount of resources to be allocated to each job. Make an estimate!!
# Last line defines the script that each job will submit to the cluster

if [ $cross -eq 1 ]; then

	cd ${fs_dir}/inputs
	subjects=`ls -d *sub-POMU*`
	timepoints=(t1 t2)
	
	for s in ${subjects[@]}; do 
		for t in ${timepoints[@]}; do
			echo "Processing: ${s}, ${t}"
			qsub \
			-o /project/3024006.02/Analyses/FreeSurfer_v7.3.2/logs \
			-e /project/3024006.02/Analyses/FreeSurfer_v7.3.2/logs \
			-N fs_cross_${s}_${t} \
			-v v=${version},fs_dir=${fs_dir},subject=${s},timepoint=${t} \
			-l 'walltime=15:00:00,mem=4gb' \
			~/scripts/Personalized-Parkinson-Project-Motor/FreeSurfer/s1_fs_cross_processSubject.sh
		done
	done
	
fi

if [ $base -eq 1 ]; then

	cd ${fs_dir}/inputs
	subjects=`ls -d *sub-POMU*`
	
	for s in ${subjects[@]}; do
			echo "Processing: ${s}"
			qsub \
			-o /project/3024006.02/Analyses/FreeSurfer_v7.3.2/logs \
			-e /project/3024006.02/Analyses/FreeSurfer_v7.3.2/logs \
			-N fs_base_${s} \
			-v v=${version},fs_dir=${fs_dir},subject=${s} \
			-l 'walltime=12:00:00,mem=4gb' \
			~/scripts/Personalized-Parkinson-Project-Motor/FreeSurfer/s2_fs_base_processSubject.sh
	done
	
fi

if [ $long -eq 1 ]; then

	cd ${fs_dir}/inputs
	subjects=`ls -d *sub-POMU*`
	timepoints=(t1 t2)
	
	for s in ${subjects[@]}; do 
		for t in ${timepoints[@]}; do
			echo "Processing: ${s}, ${t}"
			qsub \
			-o /project/3024006.02/Analyses/FreeSurfer_v7.3.2/logs \
			-e /project/3024006.02/Analyses/FreeSurfer_v7.3.2/logs \
			-N fs_long_${s}_${t} \
			-v v=${version},fs_dir=${fs_dir},subject=${s},timepoint=${t} \
			-l 'walltime=12:00:00,mem=4gb' \
			~/scripts/Personalized-Parkinson-Project-Motor/FreeSurfer/s3_fs_long_processSubject.sh
		done
	done

fi



