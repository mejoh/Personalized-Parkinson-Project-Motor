#!/bin/bash

#list_subjects=`ls -d /project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/sub-POMU[A-Z]* | xargs -n 1 basename | tr '\n' ' '`; for s in ${list_subjects[@]}; do qsub -o /project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/afc/logs -e /project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/afc/logs -N afc_${s} -v sub=${s} -l 'walltime=00:30:00,mem=7gb' ~/scripts/Personalized-Parkinson-Project-Motor/AFNI/AFC.sh; done

# sub=sub-POMU00094252BA30B84F
# sub=sub-POMU7E189744A85E60A3

##### Set process variables
module load afni/2022
export OMP_NUM_THREADS=1

##### Set mask
# mask=/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/Masks/3dLME_4dConsMask_bin-ero.nii.gz
mask=/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/Masks/BG-dysfunc_and_pareital-comp_and_striatum_dil.nii.gz

##### Find sessions
#sessions=(ses-PITVisit1 ses-PITVisit2 ses-POMVisit1 ses-POMVisit3)
dAna=/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem
sessions=`ls -d $dAna/$sub/ses*`
sessions=`basename -a $sessions`

##### Use 1st-level residuals to estimate AFC
for ses in ${sessions[@]}; do
  res4d=$dAna/$sub/$ses/1st_level/Res4d.nii.gz
  output=$dAna/afc/Masked/${sub}_${ses}_afc.txt
  if [ -f $res4d ] && [ -f $mask ] && [ ! -f $output ]; then
    echo "Estimating autocorrelation function (afc) for $sub $ses"
    /opt/afni/2022/3dFWHMx \
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

# Run after afc_summary.R
# cd /project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/afc/Masked
# mask=/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/Masks/3dLME_4dConsMask_bin-ero.nii.gz
# mask=/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/Masks/BG-dysfunc_and_pareital-comp_and_striatum_dil.nii.gz
# 3dClustSim -LOTS -nodec -mask $mask -acf `cat afc_FWHMxyz.txt` -prefix CLUSTER-TABLE

