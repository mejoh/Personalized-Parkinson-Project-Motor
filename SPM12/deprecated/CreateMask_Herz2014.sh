#!/bin/bash

cd /project/3024006.02/Analyses/Masks/

# Left SPL MNI: [-32 -46 62]
fslmaths standard/spm/avg152T1.nii -mul -0 SPL_Herz2014 -odt float

fslmaths SPL_Herz2014 -add 1 -roi 28 1 40 1 67 1 0 1 rightSPL_Herz2014 -odt float
fslmaths SPL_Herz2014 -add 1 -roi 62 1 40 1 67 1 0 1 leftSPL_Herz2014 -odt float

fslmaths rightSPL_Herz2014 -kernel sphere 8 -fmean -bin rightSPL_Herz2014 -odt float
fslmaths leftSPL_Herz2014 -kernel sphere 8 -fmean -bin leftSPL_Herz2014 -odt float

fslmaths rightSPL_Herz2014 -add leftSPL_Herz2014 biSPL_Herz2014

gunzip rightSPL_Herz2014.nii.gz
gunzip leftSPL_Herz2014.nii.gz
gunzip biSPL_Herz2014.nii.gz

# Right Putamen MNI: [26 -4 -8]
fslmaths standard/spm/avg152T1.nii -mul 0 PP_Herz2014 -odt float

fslmaths PP_Herz2014 -add 1 -roi 32 1 61 1 32 1 0 1 rightPP_Herz2014 -odt float
fslmaths PP_Herz2014 -add 1 -roi 58 1 61 1 32 1 0 1 leftPP_Herz2014 -odt float

fslmaths rightPP_Herz2014 -kernel sphere 5 -fmean -bin rightPP_Herz2014 -odt float
fslmaths leftPP_Herz2014 -kernel sphere 5 -fmean -bin leftPP_Herz2014 -odt float

fslmaths rightPP_Herz2014 -add leftPP_Herz2014 biPP_Herz2014

gunzip rightPP_Herz2014.nii.gz
gunzip leftPP_Herz2014.nii.gz
gunzip biPP_Herz2014.nii.gz
