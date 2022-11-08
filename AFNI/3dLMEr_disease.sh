#!/bin/bash

#qsub -o /project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/logs -e /project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/logs -N 3dLMEr_disease_13 -l 'nodes=1:ppn=12,walltime=10:00:00,mem=20gb' /project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/3dLMEr_disease/3dLMEr_disease.sh

module unload afni; module load afni/2022

con=con_0013
dOutput=/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/3dLMEr_disease
dataTable=/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/${con}_disease_dataTable.txt
cd $dOutput

/opt/afni/2022/3dLMEr -prefix $dOutput/${con}_Group_x_Time -jobs 12 \
-model '1+Group*TimepointNr+Age_Dmean+MeanFD_Dmean+Sex+(1|Subj)' \
-qVars 'Age_Dmean,MeanFD_Dmean' \
-resid ${con}_Residuals \
-gltCode Time_by_Group 'TimepointNr : 1*T1 -1*T0 Group : 1*HC_PIT -1*PD_POM' \
-gltCode Time_by_HC 'TimepointNr : 1*T1 -1*T0 Group : 1*HC_PIT' \
-gltCode Time_by_PD 'TimepointNr : 1*T1 -1*T0 Group : 1*PD_POM' \
-gltCode BA_by_Group 'TimepointNr : 1*T0 Group : 1*HC_PIT -1*PD_POM' \
-gltCode FU_by_Group 'TimepointNr : 1*T1 Group : 1*HC_PIT -1*PD_POM' \
-gltCode BA_by_HC 'TimepointNr : 1*T0 Group : 1*HC_PIT' \
-gltCode FU_by_HC 'TimepointNr : 1*T1 Group : 1*HC_PIT' \
-gltCode BA_by_PD 'TimepointNr : 1*T0 Group : 1*PD_POM' \
-gltCode FU_by_PD 'TimepointNr : 1*T1 Group : 1*PD_POM' \
-gltCode Time 'TimepointNr : 1*T1 -1*T0' \
-gltCode BA 'TimepointNr : 1*T0' \
-gltCode FU 'TimepointNr : 1*T1' \
-gltCode Group 'Group : 1*HC_PIT -1*PD_POM' \
-gltCode HC 'Group : 1*HC_PIT' \
-gltCode PD 'Group : 1*PD_POM' \
-dataTable \
`cat $dataTable`
