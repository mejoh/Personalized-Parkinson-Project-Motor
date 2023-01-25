#!/bin/bash

# created by uber_ttest.py: version 2.1 (May 11, 2020)
# creation date: Fri Jan 13 11:39:59 2023

#QSUB
#CON=(con_0010 con_0012 con_0013); ROI=(0 1); for con in ${CON[@]}; do for roi in ${ROI[@]}; do qsub -o /project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/logs -e /project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/logs -N 3dttest_s_${con}_${roi} -v R=${roi},C=${con} -l 'nodes=1:ppn=32,walltime=04:00:00,mem=65gb' /home/sysneu/marjoh/scripts/Personalized-Parkinson-Project-Motor/AFNI/3dttest++_severity.sh; done; done

# R=1
# C=con_0010

ROI=${R}				# 1 = ROI, 0 = Whole-brain
con=${C}				# con_0010 = Mean, con_0012 = 2>1, con_0013 = 3>1

# ---------------------- set process variables ----------------------

export OMP_NUM_THREADS=32

module unload afni; module load afni/2022
module unload R; module load R/4.1.0

dOutput=/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI

covars=/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/${con}_severity-BAcov_dataTable.txt

dirA=/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/${con}/ses-Diff

# Define mask
if [ $ROI -eq 1 ]; then

	# ROI analysis
	echo "ROI analysis"
	dOutput=$dOutput/ROI
	mask_dset=/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/Masks/BG-dysfunc_and_pareital-comp_and_striatum_dil.nii.gz

elif [ $ROI -eq 0 ]; then

	# Whole-brain analysis
	echo "Whole-brain analysis"
	dOutput=$dOutput/WholeBrain
	mask_dset=/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/Masks/3dLME_4dConsMask_bin-ero.nii.gz

fi

# specify and possibly create results directory
results_dir=$dOutput/3dttest++_severity
mkdir -p $results_dir
cd $results_dir
cp $mask_dset $(pwd)/mask.nii.gz
cp $covars $(pwd)/${con}_covars.txt
rm ${con}_severity*

# ------------------------- process the data -------------------------

3dttest++ -prefix ${con}_severity                                                \
		  -covariates ${covars}														\
		  -Clustsim	32																	\
          -mask $mask_dset                                                                \
          -setA setlistA                                                                  \
             0002C991F61D84B4_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMU0002C991F61D84B4_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             00094252BA30B84F_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMU00094252BA30B84F_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             00A6F1FC997C42C6_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMU00A6F1FC997C42C6_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             020A9277DF9F5A83_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMU020A9277DF9F5A83_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             022823FBC6EBD9D9_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMU022823FBC6EBD9D9_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             0239E7BEAE4051D9_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMU0239E7BEAE4051D9_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             02C91FA4B6A78EB1_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMU02C91FA4B6A78EB1_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             04AD481098C79AF2_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMU04AD481098C79AF2_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             06664E2F91AA04E0_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMU06664E2F91AA04E0_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             085C98CE3CB8B59B_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMU085C98CE3CB8B59B_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             08DC74B16BF4B68D_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMU08DC74B16BF4B68D_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             0AB6BCFE0591341C_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMU0AB6BCFE0591341C_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             0AEE0E7E9F195659_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMU0AEE0E7E9F195659_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             0C177BAE3D332846_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMU0C177BAE3D332846_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             0C7CB0F2155DE5AB_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMU0C7CB0F2155DE5AB_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             0E19B895DF700AB0_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMU0E19B895DF700AB0_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             10614F30873FC818_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMU10614F30873FC818_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             108A8C24838E6352_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMU108A8C24838E6352_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             10BF56A66772FD4B_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMU10BF56A66772FD4B_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             1276E289029EB39E_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMU1276E289029EB39E_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             12818A4F60BE2BE2_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMU12818A4F60BE2BE2_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             12FA62414399DD8F_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMU12FA62414399DD8F_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             1602890C0D61EAD1_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMU1602890C0D61EAD1_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             184AA121F3E8D5E5_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMU184AA121F3E8D5E5_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             1A50F30F4A977983_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMU1A50F30F4A977983_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             1AE17DD408EE8BBD_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMU1AE17DD408EE8BBD_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             1C34E1FD03D68AC7_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMU1C34E1FD03D68AC7_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             1C7AEA3B0ADEB876_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMU1C7AEA3B0ADEB876_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             1CA754739B57B126_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMU1CA754739B57B126_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             1CF55A8FB405D10A_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMU1CF55A8FB405D10A_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             1E5476D0796BB08E_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMU1E5476D0796BB08E_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             1E7EF007D32758D4_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMU1E7EF007D32758D4_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             1EBB37488F2B1529_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMU1EBB37488F2B1529_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             1EC01A53575D7104_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMU1EC01A53575D7104_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             1EDD7C2E9E8DF70C_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMU1EDD7C2E9E8DF70C_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             1EDE8A58AF75A9D4_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMU1EDE8A58AF75A9D4_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             20075E6786088974_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMU20075E6786088974_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             20E3ED60D71C4BDB_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMU20E3ED60D71C4BDB_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             20E6FE0279A99887_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMU20E6FE0279A99887_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             20F386A713FBC96C_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMU20F386A713FBC96C_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             22F9D233157F7221_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMU22F9D233157F7221_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             24710476D1CC49B2_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMU24710476D1CC49B2_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             249688DEF580F9F8_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMU249688DEF580F9F8_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             260D83F38C26283C_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMU260D83F38C26283C_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             26E8AE13D9BC972B_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMU26E8AE13D9BC972B_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             284B18EB0D0606CF_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMU284B18EB0D0606CF_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             289DBB72C52A194B_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMU289DBB72C52A194B_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             2C29C13627B36E6D_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMU2C29C13627B36E6D_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             2C88568084E2F0F2_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMU2C88568084E2F0F2_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             2CDEB06F355EE49D_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMU2CDEB06F355EE49D_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             2E602750DF4453AB_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMU2E602750DF4453AB_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             2ECBD9FDB02B0BFA_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMU2ECBD9FDB02B0BFA_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             30A8145094B8568C_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMU30A8145094B8568C_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             3227A783C83B9916_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMU3227A783C83B9916_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             3227DABC7764ADB0_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMU3227DABC7764ADB0_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             32C52AEA06F071F1_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMU32C52AEA06F071F1_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             3412004B565A0E69_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMU3412004B565A0E69_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             345AFBEDED4493D2_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMU345AFBEDED4493D2_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             34F2C6744D47D3B9_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMU34F2C6744D47D3B9_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             3818A25BC84175C3_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMU3818A25BC84175C3_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             38588D7F10CCC56F_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMU38588D7F10CCC56F_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             3A4A4F94D24346DF_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMU3A4A4F94D24346DF_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             3AAAEDB66FF3FD6D_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMU3AAAEDB66FF3FD6D_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             3C0AB893667D7B00_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMU3C0AB893667D7B00_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             3C2A2F759C62AEEA_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMU3C2A2F759C62AEEA_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             3C57634EE8A0414B_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMU3C57634EE8A0414B_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             3CCBFEB405AC54DB_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMU3CCBFEB405AC54DB_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             465A8D6824D777B9_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMU465A8D6824D777B9_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             4676B34286BA2D6E_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMU4676B34286BA2D6E_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             46D404208FF82848_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMU46D404208FF82848_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             48DDAA06FA8012C5_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMU48DDAA06FA8012C5_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             4A3F2DBF783717C2_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMU4A3F2DBF783717C2_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             4AD7E84C7EE45A54_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMU4AD7E84C7EE45A54_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             4C1AB897320D7D8A_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMU4C1AB897320D7D8A_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             4CB9394F262897F8_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMU4CB9394F262897F8_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             4CC057B13DBB2927_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMU4CC057B13DBB2927_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             4E2A1A76EDD2CCE3_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMU4E2A1A76EDD2CCE3_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             4E60B43DDEFC32ED_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMU4E60B43DDEFC32ED_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             5076644BBCADBB7C_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMU5076644BBCADBB7C_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             50FA20AC84D19C9D_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMU50FA20AC84D19C9D_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             5433A8F50C28EED0_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMU5433A8F50C28EED0_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             54503B880C9EB267_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMU54503B880C9EB267_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             561B5B2F8CC4376F_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMU561B5B2F8CC4376F_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             5627BB30E3214919_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMU5627BB30E3214919_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             56AB3BB417CE7A94_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMU56AB3BB417CE7A94_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             56CD6D4F140287EB_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMU56CD6D4F140287EB_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             58B6CDD53AD4049C_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMU58B6CDD53AD4049C_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             5C25F24BD734C250_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMU5C25F24BD734C250_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             5C6D29ADEA24E379_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMU5C6D29ADEA24E379_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             5E52DC9411ED0C9C_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMU5E52DC9411ED0C9C_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             6009A5A4295DA773_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMU6009A5A4295DA773_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             600F0CF7479729AA_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMU600F0CF7479729AA_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             602ABC476136B813_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMU602ABC476136B813_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             60AC8E66D550EFD1_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMU60AC8E66D550EFD1_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             623C1216D7130AB3_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMU623C1216D7130AB3_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             627D79E96AB466DC_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMU627D79E96AB466DC_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             6886340AA50ED0F6_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMU6886340AA50ED0F6_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             6A421CB95A963ECF_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMU6A421CB95A963ECF_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             6A6B4C0AA265882B_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMU6A6B4C0AA265882B_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             6AB50AF4C627380A_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMU6AB50AF4C627380A_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             6E6C9C134160CB8D_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMU6E6C9C134160CB8D_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             70496A90AAFD179A_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMU70496A90AAFD179A_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             706F74F4EACBB3E1_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMU706F74F4EACBB3E1_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             70D4A075E5621333_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMU70D4A075E5621333_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             7272D851E73EF700_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMU7272D851E73EF700_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             72BD62638A9F7B6B_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMU72BD62638A9F7B6B_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             72DEC6BF23AC40D6_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMU72DEC6BF23AC40D6_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             7615B16FBF519FAD_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMU7615B16FBF519FAD_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             761CA0228C6BA0F4_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMU761CA0228C6BA0F4_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             76C186E43AFC583D_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMU76C186E43AFC583D_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             7830F3139B54A581_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMU7830F3139B54A581_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             78FC9EC1D822238D_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMU78FC9EC1D822238D_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             7AABE759AC531D35_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMU7AABE759AC531D35_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             7C93AFD65302F67C_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMU7C93AFD65302F67C_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             7E784DF37C02A17A_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMU7E784DF37C02A17A_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             7E867EDD989E4D4C_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMU7E867EDD989E4D4C_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             7E92844683A06185_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMU7E92844683A06185_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             80317AF4033FE35C_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMU80317AF4033FE35C_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             8067BDE54D1B1B4A_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMU8067BDE54D1B1B4A_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             80C7D6A96AA13388_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMU80C7D6A96AA13388_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             820443CEE295DFEC_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMU820443CEE295DFEC_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             82DFBC7D98B21F19_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMU82DFBC7D98B21F19_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             82E58ECC13773EA2_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMU82E58ECC13773EA2_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             861CCD0C9E26D343_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMU861CCD0C9E26D343_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             861E5F5DB4D75868_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMU861E5F5DB4D75868_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             86B05D739B8524A5_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMU86B05D739B8524A5_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             86FC41D3E1F9F145_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMU86FC41D3E1F9F145_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             889979EA743C6466_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMU889979EA743C6466_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             8A6F766544B02956_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMU8A6F766544B02956_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             8AFD7C0365EED7C9_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMU8AFD7C0365EED7C9_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             8AFE70EE7887EE3E_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMU8AFE70EE7887EE3E_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             8EBDD19EC83F31B7_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMU8EBDD19EC83F31B7_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             900F78E54F00A78A_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMU900F78E54F00A78A_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             90251C339D9FEADE_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMU90251C339D9FEADE_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             9056920DE2D533BB_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMU9056920DE2D533BB_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             9298FBD85B279AA2_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMU9298FBD85B279AA2_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             942853AA5F620FD8_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMU942853AA5F620FD8_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             94CB36DBA98CF261_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMU94CB36DBA98CF261_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             94E6A93D782CE718_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMU94E6A93D782CE718_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             98768D0FB5B292BF_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMU98768D0FB5B292BF_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             98ADD50DEBE46D5D_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMU98ADD50DEBE46D5D_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             98DD6951EEFFC3EE_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMU98DD6951EEFFC3EE_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             9A08794D78B1E1A0_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMU9A08794D78B1E1A0_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             9A6F4EBE996632F4_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMU9A6F4EBE996632F4_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             9E8C713BB3FCB6D8_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMU9E8C713BB3FCB6D8_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             A07DDC184B872A86_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMUA07DDC184B872A86_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             A0CD6EB328D6C5F2_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMUA0CD6EB328D6C5F2_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             A2417117F868F087_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMUA2417117F868F087_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             A2B1CD3314B0AEA3_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMUA2B1CD3314B0AEA3_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             A2B8C1335BB9C43B_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMUA2B8C1335BB9C43B_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             A6A581DA54FF6B66_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMUA6A581DA54FF6B66_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             A6BD4DCB8040A67B_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMUA6BD4DCB8040A67B_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             AAF065845E79A42A_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMUAAF065845E79A42A_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             AC1CBAC934160A54_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMUAC1CBAC934160A54_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             AC2513F0E5E32349_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMUAC2513F0E5E32349_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             B0140EA8042C4E37_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMUB0140EA8042C4E37_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             B095BA226B76557A_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMUB095BA226B76557A_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             B0B32692E1393605_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMUB0B32692E1393605_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             B24789880E112F8F_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMUB24789880E112F8F_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             B254AF77A1A1D478_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMUB254AF77A1A1D478_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             B2DCE5473F9AE647_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMUB2DCE5473F9AE647_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             B6FBED8DC74878A8_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMUB6FBED8DC74878A8_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             B8593E25A5D0A1A1_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMUB8593E25A5D0A1A1_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             BA677232DD4D27FD_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMUBA677232DD4D27FD_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             BA958B8183C9F612_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMUBA958B8183C9F612_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             BA95A9F6A41E872C_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMUBA95A9F6A41E872C_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             BC2FF1B37472E0BC_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMUBC2FF1B37472E0BC_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             BC9C3498C802AE9C_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMUBC9C3498C802AE9C_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             BEAFC71F7A821458_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMUBEAFC71F7A821458_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             BEE233B508B1560B_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMUBEE233B508B1560B_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             C0AA783A209F4120_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMUC0AA783A209F4120_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             C2917FBF8466577F_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMUC2917FBF8466577F_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             C2A7E2A8C7C59E8E_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMUC2A7E2A8C7C59E8E_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             C2B9BDB672CFBB53_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMUC2B9BDB672CFBB53_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             C4526BFEA3F9DAA5_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMUC4526BFEA3F9DAA5_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             C46EF66F262BAC3C_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMUC46EF66F262BAC3C_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             C47417F47F5A82AE_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMUC47417F47F5A82AE_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             C484947B8988A6FE_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMUC484947B8988A6FE_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             C4FD95EDB3CA4644_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMUC4FD95EDB3CA4644_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             C6F238EF1A578EA5_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMUC6F238EF1A578EA5_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             C807A64CCB3307BA_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMUC807A64CCB3307BA_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             C80F15E9B41B3EE4_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMUC80F15E9B41B3EE4_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             C81B8DDB39787089_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMUC81B8DDB39787089_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             C86C6B41DE5A61DB_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMUC86C6B41DE5A61DB_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             C8E6043E4D2C90CA_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMUC8E6043E4D2C90CA_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             CAC0EDBAB573E7C8_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMUCAC0EDBAB573E7C8_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             CADA13597E19F3EF_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMUCADA13597E19F3EF_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             CCB2CF9C023F5DEF_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMUCCB2CF9C023F5DEF_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             CCFE8D79143CF859_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMUCCFE8D79143CF859_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             CE5C9ED9AF4FB994_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMUCE5C9ED9AF4FB994_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             D03A248AEB7001CF_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMUD03A248AEB7001CF_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             D0ADCD407E6B4875_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMUD0ADCD407E6B4875_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             D214335D3448F992_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMUD214335D3448F992_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             D2870200E030B451_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMUD2870200E030B451_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             D288CB7C2273AD34_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMUD288CB7C2273AD34_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             D2E7F412BB757295_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMUD2E7F412BB757295_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             D4F57C78CB909834_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMUD4F57C78CB909834_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             D6C41C08C7D228C4_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMUD6C41C08C7D228C4_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             D84A16A5685258CF_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMUD84A16A5685258CF_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             D8989AED9CFC02C8_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMUD8989AED9CFC02C8_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             D8BFFBFC180F0CBA_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMUD8BFFBFC180F0CBA_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             DA7DFF4B345508AA_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMUDA7DFF4B345508AA_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             DCE36875FFBC2199_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMUDCE36875FFBC2199_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             DE5EB31B42F14DBB_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMUDE5EB31B42F14DBB_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             DEC90EA2FF4B337C_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMUDEC90EA2FF4B337C_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             E0364E703665142A_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMUE0364E703665142A_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             E0EBE590CC91EF57_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMUE0EBE590CC91EF57_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             E0EFDE0DD571E3A5_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMUE0EFDE0DD571E3A5_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             E21C660F063ACA0A_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMUE21C660F063ACA0A_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             E27AD07D69403066_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMUE27AD07D69403066_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             E29FE452ACD18D1E_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMUE29FE452ACD18D1E_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             E49FF489B8076A3E_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMUE49FF489B8076A3E_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             E664379C5E29F377_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMUE664379C5E29F377_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             E6D9378D5C51B30C_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMUE6D9378D5C51B30C_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             E8538046C2F87D5D_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMUE8538046C2F87D5D_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             E88704140034927E_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMUE88704140034927E_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             EA10BF7DD47D91C1_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMUEA10BF7DD47D91C1_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             EAE92BBCD628CC94_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMUEAE92BBCD628CC94_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             EE0210FBB6C7AF4C_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMUEE0210FBB6C7AF4C_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             EE16EA86913A5BEC_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMUEE16EA86913A5BEC_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             EED344D99F59534D_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMUEED344D99F59534D_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             EEF2D9E691B25D9D_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMUEEF2D9E691B25D9D_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             F01E528FAFA8BC19_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMUF01E528FAFA8BC19_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             F0249FEA0AB58241_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMUF0249FEA0AB58241_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             F0972E8CD008365F_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMUF0972E8CD008365F_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             F425DA29DA955CA4_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMUF425DA29DA955CA4_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             F61E7C93AFFF6F01_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMUF61E7C93AFFF6F01_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             F655D0BE9213C22B_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMUF655D0BE9213C22B_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             F802ADB98AD8C232_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMUF802ADB98AD8C232_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             F88D66F319B9B4A3_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMUF88D66F319B9B4A3_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             F8C5A88ADC866F24_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMUF8C5A88ADC866F24_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             F8EBD4A1FA1E13A4_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMUF8EBD4A1FA1E13A4_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             FAD42CA8190CAAF1_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMUFAD42CA8190CAAF1_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             FC6A1D3347CFE2F8_ses-POMVisitDiff_${con}                                   \
          "$dirA/PD_POM_sub-POMUFC6A1D3347CFE2F8_ses-POMVisitDiff_${con}.nii[0]"        \
                                                                                          \
             FCE368C030AA8076_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMUFCE368C030AA8076_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             FE8CFD50D9A1714E_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMUFE8CFD50D9A1714E_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             FEABC648D7E27C6F_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMUFEABC648D7E27C6F_ses-POMVisitDiff_${con}L2Rswap.nii[0]" \
                                                                                          \
             FEF5CB22166E0EB3_ses-POMVisitDiff_${con}L2Rswap                            \
          "$dirA/PD_POM_sub-POMUFEF5CB22166E0EB3_ses-POMVisitDiff_${con}L2Rswap.nii[0]"

