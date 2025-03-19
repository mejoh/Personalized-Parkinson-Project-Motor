#!/bin/bash
# ~/scripts/Personalized-Parkinson-Project-Motor/FreeSurfer/fs_submitJobs.sh

### Description: 
### Submit one job per subject. Edit the 
### fs_*_processSubject.sh scripts so that it 
### runs the FS longitudinal pipeline from start to finish.
### Note that subjects that already have output will not be processed by FS

# OPTS
cross=1
base=0
long=0

# Variables that are passed to jobs
version=7.3.2
fs_dir=/project/3022026.01/pep/bids/derivatives/freesurfer_v${version}

# Submit a job for each subject
# -o -e:location of log files
# -N: name of job
# -v: Subject to be processed
# -t: The timepoint to be processed
# -l: Resources allocated to job
# Last line defines the script that each job will submit to the cluster

if [ $cross -eq 1 ]; then

  # Estimated resources: ~6-8h per subject, 2.5gb
	# Note that some subjects can take much longer (+20h)

	cd ${fs_dir}/inputs
	subjects=`ls -d *sub-POMU*`
	# subjects=(sub-POMU6059DC1B31E11124 sub-POMU0E19B895DF700AB0 sub-POMU100B8EB93AAE67A7 sub-POMU0CCCA6B887698DA6 sub-POMU0C7CB0F2155DE5AB sub-POMU0C9C8D543994FEDC sub-POMU0E19B895DF700AB0 sub-POMU0C9C8D543994FEDC)
	# subjects=(sub-POMU56F70F8137CF0C55)
	timepoints=(t1 t2)
	
	for s in ${subjects[@]}; do 
		for t in ${timepoints[@]}; do
			echo "Processing: ${s}, ${t}"
			qsub \
			-o /project/3022026.01/pep/bids/derivatives/freesurfer_v7.3.2/logs \
			-e /project/3022026.01/pep/bids/derivatives/freesurfer_v7.3.2/logs \
			-N fs_cross_${s}_${t} \
			-v v=${version},fs_dir=${fs_dir},subject=${s},timepoint=${t} \
			-l 'nodes=1:ppn=2,walltime=20:00:00,mem=7gb' \
			~/scripts/Personalized-Parkinson-Project-Motor/FreeSurfer/s1_fs_cross_processSubject.sh
		done
	done
	
fi

if [ $base -eq 1 ]; then

  # Estimated resources: ~6-8h per subject, 2.5gb
	# Note that some subjects can take much longer (+20h)

	cd ${fs_dir}/inputs
	subjects=`ls -d *sub-POMU*`
	
	for s in ${subjects[@]}; do
			echo "Processing: ${s}"
			qsub \
			-o /project/3022026.01/pep/bids/derivatives/freesurfer_v7.3.2/logs \
			-e /project/3022026.01/pep/bids/derivatives/freesurfer_v7.3.2/logs \
			-N fs_base_${s} \
			-v v=${version},fs_dir=${fs_dir},subject=${s} \
			-l 'nodes=1:ppn=2,walltime=20:00:00,mem=4gb' \
			~/scripts/Personalized-Parkinson-Project-Motor/FreeSurfer/s2_fs_base_processSubject.sh
	done
	
fi

if [ $long -eq 1 ]; then

  # Estimated resources: ~3-4h per subject, 2.5gb

	cd ${fs_dir}/inputs
	subjects=`ls -d *sub-POMU*`
	timepoints=(t1 t2)
	
	for s in ${subjects[@]}; do 
		for t in ${timepoints[@]}; do
			echo "Processing: ${s}, ${t}"
			qsub \
			-o /project/3022026.01/pep/bids/derivatives/freesurfer_v7.3.2/logs \
			-e /project/3022026.01/pep/bids/derivatives/freesurfer_v7.3.2/logs \
			-N fs_long_${s}_${t} \
			-v v=${version},fs_dir=${fs_dir},subject=${s},timepoint=${t} \
			-l 'nodes=1:ppn=2,walltime=20:00:00,mem=4gb' \
			~/scripts/Personalized-Parkinson-Project-Motor/FreeSurfer/s3_fs_long_processSubject.sh
		done
	done

fi



