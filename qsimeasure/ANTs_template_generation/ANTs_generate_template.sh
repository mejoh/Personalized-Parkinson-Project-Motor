#!/bin/bash

# # fs_dir=""
# # cd $fs_dir

# # # Generate a template using FS make_average_volume
# # make_average_volume \
	# # --out base_average_fs \
	# # --subjects `find /project/3024006.02/Analyses/FreeSurfer_v7.3.2/LongitudinalTemplate/outputs/ -maxdepth 1 -type d -printf "%f\n" | awk 'length==27'`

# # # Generate template by averaging MNI-registered anatomicals
# # # 0 = ANTs, 1 = FNIRT
# # TYPE=1

# # if [ $TYPE -eq 0 ]; then
  # # TEMPLATEDIR=avg_base_ANTs
  # # # images=`find *_sub-POMU*.long*/highres2mni/*T1_reo_N4corr_brain_mni-ANTsWarped.nii.gz`
	# # images=`find \( -name "*T1_reo_N4corr_brain_mni-ANTsWarped.nii.gz" -type f \) -not \( -name "*_sub-POMU*_t*T1_reo_N4corr_brain_mni-ANTsWarped.nii.gz" -type f \)`
# # elif [ $TYPE -eq 1 ]; then
  # # TEMPLATEDIR=avg_base_FNIRT
  # # # images=`find *_sub-POMU*.long*/highres2mni/*T1_reo_N4corr_mni-FNIRT.nii.gz`
	# # images=`find \( -name "*T1_reo_N4corr_mni-FNIRT.nii.gz" -type f \) -not \( -name "*_sub-POMU*_t*T1_reo_N4corr_mni-FNIRT.nii.gz" -type f \)`
# # fi

# # # Simple averaging of images
# # mkdir -p ${TEMPLATEDIR}
# # fslmerge -t ${TEMPLATEDIR}/template_4D_anat ${images}
# # fslmaths ${TEMPLATEDIR}/template_4D_anat -Tmean ${TEMPLATEDIR}/template_avg_anat_asym
# # fslswapdim ${TEMPLATEDIR}/template_avg_anat_asym -x y z ${TEMPLATEDIR}/template_avg_anat_asym_swap
# # fslmerge -t ${TEMPLATEDIR}/template_avg_anat_4D ${TEMPLATEDIR}/template_avg_anat_asym ${TEMPLATEDIR}/template_avg_anat_asym_swap
# # fslmaths ${TEMPLATEDIR}/template_avg_anat_4D -Tmean ${TEMPLATEDIR}/template_avg_anat_sym

# Load an older version of ANTs, because it works while the newer does not
module unload ANTs; module add ANTs/20150225
# export APPTAINER="/opt/apptainer/1.1.5"
# export ANTs_IMAGE="/opt/ANTs/2.4.0/ants-2.4.0.simg"
inputPath=/project/3022026.01/pep/bids/derivatives/qsiprep
outputPath=/project/3024006.02/templates/template_50HC50PD/HCP1065_FA_template
TEMPLATE=/project/3024006.02/templates/fsl/FSL_HCP1065_FA_1mm.nii.gz
mkdir -p $outputPath
cd $outputPath
cp ${TEMPLATE} ${outputPath}/standard.nii.gz

# antsMultivariateTemplateConstruction.sh won't work unless you remove '-q nopreempt' from
# the qsub command prompted by using argument '-c 4'. The script has
# therefore been copied to the project directory and adapted
# https://sourceforge.net/p/advants/discussion/840261/thread/3bccddeb/
	
# T1w
# cmd="/project/3024006.02/Analyses/FreeSurfer_v7.3.2/LongitudinalTemplate/antsMultivariateTemplateConstruction.sh -d 3 -o ${outputPath}/T_ -c 4 -g 0.25 -i 5 -j 2 -k 1 -w 1 -m 100x70x50x10 -n 1 -r 1 -s CC -t GR -y 0 -z /opt/fsl/6.0.5/data/standard/MNI152_T1_2mm_brain.nii.gz `find ${inputPath}/*_sub-POMU*/highres2mni -name "*_t[1-2]*T1_reo_N4corr_brain.nii.gz" -type f -not -name "*_t[1-2].long*T1_reo_N4corr_brain.nii.gz" -type f`"
# FA
i_PIT1=( `ls /project/3022026.01/pep/bids/derivatives/qsiprep/sub-*/ses-PITVisit1/metrics/dipy_fw/sub-*fsl_FA.nii.gz` )
i_PIT2=( `ls /project/3022026.01/pep/bids/derivatives/qsiprep/sub-*/ses-PITVisit2/metrics/dipy_fw/sub-*fsl_FA.nii.gz` )
i_POM1=( `ls /project/3022026.01/pep/bids/derivatives/qsiprep/sub-*/ses-POMVisit1/metrics/dipy_fw/sub-*fsl_FA.nii.gz` )
i_POM3=( `ls /project/3022026.01/pep/bids/derivatives/qsiprep/sub-*/ses-POMVisit3/metrics/dipy_fw/sub-*fsl_FA.nii.gz` )
imgs=`echo "${i_PIT1[@]:0:50} ${i_PIT2[@]:0:50} ${i_POM1[@]:0:50} ${i_POM3[@]:0:50}"`
# `find ${inputPath}/sub*/ses*/metrics/dipy_b0 -name "sub-*dipy-b0.nii.gz" -type f`
/project/3024006.02/templates/template_50HC50PD/antsMultivariateTemplateConstruction.sh -d 3 -o ${outputPath}/T_ -c 4 -g 0.25 -i 4 -j 2 -k 1 -w 1 -m 100x70x50x10 -n 1 -r 1 -s CC -t GR -y 0 -z ${outputPath}/standard.nii.gz `echo ${imgs[@]}`

#${APPTAINER}/bin/apptainer run ${ANTs_IMAGE} ${cmd}
	
	# LONGITUDINAL
	# `find ${inputPath}/*_sub-POMU*.long*/highres2mni -name "*_T1_reo_N4corr_brain.nii.gz" -type f`
	# BASE
	# `find ${inputPath}/*_sub-POMU*_t[1-2]/highres2mni -name "*T1_reo_N4corr_brain.nii.gz" -type f -not -name "*_t[1-2]*T1_reo_N4corr_brain.nii.gz" -type f`
	# ORIG
	# `find ${inputPath}/*_sub-POMU*/highres2mni -name "*_t[1-2]*T1_reo_N4corr_brain.nii.gz" -type f -not -name "*_t[1-2].long*T1_reo_N4corr_brain.nii.gz" -type f`
	