#!/bin/bash

#CON=(con_0010 con_0012 con_0013); GC=(0 1); ROI=(0 1); for con in ${CON[@]}; do for roi in ${ROI[@]}; do for gc in ${GC[@]}; do qsub -o /project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/logs -e /project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/logs -N 3dMVM_${con}_${roi}${gc} -v R=${roi},G=${gc},C=${con} -l 'nodes=1:ppn=32,walltime=03:00:00,mem=40gb' /home/sysneu/marjoh/scripts/Personalized-Parkinson-Project-Motor/AFNI/3dMVM.sh; done; done; done

# R=1
# G=0
# C=con_0010

### OPTIONS ###
ROI=${R}				# 1 = ROI, 0 = Whole-brain
GroupComparison=${G}	# 1 = Group comparison, 0 = Correlation analysis
con=${C}				# con_0010 = Mean, con_0012 = 2>1, con_0013 = 3>1
###

module unload afni; module load afni/2022
module unload R; module load R/4.1.0
njobs=32

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

# Run analysis
if [ $GroupComparison -eq 1 ]; then

	echo "Group comparison"
	dOutput=$dOutput/3dMVM_disease
	mkdir -p $dOutput
	dataTable=/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/${con}_disease-delta_dataTable.txt
	cd $dOutput
	cp $mask $(pwd)/mask.nii.gz
	cp $dataTable $(pwd)
	rm ${con}*.BRIK ${con}*.HEAD
	
	/opt/afni/2022/3dMVM -prefix ${dOutput}/${con}_Group2 -jobs $njobs \
		-mask $mask \
		-bsVars "Group+Age+Sex" \
		-qVars "Age" \
		-num_glt 1 \
		-gltLabel 1 group -gltCode 1 'Group : -1*HC_PIT 1*PD_POM' \
		-dataTable \
		`cat $dataTable`

elif [ $GroupComparison -eq 0 ]; then

	echo "Brain-clinical correlation"
	dOutput=$dOutput/3dMVM_severity
	mkdir -p $dOutput
	dataTable=/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/${con}_severity-delta_dataTable.txt
	cd $dOutput
	cp $mask $(pwd)/mask.nii.gz
	cp $dataTable $(pwd)
	rm ${con}*.BRIK ${con}*.HEAD
	
	/opt/afni/2022/3dMVM -prefix ${dOutput}/${con}_Severity -jobs $njobs \
		-mask $mask \
		-bsVars "ClinScore.delta+ClinScore.BA+Age+Sex" \
		-qVars "ClinScore.delta,ClinScore.BA,Age" \
		-num_glt 2 \
		-gltLabel 1 Delta -gltCode 1 'ClinScore.delta: ' \
		-gltLabel 2 Baseline -gltCode 2 'ClinScore.BA: ' \
		-dataTable \
		`cat $dataTable`

fi
