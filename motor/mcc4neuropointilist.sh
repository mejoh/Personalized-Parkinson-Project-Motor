#!/bin/bash

# mcc4neuropointilist.sh
# Martin E. Johansson, 8/12/2022
# Thresholding of p-images and masking of t-images from Neuropointilist
# Outputs FDR- and FWE-corrected images
# FWE-correction relies on knowledge of minimum extent of clusters (calculated in AFNI)

d='/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/neuropointillist/disease/Whole/'
cd $d
pvals=`ls $d/*pvalue.nii.gz`

#i=/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/neuropointillist/disease/stats/PDvsHC.groupXtimeXchoice3c.pvalue.nii.gz

for i in ${pvals[@]} ; do
	
	# Remove extension
	filename=$(basename -- "$i")
	extension="${filename##*.}"
	filename="${filename%.*}"
	filename="${filename%.*}"

	# Mask
	fslmaths $filename \
	-uthr 998 \
	-bin \
	${filename}_uthr998
	
	# 1-p image
	fslmaths $filename \
	-mul -1 \
	-add 1 \
	-mas ${filename}_uthr998 \
	${filename}_1minp
	
	# FWE-correction
	cluster \
	-i ${filename}_1minp \
	-t 0.99 \
	--minextent=108 \
	--connectivity=18 \
	--othresh=${filename}_fwe-corr \
	-o ${filename}_fwe-corr-idx \
	> ${filename}_fwe-corr.txt
	fslmaths ${filename}_fwe-corr-idx -bin ${filename}_fwe-corr-mask
	
	# FDR-correction
	fdr \
	-i ${filename}_1minp \
	--oneminusp \
	-q 0.05 \
	-m ${filename}_uthr998 \
	--othresh=${filename}_fdr-corr \
        > ${filename}_fdr-corr.txt
	fslmaths ${filename}_fdr-corr -bin ${filename}_fdr-corr-mask
	
	# Mask t-image
	cimg="${filename%.*}.chisq"
	timg="${filename%.*}.tvalue"
	if [ -f "${cimg}.nii.gz" ]; then
	fslmaths $cimg -uthr 998 -mas ${filename}_fwe-corr-mask ${cimg}_fwe-corr
	fslmaths $cimg -uthr 998 -mas ${filename}_fdr-corr-mask ${cimg}_fdr-corr
	elif [ -f "${timg}.nii.gz" ]; then
	fslmaths $timg -uthr 998 -mas ${filename}_fwe-corr-mask ${timg}_fwe-corr
	fslmaths $timg -uthr 998 -mas ${filename}_fdr-corr-mask ${timg}_fdr-corr
	fi

done
