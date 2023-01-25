#!/bin/bash

dir=/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/ROI
source ~/scripts/Personalized-Parkinson-Project-Motor/AFNI/ExtractClusters.sh
#extract_clusters <Analysis directory> <File name> <Effect> <Data for show> <Data for threhsolding> <Type of stat> <Cluster size thr>

#3dMVM - disease
extract_clusters $dir/3dMVM_disease con_0010_Group2 T_Delta 4 5 T 10
extract_clusters $dir/3dMVM_disease con_0012_Group2 T_Delta 4 5 T 10
extract_clusters $dir/3dMVM_disease con_0013_Group2 T_Delta 4 5 T 10
#3dMVM - severity
extract_clusters $dir/3dMVM_severity con_0010_Severity T_Delta 5 6 T 10
extract_clusters $dir/3dMVM_severity con_0012_Severity T_Delta 5 6 T 10
extract_clusters $dir/3dMVM_severity con_0013_Severity T_Delta 5 6 T 10
#3dttest++ - disease
extract_clusters $dir/3dttest++ con_0010_PDvsHC T_Delta 0 1 Z 35
extract_clusters $dir/3dttest++ con_0012_PDvsHC T_Delta 0 1 Z 35
extract_clusters $dir/3dttest++ con_0013_PDvsHC T_Delta 0 1 Z 34
#3dttest++ - severity
extract_clusters $dir/3dttest++_severity con_0010_severity T_Delta 4 5 Z 35
extract_clusters $dir/3dttest++_severity con_0012_severity T_Delta 4 5 Z 31
extract_clusters $dir/3dttest++_severity con_0013_severity T_Delta 4 5 Z 34

# 3dLME_AC - disease
extract_clusters $dir/3dLME_disease con_0010_Group2_x_YearsToFollowUp2-poly1 Z_TimeGroup 5 6 Z 30
extract_clusters $dir/3dLME_disease con_0012_Group2_x_YearsToFollowUp2-poly1 Z_TimeGroup 5 6 Z 30
extract_clusters $dir/3dLME_disease con_0013_Group2_x_YearsToFollowUp2-poly1 Z_TimeGroup 5 6 Z 30

# 3dLME - disease
extract_clusters $dir/3dLME_disease con_combined_Group2_x_YearsToFollowUp2-poly1_x_Type3 Z_TimeGroupType2gt1 9 10 Z 30
extract_clusters $dir/3dLME_disease con_combined_Group2_x_YearsToFollowUp2-poly1_x_Type3 Z_TimeGroupType3gt1 11 12 Z 30
extract_clusters $dir/3dLME_disease con_combined_Group2_x_YearsToFollowUp2-poly1_x_Type3 Z_TimeGroup 17 18 Z 30

