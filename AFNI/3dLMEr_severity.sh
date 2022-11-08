#!/bin/bash

#qsub -o /project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/logs -e /project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/logs -N 3dLMEr_severity_13 -l 'nodes=1:ppn=12,walltime=10:00:00,mem=20gb' /project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/3dLMEr_severity/3dLMEr_severity.sh

module unload afni; module load afni/2022

con=con_0013
dOutput=/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/3dLMEr_severity
dataTable=/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/${con}_severity_dataTable.txt
cd $dOutput

/opt/afni/2022/3dLMEr -prefix $dOutput/${con}_Time_x_Severity -jobs 12 \
-model '1+BradyRigScore_Dmean*TimepointNr+Age_Dmean+MeanFD_Dmean+Sex+(1|Subj)' \
-qVars 'BradyRigScore_Dmean,Age_Dmean,MeanFD_Dmean' \
-resid ${con}_Residuals \
-gltCode Progression 'BradyRigScore_Dmean :' \
-dataTable \
`cat $dataTable`
