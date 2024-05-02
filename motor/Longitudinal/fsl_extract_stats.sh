#!/bin/bash

usage() {

  cat <<USAGE
	
	Usage:
	
	`basename $0` -args
	
	Description:
	
	Extract statistics from 4d input data based on output from FSL-randomise. Yields
	single-subject statistics, information about significant clusters, and coarse
	visualizations (to do).
	
	-d: Input data in 4D format
	
	-n: Image names in row-wise text-file format
	
	-p: FWE-corrected 1-p image from randomise
	
	-t: t- or tfce-statistical image from randomise
	
	-o: Output basename
	
	Example:
	
	1. fsl_extract_stats.sh -d /path/to/analysis/data/4dimg.nii.gz -n /path/to/analysis/data/4dtxt.txt -p /path/to/analysis/stats/contrast/corrp.nii.gz -t /path/to/analysis/stats/contrast/tfce.nii.gz -o /path/to/analysis/stats/vals/outputname
	
USAGE

  exit 1

}

# Provide help
[ "$1" == "" ] && usage >&2
[ "$1" == "-h" ] && usage >&2
[ "$1" == "--help" ] && usage >&2

# Command-line arguemnts
while getopts ":d:n:p:t:o:" OPT; do

  case "${OPT}" in 
		d)
			echo ">>> -d ${OPTARG}"
			optD=${OPTARG}
		;;
		n)
			echo ">>> -n ${OPTARG}"
			optN=${OPTARG}
		;;
		p)
			echo ">>> -p ${OPTARG}"
			optP=${OPTARG}
		;;
		t)
			echo ">>> -t ${OPTARG}"
			optT=${OPTARG}
		;;
		o)
			echo ">>> -o ${OPTARG}"
			optO=${OPTARG}
		;;
		\?)
			echo ">>> Error: invalid option -${OPTARG}"
			usage >&2
		;;
		:)
			echo ">>>> Error: option -${OPTARG} requires an argument"
			usage >&2
		;;
	esac

done

# Set up environment
# Note on FSL: beware of using fslstats -K in version of FSL higher
# than v6.0.1. In v6.0.5, this command will loop through the mask
# indices, producing one value per maks, that is inserted in a single
# column. This leads to a single column with a mix of values from each
# mask index. 
export FSLDIR=/opt/fsl/6.0.1
.  ${FSLDIR}/etc/fslconf/fsl.sh
export AFNIDIR=/opt/afni/2022
module load afni/2022
DATA=${optD}
DATADIR=`dirname ${DATA}`
NTXT=${optN}
PIMG=${optP}
TIMG=${optT}
OUTBN=${optO}
OUTDIR=`dirname ${OUTBN}`
mkdir -p ${OUTDIR}

# Check arguments
if [[ ! -f ${DATA} || ! -f ${NTXT} || ! -f ${PIMG} || ! -f ${TIMG} ]]; then
	echo ">>> ERROR: one or more inputs do not exist. Check file names"
	exit 1
fi

# Create index mask
## Create a mask from thresholded p-image
${FSLDIR}/bin/fslmaths \
	${PIMG} \
	-thr 0.95 \
	-bin \
	${OUTBN}_mask_bin
	
## Check if index mask contains values. If not, exit.
SIG=( `${FSLDIR}/bin/fslstats ${OUTBN}_mask_bin -R` )
if [[ ${SIG[1]%.*} -gt 0 ]]; then
	echo ">>> Significant results! Congratulations."
else
	echo ">>> No significant results. How sad."
	touch ${OUTBN}_NO_RESULTS.txt
	rm ${OUTBN}_mask_bin.nii.gz
	exit 0
fi

## t- or tfce-image for visualization
### Masked
${FSLDIR}/bin/fslmaths \
	${TIMG} \
	-mas ${OUTBN}_mask_bin \
	${OUTBN}_mask_t
	
	### Full
	${FSLDIR}/bin/fslmaths \
	${TIMG} \
	-mul 1 \
	${OUTBN}_full_t

## Define cluster mask
${FSLDIR}/bin/cluster \
	-i ${PIMG} \
	-t 0.95 \
	-o ${OUTBN}_cluster_index \
	> ${OUTBN}_cluster.txt
	
# Extract stats
## Summary of all participants
${FSLDIR}/bin/fslstats \
	-K ${OUTBN}_cluster_index \
	${DATA} \
	-M -S > ${OUTBN}_stats_summary.txt

## Average and SD of each participant
minmax=( `fslstats ${OUTBN}_cluster_index -R` )
max=`echo ${minmax[1]} | cut -c -1`
for(( i=1; i<$(($max+1)); i++ )); do


	${FSLDIR}/bin/fslmaths \
		${OUTBN}_cluster_index \
		-thr ${i} \
		-uthr ${i} \
		${OUTBN}_cluster_index_${i}
		
	${FSLDIR}/bin/fslstats \
		-t \
		${DATA} \
		-k ${OUTBN}_cluster_index_${i} \
		-M > ${OUTBN}_tmp.txt
		
		cat ${OUTBN}_tmp.txt | tr -d '[:blank:]' > ${OUTBN}_stats_avg_clust${i}.txt
		
		${FSLDIR}/bin/fslstats \
		-t \
		${DATA} \
		-k ${OUTBN}_cluster_index_${i} \
		-S > ${OUTBN}_tmp.txt
		
		cat ${OUTBN}_tmp.txt | tr -d '[:blank:]' > ${OUTBN}_stats_sd_clust${i}.txt
		
		rm ${OUTBN}_cluster_index_${i}.nii.gz
		rm ${OUTBN}_tmp.txt
		
done

paste -d , ${OUTBN}_stats_avg_clust* > ${OUTBN}_stats_avg.txt
paste -d , ${OUTBN}_stats_sd_clust* > ${OUTBN}_stats_sd.txt
rm ${OUTBN}_stats_*_clust*.txt

# # # Extract stats
# # # #Summary of all participants
# # # ${FSLDIR}/bin/fslstats \
	# # # -K ${OUTBN}_cluster_index \
	# # # ${DATA} \
	# # # -M -S > ${OUTBN}_stats_summary.txt

# # # # Average per participant
# # # ${FSLDIR}/bin/fslstats \
	# # # -t \
	# # # -K ${OUTBN}_cluster_index \
	# # # ${DATA} \
	# # # -M > ${OUTBN}_stats_avg_clust.txt
	
# # # # Standard deviations per participant
# # # ${FSLDIR}/bin/fslstats \
	# # # -t \
	# # # -K ${OUTBN}_cluster_index \
	# # # ${DATA} \
	# # # -S > ${OUTBN}_stats_sd_clust.txt
	
# # # Reformat stats
# # # # Split single column of values into one column per cluster
# # # split -l `${FSLDIR}/bin/fslnvols ${DATA}` --numeric-suffixes ${OUTBN}_stats_avg.txt ${OUTBN}_stats_avg_clust
# # # paste -d , ${OUTBN}_stats_avg_clust* | tr -d '[:blank:]' > ${OUTBN}_stats_avg.txt
# # # rm ${OUTBN}_stats_avg_clust*

# # # split -l `${FSLDIR}/bin/fslnvols ${DATA}` --numeric-suffixes ${OUTBN}_stats_sd.txt ${OUTBN}_stats_sd_clust
# # # paste -d , ${OUTBN}_stats_sd_clust* | tr -d '[:blank:]' > ${OUTBN}_stats_sd.txt
# # # rm ${OUTBN}_stats_sd_clust*

# Join image names and stats files
paste -d , ${NTXT} ${OUTBN}_stats_avg.txt > ${OUTBN}_stats_avg_agg.txt
paste -d , ${NTXT} ${OUTBN}_stats_sd.txt > ${OUTBN}_stats_sd_agg.txt

# Atlas
${AFNIDIR}/3dcopy ${OUTBN}_cluster_index.nii.gz ${OUTBN}_cluster_index
${AFNIDIR}/3drefit -space MNI ${OUTBN}_cluster_index+tlrc.
${AFNIDIR}/whereami -space MNI -spm -atlas CA_MPM_22_MNI -omask ${OUTBN}_cluster_index+tlrc. > ${OUTBN}_cluster_index_a-CA_MPM_22-MNI.txt
${AFNIDIR}/whereami -space MNI -spm -atlas CA_ML_18_MNI -omask ${OUTBN}_cluster_index+tlrc. > ${OUTBN}_cluster_index_a-CA_ML_18_MNI.txt
${AFNIDIR}/whereami -space MNI -spm -atlas MNI_Glasser_HCP_v1.0 -omask ${OUTBN}_cluster_index+tlrc. > ${OUTBN}_cluster_index_a-MNI_Glasser_HCP_v1.0.txt
rm ${OUTBN}_cluster_index+tlrc.*

# Coarse visualization of results (horizontal slices over entire brain)
# BACKGROUND=/project/3024006.02/templates/templateflow/tpl-MNI152NLin6Asym_res-02_desc-brain_T1w_resampled.nii.gz
BACKGROUND=/opt/fsl/6.0.5/data/standard/MNI152_T1_2mm_brain.nii.gz
STATIMG=${OUTBN}_mask_t
LUT=/opt/fsl/6.0.0/etc/luts/renderhot.lut
MINMAX=( `${FSLDIR}/bin/fslstats ${STATIMG} -n -R` )
${FSLDIR}/bin/overlay 1 0 ${BACKGROUND} -A ${STATIMG} 0.1 ${MINMAX[1]} ${OUTBN}_overlay
OVERLAY=${OUTBN}_overlay
TMPDIR=${OUTBN}_tmp
mkdir -p ${TMPDIR}

${FSLDIR}/bin/slicer ${OVERLAY} -l ${LUT} -L \
-z 0.040 ${TMPDIR}/040.png \
-z 0.060 ${TMPDIR}/060.png \
-z 0.080 ${TMPDIR}/080.png \
-z 0.100 ${TMPDIR}/100.png \
-z 0.120 ${TMPDIR}/120.png \
-z 0.140 ${TMPDIR}/140.png \
-z 0.160 ${TMPDIR}/160.png \
-z 0.180 ${TMPDIR}/180.png \
-z 0.200 ${TMPDIR}/200.png \
-z 0.220 ${TMPDIR}/220.png \
-z 0.240 ${TMPDIR}/240.png \
-z 0.260 ${TMPDIR}/260.png \
-z 0.280 ${TMPDIR}/280.png \
-z 0.300 ${TMPDIR}/300.png \
-z 0.320 ${TMPDIR}/320.png \
-z 0.340 ${TMPDIR}/340.png \
-z 0.360 ${TMPDIR}/360.png \
-z 0.380 ${TMPDIR}/380.png \
-z 0.400 ${TMPDIR}/400.png \
-z 0.420 ${TMPDIR}/420.png \
-z 0.440 ${TMPDIR}/440.png \
-z 0.460 ${TMPDIR}/460.png \
-z 0.480 ${TMPDIR}/480.png \
-z 0.500 ${TMPDIR}/500.png \
-z 0.520 ${TMPDIR}/520.png \
-z 0.540 ${TMPDIR}/540.png \
-z 0.560 ${TMPDIR}/560.png \
-z 0.580 ${TMPDIR}/580.png \
-z 0.600 ${TMPDIR}/600.png \
-z 0.620 ${TMPDIR}/620.png \
-z 0.640 ${TMPDIR}/640.png \
-z 0.660 ${TMPDIR}/660.png \
-z 0.680 ${TMPDIR}/680.png \
-z 0.700 ${TMPDIR}/700.png \
-z 0.720 ${TMPDIR}/720.png \
-z 0.740 ${TMPDIR}/740.png \
-z 0.760 ${TMPDIR}/760.png \
-z 0.780 ${TMPDIR}/780.png \
-z 0.800 ${TMPDIR}/800.png \
-z 0.820 ${TMPDIR}/820.png \
-z 0.840 ${TMPDIR}/840.png

${FSLDIR}/bin/pngappend \
${TMPDIR}/060.png + \
${TMPDIR}/080.png + \
${TMPDIR}/100.png + \
${TMPDIR}/120.png + \
${TMPDIR}/140.png + \
${TMPDIR}/160.png + \
${TMPDIR}/180.png + \
${TMPDIR}/200.png + \
${TMPDIR}/220.png + \
${TMPDIR}/240.png \
${TMPDIR}/row1.png

${FSLDIR}/bin/pngappend \
${TMPDIR}/260.png + \
${TMPDIR}/280.png + \
${TMPDIR}/300.png + \
${TMPDIR}/320.png + \
${TMPDIR}/340.png + \
${TMPDIR}/360.png + \
${TMPDIR}/380.png + \
${TMPDIR}/300.png + \
${TMPDIR}/420.png + \
${TMPDIR}/440.png \
${TMPDIR}/row2.png

${FSLDIR}/bin/pngappend \
${TMPDIR}/460.png + \
${TMPDIR}/480.png + \
${TMPDIR}/500.png + \
${TMPDIR}/520.png + \
${TMPDIR}/540.png + \
${TMPDIR}/560.png + \
${TMPDIR}/580.png + \
${TMPDIR}/600.png + \
${TMPDIR}/620.png + \
${TMPDIR}/640.png \
${TMPDIR}/row3.png

${FSLDIR}/bin/pngappend \
${TMPDIR}/660.png + \
${TMPDIR}/680.png + \
${TMPDIR}/700.png + \
${TMPDIR}/720.png + \
${TMPDIR}/740.png + \
${TMPDIR}/760.png + \
${TMPDIR}/780.png + \
${TMPDIR}/800.png + \
${TMPDIR}/820.png + \
${TMPDIR}/840.png \
${TMPDIR}/row4.png

${FSLDIR}/bin/pngappend \
${TMPDIR}/row1.png - \
${TMPDIR}/row2.png - \
${TMPDIR}/row3.png - \
${TMPDIR}/row4.png \
${OUTBN}_visualization.png

rm -r ${TMPDIR}
