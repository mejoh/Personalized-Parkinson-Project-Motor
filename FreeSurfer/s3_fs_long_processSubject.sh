#!/bin/bash

# Re-run the full recon-all pipeline for each subject's sessions

# v="7.3.2"
# fs_dir=/project/3024006.02/Analyses/FreeSurfer_v${v}
# subject='PD_sub-POMU00094252BA30B84F'
# timepoint='t1'

# Set the environment and select the FreeSurfer version your working group is working with, i.e., 5.3, 6.0, 7.1. 
module unload freesurfer; module load freesurfer/${v}
export FREESURFER_HOME="/opt/freesurfer/${v}"
export SUBJECTS_DIR=${fs_dir}/outputs
source $FREESURFER_HOME/SetUpFreeSurfer.sh

cd $SUBJECTS_DIR

if [[ -d ${subject}_${timepoint} ]]; then

	$FREESURFER_HOME/bin/recon-all -long ${subject}_${timepoint} ${subject} -all -threads 2

else

	echo "Exiting: No inputs to be processed!"

fi
