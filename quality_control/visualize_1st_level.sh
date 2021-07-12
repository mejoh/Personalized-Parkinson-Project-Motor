#!/bin/bash

###################DESCRIPTION####################
## Generates a .html file with slices from 1st- ##
## level analysis overlaid on BOLD-ref image.   ##
## Gives overview of activation-pattern.        ##
##################################################

FMRIPREPdir=/project/3022026.01/pep/bids/derivatives/fmriprep		# Specify directories
SPMdir=/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem
FSLdir=/opt/fsl/6.0.0/etc/luts/renderhot.lut

cd ${SPMdir}
mkdir -p ${SPMdir}/QC
input_list=`ls -d sub-*`					# Create input list with all participants in SPMdir
#input_list=sub-POMU8067BDE54D1B1B4A
subs_analyzed=( $input_list )					# Print how many, and which, subjects are listed
echo ${input_list}
echo "Number of subjects found:" ${#subs_analyzed[@]}

for sub in ${input_list[@]}; do
	OUTPUTdir=${SPMdir}/${sub}
	Sessions=`find $FMRIPREPdir/${sub} -name 'ses*'`
	for s in ${Sessions[@]}; do
		Visit=`basename $s`
		OUTPUTname=spmT_0001_slices		
		BGimg=${FMRIPREPdir}/${sub}/$Visit/func/*_task-motor_acq-MB6_run-1_space-MNI152NLin6Asym_boldref.nii.gz
		OrigSTATSimg=${SPMdir}/${sub}/$Visit/1st_level/spmT_0001.nii		# <<<< Make sure this is the contrast for 'External'!

		if [ -f "${OrigSTATSimg}" ]; then

			# Overlay stats image onto BOLDref
			minmax=(`fslstats ${OrigSTATSimg} -n -R`)
			overlay 1 1 ${BGimg} -a ${OrigSTATSimg} 1 ${minmax[1]} ${OUTPUTdir}/overlay_img

			# Create images of various slices
			slicer ${OUTPUTdir}/overlay_img -l ${FSLdir} -z 0.580 ${OUTPUTdir}/580.png -z 0.600 ${OUTPUTdir}/600.png -z 0.620 ${OUTPUTdir}/620.png -z 0.640 ${OUTPUTdir}/640.png -z 0.660 ${OUTPUTdir}/660.png -z 0.680 ${OUTPUTdir}/680.png -z 0.700 ${OUTPUTdir}/700.png -z 0.720 ${OUTPUTdir}/720.png -z 0.740 ${OUTPUTdir}/740.png

			# Append to single image
			pngappend ${OUTPUTdir}/580.png + ${OUTPUTdir}/600.png + ${OUTPUTdir}/620.png + ${OUTPUTdir}/640.png + ${OUTPUTdir}/660.png + ${OUTPUTdir}/680.png + ${OUTPUTdir}/700.png + ${OUTPUTdir}/720.png + ${OUTPUTdir}/740.png ${OUTPUTdir}/${sub}_${Visit}_${OUTPUTname}.png
			# Clean up output		
			rm ${OUTPUTdir}/5*.png ${OUTPUTdir}/6*.png ${OUTPUTdir}/7*.png ${OUTPUTdir}/overlay_img.nii.gz
			# Move to QC folder
			mv ${OUTPUTdir}/${sub}_${Visit}_${OUTPUTname}.png ${SPMdir}/QC/${sub}_${Visit}_${OUTPUTname}.png

		else

			echo "Skipping ${sub} ${Visit}: does not have 1st level output"

		fi
	done
done

# Merge all images into a single file
mkdir -p ${SPMdir}/QC
convert `ls ${SPMdir}/QC/sub*_slices.png` -append ${SPMdir}/QC/1st_level_QC.png
