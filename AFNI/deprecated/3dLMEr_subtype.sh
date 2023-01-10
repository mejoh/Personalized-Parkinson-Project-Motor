#!/bin/bash

#qsub -o /project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/logs -e /project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/logs -N 3dLMEr_subtype_13 -l 'nodes=1:ppn=12,walltime=10:00:00,mem=20gb' /project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/3dLMEr_subtype/3dLMEr_subtype.sh

module unload afni; module load afni/2022

con=con_0013
dOutput=/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/3dLMEr_subtype
dataTable=/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/${con}_subtype_dataTable.txt
cd $dOutput

/opt/afni/2022/3dLMEr -prefix $dOutput/${con}_Subtype_x_Time -jobs 12 \
-model '1+Subtype*TimepointNr+Age_Dmean+MeanFD_Dmean+Sex+(1|Subj)' \
-qVars 'Age_Dmean,MeanFD_Dmean' \
-resid ${con}_Residuals \
-gltCode Time_by_MMP_DM 'TimepointNr : 1*T1 -1*T0 Subtype : 1*1_Mild-Motor -1*3_Diffuse-Malignant' \
-gltCode Time_by_MMP_IM 'TimepointNr : 1*T1 -1*T0 Subtype : 1*1_Mild-Motor -1*2_Intermediate' \
-gltCode Time_by_IM_DM 'TimepointNr : 1*T1 -1*T0 Subtype : 1*2_Intermediate -1*3_Diffuse-Malignant' \
-gltCode Time_by_MMP 'TimepointNr : 1*T1 -1*T0 Subtype : 1*1_Mild-Motor' \
-gltCode Time_by_IM 'TimepointNr : 1*T1 -1*T0 Subtype : 1*2_Intermediate' \
-gltCode Time_by_DM 'TimepointNr : 1*T1 -1*T0 Subtype : 1*3_Diffuse-Malignant' \
-gltCode BA_by_MMP_DM 'TimepointNr : 1*T0 Subtype : 1*1_Mild-Motor -1*3_Diffuse-Malignant' \
-gltCode BA_by_MMP_IM 'TimepointNr : 1*T0 Subtype : 1*1_Mild-Motor -1*2_Intermediate' \
-gltCode BA_by_IM_DM 'TimepointNr : 1*T0 Subtype : 1*2_Intermediate -1*3_Diffuse-Malignant' \
-gltCode FU_by_MMP_DM 'TimepointNr : 1*T1 Subtype : 1*1_Mild-Motor -1*3_Diffuse-Malignant' \
-gltCode FU_by_MMP_IM 'TimepointNr : 1*T1 Subtype : 1*1_Mild-Motor -1*2_Intermediate' \
-gltCode FU_by_IM_DM 'TimepointNr : 1*T1 Subtype : 1*2_Intermediate -1*3_Diffuse-Malignant' \
-gltCode BA_by_MMP 'TimepointNr : 1*T0 Subtype : 1*1_Mild-Motor' \
-gltCode BA_by_IM 'TimepointNr : 1*T0 Subtype : 1*2_Intermediate' \
-gltCode BA_by_DM 'TimepointNr : 1*T0 Subtype : 1*3_Diffuse-Malignant' \
-gltCode FU_by_MMP 'TimepointNr : 1*T1 Subtype : 1*1_Mild-Motor' \
-gltCode FU_by_IM 'TimepointNr : 1*T1 Subtype : 1*2_Intermediate' \
-gltCode FU_by_DM 'TimepointNr : 1*T1 Subtype : 1*1_Mild-Motor' \
-gltCode Time 'TimepointNr : 1*T1 -1*T0' \
-gltCode BA 'TimepointNr : 1*T0' \
-gltCode FU 'TimepointNr : 1*T1' \
-gltCode MMP_DM 'Subtype : 1*1_Mild-Motor -1*3_Diffuse-Malignant' \
-gltCode MMP_IM 'Subtype : 1*1_Mild-Motor -1*2_Intermediate' \
-gltCode IM_DM 'Subtype : 1*2_Intermediate -1*3_Diffuse-Malignant' \
-gltCode MMP 'Subtype : 1*1_Mild-Motor' \
-gltCode MMP 'Subtype : 1*2_Intermediate' \
-gltCode MMP 'Subtype : 1*3_Diffuse-Malignant' \
-dataTable \
`cat $dataTable`
