#!/bin/bash

#qsub -o /project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/logs -e /project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/logs -N 3dLMEr-rs_severity -l 'nodes=1:ppn=12,walltime=20:00:00,mem=60gb' /project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/3dLMEr_severity/3dLMEr_severity_ranSlope.sh

module unload afni; module load afni/2022

con=con_combined
dOutput=/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/3dLMEr_severity
dataTable=/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/${con}_severity_dataTable.txt
cd $dOutput

/opt/afni/2022/3dLMEr -prefix $dOutput/${con}_Time_x_Severity_x_Type -jobs 12 \
-model '1+BradyRigScore_Dmean*TimepointNr*trial_type+Age_Dmean+MeanFD_Dmean+Sex+(1+BradyRigScore_Dmean|Subj)' \
-qVars 'BradyRigScore_Dmean,Age_Dmean,MeanFD_Dmean' \
-resid ${con}_Residuals \
-gltCode Type_by_Time_by_Severity 'trial_type : 1*1c 1*2c 1*3c TimepointNr : 1*T1 -1*T0 BradyRigScore_Dmean :' \
-gltCode Type21_by_Time_by_Severity 'trial_type : -1*1c 1*2c TimepointNr : 1*T1 -1*T0 BradyRigScore_Dmean :' \
-gltCode Type31_by_Time_by_Severity 'trial_type : -1*1c 1*3c TimepointNr : 1*T1 -1*T0 BradyRigScore_Dmean :' \
-gltCode Type32_by_Time_by_Severity 'trial_type : -1*2c 1*3c TimepointNr : 1*T1 -1*T0 BradyRigScore_Dmean :' \
-gltCode Time_by_Severity 'TimepointNr : 1*T1 -1*T0 BradyRigScore_Dmean :' \
-gltCode Time_by_Severity 'trial_type : 1*1c 1*2c 1*3c BradyRigScore_Dmean :' \
-gltCode Severity 'BradyRigScore_Dmean :' \
-dataTable \
`cat $dataTable`








