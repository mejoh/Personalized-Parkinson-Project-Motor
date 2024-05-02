#!/bin/bash

#qsub -o /project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/logs -e /project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/logs -N 3dLME_test -l 'nodes=1:ppn=32,walltime=06:00:00,mem=90gb' /home/sysneu/marjoh/scripts/Personalized-Parkinson-Project-Motor/AFNI/3dLME.sh

#ROI=(2 0); SUBTYPE=(HCvsMMP HCvsIM HCvsDM MMPvsIM MMPvsDM IMvsDM); CON=(con_combined con_0007 con_0010); for roi in ${ROI[@]}; do for subtype in ${SUBTYPE[@]}; do for con in ${CON[@]}; do qsub -o /project/3024006.02/Analyses/motor_task/Group/Longitudinal/AFNI/logs -e /project/3024006.02/Analyses/motor_task/Group/Longitudinal/AFNI/logs/ -N 3dLME_${subtype}_${roi}${con} -v R=${roi},S=${subtype},C=${con} -l 'nodes=1:ppn=22,walltime=10:00:00,mem=55gb' /home/sysneu/marjoh/scripts/Personalized-Parkinson-Project-Motor/AFNI/3dLME_subtype.sh; done; done; done

# R=1
# S=HCvsDM
# C=con_combined

### OPTIONS ###
ROI=${R}				# 1 = ROI, 0 = Whole-brain
subtype=${S}
con=${C}				# con_0010 = Mean, con_0012 = 2>1, con_0013 = 3>1, con_combined = All conditions
###

module unload afni; module load afni/2022
module unload R; module load R/4.1.0
njobs=22
export OMP_NUM_THREADS=22

dOutput=/project/3024006.02/Analyses/motor_task/Group/Longitudinal/AFNI

# Define mask
if [ $ROI -eq 1 ]; then

	# ROI analysis
	echo "ROI analysis - Partial"
	dOutput=$dOutput/ROI/Masked_partial
  mask=/project/3024006.02/Analyses/motor_task/Group/Longitudinal/Masks/bi_partial_clincorr_bg_mask_cropped.nii

elif [ $ROI -eq 2 ]; then

	# ROI analysis
	echo "ROI analysis - Full"
	dOutput=$dOutput/ROI/Masked_full
	mask=/project/3024006.02/Analyses/motor_task/Group/Longitudinal/Masks/bi_full_clincorr_bg_mask_cropped.nii

elif [ $ROI -eq 0 ]; then

	# Whole-brain analysis
	echo "Whole-brain analysis"
	dOutput=$dOutput/WholeBrain
	mask=/project/3024006.02/Analyses/motor_task/Group/Longitudinal/Masks/wd/tpl-MNI152NLin6Asym_desc-brain_mask.nii

fi

dOutput=$dOutput/3dLME_${subtype}
mkdir -p $dOutput
dataTable=/project/3024006.02/Analyses/motor_task/Group/Longitudinal/AFNI/${con}_disease_${subtype}_dataTable.txt
cd $dOutput
cp $mask $(pwd)/mask.nii
cp $dataTable $(pwd)
rm ${con}*.BRIK ${con}*.HEAD

# Run analysis
if [ ${con} = "con_combined" ]; then

	echo "Performing full LMER"
	
	# Potentially useful arguments
	# -resid ${dOutput}/${con}_${subtype}_x_TimepointNr2_x_Type3_resid.nii \

	/opt/afni/2022/3dLMEr -prefix ${dOutput}/${con}_${subtype}_x_TimepointNr2_x_Type3 -jobs $njobs \
	-resid ${dOutput}/${con}_${subtype}_x_TimepointNr2_x_Type3_resid \
	-mask $mask \
	-model '1+Subtype*TimepointNr*trial_type+Age+Sex+NpsEducYears+RespHandIsDominant+(1+TimepointNr|Subj)' \
	-qVars 'Age,NpsEducYears' \
	-gltCode Group_by_Time_by_Type23gt1 'Subtype : -1*G1 1*G2 trial_type : -1*1c 1*23c TimepointNr : -1*T0 1*T1' \
	-gltCode G1_by_Time_by_Type23gt1 'Subtype : 1*G1 trial_type : -1*1c 1*23c TimepointNr : -1*T0 1*T1' \
	-gltCode G2_by_Time_by_Type23gt1 'Subtype : 1*G2 trial_type : -1*1c 1*23c TimepointNr : -1*T0 1*T1' \
	-gltCode Group_by_Time 'Subtype : -1*G1 1*G2 TimepointNr : -1*T0 1*T1' \
	-gltCode G1_by_Time 'Subtype : 1*G1 TimepointNr : -1*T0 1*T1' \
	-gltCode G2_by_Time 'Subtype : 1*G2 TimepointNr : -1*T0 1*T1' \
	-gltCode Group_by_Type23gt1 'Subtype : -1*G1 1*G2 trial_type : -1*1c 1*23c' \
	-gltCode G1_by_Type23gt1 'Subtype : 1*G1 trial_type : -1*1c 1*23c' \
	-gltCode G2_by_Type23gt1 'Subtype : 1*G2 trial_type : -1*1c 1*23c' \
	-gltCode Group_by_Type23gt1_BA 'Subtype : -1*G1 1*G2 trial_type : -1*1c 1*23c TimepointNr : 1*T0' \
	-gltCode G1_by_Type23gt1_BA 'Subtype : 1*G1 trial_type : -1*1c 1*23c TimepointNr : 1*T0' \
	-gltCode G2_by_Type23gt1_BA 'Subtype : 1*G2 trial_type : -1*1c 1*23c TimepointNr : 1*T0' \
	-gltCode Group_by_Type23gt1_FU 'Subtype : -1*G1 1*G2 trial_type : -1*1c 1*23c TimepointNr : 1*T1' \
	-gltCode G1_by_Type23gt1_FU 'Subtype : 1*G1 trial_type : -1*1c 1*23c TimepointNr : 1*T1' \
	-gltCode G2_by_Type23gt1_FU 'Subtype : 1*G2 trial_type : -1*1c 1*23c TimepointNr : 1*T1' \
	-gltCode Group 'Subtype : -1*G1 1*G2' \
	-gltCode Group_BA 'Subtype : -1*G1 1*G2 TimepointNr : 1*T0' \
	-gltCode Group_FU 'Subtype : -1*G1 1*G2 TimepointNr : 1*T1' \
	-gltCode Time 'TimepointNr : -1*T0 1*T1' \
	-gltCode Type23gt1 'trial_type : -1*1c 1*23c' \
	-gltCode Type23gt1_BA 'trial_type : -1*1c 1*23c TimepointNr : 1*T0' \
	-gltCode Type23gt1_FU 'trial_type : -1*1c 1*23c TimepointNr : 1*T1' \
	-dataTable \
	`cat $dataTable`

else

	echo "Performing LMER collapsed across conditions"

	/opt/afni/2022/3dLMEr -prefix ${dOutput}/${con}_${subtype}_x_TimepointNr2 -jobs $njobs \
	-resid ${dOutput}/${con}_${subtype}_x_TimepointNr2_resid \
	-mask $mask \
	-model '1+Subtype*TimepointNr+Age+Sex+NpsEducYears+RespHandIsDominant+(1+TimepointNr|Subj)' \
	-qVars 'Age,NpsEducYears' \
	-gltCode Group_by_Time 'Subtype : -1*G1 1*G2 TimepointNr : -1*T0 1*T1' \
	-gltCode Group_by_BA 'Subtype : -1*G1 1*G2 TimepointNr : 1*T0' \
	-gltCode Group_by_FU 'Subtype : -1*G1 1*G2 TimepointNr : 1*T1' \
	-gltCode G1_by_Time 'Subtype : 1*G1 TimepointNr : -1*T0 1*T1' \
	-gltCode G2_by_Time 'Subtype : 1*G2 TimepointNr : -1*T0 1*T1' \
	-gltCode Group 'Subtype : -1*G1 1*G2' \
	-gltCode G1 'Subtype : 1*G1' \
	-gltCode G2 'Subtype : 1*G2' \
	-gltCode Time 'TimepointNr : -1*T0 1*T1' \
	-gltCode BA 'TimepointNr : 1*T0' \
	-gltCode FU 'TimepointNr : 1*T1' \
	-dataTable \
	`cat $dataTable`

fi
