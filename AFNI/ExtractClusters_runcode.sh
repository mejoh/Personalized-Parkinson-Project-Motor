#!/bin/bash

dir=/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/WholeBrain
cd $dir
source ~/scripts/Personalized-Parkinson-Project-Motor/AFNI/ExtractClusters.sh
nvox=`1d_tool.py -infile /project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/afc/CLUSTER-TABLE.NN2_2sided.1D -csim_show_clustsize -verb 0`
# nvox=`1d_tool.py -infile /project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/afc/Masked/CLUSTER-TABLE.NN2_2sided.1D -csim_show_clustsize -verb 0`
#extract_clusters <Analysis directory> <File name> <Effect> <Data for show> <Data for threhsolding> <Type of stat> <Cluster size thr>

# #3dMVM - disease
# extract_clusters $dir/3dMVM_disease con_0010_Group2 T_Delta 4 5 T $nvox
# extract_clusters $dir/3dMVM_disease con_0012_Group2 T_Delta 4 5 T $nvox
# extract_clusters $dir/3dMVM_disease con_0013_Group2 T_Delta 4 5 T $nvox
# #3dMVM - severity
# extract_clusters $dir/3dMVM_severity con_0010_Severity T_Delta 5 6 T $nvox
# extract_clusters $dir/3dMVM_severity con_0012_Severity T_Delta 5 6 T $nvox
# extract_clusters $dir/3dMVM_severity con_0013_Severity T_Delta 5 6 T $nvox
#3dttest++ - disease
extract_clusters $dir/3dttest++ con_0010_Group2 T_Delta 0 1 Z `1d_tool.py -infile 3dttest++/con_0010_Group2.CSimA.NN2_2sided.1D -csim_show_clustsize -verb 0`
extract_clusters $dir/3dttest++ con_0012_Group2 T_Delta 0 1 Z `1d_tool.py -infile 3dttest++/con_0012_Group2.CSimA.NN2_2sided.1D -csim_show_clustsize -verb 0`
extract_clusters $dir/3dttest++ con_0013_Group2 T_Delta 0 1 Z `1d_tool.py -infile 3dttest++/con_0013_Group2.CSimA.NN2_2sided.1D -csim_show_clustsize -verb 0`
extract_clusters $dir/3dttest++ con_0008_Group2 T_Delta 0 1 Z `1d_tool.py -infile 3dttest++/con_0008_Group2.CSimA.NN2_2sided.1D -csim_show_clustsize -verb 0`
#3dttest++ - severity
extract_clusters $dir/3dttest++_severity con_0010_Severity2 T_Delta 4 5 Z `1d_tool.py -infile 3dttest++_severity/con_0010_Severity2.CSimA.NN2_2sided.1D -csim_show_clustsize -verb 0`
extract_clusters $dir/3dttest++_severity con_0012_Severity2 T_Delta 4 5 Z `1d_tool.py -infile 3dttest++_severity/con_0012_Severity2.CSimA.NN2_2sided.1D -csim_show_clustsize -verb 0`
extract_clusters $dir/3dttest++_severity con_0013_Severity2 T_Delta 4 5 Z `1d_tool.py -infile 3dttest++_severity/con_0013_Severity2.CSimA.NN2_2sided.1D -csim_show_clustsize -verb 0`
extract_clusters $dir/3dttest++_severity con_0008_Severity2 T_Delta 4 5 Z `1d_tool.py -infile 3dttest++_severity/con_0008_Severity2.CSimA.NN2_2sided.1D -csim_show_clustsize -verb 0`
# 3dLME - disease
extract_clusters $dir/3dLME_disease con_combined_Group2_x_TimepointNr2_x_Type3 Z_TimeGroupType2gt1 9 10 Z $nvox
extract_clusters $dir/3dLME_disease con_combined_Group2_x_TimepointNr2_x_Type3 Z_TimeGroupType3gt1 11 12 Z $nvox
extract_clusters $dir/3dLME_disease con_combined_Group2_x_TimepointNr2_x_Type3 Z_TimeGroupType3gt2 13 14 Z $nvox
extract_clusters $dir/3dLME_disease con_combined_Group2_x_TimepointNr2_x_Type3 Z_TimeGroup 17 18 Z $nvox
extract_clusters $dir/3dLME_disease con_combined_Group2_x_TimepointNr2_x_Type3 Z_Group 47 48 Z $nvox
extract_clusters $dir/3dLME_disease con_combined_Group2_x_TimepointNr2_x_Type3 Z_GroupBA 49 50 Z $nvox
extract_clusters $dir/3dLME_disease con_combined_Group2_x_TimepointNr2_x_Type3 Z_GroupFU 51 52 Z $nvox
extract_clusters $dir/3dLME_disease con_combined_Group2_x_TimepointNr2_x_Type3 Z_Time 53 54 Z $nvox
extract_clusters $dir/3dLME_disease con_combined_Group2_x_TimepointNr2_x_Type3 Z_Type2gt1 55 56 Z $nvox
extract_clusters $dir/3dLME_disease con_combined_Group2_x_TimepointNr2_x_Type3 Z_Type2gt1BA 57 58 Z $nvox
extract_clusters $dir/3dLME_disease con_combined_Group2_x_TimepointNr2_x_Type3 Z_Type2gt1FU 59 60 Z $nvox
extract_clusters $dir/3dLME_disease con_combined_Group2_x_TimepointNr2_x_Type3 Z_Type3gt1 61 62 Z $nvox
extract_clusters $dir/3dLME_disease con_combined_Group2_x_TimepointNr2_x_Type3 Z_Type3gt1BA 63 64 Z $nvox
extract_clusters $dir/3dLME_disease con_combined_Group2_x_TimepointNr2_x_Type3 Z_Type3gt1FU 65 66 Z $nvox
extract_clusters $dir/3dLME_disease con_combined_Group2_x_TimepointNr2_x_Type3 Z_Type3gt2 67 68 Z $nvox
extract_clusters $dir/3dLME_disease con_combined_Group2_x_TimepointNr2_x_Type3 Z_Type3gt2BA 69 70 Z $nvox
extract_clusters $dir/3dLME_disease con_combined_Group2_x_TimepointNr2_x_Type3 Z_Type3gt2FU 71 72 Z $nvox
# # 3dLME_AC - disease
# extract_clusters $dir/3dLME_disease con_0010_Group2_x_TimepointNr2-poly1 Z_TimeGroup 5 6 Z $nvox
# extract_clusters $dir/3dLME_disease con_0012_Group2_x_TimepointNr2-poly1 Z_TimeGroup 5 6 Z $nvox
# extract_clusters $dir/3dLME_disease con_0013_Group2_x_TimepointNr2-poly1 Z_TimeGroup 5 6 Z $nvox
# 3dLME - subtype
	# MMP vs IM
extract_clusters $dir/3dLME_subtype con_combined_MMPvsIM_x_TimepointNr2_x_Type3 Z_TimeGroupType2gt1 9 10 Z $nvox
extract_clusters $dir/3dLME_subtype con_combined_MMPvsIM_x_TimepointNr2_x_Type3 Z_TimeGroupType3gt1 11 12 Z $nvox
extract_clusters $dir/3dLME_subtype con_combined_MMPvsIM_x_TimepointNr2_x_Type3 Z_TimeGroupType3gt2 13 14 Z $nvox
extract_clusters $dir/3dLME_subtype con_combined_MMPvsIM_x_TimepointNr2_x_Type3 Z_TimeGroup 17 18 Z $nvox
	# MMP vs DM
extract_clusters $dir/3dLME_subtype con_combined_MMPvsDM_x_TimepointNr2_x_Type3 Z_TimeGroupType2gt1 9 10 Z $nvox
extract_clusters $dir/3dLME_subtype con_combined_MMPvsDM_x_TimepointNr2_x_Type3 Z_TimeGroupType3gt1 11 12 Z $nvox
extract_clusters $dir/3dLME_subtype con_combined_MMPvsDM_x_TimepointNr2_x_Type3 Z_TimeGroupType3gt2 13 14 Z $nvox
extract_clusters $dir/3dLME_subtype con_combined_MMPvsDM_x_TimepointNr2_x_Type3 Z_TimeGroup 17 18 Z $nvox
	# IM vs DM
extract_clusters $dir/3dLME_subtype con_combined_IMvsDM_x_TimepointNr2_x_Type3 Z_TimeGroupType2gt1 9 10 Z $nvox
extract_clusters $dir/3dLME_subtype con_combined_IMvsDM_x_TimepointNr2_x_Type3 Z_TimeGroupType3gt1 11 12 Z $nvox
extract_clusters $dir/3dLME_subtype con_combined_IMvsDM_x_TimepointNr2_x_Type3 Z_TimeGroupType3gt2 13 14 Z $nvox
extract_clusters $dir/3dLME_subtype con_combined_IMvsDM_x_TimepointNr2_x_Type3 Z_TimeGroup 17 18 Z $nvox
	# HC vs MMP
extract_clusters $dir/3dLME_subtype con_combined_HCvsMMP_x_TimepointNr2_x_Type3 Z_TimeGroupType2gt1 9 10 Z $nvox
extract_clusters $dir/3dLME_subtype con_combined_HCvsMMP_x_TimepointNr2_x_Type3 Z_TimeGroupType3gt1 11 12 Z $nvox
extract_clusters $dir/3dLME_subtype con_combined_HCvsMMP_x_TimepointNr2_x_Type3 Z_TimeGroupType3gt2 13 14 Z $nvox
extract_clusters $dir/3dLME_subtype con_combined_HCvsMMP_x_TimepointNr2_x_Type3 Z_TimeGroup 17 18 Z $nvox
	# HC vs IM
extract_clusters $dir/3dLME_subtype con_combined_HCvsIM_x_TimepointNr2_x_Type3 Z_TimeGroupType2gt1 9 10 Z $nvox
extract_clusters $dir/3dLME_subtype con_combined_HCvsIM_x_TimepointNr2_x_Type3 Z_TimeGroupType3gt1 11 12 Z $nvox
extract_clusters $dir/3dLME_subtype con_combined_HCvsIM_x_TimepointNr2_x_Type3 Z_TimeGroupType3gt2 13 14 Z $nvox
extract_clusters $dir/3dLME_subtype con_combined_HCvsIM_x_TimepointNr2_x_Type3 Z_TimeGroup 17 18 Z $nvox
	# HC vs DM
extract_clusters $dir/3dLME_subtype con_combined_HCvsDM_x_TimepointNr2_x_Type3 Z_TimeGroupType2gt1 9 10 Z $nvox
extract_clusters $dir/3dLME_subtype con_combined_HCvsDM_x_TimepointNr2_x_Type3 Z_TimeGroupType3gt1 11 12 Z $nvox
extract_clusters $dir/3dLME_subtype con_combined_HCvsDM_x_TimepointNr2_x_Type3 Z_TimeGroupType3gt2 13 14 Z $nvox
extract_clusters $dir/3dLME_subtype con_combined_HCvsDM_x_TimepointNr2_x_Type3 Z_TimeGroup 17 18 Z $nvox