#!/bin/bash

outputdir="/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/visualization/OverlayWithHerz/"
cd $outputdir

outputname="stat_HcOff_x_ExtInt2Int3_Catch_NoOutliers"
statimg1="/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/HcOff_x_ExtInt2Int3Catch_NoOutliers/Clusters_HCgtPD_Mean.nii"
statimg2="/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/HcOff_x_ExtInt2Int3Catch_NoOutliers/Clusters_HCgtPD_EXTgtINT.nii"
fslmaths $statimg1 -nan statimg1 -odt float
fslmaths $statimg2 -nan statimg2 -odt float
fslmaths statimg1 -add statimg2 -bin statimg -odt float
fslswapdim statimg -x y z $outputname

outputname="stat_OneSampleTtest_ClinCorr-Off-BAAppendicularSum_NoOutliers"
statimg1="/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/OneSampleTtest_ClinCorr-Off-BAAppendicularSum_NoOutliers/Int>Ext/Clusters_NegBA.nii"
statimg2="/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/OneSampleTtest_ClinCorr-Off-BAAppendicularSum_NoOutliers/Mean_ExtInt/Clusters_PosBA.nii"
fslmaths $statimg1 -nan statimg1 -odt float
fslmaths $statimg2 -nan statimg2 -odt float
fslmaths statimg1 -add statimg2 -bin statimg -odt float
fslswapdim statimg -x y z $outputname

outputname="stat_OneSampleTtest_ClinCorr-Off-Prog-AppendicularSum_NoOutliers"
statimg1="/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/OneSampleTtest_ClinCorr-Off-Prog-AppendicularSum_NoOutliers/Int>Ext/Clusters_PosProg.nii"
fslmaths $statimg1 -nan statimg1 -odt float
fslmaths statimg1 -bin statimg -odt float
fslswapdim statimg -x y z $outputname

rm statimg*.nii.gz


