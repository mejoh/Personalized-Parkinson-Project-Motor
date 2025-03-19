#!/bin/bash

#qsub -o /project/3024006.02/Analyses/MJF_FreeWater/logs -e /project/3024006.02/Analyses/MJF_FreeWater/logs -N 3dLME_MD -l 'nodes=1:ppn=32,walltime=03:00:00,mem=60gb' /home/sysneu/marjoh/scripts/qsimeasure/analyze_3dLME.sh

module unload afni; module load afni/2022
module unload R; module load R/4.1.0
njobs=32

mask=/project/3024006.02/Analyses/MJF_FreeWater/masks/bi_full_clincorr_bg_mask_cropped_MD.nii.gz
# mask=/project/3024006.02/Analyses/MJF_FreeWater/masks/test_mask.nii.gz
dataTable=/project/3024006.02/Analyses/MJF_FreeWater/data/AFNI/MD/HCvsPD_MD.txt

dOutput=/project/3024006.02/Analyses/MJF_FreeWater/stats/AFNI/MD
dOutput=$dOutput/3dLME_disease
mkdir -p $dOutput
cd $dOutput
cp $mask $(pwd)/mask.nii.gz
cp $dataTable $(pwd)/dataTable.txt
rm ${con}*.BRIK ${con}*.HEAD

/opt/afni/2022/3dLMEr -prefix ${dOutput}/MD_Group2_x_TimepointNr2 -jobs $njobs \
	-resid ${dOutput}/MD_Group2_x_TimepointNr2_resid \
	-mask $mask \
	-model '1+ParticipantType*TimepointNr+Age+Gender+NpsEducYears+(1|Subj)' \
	-qVars 'Age,NpsEducYears' \
	-bounds 0.000 0.003 \
	-gltCode Group_by_Time 'ParticipantType : -1*HC_PIT 1*PD_POM TimepointNr : -1*T0 1*T1' \
	-gltCode HC_by_Time 'ParticipantType : 1*HC_PIT TimepointNr : -1*T0 1*T1' \
	-gltCode PD_by_Time 'ParticipantType : 1*PD_POM TimepointNr : -1*T0 1*T1' \
	-gltCode Group 'ParticipantType : -1*HC_PIT 1*PD_POM' \
	-gltCode Group_BA 'ParticipantType : -1*HC_PIT 1*PD_POM TimepointNr : 1*T0' \
	-gltCode Group_FU 'ParticipantType : -1*HC_PIT 1*PD_POM TimepointNr : 1*T1' \
	-gltCode Time 'TimepointNr : -1*T0 1*T1' \
	-dataTable \
	`cat $(pwd)/dataTable.txt`

