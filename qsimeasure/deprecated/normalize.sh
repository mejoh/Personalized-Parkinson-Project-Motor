#!/bin/bash

# Usage

usage (){

	cat <<USAGE
	
	Usage:
	
	`basename $0` -d <path> -p <subid> <other options>
	
	Description:
	
	Normalize qsimeasure.py output to MNI-space
	
	Compulsory arguments:
	
	-d: BIDS directory
	
	-p: Subject ID
	
USAGE

	exit 1

}

# Provide help
[ "$1" == "" ] && usage >&2
[ "$1" == "-h" ] && usage >&2
[ "$1" == "--help" ] && usage >&2

# Get command-line options
while getopts ":d:p:" OPT; do
	case "${OPT}" in
		d)
			echo ">>> -d ${OPTARG}"
			optD=${OPTARG}
		;;
		p)
			echo ">>> -p ${OPTARG}"
			optP=${OPTARG}
		;;
		\?)
			echo ">>> Error: Invalid option -${OPTARG}."
			usage >&2
		;;
		:)
			echo ">>>> Error: Option -${OPTARG} requires an argument."
			usage >&2
		;;
		esac
done
shift $((OPTIND-1))

## Set up environment, directories, and template (adjust as necessary)
export APPTAINER="/opt/apptainer/1.1.5"
export ANTs_IMAGE="/opt/ANTs/2.4.0/ants-2.4.0.simg"
export FREESURFER_HOME="/opt/freesurfer/7.3.2"
export FSLDIR=/opt/fsl/6.0.5
.  ${FSLDIR}/etc/fslconf/fsl.sh
export C3D="/opt/c3d/1.0.0"

bidsdir=${optD}
subject=${optP}
qsiprepdir=${bidsdir}/derivatives/qsiprep
bids_sub=${bidsdir}/${subject}
qsiprep_sub=${qsiprepdir}/${subject}

# MNI_img="/project/3024006.02/templates/templateflow/tpl-MNI152NLin6Asym_res-02_desc-brain_T1w.nii.gz"
MNI_img="/project/3024006.02/templates/templateflow/tpl-MNI152NLin6Asym_res-01_desc-brain_T1w.nii.gz"

# Check mandatory arguments
if [ ! "$bidsdir" ] || [ ! "$subject" ]; then
  echo ">>> Error: arguments -d and -p must be provided"
  usage >&2
fi
# Check that options are valid
	# QSIprep directory
if [ ! -f "${qsiprepdir}/${subject}.html" ]; then
	echo ">>> Error: QSIprep output missing"
	exit 1
fi

## Build within-subject anatomical template
echo ">>> Finding anatomicals..."
mkdir -p ${qsiprep_sub}/wd
anat=( $(ls ${bids_sub}/ses*/anat/*_T1w.nii.gz) )
len=${#anat[@]}
if [ ${len} -lt 1 ]; then
 echo ">>> Error: No anatomicals found"
 exit 1
fi
# N4 correction
echo ">>> N4 bias field correction"
for (( i=0; i<${len}; i++ )); do
 echo "Correcting img: $((${i}+1))"
 cmd="N4BiasFieldCorrection -d 3 -i ${anat[i]} -o [ ${qsiprep_sub}/wd/i${i}_anat_N4.nii.gz, ${qsiprep_sub}/wd/i${i}_anat_N4_bias_field.nii.gz ]"
 ${APPTAINER}/bin/apptainer run ${ANTs_IMAGE} ${cmd}
done
# Template creation
echo ">>> Creating template"
moving=( $(ls ${qsiprep_sub}/wd/i*_anat_N4.nii.gz) )
${FREESURFER_HOME}/bin/mri_robust_template \
 --satit \
 --mov `echo ${moving[@]}`\
 --inittp 1 \
 --iscale \
 --template ${qsiprep_sub}/wd/template_T1w.nii.gz \
 --subsample 200
# Skullstrip
echo "Brain extraction: mri_synthstrip"
${FREESURFER_HOME}/bin/mri_synthstrip \
  -i ${qsiprep_sub}/wd/template_T1w.nii.gz \
  -o ${qsiprep_sub}/wd/template_T1w_brain.nii.gz \
  -m ${qsiprep_sub}/wd/template_T1w_brain_mask.nii.gz \
	-b -1
moving=${qsiprep_sub}/wd/template_T1w_brain.nii.gz

## Estimate anat2mni transformation
echo ">>> Estimating transform: T1w to MNI"
cmd="antsRegistration --collapse-output-transforms 1 --dimensionality 3 --float 1 --initial-moving-transform [ ${MNI_img}, ${moving}, 1 ] --initialize-transforms-per-stage 0 --interpolation LanczosWindowedSinc --output [ ${qsiprep_sub}/wd/ants_t1_to_mni, ${qsiprep_sub}/wd/ants_t1_to_mni_Warped.nii.gz ] --transform Rigid[ 0.05 ] --metric Mattes[ ${MNI_img}, ${moving}, 1, 56, Regular, 0.25 ] --convergence [ 100x100, 1e-06, 20 ] --smoothing-sigmas 2.0x1.0vox --shrink-factors 2x1 --use-histogram-matching 1 --transform Affine[ 0.08 ] --metric Mattes[ ${MNI_img}, ${moving}, 1, 56, Regular, 0.25 ] --convergence [ 100x100, 1e-06, 20 ] --smoothing-sigmas 1.0x0.0vox --shrink-factors 2x1 --use-histogram-matching 1 --transform SyN[ 0.1, 3.0, 0.0 ] --metric CC[ ${MNI_img}, ${moving}, 1, 4, None, 1 ] --convergence [ 100x70x50x20, 1e-06, 10 ] --smoothing-sigmas 3.0x2.0x1.0x0.0vox --shrink-factors 8x4x2x1 --use-histogram-matching 1 --winsorize-image-intensities [ 0.005, 0.995 ] --write-composite-transform 1 -v"
${APPTAINER}/bin/apptainer run ${ANTs_IMAGE} ${cmd}
anat2mni=${qsiprep_sub}/wd/ants_t1_to_mniComposite.h5

## Loop over sessions
sessions=( $(ls -d ${qsiprep_sub}/ses*) )
len=${#sessions[@]}
for (( i=0; i<${len}; i++ )); do

	echo ">>> Estimating transform: b0 to MNI, session $((${i}+1))"
 ## Estimate b02anat transformation
 b0=( $(ls ${sessions[i]}/metrics/dipy_b0/dipy_b0_mean.nii.gz) )
 if [ ! -f ${b0} ]; then
 echo "Error: Missing b0-image"
	continue
 fi
 
 ${FSLDIR}/bin/fslreorient2std ${b0} ${qsiprep_sub}/wd/i${i}_b0.nii.gz
 
 cmd="N4BiasFieldCorrection -d 3 -i ${qsiprep_sub}/wd/i${i}_b0.nii.gz -o [ ${qsiprep_sub}/wd/i${i}_b0_N4.nii.gz, ${qsiprep_sub}/wd/i${i}_b0_N4_bias_field.nii.gz ]"
 ${APPTAINER}/bin/apptainer run ${ANTs_IMAGE} ${cmd}

# Estimate epi2anat
echo "Running epi_reg"
${FSLDIR}/bin/epi_reg \
 --epi=${qsiprep_sub}/wd/i${i}_b0_N4.nii.gz \
 --t1=${qsiprep_sub}/wd/template_T1w.nii.gz \
 --t1brain=${qsiprep_sub}/wd/template_T1w_brain.nii.gz \
 --out=${qsiprep_sub}/wd/i${i}_epi2anat
 
# Convert .mat to ITK .txt
echo "Converting .mat to ITK .txt"
${C3D}/bin/c3d_affine_tool \
 -ref ${qsiprep_sub}/wd/template_T1w_brain.nii.gz \
 -src ${qsiprep_sub}/wd/i${i}_b0_N4.nii.gz \
 ${qsiprep_sub}/wd/i${i}_epi2anat.mat \
 -fsl2ras \
 -oitk ${qsiprep_sub}/wd/i${i}_epi2anat_mat2itk.txt
epi2anat=${qsiprep_sub}/wd/i${i}_epi2anat_mat2itk.txt
 
 # Normalize all qsimeasure outputs
 metrics=( $(ls ${sessions[i]}/metrics/*/dipy*nii.gz) )
 echo ${metrics[@]}
 lan=${#metrics[@]}
 for (( j=0; j<${lan}; j++ )); do
 
  in=${metrics[j]}
  dn=`dirname ${in}`
  bn=`basename ${in}`
	on=${dn}/n1_${bn}
	echo ">>> Applying transform: ${bn} to MNI"
	
	# Reorient and N4 correct
	${FSLDIR}/bin/fslreorient2std ${in} ${qsiprep_sub}/wd/metric.nii.gz
	cmd="N4BiasFieldCorrection -d 3 -i ${qsiprep_sub}/wd/metric.nii.gz -o [ ${qsiprep_sub}/wd/metric.nii.gz, ${qsiprep_sub}/wd/metric_bias_field.nii.gz ]"
  ${APPTAINER}/bin/apptainer run ${ANTs_IMAGE} ${cmd}
	
	# Normalize
	cmd="antsApplyTransforms --default-value 0 --float 1 --input ${qsiprep_sub}/wd/metric.nii.gz --interpolation LanczosWindowedSinc --output ${on} --reference-image ${MNI_img} --transform ${anat2mni} --transform ${epi2anat} --transform identity -v"
 ${APPTAINER}/bin/apptainer run ${ANTs_IMAGE} ${cmd}
	
 done

done

# Clean up
mkdir -p ${qsiprep_sub}/anat
${FSLDIR}/bin/immv ${qsiprep_sub}/wd/template_T1w.nii.gz ${qsiprep_sub}/anat/template_T1w.nii.gz
${FSLDIR}/bin/immv ${qsiprep_sub}/wd/template_T1w_brain.nii.gz ${qsiprep_sub}/anat/template_T1w_brain.nii.gz
#rm -r ${qsiprep_sub}/wd

