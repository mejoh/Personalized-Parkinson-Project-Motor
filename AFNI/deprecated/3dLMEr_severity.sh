#!/bin/bash

#qsub -o /project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/logs -e /project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/logs -N 3dLMEr_severity_13 -l 'nodes=1:ppn=12,walltime=10:00:00,mem=20gb' //home/sysneu/marjoh/scripts/Personalized-Parkinson-Project-Motor/AFNI/3dLMEr_severity.sh

module unload afni; module load afni/2022

con=con_0013
dOutput=/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/3dLMEr_severity
dataTable=/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/${con}_severity_dataTable.txt
cd $dOutput

/opt/afni/2022/3dLMEr -prefix $dOutput/${con}_Severity -jobs 12 \
-model '1+ClinScore.gmc+Age.gmc+MeanFD.gmc+Sex+(1|Subj)' \
-qVars 'ClinScore.gmc,Age.gmc,MeanFD.gmc' \
-resid ${con}_Residuals \
-gltCode Progression 'ClinScore.gmc :' \
-dataTable \
`cat $dataTable`
