#!/bin/bash

# Copy multiple sessions for patients and controls
# The script is split into doing complete cases and single sessions to 
# avoid including OFF-state patients. 

prepend_hc=""
prepend_pd=""
bidsdir="/project/3022026.01/pep/bids"
outdir="/project/3022026.01/pep/bids/derivatives/freesurfer_v7.3.2/inputs"
qcdir="/project/3022026.01/pep/bids/derivatives/freesurfer_v7.3.2/qc/t1refs/"
cd $bidsdir 
#subs=`cat /project/3024006.02/templates/template_50HC50PD/list.txt`
subs=`ls -d sub-POMU*` 

for s in ${subs[@]}; do

	echo "Processing ${s}"

	pd1=${bidsdir}/${s}/ses-POMVisit1/anat/${s}_ses-POMVisit1_acq-MPRAGE_run-1_T1w.nii.gz
	pd2=${bidsdir}/${s}/ses-POMVisit3/anat/${s}_ses-POMVisit3_acq-MPRAGE_run-1_T1w.nii.gz
	hc1=${bidsdir}/${s}/ses-PITVisit1/anat/${s}_ses-PITVisit1_acq-MPRAGE_run-1_T1w.nii.gz
	hc2=${bidsdir}/${s}/ses-PITVisit2/anat/${s}_ses-PITVisit2_acq-MPRAGE_run-1_T1w.nii.gz
	
	# Complete PD cases
	if [[ (-f $pd1 && -f $pd2 && ! -f $hc2) ]]; then
		
		echo "PD: complete case, copying both visits"
		mkdir -p ${outdir}/${prepend_pd}${s}
		cp $pd1 ${outdir}/${prepend_pd}${s}/${prepend_pd}${s}_t1_T1w.nii.gz
		cp $pd2 ${outdir}/${prepend_pd}${s}/${prepend_pd}${s}_t2_T1w.nii.gz
		# slices ${outdir}/${prepend_pd}${s}/${prepend_pd}${s}_t1_T1w.nii.gz -o ${qcdir}/${prepend_pd}${s}_t1_T1ref.gif
		# slices ${outdir}/${prepend_pd}${s}/${prepend_pd}${s}_t2_T1w.nii.gz -o ${qcdir}/${prepend_pd}${s}_t2_T1ref.gif
	
	# PD visit 1 only
	elif [[ (-f $pd1 && ! -f $pd2 && ! -f $hc2) ]]; then
	
		echo "PD: incomplete case, copying visit 1"
		mkdir -p ${outdir}/${prepend_pd}${s}
		cp $pd1 ${outdir}/${prepend_pd}${s}/${prepend_pd}${s}_t1_T1w.nii.gz
		# slices ${outdir}/${prepend_pd}${s}/${prepend_pd}${s}_t1_T1w.nii.gz -o ${qcdir}/${prepend_pd}${s}_t1_T1ref.gif
	
	# PD visit 2 only
	elif [[ (! -f $pd1 && -f $pd2 && ! -f $hc2) ]]; then
	
		echo "PD: incomplete case, copying visit 2"
		mkdir -p ${outdir}/${prepend_pd}${s}
		cp $pd2 ${outdir}/${prepend_pd}${s}/${prepend_pd}${s}_t2_T1w.nii.gz
		# slices ${outdir}/${prepend_pd}${s}/${prepend_pd}${s}_t2_T1w.nii.gz -o ${qcdir}/${prepend_pd}${s}_t2_T1ref.gif
		
	# Complete HC cases	
	elif [[ (-f $hc1 && -f $hc2) ]]; then
	
		echo "HC: complete case, copying both visits"
		mkdir -p ${outdir}/${prepend_hc}${s}
		cp $hc1 ${outdir}/${prepend_hc}${s}/${prepend_hc}${s}_t1_T1w.nii.gz
		cp $hc2 ${outdir}/${prepend_hc}${s}/${prepend_hc}${s}_t2_T1w.nii.gz
		# slices ${outdir}/${prepend_hc}${s}/${prepend_hc}${s}_t1_T1w.nii.gz -o ${qcdir}/${prepend_hc}${s}_t1_T1ref.gif
		# slices ${outdir}/${prepend_hc}${s}/${prepend_hc}${s}_t2_T1w.nii.gz -o ${qcdir}/${prepend_hc}${s}_t2_T1ref.gif
		
	# HC visit 1 only	
	elif [[ (-f $hc1 && ! -f $pd1 && ! -f $pd2) ]]; then
	
		echo "HC: incomplete case, copying visit 1"
		mkdir -p ${outdir}/${prepend_hc}${s}
		cp $hc1 ${outdir}/${prepend_hc}${s}/${prepend_hc}${s}_t1_T1w.nii.gz
		# slices ${outdir}/${prepend_hc}${s}/${prepend_hc}${s}_t1_T1w.nii.gz -o ${qcdir}/${prepend_hc}${s}_t1_T1ref.gif
	
	# HC visit 2 only
	elif [[ (! -f $hc1 && -f $hc2) ]]; then
	
		echo "HC: incomplete case, copying visit 2"
		mkdir -p ${outdir}/${prepend_hc}${s}
		cp $hc2 ${outdir}/${prepend_hc}${s}/${prepend_hc}${s}_t2_T1w.nii.gz
		# slices ${outdir}/${prepend_hc}${s}/${prepend_hc}${s}_t2_T1w.nii.gz -o ${qcdir}/${prepend_hc}${s}_t2_T1ref.gif
		
	fi
	
	echo "DONE"

done
