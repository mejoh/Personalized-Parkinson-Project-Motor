#!/bin/bash

# Creates an unbiased template for each subject based on multiple timepoints
# Note that subjects with only single timepoints must still be processed through this pipeline

# v="7.3.2"
# fs_dir=/project/3024006.02/Analyses/FreeSurfer_v${v}
# subject='PD_sub-POMU00094252BA30B84F'

# Set the environment and select the FreeSurfer version your working group is working with, i.e., 5.3, 6.0, 7.1. 
module unload freesurfer; module load freesurfer/${v}
export FREESURFER_HOME="/opt/freesurfer/${v}"
export SUBJECTS_DIR=${fs_dir}/outputs
source $FREESURFER_HOME/SetUpFreeSurfer.sh

cd $SUBJECTS_DIR

t1=${subject}_t1
t2=${subject}_t2

if [[ -d $t1 && -d $t2 ]]; then

	$FREESURFER_HOME/bin/recon-all -base ${subject} -tp ${t1} -tp ${t2} -all -threads 2
	
elif [[ -d $t1 && ! -d $t2 ]]; then

	$FREESURFER_HOME/bin/recon-all -base ${subject} -tp ${t1} -all -threads 2
	
elif [[ ! -d $t1 && -d $t2 ]]; then

	$FREESURFER_HOME/bin/recon-all -base ${subject} -tp ${t2} -all -threads 2
	
elif [[ ! -d $t1 && ! -d $t2 ]]; then

	echo "Exiting: No inputs to be processed!"
	
fi
