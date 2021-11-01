#!/bin/bash

visit="Visit1"
outputimg="/project/3024006.02/Analyses/Masks/WholeBrain"
#initimg="/project/3024006.02/Analyses/Masks/standard/fsl/MNI152_T1_2mm_brain_mask.nii"
initimg="/project/3022026.01/pep/bids/derivatives/fmriprep/sub-POMU04AD481098C79AF2/ses-POMVisit1/func/sub-POMU04AD481098C79AF2_ses-POMVisit1_task-motor_acq-MB6_run-1_space-MNI152NLin6Asym_desc-brain_mask.nii.gz"
fslmaths $initimg -mul 0 $outputimg

# List of subjects
analysesdir="/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/"
cd $analysesdir
subs=`ls -d sub-POMU*/ses-*$visit`
nrsubs=`ls -d sub-POMU*/ses-*$visit | wc -l`

# Combine fmriprep masks
for i in ${subs[@]}; do
  fmriprepdir="/project/3022026.01/pep/bids/derivatives/fmriprep/$i/func/"
  inputimg="*_task-motor_acq-MB6_run-1_space-MNI152NLin6Asym_desc-brain_mask.nii.gz"
  fslmaths $outputimg -add $fmriprepdir/$inputimg $outputimg
done

# Finalize group level mask
fslmaths $outputimg -thr `echo "$nrsubs*0.9" | bc` -bin $outputimg
gunzip ${outputimg}.nii.gz





