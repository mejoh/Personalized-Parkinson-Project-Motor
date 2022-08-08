#!/bin/bash

#list_subjects=`ls -d /project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/sub-POMU* | xargs -n 1 basename | tr '\n' ' '`; for s in ${list_subjects[@]}; do qsub -o /project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/afc/logs -e /project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/afc/logs -N afc_${s} -v sub=${s} -l 'walltime=01:00:00,mem=6gb' ~/scripts/Personalized-Parkinson-Project-Motor/motor/motor_afc.sh; done

#sub=sub-POMU00094252BA30B84F

module load afni

sessions=(ses-PITVisit1 ses-PITVisit2 ses-POMVisit1 ses-POMVisit3)
dAna=/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem

for ses in ${sessions[@]}; do
  mask=$dAna/$sub/$ses/1st_level/mask.nii
  res4d=$dAna/$sub/$ses/1st_level/Res4d.nii.gz
  output=$dAna/afc/${sub}_${ses}_afc.txt
  if [ -f $res4d ] && [ -f $mask ] && [ ! -f $output ]; then
    echo "Estimating autocorrelation function (afc) for $sub $ses"
    3dFWHMx \
    -mask $mask \
    -input $res4d \
    -acf NULL \
    -detrend > $output
  elif [ -f $output ]; then
    echo "Already processed $sub $ses, skipping..."
  else
    echo "No residuals found for $sub $ses, skipping..."
  fi
done

