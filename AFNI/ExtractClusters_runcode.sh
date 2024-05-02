#!/bin/bash

module load afni
dir=/project/3024006.02/Analyses/motor_task/Group/Longitudinal/AFNI/ROI/Masked_full/
cd $dir
source ~/scripts/Personalized-Parkinson-Project-Motor/AFNI/ExtractClusters.sh
# nvox=`1d_tool.py -infile /project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/afc/CLUSTER-TABLE.NN2_2sided.1D -csim_show_clustsize -verb 0`
# nvox=`1d_tool.py -infile /project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/afc/Masked/CLUSTER-TABLE.NN2_2sided.1D -csim_show_clustsize -verb 0`
#extract_clusters <Analysis directory> <File name> <Effect> <Data for show> <Data for threhsolding> <Type of stat> <Cluster size thr>

# #3dMVM - subtype
# extract_clusters $dir/3dMVM_subtype con_0010_MMPvsDM T_Delta 4 5 T $nvox
# extract_clusters $dir/3dMVM_subtype con_0012_MMPvsDM T_Delta 4 5 T $nvox
# extract_clusters $dir/3dMVM_subtype con_0013_MMPvsDM T_Delta 4 5 T $nvox
# #3dMVM - severity
# extract_clusters $dir/3dMVM_severity con_0010_Severity T_Delta 5 6 T $nvox
# extract_clusters $dir/3dMVM_severity con_0012_Severity T_Delta 5 6 T $nvox
# extract_clusters $dir/3dMVM_severity con_0013_Severity T_Delta 5 6 T $nvox
#3dttest++ - subtype
# nvox=`1d_tool.py -infile 3dttest++/con_0010_MMPvsDM.CSimA.NN2_2sided.1D -csim_show_clustsize -verb 0`
# extract_clusters $dir/3dttest++ con_0010_MMPvsDM T_Delta 1 1 Z $nvox
# extract_clusters $dir/3dttest++ con_0012_MMPvsDM T_Delta 1 1 Z $nvox
# extract_clusters $dir/3dttest++ con_0013_MMPvsDM T_Delta 1 1 Z $nvox
#3dttest++ - disease
nvox=`1d_tool.py -infile 3dttest++/con_0010_Group2.CSimA.NN2_2sided.1D -csim_show_clustsize -verb 0`
extract_clusters $dir/3dttest++ con_0010_Group2 T_Delta 1 1 Z $nvox
nvox=`1d_tool.py -infile 3dttest++/con_0007_Group2.CSimA.NN2_2sided.1D -csim_show_clustsize -verb 0`
extract_clusters $dir/3dttest++ con_0007_Group2 T_Delta 1 1 Z $nvox
#3dttest++ - severity
nvox=`1d_tool.py -infile 3dttest++_severity/con_0010_Severity.CSimA.NN2_2sided.1D -csim_show_clustsize -verb 0`
extract_clusters $dir/3dttest++_severity con_0010_Severity T_Delta_brady 5 5 Z $nvox
extract_clusters $dir/3dttest++_severity con_0010_Severity T_Delta_moca 9 9 Z $nvox
nvox=`1d_tool.py -infile 3dttest++_severity/con_0007_Severity.CSimA.NN2_2sided.1D -csim_show_clustsize -verb 0`
extract_clusters $dir/3dttest++_severity con_0007_Severity T_Delta_brady 5 5 Z $nvox
extract_clusters $dir/3dttest++_severity con_0007_Severity T_Delta_moca 9 9 Z $nvox
# 3dLME - disease
## Combined
nvox=`1d_tool.py -infile 3dLME_disease/con_combined_Group2_x_TimepointNr2_x_Type3.CSimA.NN2_2sided.1D -csim_show_clustsize -verb 0`
# extract_clusters $dir/3dLME_disease con_combined_Group2_x_TimepointNr2_x_Type3 chi_TimeGroupType 8 8 Chisq $nvox
# extract_clusters $dir/3dLME_disease con_combined_Group2_x_TimepointNr2_x_Type3 chi_TimeGroup 5 5 Chisq $nvox
# extract_clusters $dir/3dLME_disease con_combined_Group2_x_TimepointNr2_x_Type3 chi_GroupType 6 6 Chisq $nvox
# extract_clusters $dir/3dLME_disease con_combined_Group2_x_TimepointNr2_x_Type3 chi_TimeType 7 7 Chisq $nvox
# extract_clusters $dir/3dLME_disease con_combined_Group2_x_TimepointNr2_x_Type3 chi_Group 0 0 Chisq $nvox
# extract_clusters $dir/3dLME_disease con_combined_Group2_x_TimepointNr2_x_Type3 chi_Time 1 1 Chisq $nvox
# extract_clusters $dir/3dLME_disease con_combined_Group2_x_TimepointNr2_x_Type3 chi_Type 2 2 Chisq $nvox
extract_clusters $dir/3dLME_disease con_combined_Group2_x_TimepointNr2_x_Type3 Z_Group_by_Time_by_Type 12 12 Z $nvox
extract_clusters $dir/3dLME_disease con_combined_Group2_x_TimepointNr2_x_Type3 Z_PD_by_Time_by_Type 16 16 Z $nvox
extract_clusters $dir/3dLME_disease con_combined_Group2_x_TimepointNr2_x_Type3 Z_HC_by_Time_by_Type 14 14 Z $nvox
extract_clusters $dir/3dLME_disease con_combined_Group2_x_TimepointNr2_x_Type3 z_Group_by_Time 18 18 Z $nvox
extract_clusters $dir/3dLME_disease con_combined_Group2_x_TimepointNr2_x_Type3 z_PD_by_Time 22 22 Z $nvox
extract_clusters $dir/3dLME_disease con_combined_Group2_x_TimepointNr2_x_Type3 z_HC_by_Time 20 20 Z $nvox
extract_clusters $dir/3dLME_disease con_combined_Group2_x_TimepointNr2_x_Type3 z_Group_by_Type 24 24 Z $nvox
extract_clusters $dir/3dLME_disease con_combined_Group2_x_TimepointNr2_x_Type3 z_PD_by_Type 28 28 Z $nvox
extract_clusters $dir/3dLME_disease con_combined_Group2_x_TimepointNr2_x_Type3 z_HC_by_Type 26 26 Z $nvox
extract_clusters $dir/3dLME_disease con_combined_Group2_x_TimepointNr2_x_Type3 Z_Group 42 42 Z $nvox
extract_clusters $dir/3dLME_disease con_combined_Group2_x_TimepointNr2_x_Type3 Z_GroupBA 44 44 Z $nvox
extract_clusters $dir/3dLME_disease con_combined_Group2_x_TimepointNr2_x_Type3 Z_GroupFU 46 46 Z $nvox
extract_clusters $dir/3dLME_disease con_combined_Group2_x_TimepointNr2_x_Type3 Z_Time 48 48 Z $nvox
extract_clusters $dir/3dLME_disease con_combined_Group2_x_TimepointNr2_x_Type3 Z_Type 50 50 Z $nvox
extract_clusters $dir/3dLME_disease con_combined_Group2_x_TimepointNr2_x_Type3 Z_TypeBA 52 52 Z $nvox
extract_clusters $dir/3dLME_disease con_combined_Group2_x_TimepointNr2_x_Type3 Z_TypeFU 54 54 Z $nvox
## Across choice
nvox=`1d_tool.py -infile 3dLME_disease/con_0010_Group2_x_TimepointNr2.CSimA.NN2_2sided.1D -csim_show_clustsize -verb 0`
extract_clusters $dir/3dLME_disease con_0010_Group2_x_TimepointNr2 chi_TimeGroup 4 4 Chisq $nvox
extract_clusters $dir/3dLME_disease con_0010_Group2_x_TimepointNr2 chi_Group 0 0 Chisq $nvox
extract_clusters $dir/3dLME_disease con_0010_Group2_x_TimepointNr2 chi_Time 1 1 Chisq $nvox
nvox=`1d_tool.py -infile 3dLME_disease/con_0012_Group2_x_TimepointNr2.CSimA.NN2_2sided.1D -csim_show_clustsize -verb 0`
extract_clusters $dir/3dLME_disease con_0012_Group2_x_TimepointNr2 chi_TimeGroup 4 4 Chisq $nvox
extract_clusters $dir/3dLME_disease con_0012_Group2_x_TimepointNr2 chi_Group 0 0 Chisq $nvox
extract_clusters $dir/3dLME_disease con_0012_Group2_x_TimepointNr2 chi_Time 1 1 Chisq $nvox
nvox=`1d_tool.py -infile 3dLME_disease/con_0013_Group2_x_TimepointNr2.CSimA.NN2_2sided.1D -csim_show_clustsize -verb 0`
extract_clusters $dir/3dLME_disease con_0013_Group2_x_TimepointNr2 chi_TimeGroup 4 4 Chisq $nvox
extract_clusters $dir/3dLME_disease con_0013_Group2_x_TimepointNr2 chi_Group 0 0 Chisq $nvox
extract_clusters $dir/3dLME_disease con_0013_Group2_x_TimepointNr2 chi_Time 1 1 Chisq $nvox
# 3dLME - severity
## Combined
nvox=`1d_tool.py -infile 3dLME_severity/con_combined_Severity2_x_Type3.CSimA.NN2_2sided.1D -csim_show_clustsize -verb 0`
extract_clusters $dir/3dLME_severity con_combined_Severity2_x_Type3 chi_CbCwType 9 9 Chisq $nvox
extract_clusters $dir/3dLME_severity con_combined_Severity2_x_Type3 chi_CbType 7 7 Chisq $nvox
extract_clusters $dir/3dLME_severity con_combined_Severity2_x_Type3 chi_CwType 8 8 Chisq $nvox
extract_clusters $dir/3dLME_severity con_combined_Severity2_x_Type3 chi_CbCw 3 3 Chisq $nvox
extract_clusters $dir/3dLME_severity con_combined_Severity2_x_Type3 chi_Cb 0 0 Chisq $nvox
extract_clusters $dir/3dLME_severity con_combined_Severity2_x_Type3 chi_Cw 2 2 Chisq $nvox
extract_clusters $dir/3dLME_severity con_combined_Severity2_x_Type3 Z_CbCwType2gt1 11 11 Z $nvox
extract_clusters $dir/3dLME_severity con_combined_Severity2_x_Type3 Z_CbCwType3gt1 13 13 Z $nvox
extract_clusters $dir/3dLME_severity con_combined_Severity2_x_Type3 Z_CbCwType23gt1 15 15 Z $nvox
extract_clusters $dir/3dLME_severity con_combined_Severity2_x_Type3 Z_CbCwTypeMean 17 17 Z $nvox
extract_clusters $dir/3dLME_severity con_combined_Severity2_x_Type3 Z_CbType2gt1 19 19 Z $nvox
extract_clusters $dir/3dLME_severity con_combined_Severity2_x_Type3 Z_CbType3gt1 21 21 Z $nvox
extract_clusters $dir/3dLME_severity con_combined_Severity2_x_Type3 Z_CbType23gt1 25 25 Z $nvox
extract_clusters $dir/3dLME_severity con_combined_Severity2_x_Type3 Z_CbTypeMean 27 27 Z $nvox
extract_clusters $dir/3dLME_severity con_combined_Severity2_x_Type3 Z_CwType2gt1 29 29 Z $nvox
extract_clusters $dir/3dLME_severity con_combined_Severity2_x_Type3 Z_CwType3gt1 31 31 Z $nvox
extract_clusters $dir/3dLME_severity con_combined_Severity2_x_Type3 Z_CwType3gt2 35 35 Z $nvox
extract_clusters $dir/3dLME_severity con_combined_Severity2_x_Type3 Z_CwTypeMean 37 37 Z $nvox
## Across choice
nvox=`1d_tool.py -infile 3dLME_severity/con_0010_Severity2.CSimA.NN2_2sided.1D -csim_show_clustsize -verb 0`
extract_clusters $dir/3dLME_severity con_0010_Severity2 chi_CbCw 4 4 Chisq $nvox
extract_clusters $dir/3dLME_severity con_0010_Severity2 chi_Cb 0 0 Chisq $nvox
extract_clusters $dir/3dLME_severity con_0010_Severity2 chi_Cw 1 1 Chisq $nvox
nvox=`1d_tool.py -infile 3dLME_severity/con_0012_Severity2.CSimA.NN2_2sided.1D -csim_show_clustsize -verb 0`
extract_clusters $dir/3dLME_severity con_0012_Severity2 chi_CbCw 4 4 Chisq $nvox
extract_clusters $dir/3dLME_severity con_0012_Severity2 chi_Cb 0 0 Chisq $nvox
extract_clusters $dir/3dLME_severity con_0012_Severity2 chi_Cw 1 1 Chisq $nvox
nvox=`1d_tool.py -infile 3dLME_severity/con_0013_Severity2.CSimA.NN2_2sided.1D -csim_show_clustsize -verb 0`
extract_clusters $dir/3dLME_severity con_0013_Severity2 chi_CbCw 4 4 Chisq $nvox
extract_clusters $dir/3dLME_severity con_0013_Severity2 chi_Cb 0 0 Chisq $nvox
extract_clusters $dir/3dLME_severity con_0013_Severity2 chi_Cw 1 1 Chisq $nvox
# 3dLME - subtype
	# # MMP vs IM
# extract_clusters $dir/3dLME_subtype con_combined_MMPvsIM_x_TimepointNr2_x_Type3 Z_TimeGroupType2gt1 9 10 Z $nvox
# extract_clusters $dir/3dLME_subtype con_combined_MMPvsIM_x_TimepointNr2_x_Type3 Z_TimeGroupType3gt1 11 12 Z $nvox
# extract_clusters $dir/3dLME_subtype con_combined_MMPvsIM_x_TimepointNr2_x_Type3 Z_TimeGroupType3gt2 13 14 Z $nvox
# extract_clusters $dir/3dLME_subtype con_combined_MMPvsIM_x_TimepointNr2_x_Type3 Z_TimeGroup 17 18 Z $nvox
	# MMP vs DM
	## Combined
nvox=`1d_tool.py -infile 3dLME_MMPvsDM/con_combined_MMPvsDM_x_TimepointNr2_x_Type3.CSimA.NN2_2sided.1D -csim_show_clustsize -verb 0`
nvox=20
# extract_clusters $dir/3dLME_subtype con_combined_MMPvsDM_x_TimepointNr2 chi_TimeGroupType 9 9 Chisq $nvox
# extract_clusters $dir/3dLME_subtype con_combined_MMPvsDM_x_TimepointNr2 chi_TimeGroup 6 6 Chisq $nvox
# extract_clusters $dir/3dLME_subtype con_combined_MMPvsDM_x_TimepointNr2 chi_GroupType 7 7 Chisq $nvox
# extract_clusters $dir/3dLME_subtype con_combined_MMPvsDM_x_TimepointNr2 chi_TimeType 8 8 Chisq $nvox
# extract_clusters $dir/3dLME_subtype con_combined_MMPvsDM_x_TimepointNr2 chi_Group 0 0 Chisq $nvox
# extract_clusters $dir/3dLME_subtype con_combined_MMPvsDM_x_TimepointNr2 chi_Time 1 1 Chisq $nvox
# extract_clusters $dir/3dLME_subtype con_combined_MMPvsDM_x_TimepointNr2 chi_Type 2 2 Chisq $nvox
extract_clusters $dir/3dLME_MMPvsDM con_combined_MMPvsDM_x_TimepointNr2_x_Type3 Z_TimeGroupType2gt1 11 11 Z $nvox
extract_clusters $dir/3dLME_MMPvsDM con_combined_MMPvsDM_x_TimepointNr2_x_Type3 Z_TimeGroupType3gt1 13 13 Z $nvox
extract_clusters $dir/3dLME_MMPvsDM con_combined_MMPvsDM_x_TimepointNr2_x_Type3 Z_TimeGroupType23gt1 17 17 Z $nvox
extract_clusters $dir/3dLME_MMPvsDM con_combined_MMPvsDM_x_TimepointNr2_x_Type3 Z_TimeGroup 19 19 Z $nvox
  ## Across choice
nvox=`1d_tool.py -infile 3dLME_subtype/con_0010_MMPvsDM_x_TimepointNr2.CSimA.NN2_2sided.1D -csim_show_clustsize -verb 0`
extract_clusters $dir/3dLME_subtype con_0010_MMPvsDM_x_TimepointNr2 chi_TimeGroup 4 4 Chisq $nvox
extract_clusters $dir/3dLME_subtype con_0010_MMPvsDM_x_TimepointNr2 chi_Group 0 0 Chisq $nvox
extract_clusters $dir/3dLME_subtype con_0010_MMPvsDM_x_TimepointNr2 chi_Time 1 1 Chisq $nvox
nvox=`1d_tool.py -infile 3dLME_subtype/con_0012_MMPvsDM_x_TimepointNr2.CSimA.NN2_2sided.1D -csim_show_clustsize -verb 0`
extract_clusters $dir/3dLME_subtype con_0012_MMPvsDM_x_TimepointNr2 chi_TimeGroup 4 4 Chisq $nvox
extract_clusters $dir/3dLME_subtype con_0012_MMPvsDM_x_TimepointNr2 chi_Group 0 0 Chisq $nvox
extract_clusters $dir/3dLME_subtype con_0012_MMPvsDM_x_TimepointNr2 chi_Time 1 1 Chisq $nvox
nvox=`1d_tool.py -infile 3dLME_subtype/con_0013_MMPvsDM_x_TimepointNr2.CSimA.NN2_2sided.1D -csim_show_clustsize -verb 0`
extract_clusters $dir/3dLME_subtype con_0013_MMPvsDM_x_TimepointNr2 chi_TimeGroup 4 4 Chisq $nvox
extract_clusters $dir/3dLME_subtype con_0013_MMPvsDM_x_TimepointNr2 chi_Group 0 0 Chisq $nvox
extract_clusters $dir/3dLME_subtype con_0013_MMPvsDM_x_TimepointNr2 chi_Time 1 1 Chisq $nvox
	# # IM vs DM
# extract_clusters $dir/3dLME_subtype con_combined_IMvsDM_x_TimepointNr2_x_Type3 Z_TimeGroupType2gt1 9 10 Z $nvox
# extract_clusters $dir/3dLME_subtype con_combined_IMvsDM_x_TimepointNr2_x_Type3 Z_TimeGroupType3gt1 11 12 Z $nvox
# extract_clusters $dir/3dLME_subtype con_combined_IMvsDM_x_TimepointNr2_x_Type3 Z_TimeGroupType3gt2 13 14 Z $nvox
# extract_clusters $dir/3dLME_subtype con_combined_IMvsDM_x_TimepointNr2_x_Type3 Z_TimeGroup 17 18 Z $nvox
	# HC vs MMP
nvox=`1d_tool.py -infile 3dLME_HCvsMMP/con_combined_HCvsMMP_x_TimepointNr2_x_Type3.CSimA.NN2_2sided.1D -csim_show_clustsize -verb 0`
extract_clusters $dir/3dLME_HCvsMMP con_combined_HCvsMMP_x_TimepointNr2_x_Type3 Z_TimeGroupType2gt1 10 10 Z $nvox
extract_clusters $dir/3dLME_HCvsMMP con_combined_HCvsMMP_x_TimepointNr2_x_Type3 Z_TimeGroupType3gt1 12 12 Z $nvox
extract_clusters $dir/3dLME_HCvsMMP con_combined_HCvsMMP_x_TimepointNr2_x_Type3 Z_TimeGroupType3gt2 16 16 Z $nvox
extract_clusters $dir/3dLME_HCvsMMP con_combined_HCvsMMP_x_TimepointNr2_x_Type3 Z_TimeGroup 18 18 Z $nvox
	# # HC vs IM
# extract_clusters $dir/3dLME_subtype con_combined_HCvsIM_x_TimepointNr2_x_Type3 Z_TimeGroupType2gt1 9 10 Z $nvox
# extract_clusters $dir/3dLME_subtype con_combined_HCvsIM_x_TimepointNr2_x_Type3 Z_TimeGroupType3gt1 11 12 Z $nvox
# extract_clusters $dir/3dLME_subtype con_combined_HCvsIM_x_TimepointNr2_x_Type3 Z_TimeGroupType3gt2 13 14 Z $nvox
# extract_clusters $dir/3dLME_subtype con_combined_HCvsIM_x_TimepointNr2_x_Type3 Z_TimeGroup 17 18 Z $nvox
	# HC vs DM
nvox=`1d_tool.py -infile 3dLME_HCvsDM/con_combined_HCvsDM_x_TimepointNr2_x_Type3.CSimA.NN2_2sided.1D -csim_show_clustsize -verb 0`
extract_clusters $dir/3dLME_HCvsDM con_combined_HCvsDM_x_TimepointNr2_x_Type3 Z_TimeGroupType2gt1 10 10 Z $nvox
extract_clusters $dir/3dLME_HCvsDM con_combined_HCvsDM_x_TimepointNr2_x_Type3 Z_TimeGroupType3gt1 12 12 Z $nvox
extract_clusters $dir/3dLME_HCvsDM con_combined_HCvsDM_x_TimepointNr2_x_Type3 Z_TimeGroupType23gt1 16 16 Z $nvox
extract_clusters $dir/3dLME_HCvsDM con_combined_HCvsDM_x_TimepointNr2_x_Type3 Z_TimeGroup 18 18 Z $nvox