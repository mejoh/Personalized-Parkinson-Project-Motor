#!/bin/bash

# Run the full recon-all pipeline for each subject's sessions

# v="7.3.2"
# fs_dir=/project/3022026.01/pep/bids/derivatives/freesurfer_v${v}
# subject='sub-POMU6059DC1B31E11124'
# timepoint='t1'

# Set the environment and select the FreeSurfer version your working group is working with, i.e., 5.3, 6.0, 7.1. 
module unload freesurfer; module load freesurfer/${v}
export FREESURFER_HOME="/opt/freesurfer/${v}"
export SUBJECTS_DIR=${fs_dir}/outputs
source $FREESURFER_HOME/SetUpFreeSurfer.sh

cd $SUBJECTS_DIR

inputimg=`find ${fs_dir}/inputs/${subject}/*_${timepoint}_T1w.nii.gz`
outputdir=${fs_dir}/outputs/${subject}_${timepoint}
outputfile=${fs_dir}/outputs/${subject}_${timepoint}/stats/aseg.stats
if [[ -f $inputimg && ! -d $outputdir ]]; then

  echo "Starting recon-all for ${subject}, ${timepoint}"
	$FREESURFER_HOME/bin/recon-all -all -i ${inputimg} -subjid ${subject}_${timepoint} -no-isrunning 

elif [[  -f $inputimg && -d $outputdir && ! -f ${outputfile} ]]; then

  echo "Continuing recon-all (autorecon3) for ${subject}, ${timepoint}"
  $FREESURFER_HOME/bin/recon-all -autorecon2 -subjid ${subject}_${timepoint} -no-isrunning -threads 2
	
elif [[ -f $outputfile ]]; then
	
	echo "Already processed ${subject}, ${timepoint}"
	
else

  echo "Exiting: No inputs to process!"
	
fi
