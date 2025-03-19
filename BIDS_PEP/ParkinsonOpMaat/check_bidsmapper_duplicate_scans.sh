#!/bin/bash

cd /project/3022026.01/bids/
touch files.txt
touch deviating_files.txt

# T1w
t1w1=`ls sub-*/ses-*/anat/*rec-*_T1w.nii.gz | wc -l`
t1w2=`ls sub-*/ses-*/anat/*rec-TE203*_T1w.nii.gz | wc -l`
t1w3=`ls sub-*/ses-*/anat/*rec-TE204*_T1w.nii.gz | wc -l`
t1w4=`ls sub-*/ses-*/anat/*rec-TE222*_T1w.nii.gz | wc -l`
echo "T1w: $t1w1 $t1w2 $t1w3 $t1w4" >> files.txt

# T2w
t2w1=`ls sub-*/ses-*/anat/*rec-*_T2w.nii.gz | wc -l`
t2w2=`ls sub-*/ses-*/anat/*rec-ROW*_T2w.nii.gz | wc -l`
t2w3=`ls sub-*/ses-*/anat/*rec-COL*_T2w.nii.gz | wc -l`
echo "T2w: $t2w1 $t2w2 $t2w3" >> files.txt

# FLAIR
flair1=`ls sub-*/ses-*/anat/*rec-*_FLAIR.nii.gz | wc -l`
flair2=`ls sub-*/ses-*/anat/*rec-ROW*_FLAIR.nii.gz | wc -l`
flair3=`ls sub-*/ses-*/anat/*rec-COL*_FLAIR.nii.gz | wc -l`
echo "FLAIR: $flair1 $flair2 $flair3" >> files.txt

# SWI
swi1=`ls sub-*/ses-*/anat/*rec-*echo-1_part-mag_MEGRE.nii.gz | wc -l`
swi2=`ls sub-*/ses-*/anat/*rec-080ROW*echo-1_part-mag_MEGRE.nii.gz | wc -l`
swi3=`ls sub-*/ses-*/anat/*rec-095ROW*echo-1_part-mag_MEGRE.nii.gz | wc -l`
swi4=`ls sub-*/ses-*/anat/*rec-080COL*echo-1_part-mag_MEGRE.nii.gz | wc -l`
swi5=`ls sub-*/ses-*/anat/*rec-091ROW*echo-1_part-mag_MEGRE.nii.gz | wc -l`
swi6=`ls sub-*/ses-*/anat/*rec-080ROWOSP*echo-1_part-mag_MEGRE.nii.gz | wc -l`
echo "SWI: $swi1 $swi2 $swi3 $swi4 $swi5 $swi6" >> files.txt

# fmap
fmap1=`ls sub-*/ses-*/fmap/*acq-MB3_dir-*_epi.nii.gz | wc -l`
fmap2=`ls sub-*/ses-*/fmap/*acq-MB3_dir-ROW*_epi.nii.gz | wc -l`
fmap3=`ls sub-*/ses-*/fmap/*acq-MB3_dir-COL*_epi.nii.gz | wc -l`
echo "fmap: $fmap1 $fmap2 $fmap3" >> files.txt

# Rest
rest1=`ls sub-*/ses-*/func/*task-rest*rec-*_bold.nii.gz | wc -l`
rest2=`ls sub-*/ses-*/func/*task-rest*rec-NoOSP*_bold.nii.gz | wc -l`
rest3=`ls sub-*/ses-*/func/*task-rest*rec-OSP*_bold.nii.gz | wc -l`
echo "Rest: $rest1 $rest2 $rest3" >> files.txt

# Reward
reward1=`ls sub-*/ses-*/func/*task-reward*rec-*echo-1*_bold.nii.gz | wc -l`
reward2=`ls sub-*/ses-*/func/*task-reward*rec-ROW*echo-1*_bold.nii.gz | wc -l`
reward3=`ls sub-*/ses-*/func/*task-reward*rec-COL*echo-1*_bold.nii.gz | wc -l`
echo "Reward: $reward1 $reward2 $reward3" >> files.txt

# Deviating files
t1w3=`ls sub-*/ses-*/anat/*rec-TE204*_T1w.nii.gz`
t1w4=`ls sub-*/ses-*/anat/*rec-TE222*_T1w.nii.gz`
t2w3=`ls sub-*/ses-*/anat/*rec-COL*_T2w.nii.gz`
flair3=`ls sub-*/ses-*/anat/*rec-COL*_FLAIR.nii.gz`
swi3=`ls sub-*/ses-*/anat/*rec-095ROW*echo-1_part-mag_MEGRE.nii.gz`
swi4=`ls sub-*/ses-*/anat/*rec-080COL*echo-1_part-mag_MEGRE.nii.gz`
swi5=`ls sub-*/ses-*/anat/*rec-091ROW*echo-1_part-mag_MEGRE.nii.gz`
swi6=`ls sub-*/ses-*/anat/*rec-080ROWOSP*echo-1_part-mag_MEGRE.nii.gz`
fmap2=`ls sub-*/ses-*/fmap/*acq-MB3_dir-ROW*_epi.nii.gz`
rest3=`ls sub-*/ses-*/func/*task-rest*rec-OSP*_bold.nii.gz`
reward2=`ls sub-*/ses-*/func/*task-reward*rec-ROW*echo-1*_bold.nii.gz`
echo "$t1w3 $t1w4 $t2w3 $flair3 $swi3 $swi4 $swi5 $swi6 $fmap2 $rest3 $reward2" >> deviating_files.txt


