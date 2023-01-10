#!/bin/bash

3dMVM -prefix Test3_NoCatch_NoMeanFD -jobs 24 \
  -SC \
  -wsMVT \
  -bsVars "Group+Age.gmc+Sex" \
  -wsVars "trial_type" \
  -qVars "Age.gmc" \
  -num_glt 4 \
  -gltLabel 1 group_by_trial_type2 -gltCode 1 'Group : 1*HC_PIT -1*PD_POM trial_type : -1*1c 1*2c' \
  -gltLabel 2 group_by_trial_type3 -gltCode 2 'Group : 1*HC_PIT -1*PD_POM trial_type : -1*1c 1*3c' \
  -gltLabel 3 group_by_trial_typeAvg -gltCode 3 'Group : 1*HC_PIT -1*PD_POM trial_type : -1*1c 0.5*2c 0.5*3c' \
  -gltLabel 4 group -gltCode 4 'Group : 1*HC_PIT -1*PD_POM' \
  -dataTable \
  `cat /project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Baseline/con_combined_disease_dataTable.txt`
