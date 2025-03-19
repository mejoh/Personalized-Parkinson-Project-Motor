#!/bin/bash

#DIR=/project/3024006.02/Analyses/motor_task/Group/Longitudinal/AFNI/WholeBrain/3dLME_disease; PREFIX=(con_combined_Group2_x_TimepointNr2_x_Type3); for prefix in ${PREFIX[@]}; do sbatch --job-name 3dLME_ClusterizeResid_${prefix} --time=03:00:00 --mem=20gb --nodes=1 --ntasks-per-node=1 --cpus-per-task=4 --export=d=${DIR},p=${prefix} --output=/project/3024006.02/Analyses/motor_task/Group/Longitudinal/AFNI/logs/o_3dLME_ClusterizeResid_${prefix}.txt --error=/project/3024006.02/Analyses/motor_task/Group/Longitudinal/AFNI/logs/e_3dLME_ClusterizeResid_${prefix}.txt /home/sysneu/marjoh/scripts/Personalized-Parkinson-Project-Motor/AFNI/3dLME_ClusterizeResid.sh; done

#d=/project/3024006.02/Analyses/motor_task/Group/Longitudinal/AFNI/WholeBrain/3dLME_disease/
#p=con_combined_Group2_x_TimepointNr2_x_Type3

##### Set process variables
module load afni/2022
module load anaconda3
source activate py310
export OMP_NUM_THREADS=4
cd $d
prefix=$p
mask=mask.nii
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
  -pthr 0.10 0.05 0.04 0.03 0.02 0.01 0.009 0.008 0.007 0.006 0.005 0.004 0.003 0.002 0.001 0.0001 \
	-athr 0.10 0.05 0.04 0.03 0.02 0.01 0.009 0.008 0.007 0.006 0.005 0.004 0.003 0.002 0.001 0.0001 \
	-nodec \
	-mask $mask \
	-acf `cat ${prefix}_FWHMx_clean.txt` \
	-prefix ${prefix}.CSimA
	
echo "## DONE"
