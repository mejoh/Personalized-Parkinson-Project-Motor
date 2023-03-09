#!/bin/bash

#qsub -o /project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/logs -e /project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/logs -N 3dLME_test -l 'nodes=1:ppn=32,walltime=06:00:00,mem=90gb' /home/sysneu/marjoh/scripts/Personalized-Parkinson-Project-Motor/AFNI/3dLME.sh

#ROI=(1 0); SUBTYPE=(HCvsMMP HCvsIM HCvsDM MMPvsIM MMPvsDM IMvsDM); CON=(con_combined); for roi in ${ROI[@]}; do for subtype in ${SUBTYPE[@]}; do for con in ${CON[@]}; do qsub -o /project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/logs -e /project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/logs -N 3dLME_${subtype}_${roi}${con} -v R=${roi},S=${subtype},C=${con} -l 'nodes=1:ppn=22,walltime=10:00:00,mem=55gb' /home/sysneu/marjoh/scripts/Personalized-Parkinson-Project-Motor/AFNI/3dLME_subtype.sh; done; done; done

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

dOutput=/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI

# Define mask
if [ $ROI -eq 1 ]; then

	# ROI analysis
	echo "ROI analysis"
	dOutput=$dOutput/ROI
	mask=/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/Masks/BG-dysfunc_and_pareital-comp_and_striatum_dil.nii.gz

elif [ $ROI -eq 0 ]; then

	# Whole-brain analysis
	echo "Whole-brain analysis"
	dOutput=$dOutput/WholeBrain
	mask=/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/Masks/3dLME_4dConsMask_bin-ero.nii.gz

fi

dOutput=$dOutput/3dLME_subtype
mkdir -p $dOutput
dataTable=/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/${con}_disease_${subtype}_dataTable.txt
cd $dOutput
cp $mask $(pwd)/mask.nii.gz
cp $dataTable $(pwd)
rm ${con}*.BRIK ${con}*.HEAD

# Run analysis
if [ ${con} = "con_combined" ]; then

	echo "Performing full LMER"

	/opt/afni/2022/3dLMEr -prefix ${dOutput}/${con}_${subtype}_x_TimepointNr2_x_Type3 -jobs $njobs \
	-resid ${dOutput}/${con}_${subtype}_x_TimepointNr2_x_Type3_resid.nii \
	-mask $mask \
	-model '1+Subtype1*TimepointNr*trial_type+Age+Sex+(1+TimepointNr|Subj)' \
	-qVars 'Age' \
	-gltCode Subtype1_by_Time_by_Type2gt1 'Subtype1 : -1*G1 1*G2 trial_type : -1*1c 1*2c TimepointNr : -1*T0 1*T1' \
	-gltCode Subtype1_by_Time_by_Type3gt1 'Subtype1 : -1*G1 1*G2 trial_type : -1*1c 1*3c TimepointNr : -1*T0 1*T1' \
	-gltCode Subtype1_by_Time_by_Type3gt2 'Subtype1 : -1*G1 1*G2 trial_type : -1*2c 1*3c TimepointNr : -1*T0 1*T1' \
	-gltCode Subtype1_by_Time_by_Type23gt1 'Subtype1 : -1*G1 1*G2 trial_type : -1*1c 0.5*2c 0.5*3c TimepointNr : -1*T0 1*T1' \
	-gltCode Subtype1_by_Time 'Subtype1 : -1*G1 1*G2 TimepointNr : -1*T0 1*T1' \
	-gltCode G1_by_Time 'Subtype1 : 1*G1 TimepointNr : -1*T0 1*T1' \
	-gltCode G2_by_Time 'Subtype1 : 1*G2 TimepointNr : -1*T0 1*T1' \
	-gltCode Subtype1_by_Type2gt1 'Subtype1 : -1*G1 1*G2 trial_type : -1*1c 1*2c' \
	-gltCode Subtype1_by_Type3gt1 'Subtype1 : -1*G1 1*G2 trial_type : -1*1c 1*3c' \
	-gltCode Subtype1_by_Type3gt2 'Subtype1 : -1*G1 1*G2 trial_type : -1*2c 1*3c' \
	-gltCode Subtype1_by_Type23gt1 'Subtype1 : -1*G1 1*G2 trial_type : -1*1c 0.5*2c 0.5*3c' \
	-gltCode G1_by_Type2gt1 'Subtype1 : 1*G1 trial_type : -1*1c 1*2c' \
	-gltCode G1_by_Type3gt1 'Subtype1 : 1*G1 trial_type : -1*1c 1*3c' \
	-gltCode G1_by_Type3gt2 'Subtype1 : 1*G1 trial_type : -1*2c 1*3c' \
	-gltCode G1_by_Type23gt1 'Subtype1 : 1*G1 trial_type : -1*1c 0.5*2c 0.5*3c' \
	-gltCode G2_by_Type2gt1 'Subtype1 : 1*G2 trial_type : -1*1c 1*2c' \
	-gltCode G2_by_Type3gt1 'Subtype1 : 1*G2 trial_type : -1*1c 1*3c' \
	-gltCode G2_by_Type3gt2 'Subtype1 : 1*G2 trial_type : -1*2c 1*3c' \
	-gltCode G2_by_Type23gt1 'Subtype1 : 1*G2 trial_type : -1*1c 0.5*2c 0.5*3c' \
	-gltCode Subtype1 'Subtype1 : -1*G1 1*G2' \
	-gltCode Time 'TimepointNr : -1*T0 1*T1' \
	-gltCode Type2gt1 'trial_type : -1*1c 1*2c' \
	-gltCode Type3gt1 'trial_type : -1*1c 1*3c' \
	-gltCode Type3gt2 'trial_type : -1*2c 1*3c' \
	-gltCode Type23gt1 'trial_type : -1*1c 0.5*2c 0.5*3c' \
	-dataTable \
	`cat $dataTable`

else

	echo "Performing LMER collapsed across conditions"

	/opt/afni/2022/3dLMEr -prefix ${dOutput}/${con}_${subtype}_x_TimepointNr2 -jobs $njobs \
	-mask $mask \
	-model '1+Subtype1*TimepointNr+Age+Sex+(1|Subj)' \
	-qVars 'Age' \
	-gltCode Subtype1_by_Time 'Subtype1 : -1*G1 1*G2 TimepointNr : -1*T0 1*T1' \
	-gltCode G1_by_Time 'Subtype1 : 1*G1 TimepointNr : -1*T0 1*T1' \
	-gltCode G2_by_Time 'Subtype1 : 1*G2 TimepointNr : -1*T0 1*T1' \
	-gltCode Subtype1 'Subtype1 : -1*G1 1*G2' \
	-gltCode G1 'Subtype1 : 1*G1' \
	-gltCode G2 'Subtype1 : 1*G2' \
	-gltCode Time 'TimepointNr : -1*T0 1*T1' \
	-gltCode BA 'TimepointNr : 1*T0' \
	-gltCode FU 'TimepointNr : 1*T1' \
	-dataTable \
	`cat $dataTable`

fi
