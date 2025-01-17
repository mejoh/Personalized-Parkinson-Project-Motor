#!/bin/bash

#qsub -o /project/3024006.02/Analyses/motor_task/Group/Longitudinal/AFNI/logs -e /project/3024006.02/Analyses/motor_task/Group/Longitudinal/AFNI/logs -N 3dLME_testRscGroup -l 'nodes=1:ppn=32,walltime=06:00:00,mem=90gb' /home/sysneu/marjoh/scripts/Personalized-Parkinson-Project-Motor/AFNI/3dLME_AcrossCondition.sh

# Torque
#CON=(con_0010 con_0007); ROI=(2 0); GC=(1); POLY=(1); for con in ${CON[@]}; do for roi in ${ROI[@]}; do for gc in ${GC[@]}; do for poly in ${POLY[@]}; do qsub -o /project/3024006.02/Analyses/motor_task/Group/Longitudinal/AFNI/logs -e /project/3024006.02/Analyses/motor_task/Group/Longitudinal/AFNI/logs -N 3dLME_AC_${con}_${roi}${gc}${poly} -v R=${roi},G=${gc},P=${poly},C=${con} -l 'nodes=1:ppn=32,walltime=03:00:00,mem=40gb' /home/sysneu/marjoh/scripts/Personalized-Parkinson-Project-Motor/AFNI/3dLME_AcrossCondition.sh; done; done; done; done
# Slurm
#CON=(con_0010 con_0007); ROI=(2 0); GC=(1); POLY=(1); for con in ${CON[@]}; do for roi in ${ROI[@]}; do for gc in ${GC[@]}; do for poly in ${POLY[@]}; do sbatch -o /project/3024006.02/Analyses/motor_task/Group/Longitudinal/AFNI/logs -J 3dLME_AC_${con}_${roi}${gc}${poly} --export=R=${roi},G=${gc},P=${poly},C=${con} -N 1 -c 32 --time=03:00:00 --mem=40G /home/sysneu/marjoh/scripts/Personalized-Parkinson-Project-Motor/AFNI/3dLME_AcrossCondition.sh; done; done; done; done

# R=2
# G=1
# P=1
# C=con_0010

### OPTIONS ###
ROI=${R}				# 1 = ROI, 0 = Whole-brain
GroupComparison=${G}	# 1 = Group comparison, 0 = Correlation analysis
Polynomial=${P}			# 1 = Linear, 2 = Quadratic, 3 = Cubic
con=${C}				# con_0010 = Mean, con_0012 = 2>1, con_0013 = 3>1, con_0008 = 3>2
###

module unload afni; module load afni/2022
module unload R; module load R/4.1.0
module load R-packages/4.1.0
njobs=32
export OMP_NUM_THREADS=32

dOutput=/project/3024006.02/Analyses/motor_task/Group/Longitudinal/AFNI

# Define mask
if [ $ROI -eq 1 ]; then

	# ROI analysis
	echo "ROI analysis - Partial"
	dOutput=$dOutput/ROI/Masked_partial
  mask=/project/3024006.02/Analyses/motor_task/Group/Longitudinal/Masks/bi_partial_clincorr_bg_mask_cropped.nii

elif [ $ROI -eq 2 ]; then

	# ROI analysis
	echo "ROI analysis - Full"
	dOutput=$dOutput/ROI/Masked_full
	mask=/project/3024006.02/Analyses/motor_task/Group/Longitudinal/Masks/bi_full_clincorr_bg_mask_cropped.nii

elif [ $ROI -eq 0 ]; then

	# Whole-brain analysis
	echo "Whole-brain analysis"
	dOutput=$dOutput/WholeBrain
	mask=/project/3024006.02/Analyses/motor_task/Group/Longitudinal/Masks/wd/tpl-MNI152NLin6Asym_desc-brain_mask.nii

fi

# Run analysis
if [ $GroupComparison -eq 1 ]; then

	echo "Performing group comparisons"

	# Linear term only
	if [ $Polynomial -eq 1 ]; then
	
		echo "TimepointNr: Linear"
		dOutput=$dOutput/3dLME_disease
		mkdir -p $dOutput
		dataTable=/project/3024006.02/Analyses/motor_task/Group/Longitudinal/AFNI/${con}_disease_dataTable.txt
		cd $dOutput
		cp $mask $(pwd)/mask.nii
		cp $dataTable $(pwd)
		rm ${con}*.BRIK ${con}*.HEAD
	
		/opt/afni/2022/3dLMEr -prefix ${dOutput}/${con}_Group2_x_TimepointNr2 -jobs $njobs \
		-resid ${dOutput}/${con}_Group2_x_TimepointNr2_resid \
		-mask $mask \
		-model '1+Group*TimepointNr+Age+Sex+NpsEducYears+RespHandIsDominant+(1|Subj)' \
		-qVars 'Age,NpsEducYears' \
		-gltCode Group_by_Time 'Group : -1*HC_PIT 1*PD_POM TimepointNr : -1*T0 1*T1' \
		-gltCode Group_by_BA 'Group : -1*HC_PIT 1*PD_POM TimepointNr : 1*T0' \
		-gltCode Group_by_FU 'Group : -1*HC_PIT 1*PD_POM TimepointNr : 1*T1' \
		-gltCode HC_by_Time 'Group : 1*HC_PIT TimepointNr : -1*T0 1*T1' \
		-gltCode PD_by_Time 'Group : 1*PD_POM TimepointNr : -1*T0 1*T1' \
		-gltCode Group 'Group : -1*HC_PIT 1*PD_POM' \
		-gltCode HC 'Group : 1*HC_PIT' \
		-gltCode PD 'Group : 1*PD_POM' \
		-gltCode Time 'TimepointNr : -1*T0 1*T1' \
		-gltCode BA 'TimepointNr : 1*T0' \
		-gltCode FU 'TimepointNr : 1*T1' \
		-dataTable \
		`cat $dataTable`

	fi

elif [ $GroupComparison -eq 0 ]; then

	echo "Performing correlation analysis"

	# Linear term only
	if [ $Polynomial -eq 1 ]; then
	
		echo "Severity: Linear"
		dOutput=$dOutput/3dLME_severity
		mkdir -p $dOutput
		dataTable=/project/3024006.02/Analyses/motor_task/Group/Longitudinal/AFNI/${con}_severity_dataTable.txt
		cd $dOutput
		cp $mask $(pwd)/mask.nii.gz
		cp $dataTable $(pwd)
		rm ${con}*.BRIK ${con}*.HEAD
	
		/opt/afni/2022/3dLMEr -prefix $dOutput/${con}_Severity2 -jobs $njobs \
		-resid ${dOutput}/${con}_Severity2_resid \
		-mask $mask \
		-model '1+ClinScore_brady_imp_cb+ClinScore_brady_imp_cw+ClinScore_cog_imp_cb+ClinScore_cog_imp_cw+Age+Sex+YearsSinceDiag.imp+NpsEducYears.imp+RespHandIsDominant+(1|Subj)' \
		-qVars 'ClinScore_brady_imp_cb,ClinScore_brady_imp_cw,ClinScore_cog_imp_cb,ClinScore_cog_imp_cw,Age,YearsSinceDiag.imp,NpsEducYears.imp' \
		-gltCode Severity_brady_cb 'ClinScore_brady_imp_cb :' \
		-gltCode Severity_brady_cw 'ClinScore_brady_imp_cw :' \
		-gltCode Severity_cog_cb 'ClinScore_cog_imp_cb :' \
		-gltCode Severity_cog_cw 'ClinScore_cog_imp_cw :' \
		-dataTable \
		`cat $dataTable`

	fi

fi

#### Code dump

# Discrete time with baseline age as covariate
# /opt/afni/2022/3dLMEr -prefix $dOutput/$prefix -jobs $njobs \
# -mask $mask \
# -model '1+Group*TimepointNr*trial_type+Age.gmc+MeanFD.gmc+Sex+(1+TimepointNr|Subj)' \
# -qVars 'Age.gmc,MeanFD.gmc' \
# -qVarCenters 62.1,0 \
# -gltCode Group_by_Time_by_Type2gt1 'Group : -1*HC_PIT 1*PD_POM TimepointNr : -1*T0 1*T1 trial_type : -1*1c 1*2c' \
# -gltCode Group_by_Time_by_Type3gt1 'Group : -1*HC_PIT 1*PD_POM TimepointNr : -1*T0 1*T1 trial_type : -1*1c 1*3c' \
# -gltCode Group_by_Time_by_Type3gt2 'Group : -1*HC_PIT 1*PD_POM TimepointNr : -1*T0 1*T1 trial_type : -1*2c 1*3c' \
# -gltCode Group_by_Time_by_Type23gt1 'Group : -1*HC_PIT 1*PD_POM TimepointNr : -1*T0 1*T1 trial_type : -1*1c 0.5*2c 0.5*3c' \
# -gltCode Group_by_Time 'Group : -1*HC_PIT 1*PD_POM TimepointNr : -1*T0 1*T1' \
# -gltCode HC_by_Time 'Group : 1*HC_PIT TimepointNr : -1*T0 1*T1' \
# -gltCode PD_by_Time 'Group : 1*PD_POM TimepointNr : -1*T0 1*T1' \
# -gltCode Group_by_BA 'Group : -1*HC_PIT 1*PD_POM TimepointNr : 1*T0' \
# -gltCode Group_by_FU 'Group : -1*HC_PIT 1*PD_POM TimepointNr : 1*T1' \
# -gltCode HC_by_BA 'Group : 1*HC_PIT TimepointNr : 1*T0' \
# -gltCode HC_by_FU 'Group : 1*HC_PIT TimepointNr : 1*T1' \
# -gltCode PD_by_BA 'Group : 1*PD_POM TimepointNr : 1*T0' \
# -gltCode PD_by_FU 'Group : 1*PD_POM TimepointNr : 1*T1' \
# -gltCode Group_by_Type2gt1 'Group : -1*HC_PIT 1*PD_POM trial_type : -1*1c 1*2c' \
# -gltCode Group_by_Type3gt1 'Group : -1*HC_PIT 1*PD_POM trial_type : -1*1c 1*3c' \
# -gltCode Group_by_Type3gt2 'Group : -1*HC_PIT 1*PD_POM trial_type : -1*2c 1*3c' \
# -gltCode Group_by_Type23gt1 'Group : -1*HC_PIT 1*PD_POM trial_type : -1*1c 0.5*2c 0.5*3c' \
# -gltCode HC_by_Type2gt1 'Group : 1*HC_PIT trial_type : -1*1c 1*2c' \
# -gltCode HC_by_Type3gt1 'Group : 1*HC_PIT trial_type : -1*1c 1*3c' \
# -gltCode HC_by_Type3gt2 'Group : 1*HC_PIT trial_type : -1*2c 1*3c' \
# -gltCode HC_by_Type23gt1 'Group : 1*HC_PIT trial_type : -1*1c 0.5*2c 0.5*3c' \
# -gltCode PD_by_Type2gt1 'Group : 1*PD_POM trial_type : -1*1c 1*2c' \
# -gltCode PD_by_Type3gt1 'Group : 1*PD_POM trial_type : -1*1c 1*3c' \
# -gltCode PD_by_Type3gt2 'Group : 1*PD_POM trial_type : -1*2c 1*3c' \
# -gltCode PD_by_Type23gt1 'Group : 1*PD_POM trial_type : -1*1c 0.5*2c 0.5*3c' \
# -gltCode Group 'Group : -1*HC_PIT 1*PD_POM' \
# -gltCode HC 'Group : 1*HC_PIT' \
# -gltCode PD 'Group : 1*PD_POM' \
# -gltCode Time 'TimepointNr : -1*T0 1*T1' \
# -gltCode BA 'TimepointNr : 1*T0' \
# -gltCode FU 'TimepointNr : 1*T1' \
# -gltCode Type2gt1 'trial_type : -1*1c 1*2c' \
# -gltCode Type3gt1 'trial_type : -1*1c 1*3c' \
# -gltCode Type3gt2 'trial_type : -1*2c 1*3c' \
# -gltCode Type23gt1 'trial_type : -1*1c 0.5*2c 0.5*3c' \
# -dataTable \
# `cat $dataTable`

# /opt/afni/2022/3dLME -prefix $dOutput/$prefix -jobs $njobs \
# -mask $mask \
# -model '1+Group*TimepointNr*trial_type+Age.gmc+MeanFD.gmc+Sex' \
# -qVars 'Age.gmc,MeanFD.gmc' \
# -ranEff '~1+TimepointNr+MeanFD.gmc' \
# -SS_type 3 \
# -num_glt 35 \
# -gltLabel 1 'Group_by_Time_by_Type2gt1' -gltCode 1 'Group : -1*HC_PIT 1*PD_POM TimepointNr : -1*T0 1*T1 trial_type : -1*1c 1*2c' \
# -gltLabel 2 'Group_by_Time_by_Type3gt1' -gltCode 2 'Group : -1*HC_PIT 1*PD_POM TimepointNr : -1*T0 1*T1 trial_type : -1*1c 1*3c' \
# -gltLabel 3 'Group_by_Time_by_Type3gt2' -gltCode 3 'Group : -1*HC_PIT 1*PD_POM TimepointNr : -1*T0 1*T1 trial_type : -1*2c 1*3c' \
# -gltLabel 4 'Group_by_Time_by_Type23gt1' -gltCode 4 'Group : -1*HC_PIT 1*PD_POM TimepointNr : -1*T0 1*T1 trial_type : -1*1c 0.5*2c 0.5*3c' \
# -gltLabel 5 'Group_by_Time' -gltCode 5 'Group : -1*HC_PIT 1*PD_POM TimepointNr : -1*T0 1*T1' \
# -gltLabel 6 'HC_by_Time' -gltCode 6 'Group : 1*HC_PIT TimepointNr : -1*T0 1*T1' \
# -gltLabel 7 'PD_by_Time' -gltCode 7 'Group : 1*PD_POM TimepointNr : -1*T0 1*T1' \
# -gltLabel 8 'Group_by_BA' -gltCode 8 'Group : -1*HC_PIT 1*PD_POM TimepointNr : 1*T0' \
# -gltLabel 9 'Group_by_FU' -gltCode 9 'Group : -1*HC_PIT 1*PD_POM TimepointNr : 1*T1' \
# -gltLabel 10 'HC_by_BA' -gltCode 10 'Group : 1*HC_PIT TimepointNr : 1*T0' \
# -gltLabel 11 'HC_by_FU' -gltCode 11 'Group : 1*HC_PIT TimepointNr : 1*T1' \
# -gltLabel 12 'PD_by_BA' -gltCode 12 'Group : 1*PD_POM TimepointNr : 1*T0' \
# -gltLabel 13 'PD_by_FU' -gltCode 13 'Group : 1*PD_POM TimepointNr : 1*T1' \
# -gltLabel 14 'Group_by_Type2gt1' -gltCode 14 'Group : -1*HC_PIT 1*PD_POM trial_type : -1*1c 1*2c' \
# -gltLabel 15 'Group_by_Type3gt1' -gltCode 15 'Group : -1*HC_PIT 1*PD_POM trial_type : -1*1c 1*3c' \
# -gltLabel 16 'Group_by_Type3gt2' -gltCode 16 'Group : -1*HC_PIT 1*PD_POM trial_type : -1*2c 1*3c' \
# -gltLabel 17 'Group_by_Type23gt1' -gltCode 17 'Group : -1*HC_PIT 1*PD_POM trial_type : -1*1c 0.5*2c 0.5*3c' \
# -gltLabel 18 'HC_by_Type2gt1' -gltCode 18 'Group : 1*HC_PIT trial_type : -1*1c 1*2c' \
# -gltLabel 19 'HC_by_Type3gt1' -gltCode 19 'Group : 1*HC_PIT trial_type : -1*1c 1*3c' \
# -gltLabel 20 'HC_by_Type3gt2' -gltCode 20 'Group : 1*HC_PIT trial_type : -1*2c 1*3c' \
# -gltLabel 21 'HC_by_Type23gt1' -gltCode 21 'Group : 1*HC_PIT trial_type : -1*1c 0.5*2c 0.5*3c' \
# -gltLabel 22 'PD_by_Type2gt1' -gltCode 22 'Group : 1*PD_POM trial_type : -1*1c 1*2c' \
# -gltLabel 23 'PD_by_Type3gt1' -gltCode 23 'Group : 1*PD_POM trial_type : -1*1c 1*3c' \
# -gltLabel 24 'PD_by_Type3gt2' -gltCode 24 'Group : 1*PD_POM trial_type : -1*2c 1*3c' \
# -gltLabel 25 'PD_by_Type23gt1' -gltCode 25 'Group : 1*PD_POM trial_type : -1*1c 0.5*2c 0.5*3c' \
# -gltLabel 26 'Group' -gltCode 26 'Group : -1*HC_PIT 1*PD_POM' \
# -gltLabel 27 'HC' -gltCode 27 'Group : 1*HC_PIT' \
# -gltLabel 28 'PD' -gltCode 28 'Group : 1*PD_POM' \
# -gltLabel 29 'Time' -gltCode 29 'TimepointNr : -1*T0 1*T1' \
# -gltLabel 30 'BA' -gltCode 30 'TimepointNr : 1*T0' \
# -gltLabel 31 'FU' -gltCode 31 'TimepointNr : 1*T1' \
# -gltLabel 32 'Type2gt1' -gltCode 32 'trial_type : -1*1c 1*2c' \
# -gltLabel 33 'Type3gt1' -gltCode 33 'trial_type : -1*1c 1*3c' \
# -gltLabel 34 'Type3gt2' -gltCode 34 'trial_type : -1*2c 1*3c' \
# -gltLabel 35 'Type23gt1' -gltCode 35 'trial_type : -1*1c 0.5*2c 0.5*3c' \
# -dataTable \
# `cat $dataTable`

# /opt/afni/2022/3dLME -prefix $dOutput/${con}_Severity-poly2_x_Type3 -jobs $njobs \
# -mask $mask \
# -model '1+ClinScore.poly1*trial_type+ClinScore.poly2*trial_type+ClinScore.poly3*trial_type+Age.gmc+MeanFD.gmc+Sex' \
# -qVars 'ClinScore.poly1,ClinScore.poly2,Age.gmc,MeanFD.gmc' \
# -ranEff '~1+ClinScore.poly1+MeanFD.gmc' \
# -SS_type 3 \
# -num_glt 12 \
# -gltLabel 1 'Type2gt1_by_Severity' -gltCode 1 'trial_type : -1*1c 1*2c ClinScore.poly1 :' \
# -gltLabel 2 'Type3gt1_by_Severity' -gltCode 2 'trial_type : -1*1c 1*3c ClinScore.poly1 :' \
# -gltLabel 3 'Type3gt2_by_Severity' -gltCode 3 'trial_type : -1*2c 1*3c ClinScore.poly1 :' \
# -gltLabel 4 'Type23gt1_by_Severity' -gltCode 4 'trial_type : -1*1c 0.5*2c 0.5*3c ClinScore.poly1 :' \
# -gltLabel 5 'Mean_by_Severity' -gltCode 5 'ClinScore.poly1 :' \
# -gltLabel 6 'Type1_by_Severity' -gltCode 6 'trial_type : 1*1c ClinScore.poly1 :' \
# -gltLabel 7 'Type2_by_Severity' -gltCode 7 'trial_type : 1*2c ClinScore.poly1 :' \
# -gltLabel 8 'Type3_by_Severity' -gltCode 8 'trial_type : 1*3c ClinScore.poly1 :' \
# -gltLabel 9 'Mean_by_Severity2' -gltCode 9 'ClinScore.poly2 :' \
# -gltLabel 10 'Type1_by_Severity2' -gltCode 10 'trial_type : 1*1c ClinScore.poly2 :' \
# -gltLabel 11 'Type2_by_Severity2' -gltCode 11 'trial_type : 1*2c ClinScore.poly2 :' \
# -gltLabel 12 'Type3_by_Severity2' -gltCode 12 'trial_type : 1*3c ClinScore.poly2 :' \
# -dataTable \
# `cat $dataTable`


# DEPRECATED: Linear and quadratic terms
	# elif [ $Polynomial -eq 2 ]; then
	
		# echo "YearsToFollowUp: Linear + Quadratic"
		# dOutput=$dOutput/3dLME_disease_p2
		# mkdir -p $dOutput
		# dataTable=/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/${con}_disease-poly2_dataTable.txt
		# cd $dOutput
		# cp $mask $(pwd)/mask.nii.gz
		# cp $dataTable $(pwd)
		# rm *.BRIK *.HEAD
		
		# /opt/afni/2022/3dLMEr -prefix ${dOutput}/${con}_Group2_x_YearsToFollowUp2-poly2_x_Type3 -jobs $njobs \
		# -mask $mask \
		# -model '1+(YearsToFollowUp.poly1+YearsToFollowUp.poly2)*Group*trial_type+Age+Sex+(1+YearsToFollowUp.poly1|Subj)' \
		# -qVars 'YearsToFollowUp.poly1,YearsToFollowUp.poly2,Age' \
		# -qVarCenters 0,0,61.73 \
		# -gltCode Group_by_Time_by_Type2gt1 'Group : -1*HC_PIT 1*PD_POM trial_type : -1*1c 1*2c YearsToFollowUp.poly1 : ' \
		# -gltCode Group_by_Time_by_Type3gt1 'Group : -1*HC_PIT 1*PD_POM trial_type : -1*1c 1*3c YearsToFollowUp.poly1 : ' \
		# -gltCode Group_by_Time_by_Type3gt2 'Group : -1*HC_PIT 1*PD_POM trial_type : -1*2c 1*3c YearsToFollowUp.poly1 : ' \
		# -gltCode Group_by_Time_by_Type23gt1 'Group : -1*HC_PIT 1*PD_POM trial_type : -1*1c 0.5*2c 0.5*3c YearsToFollowUp.poly1 : ' \
		# -gltCode Group_by_Time 'Group : -1*HC_PIT 1*PD_POM YearsToFollowUp.poly1 : ' \
		# -gltCode HC_by_Time 'Group : 1*HC_PIT YearsToFollowUp.poly1 : ' \
		# -gltCode PD_by_Time 'Group : 1*PD_POM YearsToFollowUp.poly1 : ' \
		# -gltCode Group_by_Time2_by_Type2gt1 'Group : -1*HC_PIT 1*PD_POM trial_type : -1*1c 1*2c YearsToFollowUp.poly2 : ' \
		# -gltCode Group_by_Time2_by_Type3gt1 'Group : -1*HC_PIT 1*PD_POM trial_type : -1*1c 1*3c YearsToFollowUp.poly2 : ' \
		# -gltCode Group_by_Time2_by_Type3gt2 'Group : -1*HC_PIT 1*PD_POM trial_type : -1*2c 1*3c YearsToFollowUp.poly2 : ' \
		# -gltCode Group_by_Time2_by_Type23gt1 'Group : -1*HC_PIT 1*PD_POM trial_type : -1*1c 0.5*2c 0.5*3c YearsToFollowUp.poly2 : ' \
		# -gltCode Group_by_Time2 'Group : -1*HC_PIT 1*PD_POM YearsToFollowUp.poly2 : ' \
		# -gltCode HC_by_Time2 'Group : 1*HC_PIT YearsToFollowUp.poly2 : ' \
		# -gltCode PD_by_Time2 'Group : 1*PD_POM YearsToFollowUp.poly2 : ' \
		# -gltCode Group_by_Type2gt1 'Group : -1*HC_PIT 1*PD_POM trial_type : -1*1c 1*2c' \
		# -gltCode Group_by_Type3gt1 'Group : -1*HC_PIT 1*PD_POM trial_type : -1*1c 1*3c' \
		# -gltCode Group_by_Type3gt2 'Group : -1*HC_PIT 1*PD_POM trial_type : -1*2c 1*3c' \
		# -gltCode Group_by_Type23gt1 'Group : -1*HC_PIT 1*PD_POM trial_type : -1*1c 0.5*2c 0.5*3c' \
		# -gltCode HC_by_Type2gt1 'Group : 1*HC_PIT trial_type : -1*1c 1*2c' \
		# -gltCode HC_by_Type3gt1 'Group : 1*HC_PIT trial_type : -1*1c 1*3c' \
		# -gltCode HC_by_Type3gt2 'Group : 1*HC_PIT trial_type : -1*2c 1*3c' \
		# -gltCode HC_by_Type23gt1 'Group : 1*HC_PIT trial_type : -1*1c 0.5*2c 0.5*3c' \
		# -gltCode PD_by_Type2gt1 'Group : 1*PD_POM trial_type : -1*1c 1*2c' \
		# -gltCode PD_by_Type3gt1 'Group : 1*PD_POM trial_type : -1*1c 1*3c' \
		# -gltCode PD_by_Type3gt2 'Group : 1*PD_POM trial_type : -1*2c 1*3c' \
		# -gltCode PD_by_Type23gt1 'Group : 1*PD_POM trial_type : -1*1c 0.5*2c 0.5*3c' \
		# -gltCode Group 'Group : -1*HC_PIT 1*PD_POM' \
		# -gltCode HC 'Group : 1*HC_PIT' \
		# -gltCode PD 'Group : 1*PD_POM' \
		# -gltCode Time 'YearsToFollowUp.poly1 : ' \
		# -gltCode Time2 'YearsToFollowUp.poly2 : ' \
		# -gltCode Type2gt1 'trial_type : -1*1c 1*2c' \
		# -gltCode Type3gt1 'trial_type : -1*1c 1*3c' \
		# -gltCode Type3gt2 'trial_type : -1*2c 1*3c' \
		# -gltCode Type23gt1 'trial_type : -1*1c 0.5*2c 0.5*3c' \
		# -dataTable \
		# `cat $dataTable`

	# # DEPRECATED: Linear and quadratic and cubic terms
	# elif [ $Polynomial -eq 3 ]; then
	
		# echo "YearsToFollowUp: Linear + Quadratic + Cubic"
		# dOutput=$dOutput/3dLME_disease_p3
		# mkdir -p $dOutput
		# dataTable=/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/${con}_disease-poly3_dataTable.txt
		# cd $dOutput
		# cp $mask $(pwd)/mask.nii.gz
		# cp $dataTable $(pwd)
		# rm *.BRIK *.HEAD
	
		# /opt/afni/2022/3dLMEr -prefix ${dOutput}/${con}_Group2_x_YearsToFollowUp2-poly3_x_Type3 -jobs $njobs \
		# -mask $mask \
		# -model '1+(YearsToFollowUp.poly1+YearsToFollowUp.poly2+YearsToFollowUp.poly3)*Group*trial_type+Age+Sex+(1+YearsToFollowUp.poly1|Subj)' \
		# -qVars 'YearsToFollowUp.poly1,YearsToFollowUp.poly2,YearsToFollowUp.poly3,Age' \
		# -qVarCenters 0,0,0,61.73 \
		# -gltCode Group_by_Time_by_Type2gt1 'Group : -1*HC_PIT 1*PD_POM trial_type : -1*1c 1*2c YearsToFollowUp.poly1 : ' \
		# -gltCode Group_by_Time_by_Type3gt1 'Group : -1*HC_PIT 1*PD_POM trial_type : -1*1c 1*3c YearsToFollowUp.poly1 : ' \
		# -gltCode Group_by_Time_by_Type3gt2 'Group : -1*HC_PIT 1*PD_POM trial_type : -1*2c 1*3c YearsToFollowUp.poly1 : ' \
		# -gltCode Group_by_Time_by_Type23gt1 'Group : -1*HC_PIT 1*PD_POM trial_type : -1*1c 0.5*2c 0.5*3c YearsToFollowUp.poly1 : ' \
		# -gltCode Group_by_Time 'Group : -1*HC_PIT 1*PD_POM YearsToFollowUp.poly1 : ' \
		# -gltCode HC_by_Time 'Group : 1*HC_PIT YearsToFollowUp.poly1 : ' \
		# -gltCode PD_by_Time 'Group : 1*PD_POM YearsToFollowUp.poly1 : ' \
		# -gltCode Group_by_Time2_by_Type2gt1 'Group : -1*HC_PIT 1*PD_POM trial_type : -1*1c 1*2c YearsToFollowUp.poly2 : ' \
		# -gltCode Group_by_Time2_by_Type3gt1 'Group : -1*HC_PIT 1*PD_POM trial_type : -1*1c 1*3c YearsToFollowUp.poly2 : ' \
		# -gltCode Group_by_Time2_by_Type3gt2 'Group : -1*HC_PIT 1*PD_POM trial_type : -1*2c 1*3c YearsToFollowUp.poly2 : ' \
		# -gltCode Group_by_Time2_by_Type23gt1 'Group : -1*HC_PIT 1*PD_POM trial_type : -1*1c 0.5*2c 0.5*3c YearsToFollowUp.poly2 : ' \
		# -gltCode Group_by_Time2 'Group : -1*HC_PIT 1*PD_POM YearsToFollowUp.poly2 : ' \
		# -gltCode HC_by_Time2 'Group : 1*HC_PIT YearsToFollowUp.poly2 : ' \
		# -gltCode PD_by_Time2 'Group : 1*PD_POM YearsToFollowUp.poly2 : ' \
		# -gltCode Group_by_Time3_by_Type2gt1 'Group : -1*HC_PIT 1*PD_POM trial_type : -1*1c 1*2c YearsToFollowUp.poly3 : ' \
		# -gltCode Group_by_Time3_by_Type3gt1 'Group : -1*HC_PIT 1*PD_POM trial_type : -1*1c 1*3c YearsToFollowUp.poly3 : ' \
		# -gltCode Group_by_Time3_by_Type3gt2 'Group : -1*HC_PIT 1*PD_POM trial_type : -1*2c 1*3c YearsToFollowUp.poly3 : ' \
		# -gltCode Group_by_Time3_by_Type23gt1 'Group : -1*HC_PIT 1*PD_POM trial_type : -1*1c 0.5*2c 0.5*3c YearsToFollowUp.poly3 : ' \
		# -gltCode Group_by_Time3 'Group : -1*HC_PIT 1*PD_POM YearsToFollowUp.poly3 : ' \
		# -gltCode HC_by_Time3 'Group : 1*HC_PIT YearsToFollowUp.poly3 : ' \
		# -gltCode PD_by_Time3 'Group : 1*PD_POM YearsToFollowUp.poly3 : ' \
		# -gltCode Group_by_Type2gt1 'Group : -1*HC_PIT 1*PD_POM trial_type : -1*1c 1*2c' \
		# -gltCode Group_by_Type3gt1 'Group : -1*HC_PIT 1*PD_POM trial_type : -1*1c 1*3c' \
		# -gltCode Group_by_Type3gt2 'Group : -1*HC_PIT 1*PD_POM trial_type : -1*2c 1*3c' \
		# -gltCode Group_by_Type23gt1 'Group : -1*HC_PIT 1*PD_POM trial_type : -1*1c 0.5*2c 0.5*3c' \
		# -gltCode HC_by_Type2gt1 'Group : 1*HC_PIT trial_type : -1*1c 1*2c' \
		# -gltCode HC_by_Type3gt1 'Group : 1*HC_PIT trial_type : -1*1c 1*3c' \
		# -gltCode HC_by_Type3gt2 'Group : 1*HC_PIT trial_type : -1*2c 1*3c' \
		# -gltCode HC_by_Type23gt1 'Group : 1*HC_PIT trial_type : -1*1c 0.5*2c 0.5*3c' \
		# -gltCode PD_by_Type2gt1 'Group : 1*PD_POM trial_type : -1*1c 1*2c' \
		# -gltCode PD_by_Type3gt1 'Group : 1*PD_POM trial_type : -1*1c 1*3c' \
		# -gltCode PD_by_Type3gt2 'Group : 1*PD_POM trial_type : -1*2c 1*3c' \
		# -gltCode PD_by_Type23gt1 'Group : 1*PD_POM trial_type : -1*1c 0.5*2c 0.5*3c' \
		# -gltCode Group 'Group : -1*HC_PIT 1*PD_POM' \
		# -gltCode HC 'Group : 1*HC_PIT' \
		# -gltCode PD 'Group : 1*PD_POM' \
		# -gltCode Time 'YearsToFollowUp.poly1 : ' \
		# -gltCode Time2 'YearsToFollowUp.poly2 : ' \
		# -gltCode Time3 'YearsToFollowUp.poly3 : ' \
		# -gltCode Type2gt1 'trial_type : -1*1c 1*2c' \
		# -gltCode Type3gt1 'trial_type : -1*1c 1*3c' \
		# -gltCode Type3gt2 'trial_type : -1*2c 1*3c' \
		# -gltCode Type23gt1 'trial_type : -1*1c 0.5*2c 0.5*3c' \
		# -dataTable \
		# `cat $dataTable`
		
		# DEPRECATED: Linear and quadratic terms
	# elif [ $Polynomial -eq 2 ]; then
	
		# echo "Severity: Linear + Quadratic"
		# dOutput=$dOutput/3dLME_severity_p2
		# mkdir -p $dOutput
		# dataTable=/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/${con}_severity-poly2_dataTable.txt
		# cd $dOutput
		# cp $mask $(pwd)/mask.nii.gz
		# cp $dataTable $(pwd)
		# rm *.BRIK *.HEAD
	
		# /opt/afni/2022/3dLMEr -prefix ${dOutput}/${con}_Severity2-poly2_x_Type3 -jobs $njobs \
		# -mask $mask \
		# -model '1+(ClinScore.poly1+ClinScore.poly2)*trial_type+Age+Sex+(1+ClinScore.poly1|Subj)' \
		# -qVars 'ClinScore.poly1,ClinScore.poly2,Age' \
		# -qVarCenters 0,0,62.04 \
		# -gltCode Type2gt1_by_Severity 'trial_type : -1*1c 1*2c ClinScore.poly1 :' \
		# -gltCode Type3gt1_by_Severity 'trial_type : -1*1c 1*3c ClinScore.poly1 :' \
		# -gltCode Type3gt2_by_Severity 'trial_type : -1*2c 1*3c ClinScore.poly1 :' \
		# -gltCode Type23gt1_by_Severity 'trial_type : -1*1c 0.5*2c 0.5*3c ClinScore.poly1 :' \
		# -gltCode Mean_by_Severity 'ClinScore.poly1 :' \
		# -gltCode Type1_by_Severity 'trial_type : 1*1c ClinScore.poly1 :' \
		# -gltCode Type2_by_Severity 'trial_type : 1*2c ClinScore.poly1 :' \
		# -gltCode Type3_by_Severity 'trial_type : 1*3c ClinScore.poly1 :' \
		# -gltCode Type2gt1_by_Severity2 'trial_type : -1*1c 1*2c ClinScore.poly2 :' \
		# -gltCode Type3gt1_by_Severity2 'trial_type : -1*1c 1*3c ClinScore.poly2 :' \
		# -gltCode Type3gt2_by_Severity2 'trial_type : -1*2c 1*3c ClinScore.poly2 :' \
		# -gltCode Type23gt1_by_Severity2 'trial_type : -1*1c 0.5*2c 0.5*3c ClinScore.poly2 :' \
		# -gltCode Mean_by_Severity2 'ClinScore.poly2 :' \
		# -gltCode Type1_by_Severity2 'trial_type : 1*1c ClinScore.poly2 :' \
		# -gltCode Type2_by_Severity2 'trial_type : 1*2c ClinScore.poly2 :' \
		# -gltCode Type3_by_Severity2 'trial_type : 1*3c ClinScore.poly2 :' \
		# -dataTable \
		# `cat $dataTable`

	# # DEPRECATED: Linear and quadratic and cubic terms
	# elif [ $Polynomial -eq 3 ]; then
	
		# echo "Severity: Linear + Quadratic + Cubic"
		# dOutput=$dOutput/3dLME_severity_p3
		# mkdir -p $dOutput
		# dataTable=/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/${con}_severity-poly3_dataTable.txt
		# cd $dOutput
		# cp $mask $(pwd)/mask.nii.gz
		# cp $dataTable $(pwd)
		# rm *.BRIK *.HEAD
	
		# /opt/afni/2022/3dLMEr -prefix ${dOutput}/${con}_Severity2-poly3_x_Type3 -jobs $njobs \
		# -mask $mask \
		# -model '1+(ClinScore.poly1+ClinScore.poly2+ClinScore.poly3)*trial_type+Age+Sex+(1+ClinScore.poly1|Subj)' \
		# -qVars 'ClinScore.poly1,ClinScore.poly2,ClinScore.poly3,Age' \
		# -qVarCenters 0,0,0,62.04 \
		# -gltCode Type2gt1_by_Severity 'trial_type : -1*1c 1*2c ClinScore.poly1 :' \
		# -gltCode Type3gt1_by_Severity 'trial_type : -1*1c 1*3c ClinScore.poly1 :' \
		# -gltCode Type3gt2_by_Severity 'trial_type : -1*2c 1*3c ClinScore.poly1 :' \
		# -gltCode Type23gt1_by_Severity 'trial_type : -1*1c 0.5*2c 0.5*3c ClinScore.poly1 :' \
		# -gltCode Mean_by_Severity 'ClinScore.poly1 :' \
		# -gltCode Type1_by_Severity 'trial_type : 1*1c ClinScore.poly1 :' \
		# -gltCode Type2_by_Severity 'trial_type : 1*2c ClinScore.poly1 :' \
		# -gltCode Type3_by_Severity 'trial_type : 1*3c ClinScore.poly1 :' \
		# -gltCode Type2gt1_by_Severity2 'trial_type : -1*1c 1*2c ClinScore.poly2 :' \
		# -gltCode Type3gt1_by_Severity2 'trial_type : -1*1c 1*3c ClinScore.poly2 :' \
		# -gltCode Type3gt2_by_Severity2 'trial_type : -1*2c 1*3c ClinScore.poly2 :' \
		# -gltCode Type23gt1_by_Severity2 'trial_type : -1*1c 0.5*2c 0.5*3c ClinScore.poly2 :' \
		# -gltCode Mean_by_Severity2 'ClinScore.poly2 :' \
		# -gltCode Type1_by_Severity2 'trial_type : 1*1c ClinScore.poly2 :' \
		# -gltCode Type2_by_Severity2 'trial_type : 1*2c ClinScore.poly2 :' \
		# -gltCode Type3_by_Severity2 'trial_type : 1*3c ClinScore.poly2 :' \
		# -gltCode Type2gt1_by_Severity3 'trial_type : -1*1c 1*2c ClinScore.poly3 :' \
		# -gltCode Type3gt1_by_Severity3 'trial_type : -1*1c 1*3c ClinScore.poly3 :' \
		# -gltCode Type3gt2_by_Severity3 'trial_type : -1*2c 1*3c ClinScore.poly3 :' \
		# -gltCode Type23gt1_by_Severity3 'trial_type : -1*1c 0.5*2c 0.5*3c ClinScore.poly3 :' \
		# -gltCode Mean_by_Severity3 'ClinScore.poly3 :' \
		# -gltCode Type1_by_Severity3 'trial_type : 1*1c ClinScore.poly3 :' \
		# -gltCode Type2_by_Severity3 'trial_type : 1*2c ClinScore.poly3 :' \
		# -gltCode Type3_by_Severity3 'trial_type : 1*3c ClinScore.poly3 :' \
		# -dataTable \
		# `cat $dataTable`