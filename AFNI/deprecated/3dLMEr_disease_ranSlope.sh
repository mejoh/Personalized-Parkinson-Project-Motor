#!/bin/bash

#qsub -o /project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/logs -e /project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/logs -N 3dLMEr-rs_disease -l 'nodes=1:ppn=12,walltime=30:00:00,mem=70gb' /home/sysneu/marjoh/scripts/Personalized-Parkinson-Project-Motor/AFNI/3dLMEr_disease_ranSlope.sh

### OPTIONS ###
ROI=1
GroupComparison=1
CorrelationAnalysis=0
###

module unload afni; module load afni/2022
con=con_combined

if [ $ROI -eq 1 ]; then
# ROI analysis
mask=/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/Masks/BG-dysfunc_and_pareital-comp_and_striatum.nii.gz
prefix=${con}_Group_x_Time_x_Type_ROI
# Whole-brain analysis
elif [ $ROI -eq 0 ]; then
mask=/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/neuropointillist/rmask_ICV.nii
prefix=${con}_Group_x_Time_x_Type_Whole
fi

if [ $GroupComparison -eq 1 ]; then

dOutput=/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/3dLME_disease
dataTable=/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/${con}_disease_dataTable.txt
cd $dOutput

#/opt/afni/2022/3dLMEr -prefix $dOutput/${con}_Group_x_Time_x_Type -jobs 12 \
#-mask /project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/neuropointillist/#rmask_ICV.nii \
#-model '1+Group*TimepointNr*trial_type+Age.gmc+MeanFD.gmc+Sex+(1|Subj)' \
#-qVars 'Age.gmc,MeanFD.gmc' \
#-gltCode Type2_by_Time_by_Group 'trial_type : -1*1c 1*2c TimepointNr : -1*T0 1*T1 Group : 1*HC_PIT -1*PD_POM' \
#-gltCode Type3_by_Time_by_Group 'trial_type : -1*1c 1*3c TimepointNr : -1*T0 1*T1 Group : 1*HC_PIT -1*PD_POM' \
#-gltCode Time_by_Group 'TimepointNr : -1*T0 1*T1 Group : 1*HC_PIT -1*PD_POM' \
#-gltCode Time_by_HC 'TimepointNr : -1*T0 1*T1 Group : 1*HC_PIT' \
#-gltCode Time_by_PD 'TimepointNr : -1*T0 1*T1 Group : 1*PD_POM' \
#-gltCode BA_by_Group 'TimepointNr : 1*T0 Group : 1*HC_PIT -1*PD_POM' \
#-gltCode FU_by_Group 'TimepointNr : 1*T1 Group : 1*HC_PIT -1*PD_POM' \
#-gltCode BA_by_HC 'TimepointNr : 1*T0 Group : 1*HC_PIT' \
#-gltCode FU_by_HC 'TimepointNr : 1*T1 Group : 1*HC_PIT' \
#-gltCode BA_by_PD 'TimepointNr : 1*T0 Group : 1*PD_POM' \
#-gltCode FU_by_PD 'TimepointNr : 1*T1 Group : 1*PD_POM' \
#-gltCode Time 'TimepointNr : -1*T0 1*T1' \
#-gltCode BA 'TimepointNr : 1*T0' \
#-gltCode FU 'TimepointNr : 1*T1' \
#-gltCode Group 'Group : 1*HC_PIT -1*PD_POM' \
#-gltCode HC 'Group : 1*HC_PIT' \
#-gltCode PD 'Group : 1*PD_POM' \
#-dataTable \
#`cat $dataTable`

/opt/afni/2022/3dLME -prefix $dOutput/$prefix -jobs 12 \
-mask $mask \
-model '1+Group*TimepointNr*trial_type+Age.gmc+MeanFD.gmc+Sex' \
-qVars 'Age.gmc,MeanFD.gmc' \
-ranEff '~1+MeanFD.gmc' \
-SS_type 3 \
-num_glt 30 \
-gltLabel 1 'Group_by_Time_by_Type2' -gltCode 1 'Group : -1*HC_PIT 1*PD_POM TimepointNr : -1*T0 1*T1 trial_type : -1*1c 1*2c' \
-gltLabel 2 'Group_by_Time_by_Type3' -gltCode 2 'Group : -1*HC_PIT 1*PD_POM TimepointNr : -1*T0 1*T1 trial_type : -1*1c 1*3c' \
-gltLabel 3 'Group_by_Time_by_Type23' -gltCode 3 'Group : -1*HC_PIT 1*PD_POM TimepointNr : -1*T0 1*T1 trial_type : -1*1c 0.5*2c 0.5*3c' \
-gltLabel 4 'Group_by_Time' -gltCode 4 'Group : -1*HC_PIT 1*PD_POM TimepointNr : -1*T0 1*T1' \
-gltLabel 5 'HC_by_Time' -gltCode 5 'Group : 1*HC_PIT TimepointNr : -1*T0 1*T1' \
-gltLabel 6 'PD_by_Time' -gltCode 6 'Group : 1*PD_POM TimepointNr : -1*T0 1*T1' \
-gltLabel 7 'Group_by_BA' -gltCode 7 'Group : -1*HC_PIT 1*PD_POM TimepointNr : 1*T0' \
-gltLabel 8 'Group_by_FU' -gltCode 8 'Group : -1*HC_PIT 1*PD_POM TimepointNr : 1*T1' \
-gltLabel 9 'HC_by_BA' -gltCode 9 'Group : 1*HC_PIT TimepointNr : 1*T0' \
-gltLabel 10 'HC_by_FU' -gltCode 10 'Group : 1*HC_PIT TimepointNr : 1*T1' \
-gltLabel 11 'PD_by_BA' -gltCode 11 'Group : 1*PD_POM TimepointNr : 1*T0' \
-gltLabel 12 'PD_by_FU' -gltCode 12 'Group : 1*PD_POM TimepointNr : 1*T1' \
-gltLabel 13 'Group_by_Type2' -gltCode 13 'Group : -1*HC_PIT 1*PD_POM trial_type : -1*1c 1*2c' \
-gltLabel 14 'Group_by_Type3' -gltCode 14 'Group : -1*HC_PIT 1*PD_POM trial_type : -1*1c 1*3c' \
-gltLabel 15 'Group_by_Type23' -gltCode 15 'Group : -1*HC_PIT 1*PD_POM trial_type : -1*1c 0.5*2c 0.5*3c' \
-gltLabel 16 'HC_by_Type2' -gltCode 16 'Group : 1*HC_PIT trial_type : -1*1c 1*2c' \
-gltLabel 17 'HC_by_Type3' -gltCode 17 'Group : 1*HC_PIT trial_type : -1*1c 1*3c' \
-gltLabel 18 'HC_by_Type23' -gltCode 18 'Group : 1*HC_PIT trial_type : -1*1c 0.5*2c 0.5*3c' \
-gltLabel 19 'PD_by_Type2' -gltCode 19 'Group : 1*PD_POM trial_type : -1*1c 1*2c' \
-gltLabel 20 'PD_by_Type3' -gltCode 20 'Group : 1*PD_POM trial_type : -1*1c 1*3c' \
-gltLabel 21 'PD_by_Type23' -gltCode 21 'Group : 1*PD_POM trial_type : -1*1c 0.5*2c 0.5*3c' \
-gltLabel 22 'Group' -gltCode 22 'Group : -1*HC_PIT 1*PD_POM' \
-gltLabel 23 'HC' -gltCode 23 'Group : 1*HC_PIT' \
-gltLabel 24 'PD' -gltCode 24 'Group : 1*PD_POM' \
-gltLabel 25 'Time' -gltCode 25 'TimepointNr : -1*T0 1*T1' \
-gltLabel 26 'BA' -gltCode 26 'TimepointNr : 1*T0' \
-gltLabel 27 'FU' -gltCode 27 'TimepointNr : 1*T1' \
-gltLabel 28 'Type2' -gltCode 28 'trial_type : -1*1c 1*2c' \
-gltLabel 29 'Type3' -gltCode 29 'trial_type : -1*1c 1*3c' \
-gltLabel 30 'Type23' -gltCode 30 'trial_type : -1*1c 0.5*2c 0.5*3c' \
-dataTable \
`cat $dataTable`

fi

if [ $CorrelationAnalysis -eq 1 ]; then

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

fi