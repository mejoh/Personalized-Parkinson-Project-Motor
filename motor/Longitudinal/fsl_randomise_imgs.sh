#!/bin/bash

# Run after fsl_randomise_covars.R

# This script will do two things:
# 1. Generate images
	# - Contrasts: 0007 and 0010
	# - Sessions: T2subT0, T0_complete, T2_complete, T0_all, T2_all
	# - Groups: PD and HC
# 2. Build design matrices from fsl_randomise_covars.R output
	# - Unpaired t-tests: group comparisons
	# - One-sample t-tests: post-hoc testing and brain-clinical correlations
# 3. Write scripts

# Set paths and parameters
groupdir=/project/3024006.02/Analyses/motor_task/Group
cd ${groupdir}
datadir=${groupdir}/Longitudinal/FSL/data
statsdir=${groupdir}/Longitudinal/FSL/stats
designsdir=${groupdir}/Longitudinal/FSL/designs
masksdir=${groupdir}/Longitudinal/Masks
MASK_ROI=${masksdir}/bi_full_clincorr_bg_mask_cropped.nii
MASK_WHOLE=${masksdir}/wd/tpl-MNI152NLin6Asym_desc-brain_mask.nii
rand="randomise_parallel"
rand_opts="-m ${MASK_ROI} -n 5000 -T -R"
rand_opts2="-m ${MASK_WHOLE} -n 5000 -T -R"

# Generate images by contrasts, groups, and time points
con=(con_0007 con_0010) # con_0011 con_0012)
ses=(ses-Diff COMPLETE_ses-Visit1 COMPLETE_ses-Visit2 ses-Visit1 ses-Visit2)
for c in ${con[@]}; do
 for s in ${ses[@]}; do 
  # Merge data for unpaired t-test
	# Note that the baseline images are demeaned
  if [ $s == "ses-Diff"  ]; then
	
   fslmerge -t ${datadir}/${c}/imgs__delta_unpaired_ttest_unmatched `cat ${datadir}/${c}/imgs__delta_unpaired_ttest_unmatched.txt`
	 fslmaths ${datadir}/${c}/imgs__delta_unpaired_ttest_unmatched -nan ${datadir}/${c}/imgs__delta_unpaired_ttest_unmatched
	 fslroi ${datadir}/${c}/imgs__delta_unpaired_ttest_unmatched ${datadir}/${c}/posthoc__imgs__delta_unpaired_ttest_unmatched_gHC 0 52
	 fslroi ${datadir}/${c}/imgs__delta_unpaired_ttest_unmatched ${datadir}/${c}/posthoc__imgs__delta_unpaired_ttest_unmatched_gPD 52 -1
	 
	 # fslmerge -t ${datadir}/${c}/imgs__delta_unpaired_ttest_matched `cat ${datadir}/${c}/imgs__delta_unpaired_ttest_matched.txt`
	 # fslmaths ${datadir}/${c}/imgs__delta_unpaired_ttest_matched -nan ${datadir}/${c}/imgs__delta_unpaired_ttest_matched
	 # fslroi ${datadir}/${c}/imgs__delta_unpaired_ttest_matched ${datadir}/${c}/posthoc__imgs__delta_unpaired_ttest_matched_gHC 0 52
	 # fslroi ${datadir}/${c}/imgs__delta_unpaired_ttest_matched ${datadir}/${c}/posthoc__imgs__delta_unpaired_ttest_matched_gPD 52 -1
	 
  elif [ $s == "COMPLETE_ses-Visit1" ]; then
	
   fslmerge -t ${datadir}/${c}/imgs__ba_unpaired_ttest_unmatched `cat ${datadir}/${c}/imgs__ba_unpaired_ttest_unmatched.txt`
   fslmaths ${datadir}/${c}/imgs__ba_unpaired_ttest_unmatched -nan ${datadir}/${c}/imgs__ba_unpaired_ttest_unmatched
   fslmaths ${datadir}/${c}/imgs__ba_unpaired_ttest_unmatched -Tmean ${datadir}/${c}/imgs__ba_unpaired_ttest_unmatched_tmean
   fslmaths ${datadir}/${c}/imgs__ba_unpaired_ttest_unmatched -sub ${datadir}/${c}/imgs__ba_unpaired_ttest_unmatched_tmean ${datadir}/${c}/imgs__ba_unpaired_ttest_unmatched_dmean
	 fslroi ${datadir}/${c}/imgs__delta_unpaired_ttest_unmatched ${datadir}/${c}/posthoc__imgs__ba_unpaired_ttest_unmatched_dmean_gHC 0 52
	 fslroi ${datadir}/${c}/imgs__delta_unpaired_ttest_unmatched ${datadir}/${c}/posthoc__imgs__ba_unpaired_ttest_unmatched_dmean_gPD 52 -1
	 
	 # fslmerge -t ${datadir}/${c}/imgs__ba_unpaired_ttest_matched `cat ${datadir}/${c}/imgs__ba_unpaired_ttest_matched.txt`
   # fslmaths ${datadir}/${c}/imgs__ba_unpaired_ttest_matched -nan ${datadir}/${c}/imgs__ba_unpaired_ttest_matched
   # fslmaths ${datadir}/${c}/imgs__ba_unpaired_ttest_matched -Tmean ${datadir}/${c}/imgs__ba_unpaired_ttest_matched_tmean
   # fslmaths ${datadir}/${c}/imgs__ba_unpaired_ttest_matched -sub ${datadir}/${c}/imgs__ba_unpaired_ttest_matched_tmean ${datadir}/${c}/imgs__ba_unpaired_ttest_matched_dmean
	 # fslroi ${datadir}/${c}/imgs__ba_unpaired_ttest_matched_dmean ${datadir}/${c}/posthoc__imgs__ba_unpaired_ttest_matched_dmean_gHC 0 52
	 # fslroi ${datadir}/${c}/imgs__ba_unpaired_ttest_matched_dmean ${datadir}/${c}/posthoc__imgs__ba_unpaired_ttest_matched_dmean_gPD 52 -1
	 
	 
  elif [ $s == "COMPLETE_ses-Visit2" ]; then
	
   fslmerge -t ${datadir}/${c}/imgs__fu_unpaired_ttest_unmatched `cat ${datadir}/${c}/imgs__fu_unpaired_ttest_unmatched.txt`
   fslmaths ${datadir}/${c}/imgs__fu_unpaired_ttest_unmatched -nan ${datadir}/${c}/imgs__fu_unpaired_ttest_unmatched
	 
	 # fslmerge -t ${datadir}/${c}/imgs__fu_unpaired_ttest_matched `cat ${datadir}/${c}/imgs__fu_unpaired_ttest_matched.txt`
   # fslmaths ${datadir}/${c}/imgs__fu_unpaired_ttest_matched -nan ${datadir}/${c}/imgs__fu_unpaired_ttest_matched
	 
	elif [ $s == "ses-Visit1" ]; then
	
	 fslmerge -t ${datadir}/${c}/by_session/${s}/imgs__unpaired_ttest_unmatched `cat ${datadir}/${c}/by_session/${s}/imgs__unpaired_ttest_unmatched.txt`
   fslmaths ${datadir}/${c}/by_session/${s}/imgs__unpaired_ttest_unmatched -nan ${datadir}/${c}/by_session/${s}/imgs__unpaired_ttest_unmatched
	
	elif [ $s == "ses-Visit2" ]; then
	
	 fslmerge -t ${datadir}/${c}/by_session/${s}/imgs__unpaired_ttest_unmatched `cat ${datadir}/${c}/by_session/${s}/imgs__unpaired_ttest_unmatched.txt`
   fslmaths ${datadir}/${c}/by_session/${s}/imgs__unpaired_ttest_unmatched -nan ${datadir}/${c}/by_session/${s}/imgs__unpaired_ttest_unmatched
	 
  fi
  # Merge data for clincorr
  if [ $s == "ses-Diff"  ]; then
	
   fslmerge -t ${datadir}/${c}/imgs__delta_clincorr `cat ${datadir}/${c}/imgs__delta_clincorr.txt`
	 fslmerge -t ${datadir}/${c}/imgs__delta_clincorr_AddCov2 `cat ${datadir}/${c}/imgs__delta_clincorr_AddCov2.txt`
	 # fslmerge -t ${datadir}/${c}/imgs__delta_clincorr_AddCov3 `cat ${datadir}/${c}/imgs__delta_clincorr_AddCov3.txt`
	 
  elif [ $s == "COMPLETE_ses-Visit1" ]; then
	
   fslmerge -t ${datadir}/${c}/imgs__ba_clincorr `cat ${datadir}/${c}/imgs__ba_clincorr.txt`
   fslmaths ${datadir}/${c}/imgs__ba_clincorr -nan ${datadir}/${c}/imgs__ba_clincorr
   fslmaths ${datadir}/${c}/imgs__ba_clincorr -Tmean ${datadir}/${c}/imgs__ba_clincorr_tmean
   fslmaths ${datadir}/${c}/imgs__ba_clincorr -sub ${datadir}/${c}/imgs__ba_clincorr_tmean ${datadir}/${c}/imgs__ba_clincorr_dmean
	 
	 fslmerge -t ${datadir}/${c}/imgs__ba_clincorr_AddCov2 `cat ${datadir}/${c}/imgs__ba_clincorr_AddCov2.txt`
   fslmaths ${datadir}/${c}/imgs__ba_clincorr_AddCov2 -nan ${datadir}/${c}/imgs__ba_clincorr_AddCov2
   fslmaths ${datadir}/${c}/imgs__ba_clincorr_AddCov2 -Tmean ${datadir}/${c}/imgs__ba_clincorr_AddCov2_tmean
   fslmaths ${datadir}/${c}/imgs__ba_clincorr_AddCov2 -sub ${datadir}/${c}/imgs__ba_clincorr_AddCov2_tmean ${datadir}/${c}/imgs__ba_clincorr_AddCov2_dmean
	 
	 # fslmerge -t ${datadir}/${c}/imgs__ba_clincorr_AddCov3 `cat ${datadir}/${c}/imgs__ba_clincorr_AddCov3.txt`
   # fslmaths ${datadir}/${c}/imgs__ba_clincorr_AddCov3 -nan ${datadir}/${c}/imgs__ba_clincorr_AddCov3
   # fslmaths ${datadir}/${c}/imgs__ba_clincorr_AddCov3 -Tmean ${datadir}/${c}/imgs__ba_clincorr_AddCov3_tmean
   # fslmaths ${datadir}/${c}/imgs__ba_clincorr_AddCov3 -sub ${datadir}/${c}/imgs__ba_clincorr_AddCov3_tmean ${datadir}/${c}/imgs__ba_clincorr_AddCov3_dmean
	 
  elif [ $s == "COMPLETE_ses-Visit2" ]; then
	
   fslmerge -t ${datadir}/${c}/imgs__fu_clincorr `cat ${datadir}/${c}/imgs__fu_clincorr.txt`
   fslmaths ${datadir}/${c}/imgs__fu_clincorr -nan ${datadir}/${c}/imgs__fu_clincorr
	 
	elif [ $s == "ses-Visit1" ]; then
	
	 fslmerge -t ${datadir}/${c}/by_session/${s}/imgs__clincorr `cat ${datadir}/${c}/by_session/${s}/imgs__clincorr.txt`
   fslmaths ${datadir}/${c}/by_session/${s}/imgs__clincorr -nan ${datadir}/${c}/by_session/${s}/imgs__clincorr
	
	elif [ $s == "ses-Visit2" ]; then
	
	 fslmerge -t ${datadir}/${c}/by_session/${s}/imgs__clincorr `cat ${datadir}/${c}/by_session/${s}/imgs__clincorr.txt`
   fslmaths ${datadir}/${c}/by_session/${s}/imgs__clincorr -nan ${datadir}/${c}/by_session/${s}/imgs__clincorr
	 
  fi
 done

 mkdir -p ${statsdir}/${c}/by_session/ses-Visit1
 mkdir -p ${designsdir}/${c}/by_session/ses-Visit1
 mkdir -p ${statsdir}/${c}/by_session/ses-Visit2
 mkdir -p ${designsdir}/${c}/by_session/ses-Visit2
 
# Generate .con files
txtfiles=( $(ls ${datadir}/${c}/cons__*.txt) )
for t in ${txtfiles[@]}; do
	DN=$(dirname ${t})
	BN=$(basename ${t})
	CN=${BN/.txt/.con}
	Text2Vest ${DN}/${BN} ${designsdir}/${CN}
done

# Construct design matrices and write job submission scripts
## Delta: Voxel-wise EV
DESIGN=delta_unpaired_ttest_unmatched_vxlEV; Text2Vest ${datadir}/${c}/covs__${DESIGN}.txt ${designsdir}/${c}/covs__${DESIGN}.mat
randcmd="${rand} -i ${datadir}/${c}/imgs__delta_unpaired_ttest_unmatched.nii.gz -o ${statsdir}/${c}/rand_${DESIGN} -d ${designsdir}/${c}/covs__${DESIGN}.mat -t ${designsdir}/cons__unpaired_ttest_vxlEV.con ${rand_opts} --vxl=7 --vxf=${datadir}/${c}/imgs__ba_unpaired_ttest_unmatched_dmean"
printf "\n${randcmd}\n\n" > ${statsdir}/${c}/cmd_rand_${DESIGN}.txt

	DESIGN=posthoc_gHC__covs__delta_unpaired_ttest_unmatched_vxlEV; Text2Vest ${datadir}/${c}/${DESIGN}.txt ${designsdir}/${c}/covs__${DESIGN}.mat
	randcmd="${rand} -1 -i ${datadir}/${c}/posthoc__imgs__delta_unpaired_ttest_unmatched_gHC.nii.gz -o ${statsdir}/${c}/rand_${DESIGN} -d ${designsdir}/${c}/covs__${DESIGN}.mat -t ${designsdir}/cons__singlegroup_ttest_vxlEV.con ${rand_opts} --vxl=6 --vxf=${datadir}/${c}/posthoc__imgs__ba_unpaired_ttest_unmatched_dmean_gHC"
	printf "\n${randcmd}\n\n" > ${statsdir}/${c}/cmd_rand_${DESIGN}.txt
	DESIGN=posthoc_gPD__covs__delta_unpaired_ttest_unmatched_vxlEV; Text2Vest ${datadir}/${c}/${DESIGN}.txt ${designsdir}/${c}/covs__${DESIGN}.mat
	randcmd="${rand} -1 -i ${datadir}/${c}/posthoc__imgs__delta_unpaired_ttest_unmatched_gPD.nii.gz -o ${statsdir}/${c}/rand_${DESIGN} -d ${designsdir}/${c}/covs__${DESIGN}.mat -t ${designsdir}/cons__singlegroup_ttest_vxlEV.con ${rand_opts} --vxl=6 --vxf=${datadir}/${c}/posthoc__imgs__ba_unpaired_ttest_unmatched_dmean_gPD"
	printf "\n${randcmd}\n\n" > ${statsdir}/${c}/cmd_rand_${DESIGN}.txt

# DESIGN=delta_unpaired_ttest_matched_vxlEV; Text2Vest ${datadir}/${c}/covs__${DESIGN}.txt ${designsdir}/${c}/covs__${DESIGN}.mat
# randcmd="${rand} -i ${datadir}/${c}/imgs__delta_unpaired_ttest_matched.nii.gz -o ${statsdir}/${c}/rand_${DESIGN} -d ${designsdir}/${c}/covs__${DESIGN}.mat -t ${designsdir}/cons__unpaired_ttest_vxlEV.con ${rand_opts} --vxl=7 --vxf=${datadir}/${c}/imgs__ba_unpaired_ttest_matched_dmean"
# printf "\n${randcmd}\n\n" > ${statsdir}/${c}/cmd_rand_${DESIGN}.txt

	# DESIGN=posthoc_gHC__covs__delta_unpaired_ttest_matched_vxlEV; Text2Vest ${datadir}/${c}/${DESIGN}.txt ${designsdir}/${c}/covs__${DESIGN}.mat
	# randcmd="${rand} -1 -i ${datadir}/${c}/posthoc__imgs__delta_unpaired_ttest_matched_gHC.nii.gz -o ${statsdir}/${c}/rand_${DESIGN} -d ${designsdir}/${c}/covs__${DESIGN}.mat -t ${designsdir}/cons__singlegroup_ttest_vxlEV.con ${rand_opts} --vxl=6 --vxf=${datadir}/${c}/posthoc__imgs__ba_unpaired_ttest_matched_dmean_gHC"
	# printf "\n${randcmd}\n\n" > ${statsdir}/${c}/cmd_rand_${DESIGN}.txt
	# DESIGN=posthoc_gPD__covs__delta_unpaired_ttest_matched_vxlEV; Text2Vest ${datadir}/${c}/${DESIGN}.txt ${designsdir}/${c}/covs__${DESIGN}.mat
	# randcmd="${rand} -1 -i ${datadir}/${c}/posthoc__imgs__delta_unpaired_ttest_matched_gPD.nii.gz -o ${statsdir}/${c}/rand_${DESIGN} -d ${designsdir}/${c}/covs__${DESIGN}.mat -t ${designsdir}/cons__singlegroup_ttest_vxlEV.con ${rand_opts} --vxl=6 --vxf=${datadir}/${c}/posthoc__imgs__ba_unpaired_ttest_matched_dmean_gPD"
	# printf "\n${randcmd}\n\n" > ${statsdir}/${c}/cmd_rand_${DESIGN}.txt

DESIGN=delta_clincorr_all_vxlEV; Text2Vest ${datadir}/${c}/covs__${DESIGN}.txt ${designsdir}/${c}/covs__${DESIGN}.mat
randcmd="${rand} -1 -i ${datadir}/${c}/imgs__delta_clincorr.nii.gz -o ${statsdir}/${c}/rand_${DESIGN} -d ${designsdir}/${c}/covs__${DESIGN}.mat -t ${designsdir}/cons__delta_clincorr_all_vxlEV.con ${rand_opts} --vxl=13 --vxf=${datadir}/${c}/imgs__ba_clincorr_dmean"
printf "\n${randcmd}\n\n" > ${statsdir}/${c}/cmd_rand_${DESIGN}.txt

	# DESIGN=delta_clincorr_all_vxlEV_AddCov1; Text2Vest ${datadir}/${c}/covs__${DESIGN}.txt ${designsdir}/${c}/covs__${DESIGN}.mat
	# randcmd="${rand} -1 -i ${datadir}/${c}/imgs__delta_clincorr.nii.gz -o ${statsdir}/${c}/rand_${DESIGN} -d ${designsdir}/${c}/covs__${DESIGN}.mat -t ${designsdir}/cons__delta_clincorr_all_vxlEV_AddCov1.con ${rand_opts} --vxl=13 --vxf=${datadir}/${c}/imgs__ba_clincorr_dmean"
	# printf "\n${randcmd}\n\n" > ${statsdir}/${c}/cmd_rand_${DESIGN}.txt

	DESIGN=delta_clincorr_all_vxlEV_AddCov2; Text2Vest ${datadir}/${c}/covs__${DESIGN}.txt ${designsdir}/${c}/covs__${DESIGN}.mat
	randcmd="${rand} -1 -i ${datadir}/${c}/imgs__delta_clincorr_AddCov2.nii.gz -o ${statsdir}/${c}/rand_${DESIGN} -d ${designsdir}/${c}/covs__${DESIGN}.mat -t ${designsdir}/cons__delta_clincorr_all_vxlEV_AddCov2.con ${rand_opts} --vxl=13 --vxf=${datadir}/${c}/imgs__ba_clincorr_AddCov2_dmean"
	printf "\n${randcmd}\n\n" > ${statsdir}/${c}/cmd_rand_${DESIGN}.txt
	
	# DESIGN=delta_clincorr_all_vxlEV_AddCov3; Text2Vest ${datadir}/${c}/covs__${DESIGN}.txt ${designsdir}/${c}/covs__${DESIGN}.mat
	# randcmd="${rand} -1 -i ${datadir}/${c}/imgs__delta_clincorr_AddCov3.nii.gz -o ${statsdir}/${c}/rand_${DESIGN} -d ${designsdir}/${c}/covs__${DESIGN}.mat -t ${designsdir}/cons__delta_clincorr_all_vxlEV_AddCov3.con ${rand_opts} --vxl=13 --vxf=${datadir}/${c}/imgs__ba_clincorr_AddCov3_dmean"
	# printf "\n${randcmd}\n\n" > ${statsdir}/${c}/cmd_rand_${DESIGN}.txt

DESIGN=delta_clincorr_brady_vxlEV; Text2Vest ${datadir}/${c}/covs__${DESIGN}.txt ${designsdir}/${c}/covs__${DESIGN}.mat
randcmd="${rand} -1 -i ${datadir}/${c}/imgs__delta_clincorr.nii.gz -o ${statsdir}/${c}/rand_${DESIGN} -d ${designsdir}/${c}/covs__${DESIGN}.mat -t ${designsdir}/cons__delta_clincorr_one_vxlEV.con ${rand_opts} --vxl=9 --vxf=${datadir}/${c}/imgs__ba_clincorr_dmean"
printf "\n${randcmd}\n\n" > ${statsdir}/${c}/cmd_rand_${DESIGN}.txt

DESIGN=delta_clincorr_moca_vxlEV; Text2Vest ${datadir}/${c}/covs__${DESIGN}.txt ${designsdir}/${c}/covs__${DESIGN}.mat
randcmd="${rand} -1 -i ${datadir}/${c}/imgs__delta_clincorr.nii.gz -o ${statsdir}/${c}/rand_${DESIGN} -d ${designsdir}/${c}/covs__${DESIGN}.mat -t ${designsdir}/cons__delta_clincorr_one_vxlEV.con ${rand_opts} --vxl=9 --vxf=${datadir}/${c}/imgs__ba_clincorr_dmean"
printf "\n${randcmd}\n\n" > ${statsdir}/${c}/cmd_rand_${DESIGN}.txt


## Delta: Un-adjusted
DESIGN=delta_unpaired_ttest_unmatched; Text2Vest ${datadir}/${c}/covs__${DESIGN}.txt ${designsdir}/${c}/covs__${DESIGN}.mat
randcmd="${rand} -i ${datadir}/${c}/imgs__delta_unpaired_ttest_unmatched.nii.gz -o ${statsdir}/${c}/rand_${DESIGN} -d ${designsdir}/${c}/covs__${DESIGN}.mat -t ${designsdir}/cons__unpaired_ttest.con ${rand_opts}"
printf "\n${randcmd}\n\n" > ${statsdir}/${c}/cmd_rand_${DESIGN}.txt

	DESIGN=posthoc_gHC__covs__delta_unpaired_ttest_unmatched; Text2Vest ${datadir}/${c}/${DESIGN}.txt ${designsdir}/${c}/covs__${DESIGN}.mat
	randcmd="${rand} -1 -i ${datadir}/${c}/posthoc__imgs__delta_unpaired_ttest_unmatched_gHC.nii.gz -o ${statsdir}/${c}/rand_${DESIGN} -d ${designsdir}/${c}/covs__${DESIGN}.mat -t ${designsdir}/cons__singlegroup_ttest.con ${rand_opts}"
	printf "\n${randcmd}\n\n" > ${statsdir}/${c}/cmd_rand_${DESIGN}.txt
	DESIGN=posthoc_gPD__covs__delta_unpaired_ttest_unmatched; Text2Vest ${datadir}/${c}/${DESIGN}.txt ${designsdir}/${c}/covs__${DESIGN}.mat
	randcmd="${rand} -1 -i ${datadir}/${c}/posthoc__imgs__delta_unpaired_ttest_unmatched_gPD.nii.gz -o ${statsdir}/${c}/rand_${DESIGN} -d ${designsdir}/${c}/covs__${DESIGN}.mat -t ${designsdir}/cons__singlegroup_ttest.con ${rand_opts}"
	printf "\n${randcmd}\n\n" > ${statsdir}/${c}/cmd_rand_${DESIGN}.txt

# DESIGN=delta_unpaired_ttest_matched; Text2Vest ${datadir}/${c}/covs__${DESIGN}.txt ${designsdir}/${c}/covs__${DESIGN}.mat
# randcmd="${rand} -i ${datadir}/${c}/imgs__delta_unpaired_ttest_matched.nii.gz -o ${statsdir}/${c}/rand_${DESIGN} -d ${designsdir}/${c}/covs__${DESIGN}.mat -t ${designsdir}/cons__unpaired_ttest.con ${rand_opts}"
# printf "\n${randcmd}\n\n" > ${statsdir}/${c}/cmd_rand_${DESIGN}.txt

	# DESIGN=posthoc_gHC__covs__delta_unpaired_ttest_matched; Text2Vest ${datadir}/${c}/${DESIGN}.txt ${designsdir}/${c}/covs__${DESIGN}.mat
	# randcmd="${rand} -1 -i ${datadir}/${c}/posthoc__imgs__delta_unpaired_ttest_matched_gHC.nii.gz -o ${statsdir}/${c}/rand_${DESIGN} -d ${designsdir}/${c}/covs__${DESIGN}.mat -t ${designsdir}/cons__singlegroup_ttest.con ${rand_opts}"
	# printf "\n${randcmd}\n\n" > ${statsdir}/${c}/cmd_rand_${DESIGN}.txt
	# DESIGN=posthoc_gPD__covs__delta_unpaired_ttest_matched; Text2Vest ${datadir}/${c}/${DESIGN}.txt ${designsdir}/${c}/covs__${DESIGN}.mat
	# randcmd="${rand} -1 -i ${datadir}/${c}/posthoc__imgs__delta_unpaired_ttest_matched_gPD.nii.gz -o ${statsdir}/${c}/rand_${DESIGN} -d ${designsdir}/${c}/covs__${DESIGN}.mat -t ${designsdir}/cons__singlegroup_ttest.con ${rand_opts}"
	# printf "\n${randcmd}\n\n" > ${statsdir}/${c}/cmd_rand_${DESIGN}.txt

DESIGN=delta_clincorr_all; Text2Vest ${datadir}/${c}/covs__${DESIGN}.txt ${designsdir}/${c}/covs__${DESIGN}.mat
randcmd="${rand} -1 -i ${datadir}/${c}/imgs__delta_clincorr.nii.gz -o ${statsdir}/${c}/rand_${DESIGN} -d ${designsdir}/${c}/covs__${DESIGN}.mat -t ${designsdir}/cons__delta_clincorr_all.con ${rand_opts}"
printf "\n${randcmd}\n\n" > ${statsdir}/${c}/cmd_rand_${DESIGN}.txt

	# DESIGN=delta_clincorr_all_AddCov1; Text2Vest ${datadir}/${c}/covs__${DESIGN}.txt ${designsdir}/${c}/covs__${DESIGN}.mat
	# randcmd="${rand} -1 -i ${datadir}/${c}/imgs__delta_clincorr.nii.gz -o ${statsdir}/${c}/rand_${DESIGN} -d ${designsdir}/${c}/covs__${DESIGN}.mat -t ${designsdir}/cons__delta_clincorr_all_AddCov1.con ${rand_opts}"
	# printf "\n${randcmd}\n\n" > ${statsdir}/${c}/cmd_rand_${DESIGN}.txt

	DESIGN=delta_clincorr_all_AddCov2; Text2Vest ${datadir}/${c}/covs__${DESIGN}.txt ${designsdir}/${c}/covs__${DESIGN}.mat
	randcmd="${rand} -1 -i ${datadir}/${c}/imgs__delta_clincorr_AddCov2.nii.gz -o ${statsdir}/${c}/rand_${DESIGN} -d ${designsdir}/${c}/covs__${DESIGN}.mat -t ${designsdir}/cons__delta_clincorr_all_AddCov2.con ${rand_opts}"
	printf "\n${randcmd}\n\n" > ${statsdir}/${c}/cmd_rand_${DESIGN}.txt
	
	# DESIGN=delta_clincorr_all_AddCov3; Text2Vest ${datadir}/${c}/covs__${DESIGN}.txt ${designsdir}/${c}/covs__${DESIGN}.mat
	# randcmd="${rand} -1 -i ${datadir}/${c}/imgs__delta_clincorr_AddCov3.nii.gz -o ${statsdir}/${c}/rand_${DESIGN} -d ${designsdir}/${c}/covs__${DESIGN}.mat -t ${designsdir}/cons__delta_clincorr_all_AddCov3.con ${rand_opts}"
	# printf "\n${randcmd}\n\n" > ${statsdir}/${c}/cmd_rand_${DESIGN}.txt

DESIGN=delta_clincorr_brady; Text2Vest ${datadir}/${c}/covs__${DESIGN}.txt ${designsdir}/${c}/covs__${DESIGN}.mat
randcmd="${rand} -1 -i ${datadir}/${c}/imgs__delta_clincorr.nii.gz -o ${statsdir}/${c}/rand_${DESIGN} -d ${designsdir}/${c}/covs__${DESIGN}.mat -t ${designsdir}/cons__delta_clincorr_one.con ${rand_opts}"
printf "\n${randcmd}\n\n" > ${statsdir}/${c}/cmd_rand_${DESIGN}.txt

DESIGN=delta_clincorr_moca; Text2Vest ${datadir}/${c}/covs__${DESIGN}.txt ${designsdir}/${c}/covs__${DESIGN}.mat
randcmd="${rand} -1 -i ${datadir}/${c}/imgs__delta_clincorr.nii.gz -o ${statsdir}/${c}/rand_${DESIGN} -d ${designsdir}/${c}/covs__${DESIGN}.mat -t ${designsdir}/cons__delta_clincorr_one.con ${rand_opts}"
printf "\n${randcmd}\n\n" > ${statsdir}/${c}/cmd_rand_${DESIGN}.txt


## Baseline 
### complete case
DESIGN=unpaired_ttest_unmatched; Text2Vest ${datadir}/${c}/covs__delta_unpaired_ttest_unmatched.txt ${designsdir}/${c}/covs__${DESIGN}.mat
randcmd="${rand} -i ${datadir}/${c}/imgs__ba_unpaired_ttest_unmatched.nii.gz -o ${statsdir}/${c}/rand_ba_${DESIGN} -d ${designsdir}/${c}/covs__${DESIGN}.mat -t ${designsdir}/cons__unpaired_ttest.con ${rand_opts2}"
printf "\n${randcmd}\n\n" > ${statsdir}/${c}/cmd_rand_ba_${DESIGN}.txt

# DESIGN=unpaired_ttest_matched; Text2Vest ${datadir}/${c}/covs__delta_unpaired_ttest_matched.txt ${designsdir}/${c}/covs__${DESIGN}.mat
# randcmd="${rand} -i ${datadir}/${c}/imgs__ba_unpaired_ttest_matched.nii.gz -o ${statsdir}/${c}/rand_ba_${DESIGN} -d ${designsdir}/${c}/covs__${DESIGN}.mat -t ${designsdir}/cons__unpaired_ttest.con ${rand_opts2}"
# printf "\n${randcmd}\n\n" > ${statsdir}/${c}/cmd_rand_ba_${DESIGN}.txt

DESIGN=clincorr_all; Text2Vest ${datadir}/${c}/covs__ba_${DESIGN}.txt ${designsdir}/${c}/covs__ba_${DESIGN}.mat
randcmd="${rand} -1 -i ${datadir}/${c}/imgs__ba_clincorr.nii.gz -o ${statsdir}/${c}/rand_ba_${DESIGN} -d ${designsdir}/${c}/covs__ba_${DESIGN}.mat -t ${designsdir}/cons__ses_clincorr_all.con ${rand_opts2}"
printf "\n${randcmd}\n\n" > ${statsdir}/${c}/cmd_rand_ba_${DESIGN}.txt

DESIGN=clincorr_brady; Text2Vest ${datadir}/${c}/covs__ba_${DESIGN}.txt ${designsdir}/${c}/covs__ba_${DESIGN}.mat
randcmd="${rand} -1 -i ${datadir}/${c}/imgs__ba_clincorr.nii.gz -o ${statsdir}/${c}/rand_ba_${DESIGN} -d ${designsdir}/${c}/covs__ba_${DESIGN}.mat -t ${designsdir}/cons__ses_clincorr_one.con ${rand_opts2}"
printf "\n${randcmd}\n\n" > ${statsdir}/${c}/cmd_rand_ba_${DESIGN}.txt

DESIGN=clincorr_moca; Text2Vest ${datadir}/${c}/covs__ba_${DESIGN}.txt ${designsdir}/${c}/covs__ba_${DESIGN}.mat
randcmd="${rand} -1 -i ${datadir}/${c}/imgs__ba_clincorr.nii.gz -o ${statsdir}/${c}/rand_ba_${DESIGN} -d ${designsdir}/${c}/covs__ba_${DESIGN}.mat -t ${designsdir}/cons__ses_clincorr_one.con ${rand_opts2}"
printf "\n${randcmd}\n\n" > ${statsdir}/${c}/cmd_rand_ba_${DESIGN}.txt

### full sample
DESIGN=unpaired_ttest_unmatched; Text2Vest ${datadir}/${c}/by_session/ses-Visit1/covs__${DESIGN}.txt ${designsdir}/${c}/by_session/ses-Visit1/covs__${DESIGN}.mat
randcmd="${rand} -i ${datadir}/${c}/by_session/ses-Visit1/imgs__unpaired_ttest_unmatched.nii.gz -o ${statsdir}/${c}/by_session/ses-Visit1/rand_ba_${DESIGN} -d ${designsdir}/${c}/by_session/ses-Visit1/covs__${DESIGN}.mat -t ${designsdir}/cons__unpaired_ttest.con ${rand_opts2}"
printf "\n${randcmd}\n\n" > ${statsdir}/${c}/by_session/ses-Visit1/cmd_rand_${DESIGN}.txt

DESIGN=clincorr_all; Text2Vest ${datadir}/${c}/by_session/ses-Visit1/covs__${DESIGN}.txt ${designsdir}/${c}/by_session/ses-Visit1/covs__${DESIGN}.mat
randcmd="${rand} -1 -i ${datadir}/${c}/by_session/ses-Visit1/imgs__clincorr.nii.gz -o ${statsdir}/${c}/by_session/ses-Visit1/rand_ba_${DESIGN} -d ${designsdir}/${c}/by_session/ses-Visit1/covs__${DESIGN}.mat -t ${designsdir}/cons__ses_clincorr_all.con ${rand_opts2}"
printf "\n${randcmd}\n\n" > ${statsdir}/${c}/by_session/ses-Visit1/cmd_rand_${DESIGN}.txt

DESIGN=clincorr_brady; Text2Vest ${datadir}/${c}/by_session/ses-Visit1/covs__${DESIGN}.txt ${designsdir}/${c}/by_session/ses-Visit1/covs__${DESIGN}.mat
randcmd="${rand} -1 -i ${datadir}/${c}/by_session/ses-Visit1/imgs__clincorr.nii.gz -o ${statsdir}/${c}/by_session/ses-Visit1/rand_ba_${DESIGN} -d ${designsdir}/${c}/by_session/ses-Visit1/covs__${DESIGN}.mat -t ${designsdir}/cons__ses_clincorr_one.con ${rand_opts2}"
printf "\n${randcmd}\n\n" > ${statsdir}/${c}/by_session/ses-Visit1/cmd_rand_${DESIGN}.txt

DESIGN=clincorr_moca; Text2Vest ${datadir}/${c}/by_session/ses-Visit1/covs__${DESIGN}.txt ${designsdir}/${c}/by_session/ses-Visit1/covs__${DESIGN}.mat
randcmd="${rand} -1 -i ${datadir}/${c}/by_session/ses-Visit1/imgs__clincorr.nii.gz -o ${statsdir}/${c}/by_session/ses-Visit1/rand_ba_${DESIGN} -d ${designsdir}/${c}/by_session/ses-Visit1/covs__${DESIGN}.mat -t ${designsdir}/cons__ses_clincorr_one.con ${rand_opts2}"
printf "\n${randcmd}\n\n" > ${statsdir}/${c}/by_session/ses-Visit1/cmd_rand_${DESIGN}.txt

## Follow-up 
### complete case
DESIGN=unpaired_ttest_unmatched; Text2Vest ${datadir}/${c}/covs__delta_unpaired_ttest_unmatched.txt ${designsdir}/${c}/covs__${DESIGN}.mat
randcmd="${rand} -i ${datadir}/${c}/imgs__fu_unpaired_ttest_unmatched.nii.gz -o ${statsdir}/${c}/rand_fu_${DESIGN} -d ${designsdir}/${c}/covs__${DESIGN}.mat -t ${designsdir}/cons__unpaired_ttest.con ${rand_opts2}"
printf "\n${randcmd}\n\n" > ${statsdir}/${c}/cmd_rand_fu_${DESIGN}.txt

# DESIGN=unpaired_ttest_matched; Text2Vest ${datadir}/${c}/covs__delta_unpaired_ttest_matched.txt ${designsdir}/${c}/covs__${DESIGN}.mat
# randcmd="${rand} -i ${datadir}/${c}/imgs__fu_unpaired_ttest_matched.nii.gz -o ${statsdir}/${c}/rand_fu_${DESIGN} -d ${designsdir}/${c}/covs__${DESIGN}.mat -t ${designsdir}/cons__unpaired_ttest.con ${rand_opts2}"
# printf "\n${randcmd}\n\n" > ${statsdir}/${c}/cmd_rand_fu_${DESIGN}.txt

DESIGN=clincorr_all; Text2Vest ${datadir}/${c}/covs__fu_${DESIGN}.txt ${designsdir}/${c}/covs__fu_${DESIGN}.mat
randcmd="${rand} -1 -i ${datadir}/${c}/imgs__fu_clincorr.nii.gz -o ${statsdir}/${c}/rand_fu_${DESIGN} -d ${designsdir}/${c}/covs__fu_${DESIGN}.mat -t ${designsdir}/cons__ses_clincorr_all.con ${rand_opts2}"
printf "\n${randcmd}\n\n" > ${statsdir}/${c}/cmd_rand_fu_${DESIGN}.txt

DESIGN=clincorr_brady; Text2Vest ${datadir}/${c}/covs__fu_${DESIGN}.txt ${designsdir}/${c}/covs__fu_${DESIGN}.mat
randcmd="${rand} -1 -i ${datadir}/${c}/imgs__fu_clincorr.nii.gz -o ${statsdir}/${c}/rand_fu_${DESIGN} -d ${designsdir}/${c}/covs__fu_${DESIGN}.mat -t ${designsdir}/cons__ses_clincorr_one.con ${rand_opts2}"
printf "\n${randcmd}\n\n" > ${statsdir}/${c}/cmd_rand_fu_${DESIGN}.txt

DESIGN=clincorr_moca; Text2Vest ${datadir}/${c}/covs__fu_${DESIGN}.txt ${designsdir}/${c}/covs__fu_${DESIGN}.mat
randcmd="${rand} -1 -i ${datadir}/${c}/imgs__fu_clincorr.nii.gz -o ${statsdir}/${c}/rand_fu_${DESIGN} -d ${designsdir}/${c}/covs__fu_${DESIGN}.mat -t ${designsdir}/cons__ses_clincorr_one.con ${rand_opts2}"
printf "\n${randcmd}\n\n" > ${statsdir}/${c}/cmd_rand_fu_${DESIGN}.txt

### full sample
DESIGN=unpaired_ttest_unmatched; Text2Vest ${datadir}/${c}/by_session/ses-Visit2/covs__${DESIGN}.txt ${designsdir}/${c}/by_session/ses-Visit2/covs__${DESIGN}.mat
randcmd="${rand} -i ${datadir}/${c}/by_session/ses-Visit2/imgs__unpaired_ttest_unmatched.nii.gz -o ${statsdir}/${c}/by_session/ses-Visit2/rand_fu_${DESIGN} -d ${designsdir}/${c}/by_session/ses-Visit2/covs__${DESIGN}.mat -t ${designsdir}/cons__unpaired_ttest.con ${rand_opts2}"
printf "\n${randcmd}\n\n" > ${statsdir}/${c}/by_session/ses-Visit2/cmd_rand_${DESIGN}.txt

DESIGN=clincorr_all; Text2Vest ${datadir}/${c}/by_session/ses-Visit2/covs__${DESIGN}.txt ${designsdir}/${c}/by_session/ses-Visit2/covs__${DESIGN}.mat
randcmd="${rand} -1 -i ${datadir}/${c}/by_session/ses-Visit2/imgs__clincorr.nii.gz -o ${statsdir}/${c}/by_session/ses-Visit2/rand_fu_${DESIGN} -d ${designsdir}/${c}/by_session/ses-Visit2/covs__${DESIGN}.mat -t ${designsdir}/cons__ses_clincorr_all.con ${rand_opts2}"
printf "\n${randcmd}\n\n" > ${statsdir}/${c}/by_session/ses-Visit2/cmd_rand_${DESIGN}.txt

DESIGN=clincorr_brady; Text2Vest ${datadir}/${c}/by_session/ses-Visit2/covs__${DESIGN}.txt ${designsdir}/${c}/by_session/ses-Visit2/covs__${DESIGN}.mat
randcmd="${rand} -1 -i ${datadir}/${c}/by_session/ses-Visit2/imgs__clincorr.nii.gz -o ${statsdir}/${c}/by_session/ses-Visit2/rand_fu_${DESIGN} -d ${designsdir}/${c}/by_session/ses-Visit2/covs__${DESIGN}.mat -t ${designsdir}/cons__ses_clincorr_one.con ${rand_opts2}"
printf "\n${randcmd}\n\n" > ${statsdir}/${c}/by_session/ses-Visit2/cmd_rand_${DESIGN}.txt

DESIGN=clincorr_moca; Text2Vest ${datadir}/${c}/by_session/ses-Visit2/covs__${DESIGN}.txt ${designsdir}/${c}/by_session/ses-Visit2/covs__${DESIGN}.mat
randcmd="${rand} -1 -i ${datadir}/${c}/by_session/ses-Visit2/imgs__clincorr.nii.gz -o ${statsdir}/${c}/by_session/ses-Visit2/rand_fu_${DESIGN} -d ${designsdir}/${c}/by_session/ses-Visit2/covs__${DESIGN}.mat -t ${designsdir}/cons__ses_clincorr_one.con ${rand_opts2}"
printf "\n${randcmd}\n\n" > ${statsdir}/${c}/by_session/ses-Visit2/cmd_rand_${DESIGN}.txt

done

