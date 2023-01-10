#!/bin/bash
# Extract clusters from 3dLME analyses

module unload afni; module load afni/2022

# extract_clusters <Analysis directory> <Effect> <Data for show> <Data for threhsolding> <Type of stat>
function extract_clusters(){

DIR=$1         # Directory containing 3dLME output
PREFIX=$2
EFFECT=$3      # Name of effect
COEF=$4        # Index of coef for -idat
STAT=$5        # Index of stats for -ithr
TYPE=$6        # F or Z, determines whether 1sided or bisided

mkdir -p $DIR/stats
cd $DIR/stats

pref_map=${EFFECT}_idxmask
pref_dat=${EFFECT}_FWEcorr-stat
clusters=${EFFECT}_clusters.txt

  if [ $TYPE == Z ]; then
	# Two-tailed Z-stat thresholding
	3dClusterize \
	  -pref_map ${pref_map} \
	  -pref_dat ${pref_dat} \
	  -mask ../mask.nii.gz \
	  -nosum \
	  -1Dformat \
	  -inset ../${PREFIX}*+tlrc.HEAD \
	  -idat ${COEF} \
	  -ithr ${STAT} \
	  -NN 2 \
	  -clust_nvox 108 \
	  -bisided p=0.001 \
	  > ${clusters}
  elif [ $TYPE == Chisq ];then
    # Two-tailed F-stat threhsolding
	# F/Chisq-values are exclusively positive
	# p/0.001 provides us with an appropriate two-tailed threshold
	# This can be confirmed by using the AFNI GUI
	3dClusterize \
	  -pref_map ${pref_map} \
	  -pref_dat ${pref_dat} \
	  -mask ../mask.nii.gz \
	  -nosum \
	  -1Dformat \
	  -inset ../${PREFIX}*+tlrc.HEAD \
	  -idat ${COEF} \
	  -ithr ${STAT} \
	  -NN 2 \
	  -clust_nvox 108 \
	  -1sided RIGHT_TAIL p=0.0005 \
	  > ${clusters}
  fi


if [ -f "${pref_map}+tlrc.HEAD" ]; then
	# 3dClusterize outputs a mask in TLRC space even though data is in MNI.
	# Caution: Cluster info is given for the same mask in both TLRC and MNI space.
	# It is unclear which of them is correct. Use at your own risk.
	whereami -atlas DD_Desai_MPM -omask ${pref_map}+tlrc. > ${pref_map}_a-DD-Desai-MPM.txt
	whereami -atlas CA_MPM_22_TT  -omask ${pref_map}+tlrc. > ${pref_map}_a-CA-MPM-22-TT.txt
	3drefit -space MNI ${pref_map}+tlrc.
	whereami -atlas CA_MPM_22_MNI  -omask ${pref_map}+tlrc. > ${pref_map}_a-CA-MPM-22-MNI.txt
	whereami -atlas MNI_Glasser_HCP_v1.0  -omask ${pref_map}+tlrc > ${pref_map}_a-MNI-Glasser-HCP-v1.txt
	whereami -atlas Brainnetome_1.0  -omask ${pref_map}+tlrc > ${pref_map}_a-Brainnetome-v1.txt
	3drefit -space TLRC ${pref_map}+tlrc.

	3dAFNItoNIFTI ${pref_map}+tlrc
	3dAFNItoNIFTI ${pref_map}+tlrc
	3dAFNItoNIFTI ${pref_dat}+tlrc
	3dAFNItoNIFTI ${pref_dat}+tlrc
fi

}

# Clear out previous output
rm /project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/ROI/3dLME_disease/stats/*
rm /project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/WholeBrain/3dLME_disease/stats/*
rm /project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/ROI/3dLME_severity/stats/*
rm /project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/WholeBrain/3dLME_severity/stats/*

##### Disease #####
# Input directory
type=(ROI WholeBrain)
for t in ${type[@]}; do
	echo "$t disease"
	dir=/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/$t/3dLME_disease
	# Effects and the indices for their coefs (used for display) and z-stats (used for thresholding)
	extract_clusters $dir con_combined_Group2_x_YearsToFollowUp2-poly1_x_Type3 Chisq_Time 0 0 Chisq
	extract_clusters $dir con_combined_Group2_x_YearsToFollowUp2-poly1_x_Type3 Chisq_Group 1 1 Chisq
	extract_clusters $dir con_combined_Group2_x_YearsToFollowUp2-poly1_x_Type3 Chisq_Type 2 2 Chisq
	extract_clusters $dir con_combined_Group2_x_YearsToFollowUp2-poly1_x_Type3 Chisq_Age 3 3 Chisq
	extract_clusters $dir con_combined_Group2_x_YearsToFollowUp2-poly1_x_Type3 Chisq_Sex 4 4 Chisq
	extract_clusters $dir con_combined_Group2_x_YearsToFollowUp2-poly1_x_Type3 Chisq_TimeGroup 5 5 Chisq
	extract_clusters $dir con_combined_Group2_x_YearsToFollowUp2-poly1_x_Type3 Chisq_TimeType 6 6 Chisq
	extract_clusters $dir con_combined_Group2_x_YearsToFollowUp2-poly1_x_Type3 Chisq_GroupType 7 7 Chisq
	extract_clusters $dir con_combined_Group2_x_YearsToFollowUp2-poly1_x_Type3 Chisq_TimeGroupType 8 8 Chisq
	
	extract_clusters $dir con_combined_Group2_x_YearsToFollowUp2-poly1_x_Type3 Z_TimeGroupType2gt1 9 10 Z
	extract_clusters $dir con_combined_Group2_x_YearsToFollowUp2-poly1_x_Type3 Z_TimeGroupType3gt1 11 12 Z
	extract_clusters $dir con_combined_Group2_x_YearsToFollowUp2-poly1_x_Type3 Z_TimeGroup 17 18 Z
	
	extract_clusters $dir con_combined_Group2_x_YearsToFollowUp2-poly1_x_Type3 Z_Group 47 48 Z
	extract_clusters $dir con_combined_Group2_x_YearsToFollowUp2-poly1_x_Type3 Z_Time 53 54 Z
	extract_clusters $dir con_combined_Group2_x_YearsToFollowUp2-poly1_x_Type3 Z_Type2gt1 55 56 Z
	extract_clusters $dir con_combined_Group2_x_YearsToFollowUp2-poly1_x_Type3 Z_Type3gt1 57 58 Z
	
done
#####

##### Severity #####
# Input directory
type=(ROI WholeBrain)
for t in ${type[@]}; do
	echo "$t severity"
	dir=/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/$t/3dLME_severity
	# Effects and the indices for their coefs (used for display) and z-stats (used for thresholding)

	extract_clusters $dir con_combined_Severity2-poly1_x_Type3 Chisq_Severity 0 0 Chisq
	extract_clusters $dir con_combined_Severity2-poly1_x_Type3 Chisq_Type 1 1 Chisq
	extract_clusters $dir con_combined_Severity2-poly1_x_Type3 Chisq_Age 2 2 Chisq
	extract_clusters $dir con_combined_Severity2-poly1_x_Type3 Chisq_Sex 3 3 Chisq
	extract_clusters $dir con_combined_Severity2-poly1_x_Type3 Chisq_SeverityType 4 4 Chisq
	
	extract_clusters $dir con_combined_Severity2-poly1_x_Type3 Z_SeverityType2gt1 5 6 Z
	extract_clusters $dir con_combined_Severity2-poly1_x_Type3 Z_SeverityType3gt1 7 8 Z
	extract_clusters $dir con_combined_Severity2-poly1_x_Type3 Z_SeverityTypeMean 13 14 Z
	
	# extract_clusters $dir con_combined_Severity-poly2_x_Type3 p2Chisq_Severity 0 0 Chisq
	# extract_clusters $dir con_combined_Severity-poly2_x_Type3 p2Chisq_Type 1 1 Chisq
	# extract_clusters $dir con_combined_Severity-poly2_x_Type3 p2Chisq_Severity2 2 2 Chisq
	# extract_clusters $dir con_combined_Severity-poly2_x_Type3 p2Chisq_Age 3 3 Chisq
	# extract_clusters $dir con_combined_Severity-poly2_x_Type3 p2Chisq_FD 4 4 Chisq
	# extract_clusters $dir con_combined_Severity-poly2_x_Type3 p2Chisq_Sex 5 5 Chisq
	# extract_clusters $dir con_combined_Severity-poly2_x_Type3 p2Chisq_SeverityType 6 6 Chisq
	# extract_clusters $dir con_combined_Severity-poly2_x_Type3 p2Chisq_Severity2Type 7 7 Chisq

	# extract_clusters $dir con_combined_Severity-poly3_x_Type3 p3Chisq_Severity 0 0 Chisq
	# extract_clusters $dir con_combined_Severity-poly3_x_Type3 p3Chisq_Type 1 1 Chisq
	# extract_clusters $dir con_combined_Severity-poly3_x_Type3 p3Chisq_Severity2 2 2 Chisq
	# extract_clusters $dir con_combined_Severity-poly3_x_Type3 p3Chisq_Severity2 3 3 Chisq
	# extract_clusters $dir con_combined_Severity-poly3_x_Type3 p3Chisq_Age 4 4 Chisq
	# extract_clusters $dir con_combined_Severity-poly3_x_Type3 p3Chisq_FD 5 5 Chisq
	# extract_clusters $dir con_combined_Severity-poly3_x_Type3 p3Chisq_Sex 6 6 Chisq
	# extract_clusters $dir con_combined_Severity-poly3_x_Type3 p3Chisq_SeverityType 7 7 Chisq
	# extract_clusters $dir con_combined_Severity-poly3_x_Type3 p3Chisq_Severity2Type 8 8 Chisq
	# extract_clusters $dir con_combined_Severity-poly3_x_Type3 p3Chisq_Severity3Type 9 9 Chisq
	
done
#####