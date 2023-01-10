#!/bin/bash

#qsub -o /project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/logs -e /project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/logs -N 3dLMEr-rs_severity -l 'nodes=1:ppn=12,walltime=05:00:00,mem=70gb' /home/sysneu/marjoh/scripts/Personalized-Parkinson-Project-Motor/AFNI/3dLMEr_severity_ranSlope.sh

module unload afni; module load afni/2022

con=con_combined
dOutput=/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/3dLME_severity
dataTable=/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/${con}_severity_dataTable.txt
cd $dOutput

#/opt/afni/2022/3dLMEr -prefix $dOutput/${con}_Severity_x_Type -jobs 12 \
#-model '1+ClinScore.gmc*trial_type+Age.gmc+MeanFD.gmc+Sex+(1+ClinScore.gmc|Subj)' \
#-qVars 'ClinScore.gmc,Age.gmc,MeanFD.gmc' \
#-resid ${con}_Residuals \
#-gltCode Type123_by_Severity 'trial_type : 1*1c 1*2c 1*3c ClinScore.gmc :' \
#-gltCode Type21_by_Severity 'trial_type : -1*1c 1*2c ClinScore.gmc :' \
#-gltCode Type31_by_Severity 'trial_type : -1*1c 1*3c ClinScore.gmc :' \
#-gltCode Severity 'ClinScore.gmc :' \
#-dataTable \
#`cat $dataTable`

/opt/afni/2022/3dLME -prefix $dOutput/${con}_Severity_x_Type -jobs 12 \
-mask /project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/Masks/BG-dysfunc_and_pareital-comp_and_striatum.nii.gz \
-model '1+ClinScore.gmc*trial_type+Age.gmc+MeanFD.gmc+Sex' \
-qVars 'ClinScore.gmc,Age.gmc,MeanFD.gmc' \
-ranEff '~1+MeanFD.gmc' \
-SS_type 3 \
-num_glt 4 \
-gltLabel 1 'Mean_by_Severity' -gltCode 1 'ClinScore.gmc :' \
-gltLabel 2 'Type2_by_Severity' -gltCode 2 'trial_type : -1*1c 1*2c ClinScore.gmc :' \
-gltLabel 3 'Type3_by_Severity' -gltCode 3 'trial_type : -1*1c 1*3c ClinScore.gmc :' \
-gltLabel 4 'Type23_by_Severity' -gltCode 4 'trial_type : -1*1c 0.5*2c 0.5*3c ClinScore.gmc :' \
-dataTable \
`cat $dataTable`






