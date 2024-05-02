#!/bin/bash
#list_subjects=`find /project/3024006.02/Analyses/FreeSurfer_v7.3.2/LongitudinalTemplate/outputs/ -maxdepth 1 -type d -printf "%f\n" | awk 'length==30'`; for s in ${list_subjects[@]}; do qsub -o /project/3024006.02/Analyses/FreeSurfer_v7.3.2/LongitudinalTemplate/logs -e /project/3024006.02/Analyses/FreeSurfer_v7.3.2/LongitudinalTemplate/logs -N tmpprep_${s} -v subject=${s} -l 'walltime=02:00:00,mem=10gb' ~/scripts/Personalized-Parkinson-Project-Motor/FreeSurfer/fs_generatetemplate_prep.sh; done

# base: 27
# orig timepoints: 30
# long: 63

FNIRT=0
ANTs=0

# subject=HC_sub-POMU0A6DB3C02691EDC8_t1.long.HC_sub-POMU0A6DB3C02691EDC8

# 1. Convert from .mgz to .nii.gz
# 2. Reorient to FSL standard
# 3. N4 bias field correction
# 4. Registration
#		- FSL: FNIRT, not diffeomorphic by construction
#		- ANTs: SyN, guaranteed diffeomorphic by construction
# Ensure that 'base' or 'long' options of fs_submitJobs.sh have been run prior
# to running this script.

export FSLDIR=/opt/fsl/6.0.5
.  ${FSLDIR}/etc/fslconf/fsl.sh
export FREESURFER_HOME="/opt/freesurfer/7.3.2"
export ANTs_HOME="/opt/ANTs/20180607/build"

module unload freesurfer; module add freesurfer/7.3.2
module unload fsl; module add fsl/6.0.5
module unload ANTs; module add ANTs/20180607

fs_dir=/project/3024006.02/Analyses/FreeSurfer_v7.3.2/LongitudinalTemplate/outputs
wd=$fs_dir/$subject/highres2mni

# Fresh directory
if [ -d "$wd" ]; then
  rm -r $wd
fi
mkdir -p $wd
cd $wd

# Conversion
echo "Converting: .mgz > .nii.gz"
$FREESURFER_HOME/bin/mri_convert \
  ../mri/T1.mgz \
	${subject}_T1.nii.gz

# Reorientation
echo "Reorienting: FreeSurfer > FSL"
$FSLDIR/bin/fslreorient2std \
  ${subject}_T1.nii.gz \
	${subject}_T1_reo.nii.gz
	
# N4 bias field correction
echo "N4 bias field correction"
$ANTs_HOME/bin/N4BiasFieldCorrection \
  -d 3 \
  -i ${subject}_T1_reo.nii.gz \
	-o [ ${subject}_T1_reo_N4corr.nii.gz, ${subject}_T1_reo_bias_field.nii.gz ]

# Brain extraction
echo "Brain extraction: mri_synthstrip"
$FREESURFER_HOME/bin/mri_synthstrip \
  -i ${subject}_T1_reo_N4corr.nii.gz \
  -o ${subject}_T1_reo_N4corr_brain.nii.gz \
  -m ${subject}_T1_reo_N4corr_brain_mask.nii.gz \
	-b -1
	
# FSL's FNIRT registration to MNI-space
if [ $FNIRT -eq 1 ]; then

# Estimate non-linear transformation from halfway anatomicals to standard space
echo "Running FLIRT"
${FSLDIR}/bin/flirt \
  -ref ${FSLDIR}/data/standard/MNI152_T1_2mm_brain \
	-in ${subject}_T1_reo_N4corr_brain.nii.gz \
	-omat ${subject}_highres2mni_affine.mat

echo "Running FNIRT"	
${FSLDIR}/bin/fnirt \
  --in=${subject}_T1_reo_N4corr.nii.gz \
	--aff=${subject}_highres2mni_affine.mat \
	--cout=${subject}_highres2mni_nlin \
	--config=T1_2_MNI152_2mm \
	--refmask=${FSLDIR}/data/standard/MNI152_T1_2mm_brain_mask_dil1.nii.gz

# Apply transformations
echo "Applying transformations FLIRT > FNIRT > MNI"
${FSLDIR}/bin/applywarp \
  --ref=${FSLDIR}/data/standard/MNI152_T1_2mm_brain \
	--in=${subject}_T1_reo_N4corr.nii.gz \
	--warp=${subject}_highres2mni_nlin \
	--out=${subject}_T1_reo_N4corr_mni-FNIRT
	
fi
	
# ANTs SyN registration to MNI-space
if [ $ANTs -eq 1 ]; then

echo "Running antsRegistrationSyN.sh"
$ANTs_HOME/bin/antsRegistrationSyN.sh \
  -d 3 \
	-f ${FSLDIR}/data/standard/MNI152_T1_2mm.nii.gz \
	-m ${subject}_T1_reo_N4corr_brain.nii.gz \
	-x ${FSLDIR}/data/standard/MNI152_T1_2mm_brain_mask_dil1.nii.gz \
	-o ${subject}_T1_reo_N4corr_brain_mni-ANTs

fi
