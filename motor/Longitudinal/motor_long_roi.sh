#!/bin/bash

wd=/project/3024006.02/Analyses/motor_task/Group/Longitudinal/Masks/wd
mkdir -p ${wd}
templatedir=/project/3024006.02/templates/templateflow
outdir=/project/3024006.02/Analyses/motor_task/Group/Longitudinal/Masks

# Construct basic masks
	# Bradykinesia + Cognitive composite
m1=/project/3024006.02/Analyses/BRAIN_2023/fMRI/Group_comparisons/ClinCorr-BA_Up3OfBradySumCognitiveComposite_T0_NoOutliers/Int2gtExt/x_Neg_Brady_Mask.nii
m2=/project/3024006.02/Analyses/BRAIN_2023/fMRI/Group_comparisons/ClinCorr-BA_Up3OfBradySumCognitiveComposite_T0_NoOutliers/Int3gtExt/x_Neg_Brady_Mask.nii
m3=/project/3024006.02/Analyses/BRAIN_2023/fMRI/Group_comparisons/ClinCorr-BA_Up3OfBradySumCognitiveComposite_T0_NoOutliers/Int2gtExt/x_Pos_CogCom_Mask.nii
m4=/project/3024006.02/Analyses/BRAIN_2023/fMRI/Group_comparisons/ClinCorr-BA_Up3OfBradySumCognitiveComposite_T0_NoOutliers/Int3gtExt/x_Pos_CogCom_Mask.nii
m5=/project/3024006.02/Analyses/BRAIN_2023/fMRI/Group_comparisons/ClinCorr-BA_Up3OfBradySumCognitiveComposite_T0_NoOutliers/Int3gtExt/x_Neg_CogCom_Mask.nii
fslmaths $m1 -add $m2 -add $m3 -add $m4 -add $m5 -bin -dilF $wd/ClinCorr_2scores_mask
	# Bradykinesia
m1=/project/3024006.02/Analyses/BRAIN_2023/fMRI/Group_comparisons/ClinCorr-BA_Up3OfBradySum_T0_NoOutliers/Int2gtExt/x_Neg_2gt1_Mask.nii
m2=/project/3024006.02/Analyses/BRAIN_2023/fMRI/Group_comparisons/ClinCorr-BA_Up3OfBradySum_T0_NoOutliers/Int3gtExt/x_Neg_3gt1_Mask.nii
m3=/project/3024006.02/Analyses/BRAIN_2023/fMRI/Group_comparisons/ClinCorr-BA_Up3OfBradySum_T0_NoOutliers/Mean_ExtInt/x_Neg_Mean_Mask.nii
fslmaths $m1 -add $m2 -add $m3 -bin -dilF $wd/ClinCorr_brady_mask
	# Cognitive composite
m1=/project/3024006.02/Analyses/BRAIN_2023/fMRI/Group_comparisons/ClinCorr-BA_CognitiveComposite_T0_NoOutliers/Int2gtExt/x_Pos_2gt1_Mask.nii
m2=/project/3024006.02/Analyses/BRAIN_2023/fMRI/Group_comparisons/ClinCorr-BA_CognitiveComposite_T0_NoOutliers/Int3gtExt/x_Pos_3gt1_Mask.nii
m3=/project/3024006.02/Analyses/BRAIN_2023/fMRI/Group_comparisons/ClinCorr-BA_CognitiveComposite_T0_NoOutliers/Mean_ExtInt/x_Pos_Mean_Mask.nii
m4=/project/3024006.02/Analyses/BRAIN_2023/fMRI/Group_comparisons/ClinCorr-BA_CognitiveComposite_T0_NoOutliers/Int3gtExt/x_Neg_3gt1_Mask.nii
fslmaths $m1 -add $m2 -add $m3 -add $m4 -bin -dilF $wd/ClinCorr_cogcom_mask
	# BG dysfunction
m1=/project/3024006.02/Analyses/BRAIN_2023/fMRI/Group_comparisons/HcOn_x_ExtInt2Int3Catch_NoOutliers/x_HCgtPD_Mean_Mask.nii
fslmaths $m1 -bin $wd/HCgtPD_mean_mask

# Construct mask alternatives
m1=$wd/ClinCorr_2scores_mask.nii.gz
m2=$wd/ClinCorr_brady_mask.nii.gz
m3=$wd/ClinCorr_cogcom_mask.nii.gz
m4=$wd/HCgtPD_mean_mask.nii.gz
fslmaths $m1 -add $m4 -bin $wd/partial_clincorr_bg_mask
fslmaths $m2 -add $m4 -bin $wd/brady_clincorr_bg_mask
fslmaths $m3 -add $m4 -bin $wd/cogcom_clincorr_bg_mask

# Flip and add

for m in partial brady cogcom; do

	fslswapdim $wd/${m}_clincorr_bg_mask -x y z $wd/${m}_clincorr_bg_mask_flip

	fslmaths $wd/${m}_clincorr_bg_mask -add $wd/${m}_clincorr_bg_mask_flip -bin -dilF $wd/bi_${m}_clincorr_bg_mask

	#3dresample -master $templatedir/tpl-MNI152NLin6Asym_res-02_desc-brain_mask.nii -prefix $wd/bi_${m}_clincorr_bg_mask_2mm.nii.gz -input $wd/bi_${m}_clincorr_bg_mask.nii.gz

	3dresample -master $wd/bi_${m}_clincorr_bg_mask.nii.gz -prefix $wd/tpl-MNI152NLin6Asym_desc-brain_mask.nii -input $templatedir/tpl-MNI152NLin6Asym_res-02_desc-brain_mask.nii

	fslmaths $wd/bi_${m}_clincorr_bg_mask -mas $wd/tpl-MNI152NLin6Asym_desc-brain_mask.nii -fillh $wd/bi_${m}_clincorr_bg_mask_cropped

	immv $wd/bi_${m}_clincorr_bg_mask_cropped $outdir/bi_${m}_clincorr_bg_mask_cropped

	gunzip $outdir/bi_${m}_clincorr_bg_mask_cropped.nii.gz

done

fslmaths $outdir/bi_brady_clincorr_bg_mask_cropped.nii -add $outdir/bi_cogcom_clincorr_bg_mask_cropped.nii -bin $outdir/bi_full_clincorr_bg_mask_cropped
gunzip $outdir/bi_full_clincorr_bg_mask_cropped.nii.gz



