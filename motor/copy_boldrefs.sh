#!/bin/bash

visit="POMVisit1"
fprepdir="/project/3022026.01/pep/bids/derivatives/fmriprep"
adir='/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem'
cd $adir
subs=`ls -d sub-POMU*`
#subs='sub-POMU4A7412A72D2973F1'
for i in ${subs[@]}; do

     boldref=${fprepdir}/${i}/ses-${visit}/func/${i}_ses-${visit}_task-motor_acq-MB6_run-1_space-MNI152NLin6Asym_boldref.nii.gz
     newimage=/project/3024006.02/Data/boldrefs/${i}_boldref.nii.gz
     cp $boldref $newimage

     outputimage=/project/3024006.02/Data/boldrefs/${i}_boldref.png
     slices $newimage -o $outputimage

done


