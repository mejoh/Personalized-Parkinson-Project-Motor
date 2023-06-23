#!/bin/bash

# Standard analyses
# dir=/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Baseline/HcOn_x_ExtInt2Int3Catch_NoOutliers
# dir=/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Baseline/HcSubtypes_x_ExtInt2Int3Catch_NoOutliers
# dir=/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Baseline/Subtypes_x_ExtInt2Int3Catch_NoOutliers
# dir=/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Baseline/ClinCorr-BA_Up3OfBradySum_T0_NoOutliers/Int2gtExt
# dir=/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Baseline/ClinCorr-BA_Up3OfBradySum_T0_NoOutliers/Int3gtExt
# dir=/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Baseline/ClinCorr-BA_Up3OfBradySum_T0_NoOutliers/Mean_ExtInt
# dir=/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Baseline/ClinCorr-BA_CognitiveComposite_T0_NoOutliers/Int2gtExt
# dir=/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Baseline/ClinCorr-BA_CognitiveComposite_T0_NoOutliers/Int3gtExt
# dir=/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Baseline/ClinCorr-BA_CognitiveComposite_T0_NoOutliers/Mean_ExtInt
# dir=/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Baseline/ClinCorr-BA_Select2_T0_NoOutliers/Int2gtExt
# dir=/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Baseline/ClinCorr-BA_Select3_T0_NoOutliers/Int3gtExt
# dir=/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Baseline/ClinCorr-BA_Motor_T0_NoOutliers/Mean_ExtInt
# dir=/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Baseline/ClinCorr-BA_Up3OfBradySumCognitiveComposite_T0_NoOutliers/Int2gtExt
# dir=/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Baseline/ClinCorr-BA_Up3OfBradySumCognitiveComposite_T0_NoOutliers/Int3gtExt

# Reserve control analyses
# dir=/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Baseline/ReserveControl_Subtypes_x_ExtInt2Int3Catch_NoOutliers
# dir=/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Baseline/ReserveControl_ClinCorr-BA_Up3OfBradySumCognitiveComposite_T0_NoOutliers/Int2gtExt
# dir=/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Baseline/ReserveControl_ClinCorr-BA_Up3OfBradySumCognitiveComposite_T0_NoOutliers/Int3gtExt
# dir=/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Baseline/ReserveControl_ClinCorr-BA_Up3OfBradySumCognitiveComposite_T0_NoOutliers/Mean_ExtInt




if [  ! "$dir" ]; then

	echo -e "\nProvide a directory please! \n"
	exit 1
	
fi

module unload afni; module load afni/2022

cd $dir
mkdir -p whereami
rm whereami/*
masks=`ls x_*_Mask.nii`
for i in ${masks[@]}; do

	filename="${i%.*}"
	echo -e "\n${filename} \n"
	
	3dcopy $i whereami/$filename
	filename2=${filename}+tlrc.
	3drefit -space MNI whereami/${filename2}
	whereami -space MNI -spm -atlas CA_MPM_22_MNI -omask whereami/${filename2} > whereami/${filename}_a-CA_MPM_22-MNI.txt
	whereami -space MNI -spm -atlas CA_ML_18_MNI -omask whereami/${filename2} > whereami/${filename}_a-CA_ML_18_MNI.txt
	whereami -space MNI -spm -atlas MNI_Glasser_HCP_v1.0 -omask whereami/${filename2} > whereami/${filename}_a-MNI_Glasser_HCP_v1.0.txt
	whereami -space MNI -spm -atlas MNI_VmPFC -omask whereami/${filename2} > whereami/${filename}_a-MNI_VmPFC.txt
	rm whereami/${filename2}*
	
done
