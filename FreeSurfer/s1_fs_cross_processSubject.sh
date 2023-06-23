#!/bin/bash

# This script will run the full recon-all pipeline for each subject's sessions

# v="7.3.2"
# fs_dir=/project/3024006.02/Analyses/FreeSurfer_v${v}
# subject='PD_sub-POMU6E2895037F9D639D'
# timepoint='t2'

# Set the environment and select the FreeSurfer version your working group is working with, i.e., 5.3, 6.0, 7.1. 
module unload freesurfer; module load freesurfer/${v}
export FREESURFER_HOME="/opt/freesurfer/${v}"
export SUBJECTS_DIR=${fs_dir}/outputs
source $FREESURFER_HOME/SetUpFreeSurfer.sh

cd $SUBJECTS_DIR

input_t1=`find ${fs_dir}/inputs/${subject}/*_${timepoint}_T1w.nii.gz`
if [[ -f $input_t1 ]]; then

	$FREESURFER_HOME/bin/recon-all -all -i ${input_t1} -subjid ${subject}_${timepoint} -no-isrunning 
	
else

  echo "Exiting: No inputs to be processed!"
	
fi
