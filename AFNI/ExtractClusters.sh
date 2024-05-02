#!/bin/bash
# Extract clusters from 3dLME analyses

# extract_clusters <Analysis directory> <File name> <Effect> <Data for show> <Data for threhsolding> <Type of stat> <Cluster size thr>
function extract_clusters(){

module unload afni; module load afni/2022

DIR=$1         # Directory containing AFNI output
PREFIX=$2	   # Name of output file to interrogate
EFFECT=$3      # Name of effect
COEF=$4        # Index of coef for -idat
STAT=$5        # Index of stats for -ithr
TYPE=$6        # F or Z, determines whether 1sided or bisided
CLUST_NVOX=$7  # Cluster size threshold (Whole-brain = 108; ROI = 21)

cwd=$(pwd)
mkdir -p $DIR/stats
cd $DIR/stats
rm ${PREFIX}*${EFFECT}*.BRIK ${PREFIX}*${EFFECT}*.HEAD

pref_map=${PREFIX}_${EFFECT}_idxmask
pref_dat=${PREFIX}_${EFFECT}_FWEcorr-stat
pref_dat2=${PREFIX}_${EFFECT}_NOcorr-stat
clusters=${PREFIX}_${EFFECT}_clusters.txt

  if [ $TYPE == Z ] || [ $TYPE == T ]; then
		# Two-tailed Z-stat thresholding
		PTHR=0.001
  elif [ $TYPE == Chisq ] || [ $TYPE == F ]; then
		# Two-tailed F-stat threhsolding
		# F/Chisq-values are exclusively positive
		# p/0.001 provides us with an appropriate two-tailed threshold
		# This can be confirmed by using the AFNI GUI
		PTHR=0.0001
  fi
	
3dClusterize \
	-pref_map ${pref_map} \
	-pref_dat ${pref_dat} \
	-mask ../mask.nii* \
	-nosum \
	-1Dformat \
	-inset ../${PREFIX}+tlrc.HEAD \
	-idat ${COEF} \
	-ithr ${STAT} \
	-NN 2 \
	-clust_nvox ${CLUST_NVOX} \
	-bisided p=0.001 \
	> ${clusters}
	
3dClusterize \
	-pref_dat ${pref_dat2} \
	-mask ../mask.nii* \
	-nosum \
	-1Dformat \
	-inset ../${PREFIX}+tlrc.HEAD \
	-idat ${COEF} \
	-ithr ${STAT}  \
	-NN 2 \
	-clust_nvox 1 \
	-bisided -0.0001 0.0001


if [ -f "${pref_map}+tlrc.HEAD" ]; then
	# 3dClusterize outputs a mask in TLRC space even though data is in MNI.
	# Caution: Cluster info is given for the same mask in both TLRC and MNI space.
	# It is unclear which of them is correct. Use at your own risk.
	# I think 3drefit simply changes coordinate systems from RAI (AFNI default) to LPS (SPM default)
	# Therefore, there should be no problem with using either output
	whereami -space TLRC -atlas DD_Desai_MPM -omask ${pref_map}+tlrc. > ${pref_map}_a-DD-Desai-MPM.txt
	whereami -space TLRC -atlas CA_MPM_22_TT  -omask ${pref_map}+tlrc. > ${pref_map}_a-CA-MPM-22-TT.txt
	3drefit -space MNI ${pref_map}+tlrc.
	whereami -space MNI -spm -atlas CA_MPM_22_MNI  -omask ${pref_map}+tlrc. > ${pref_map}_a-CA-MPM-22-MNI.txt
	whereami -space MNI -spm -atlas MNI_Glasser_HCP_v1.0  -omask ${pref_map}+tlrc > ${pref_map}_a-MNI-Glasser-HCP-v1.txt
	whereami -space MNI -spm -atlas Brainnetome_1.0  -omask ${pref_map}+tlrc > ${pref_map}_a-Brainnetome-v1.txt
	# 3drefit -space TLRC ${pref_map}+tlrc.

	3dAFNItoNIFTI ${pref_map}+tlrc
	# 3dAFNItoNIFTI ${pref_map}+tlrc
	3dAFNItoNIFTI ${pref_dat}+tlrc
	3dAFNItoNIFTI ${pref_dat2}+tlrc
	
	# Alternatively, check peak coordinates
	# Here, there is no need to convert between coordinate systems
	# However, you need to find a way to get the peaks
	# a1=MNI_Glasser_HCP_v1.0
	# a2=Brainnetome_1.0
	# a3=CA_MPM_22_MNI
	# a4=CA_MPM_18_MNI
	# a5=CA_ML_18_MNI
	# a6=MNI_VmPFC
	# a7=DD_Desai_MPM
	# coord=(-19 -65 60)
	# whereami ${coord[@]} -space MNI -lpi -atlas $a1
	# whereami ${coord[@]} -space MNI -lpi -atlas $a3
	# whereami ${coord[@]} -space MNI -lpi -atlas $a7
		
	# Output: Mean, standard deviation, cluster size + cluster volume, coords of maximum after taking absolute values of image
	echo "Mean SD K Vol Min Max X Y Z" > ${PREFIX}_${EFFECT}_clusters-stats.txt
  fslstats \
	-K ${pref_map}.nii \
	${pref_dat}.nii \
	-M -S -V -R -a -x >> ${PREFIX}_${EFFECT}_clusters-stats.txt
	
fi

cd $cwd

}

