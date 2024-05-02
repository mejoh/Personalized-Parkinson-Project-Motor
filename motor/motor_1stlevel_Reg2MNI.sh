#!/bin/bash

#subdir="/project/3022026.01/pep/bids/derivatives/fmriprep_v23.0.2/motor"; list_subjects=`find ${subdir}/sub-POMU[A-Z]* -maxdepth 0 -type d -printf "%f\n"`; for s in ${list_subjects[@]}; do list_sessions=`find ${subdir}/${s}/ses-* -maxdepth 0 -type d -printf "%f\n"`; for v in ${list_sessions[@]}; do qsub -o /project/3024006.02/Analyses/motor_task/func2sst/logs -e /project/3024006.02/Analyses/motor_task/func2sst/logs -N func2sst_${s}_${v} -v subject=${s},session=${v} -l 'walltime=03:00:00,mem=16gb' ~/scripts/Personalized-Parkinson-Project-Motor/motor/motor_1stlevel_Reg2MNI.sh; done; done

#subdir="/project/3022026.01/pep/bids/derivatives/fmriprep_v23.0.2/motor"; list_subjects=(sub-POMUC210A497167526A3); for s in ${list_subjects[@]}; do list_sessions=`find ${subdir}/${s}/ses-* -maxdepth 0 -type d -printf "%f\n"`; for v in ${list_sessions[@]}; do qsub -o /project/3024006.02/Analyses/motor_task/func2sst/logs -e /project/3024006.02/Analyses/motor_task/func2sst/logs -N func2sst_${s}_${v} -v subject=${s},session=${v} -l 'walltime=03:00:00,mem=16gb' ~/scripts/Personalized-Parkinson-Project-Motor/motor/motor_1stlevel_Reg2MNI.sh; done; done

# subject=sub-POMUBA958B8183C9F612
# session=ses-POMVisit1

sub=${subject}
ses=${session}

# Init
wd=/project/3024006.02/wd/${sub}_${ses}
fmriprepdir=/project/3022026.01/pep/bids/derivatives/fmriprep_v23.0.2/motor
# templatedir=/project/3024006.02/templates/templateflow
# template=${templatedir}/tpl-MNI152NLin6Asym_res-02_T1w.nii.gz
templatedir=/project/3024006.02/templates/template_50HC50PD/ANTs_template_long
template=${templatedir}/T_template0.nii.gz
# template_mask=${templatedir}/T_template0_mask_dil1.nii.gz
outdir_func=${fmriprepdir}/${sub}/${ses}/func
outdir_qc=/project/3024006.02/Analyses/motor_task/func2sst/${sub}/${ses}
FWHM=6

# Set up environment
# export ANTs_HOME="/opt/ANTs/20180607/build"
export APPTAINER="/opt/apptainer/1.1.5"
export ANTs_IMAGE="/opt/ANTs/2.4.0/ants-2.4.0.simg"
export FSLDIR=/opt/fsl/6.0.5
.  ${FSLDIR}/etc/fslconf/fsl.sh
export FREESURFER_HOME="/opt/freesurfer/7.3.2"
export C3D="/opt/c3d/1.0.0"

mkdir -p ${wd}
cd ${wd}
echo "$(pwd)"

## Anatomical processing
# 1. Locate anatomical
# 2. N4 bias field correction
# 3. Brain extraction
# 4. Estimate anat2mni

# Locate anatomical image
anat=${fmriprepdir}/${sub}/anat/${sub}_acq-MPRAGE_run-1_desc-preproc_T1w.nii.gz
if [ ! -f ${anat} ]; then
 anat=${fmriprepdir}/${sub}/anat/${sub}_run-1_desc-preproc_T1w.nii.gz # Bug for 3 subs, acq-MPRAGE missing from T1w name
fi
if [ ! -f ${anat} ]; then
 anat=${fmriprepdir}/${sub}/anat/${sub}_acq-MPRAGE_desc-preproc_T1w.nii.gz # Bug for 1 subs, run-1 missing from T1w name
fi
if [ ! -f ${anat} ]; then
 anat=${fmriprepdir}/${sub}/${ses}/anat/${sub}_${ses}_acq-MPRAGE_run-1_desc-preproc_T1w.nii.gz
fi
if [ ! -f ${anat} ]; then
 echo "No anatomical found for ${sub} ${ses}, exiting..."
 exit 1
fi

# N4 bias field correction
echo "N4 bias field correction"
cmd="N4BiasFieldCorrection -d 3 -i ${anat} -o [ anat_N4.nii.gz, anat_N4_bias_field.nii.gz ]"
${APPTAINER}/bin/apptainer run ${ANTs_IMAGE} ${cmd}

# Brain extraction
echo "Brain extraction: mri_synthstrip"
${FREESURFER_HOME}/bin/mri_synthstrip \
  -i anat_N4.nii.gz \
  -o anat_N4_brain.nii.gz \
  -m anat_N4_brain_mask.nii.gz \
	-b -1
moving="anat_N4_brain.nii.gz"

# Estimate anat2template transformation
echo "Running antsRegistrationSyN.sh"
# (same code as fmriprep except that the --initial-moving-transform argument is altered)
cmd="antsRegistration --collapse-output-transforms 1 --dimensionality 3 --float 1 --initial-moving-transform [ ${template}, ${moving}, 1 ] --initialize-transforms-per-stage 0 --interpolation LanczosWindowedSinc --output [ ants_t1_to_mni, ants_t1_to_mni_Warped.nii.gz ] --transform Rigid[ 0.05 ] --metric Mattes[ ${template}, ${moving}, 1, 56, Regular, 0.25 ] --convergence [ 100x100, 1e-06, 20 ] --smoothing-sigmas 2.0x1.0vox --shrink-factors 2x1 --use-histogram-matching 1 --transform Affine[ 0.08 ] --metric Mattes[ ${template}, ${moving}, 1, 56, Regular, 0.25 ] --convergence [ 100x100, 1e-06, 20 ] --smoothing-sigmas 1.0x0.0vox --shrink-factors 2x1 --use-histogram-matching 1 --transform SyN[ 0.1, 3.0, 0.0 ] --metric CC[ ${template}, ${moving}, 1, 4, None, 1 ] --convergence [ 100x70x50x20, 1e-06, 10 ] --smoothing-sigmas 3.0x2.0x1.0x0.0vox --shrink-factors 8x4x2x1 --use-histogram-matching 1 --winsorize-image-intensities [ 0.005, 0.995 ]  --write-composite-transform 1 -v"
${APPTAINER}/bin/apptainer run ${ANTs_IMAGE} ${cmd}
anat2mni=ants_t1_to_mniComposite.h5 # custom
#anat2mni=/project/3022026.01/pep/bids/derivatives/fmriprep_v23.0.2/motor/${sub}/anat/${sub}_acq-MPRAGE_run-1_from-T1w_to-MNI152NLin6Asym_mode-image_xfm.h5 # fmriprep

## Functional processing
# 1. Specify functional data
# 2. Generate bold reference image
# 3. Estimate func2anat (BBR)
# 4. Convert .mat to ITK .txt format
# 4. Split functional data into single volumes
# 5. Apply transforms
# 6. Merge to 4d image
# 7. Brain extraction

# Specify functional scan (in native space)
func=${fmriprepdir}/${sub}/${ses}/func/${sub}_${ses}_task-motor_acq-MB6_run-1_echo-1_desc-preproc_bold.nii.gz
if [ ! -f ${func} ]; then
	echo "No functional found for ${sub} ${ses}, exiting..."
	exit 1
fi

echo "Generating BOLD-reference, N4-correcting as well"
nvols=`${FSLDIR}/bin/fslnvols ${func}`
${FSLDIR}/bin/fslroi ${func} example_func $((${nvols} / 2)) 1
cmd="N4BiasFieldCorrection -d 3 -i example_func.nii.gz -o [ example_func_N4.nii.gz, example_func_N4_bias_field.nii.gz ]"
${APPTAINER}/bin/apptainer run ${ANTs_IMAGE} ${cmd}

# Estimate func2anat
echo "Running epi_reg"
${FSLDIR}/bin/epi_reg \
 --epi=example_func_N4.nii.gz \
 --t1=anat_N4.nii.gz \
 --t1brain=anat_N4_brain.nii.gz \
 --out=bold2anat
 
# Convert .mat to ITK .txt
echo "Converting .mat to ITK .txt"
${C3D}/bin/c3d_affine_tool \
 -ref anat_N4_brain.nii.gz \
 -src example_func_N4.nii.gz \
 bold2anat.mat \
 -fsl2ras \
 -oitk bold2anat_mat2itk.txt
func2anat=bold2anat_mat2itk.txt # custom
# func2anat=${fmriprepdir}/${sub}/${ses}/anat/${sub}_${ses}_acq-MPRAGE_run-1_from-orig_to-T1w_mode-image_xfm.txt # fmriprep

# Split into 3d
echo "Splitting 4d functional into volumes"
${FSLDIR}/bin/fslsplit ${func} vol -t

# Transform individual 3d vols to template-space and upsample
echo "Running antsApplyTransforms on single volumes"
imvols=`ls vol*.nii.gz`
for v in ${imvols[@]}; do
 # (same code as fmriprep except no initial transform, and no identity transform)
 cmd="antsApplyTransforms --default-value 0 --float 1 --input ${v} --interpolation LanczosWindowedSinc --output ${v} --reference-image ${template} --transform ${anat2mni} --transform ${func2anat} --transform identity -v"
 ${APPTAINER}/bin/apptainer run ${ANTs_IMAGE} ${cmd}
done

# Merge to final output
echo "Merging final output image"
${FSLDIR}/bin/fslmerge -t func_data `ls vol*.nii.gz`
rm vol*.nii.gz

# BET, SUSAN, and grand mean scaling (FSL style)
echo "FSL: initializing"
${FSLDIR}/bin/fslmaths func_data prefiltered_func_data -odt float

${FSLDIR}/bin/fslmaths prefiltered_func_data -Tmean mean_func

echo "FSL: bet2"
${FSLDIR}/bin/bet2 mean_func mask -f 0.3 -n -m; ${FSLDIR}/bin/immv mask_mask mask

echo "FSL: susan"
${FSLDIR}/bin/fslmaths prefiltered_func_data -mas mask prefiltered_func_data_bet

robustint=`${FSLDIR}/bin/fslstats prefiltered_func_data_bet -p 2 -p 98 | cut -d' ' -f2-`; echo ${robustint} 
intthr=`echo "${robustint}*0.1" | bc`; echo ${intthr}
${FSLDIR}/bin/fslmaths prefiltered_func_data_bet -thr ${intthr} -Tmin -bin mask -odt char

${FSLDIR}/bin/fslmaths mask -dilF mask

${FSLDIR}/bin/fslmaths prefiltered_func_data -mas mask prefiltered_func_data_thresh

${FSLDIR}/bin/fslmaths prefiltered_func_data_thresh -Tmean mean_func

smoothing_extent_sigma=`echo $(echo ${FWHM} / 2.355 | bc -l)`; echo ${smoothing_extent_sigma}		# FWHM = sigma*sqrt(8*ln(2)) = sigma*2.3548. FSL rounds to 3.355
medianint=`${FSLDIR}/bin/fslstats prefiltered_func_data -k mask -p 50`; echo ${medianint}
bt=`echo "${medianint}*0.75" | bc`; echo ${bt}
${FSLDIR}/bin/susan prefiltered_func_data_thresh ${bt} ${smoothing_extent_sigma} 3 1 1 mean_func ${bt} prefiltered_func_data_smooth
rm prefiltered_func_data.nii.gz

${FSLDIR}/bin/fslmaths prefiltered_func_data_smooth -mas mask prefiltered_func_data_smooth

echo "FSL: grand mean scaling"
scaling_factor=`echo "10000 / ${medianint}" | bc -l`; echo ${scaling_factor}
${FSLDIR}/bin/fslmaths prefiltered_func_data_smooth -mul ${scaling_factor} prefiltered_func_data_intnorm

${FSLDIR}/bin/fslmaths prefiltered_func_data_intnorm filtered_func_data

# Quality control: normalization to template
echo "FSL: slicer"
	# anat2mni
${FSLDIR}/bin/slicer ants_t1_to_mni_Warped.nii.gz ${template} -s 2 -x 0.35 sla.png -x 0.45 slb.png -x 0.55 slc.png -x 0.65 sld.png -y 0.35 sle.png -y 0.45 slf.png -y 0.55 slg.png -y 0.65 slh.png -z 0.35 sli.png -z 0.41 slj.png -z 0.55 slk.png -z 0.65 sll.png ; 
${FSLDIR}/bin/pngappend sla.png + slb.png + slc.png + sld.png + sle.png + slf.png + slg.png + slh.png + sli.png + slj.png + slk.png + sll.png ants_t1_to_mni_Warped1.png ; 
${FSLDIR}/bin/slicer ${template} ants_t1_to_mni_Warped.nii.gz -s 2 -x 0.35 sla.png -x 0.45 slb.png -x 0.55 slc.png -x 0.65 sld.png -y 0.35 sle.png -y 0.45 slf.png -y 0.55 slg.png -y 0.65 slh.png -z 0.35 sli.png -z 0.41 slj.png -z 0.55 slk.png -z 0.65 sll.png ; 
${FSLDIR}/bin/pngappend sla.png + slb.png + slc.png + sld.png + sle.png + slf.png + slg.png + slh.png + sli.png + slj.png + slk.png + sll.png ants_t1_to_mni_Warped2.png ; 
${FSLDIR}/bin/pngappend ants_t1_to_mni_Warped1.png - ants_t1_to_mni_Warped2.png reg_anat2mni.png; rm -f sl?.png ants_t1_to_mni_Warped2.png; rm ants_t1_to_mni_Warped1.png
	# func2mni
${FSLDIR}/bin/slicer mean_func ${template} -s 2 -x 0.35 sla.png -x 0.45 slb.png -x 0.55 slc.png -x 0.65 sld.png -y 0.35 sle.png -y 0.45 slf.png -y 0.55 slg.png -y 0.65 slh.png -z 0.35 sli.png -z 0.41 slj.png -z 0.55 slk.png -z 0.65 sll.png ; 
${FSLDIR}/bin/pngappend sla.png + slb.png + slc.png + sld.png + sle.png + slf.png + slg.png + slh.png + sli.png + slj.png + slk.png + sll.png mean_func1.png ; 
${FSLDIR}/bin/slicer ${template} mean_func -s 2 -x 0.35 sla.png -x 0.45 slb.png -x 0.55 slc.png -x 0.65 sld.png -y 0.35 sle.png -y 0.45 slf.png -y 0.55 slg.png -y 0.65 slh.png -z 0.35 sli.png -z 0.41 slj.png -z 0.55 slk.png -z 0.65 sll.png ; 
${FSLDIR}/bin/pngappend sla.png + slb.png + slc.png + sld.png + sle.png + slf.png + slg.png + slh.png + sli.png + slj.png + slk.png + sll.png mean_func2.png ; 
${FSLDIR}/bin/pngappend mean_func1.png - mean_func2.png reg_func2mni.png; rm -f sl?.png mean_func2.png; rm mean_func1.png

# Move to output directory
echo "Moving image to output destination"
mkdir -p ${outdir_qc}
${FSLDIR}/bin/immv filtered_func_data.nii.gz ${outdir_func}/${sub}_${ses}_task-motor_acq-MB6_run-1_space-SST_desc-preproc_bold.nii.gz
${FSLDIR}/bin/immv mask.nii.gz ${outdir_func}/${sub}_${ses}_task-motor_acq-MB6_run-1_space-SST_desc-brain_mask.nii.gz
mv reg_anat2mni.png ${outdir_qc}/reg_anat2mni.png
mv reg_func2mni.png ${outdir_qc}/reg_func2mni.png
 
# Clean up work directory
rm ${wd}/*



















