#!/bin/bash

# DISEASE
#DIR=/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/ROI/BG_Parietal/3dLME_disease; PREFIX=(con_0010_Group2_x_TimepointNr2 con_0012_Group2_x_TimepointNr2 con_0013_Group2_x_TimepointNr2 con_combined_Group2_x_TimepointNr2_x_Type3); for prefix in ${PREFIX[@]}; do qsub -o /project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/logs -e /project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/logs -N ClustSim_${prefix} -v d=${DIR},p=${prefix} -l 'nodes=1:ppn=4,walltime=01:00:00,mem=20gb' /home/sysneu/marjoh/scripts/Personalized-Parkinson-Project-Motor/AFNI/3dLME_ClusterizeResid.sh; done

# SUBTYPE
#COMP=MMPvsDM; DIR=/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/ROI/Parietal/3dLME_${COMP}; PREFIX=(con_0010_${COMP}_x_TimepointNr2 con_0012_${COMP}_x_TimepointNr2 con_0013_${COMP}_x_TimepointNr2 con_combined_${COMP}_x_TimepointNr2_x_Type3); for prefix in ${PREFIX[@]}; do qsub -o /project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/logs -e /project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/logs -N ClustSim_${prefix} -v d=${DIR},p=${prefix} -l 'nodes=1:ppn=4,walltime=01:30:00,mem=20gb' /home/sysneu/marjoh/scripts/Personalized-Parkinson-Project-Motor/AFNI/3dLME_ClusterizeResid.sh; done

# SEVERITY
#DIR=/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/ROI/Parietal/3dLME_severity; PREFIX=(con_0010_Severity2 con_0012_Severity2 con_0013_Severity2 con_combined_Severity2_x_Type3); for prefix in ${PREFIX[@]}; do qsub -o /project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/logs -e /project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/logs -N ClustSim_${prefix} -v d=${DIR},p=${prefix} -l 'nodes=1:ppn=4,walltime=01:00:00,mem=20gb' /home/sysneu/marjoh/scripts/Personalized-Parkinson-Project-Motor/AFNI/3dLME_ClusterizeResid.sh; done

d=/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/ON_ANALYSES/WholeBrain/3dLME_disease
p=con_combined_Group2_x_TimepointNr2_x_Type3

##### Set process variables
module load afni
export OMP_NUM_THREADS=8
cd $d
prefix=$p
mask=mask.nii.gz
resid=${prefix}_resid+tlrc

# Estimate autocorrelation function
echo "## Estimating autocorrelation"
rm ${prefix}_FWHMx.txt
3dFWHMx \
  -mask $mask \
  -input $resid \
  -acf NULL \
  -detrend > ${prefix}_FWHMx.txt

# Prettify output		
echo "## Modifying 3dFWHMx output"
rm ${prefix}_FWHMx_clean.txt
1d_tool.py \
	-infile ${prefix}_FWHMx.txt \
	-select_rows '1' \
	-select_cols '0..2' \
	-write ${prefix}_FWHMx_clean.txt \
	-overwrite

# Simulate cluster extent thresholds
echo "## Simulating cluster extent thresholds"
rm ${prefix}_CLUSTER-TABLE*
3dClustSim \
  -LOTS \
	-nodec \
	-mask $mask \
	-acf `cat ${prefix}_FWHMx_clean.txt` \
	-prefix ${prefix}.CSimA
	
echo "## DONE"