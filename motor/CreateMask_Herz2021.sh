#!/bin/bash

cd /project/3024006.02/Analyses/Masks/

mm=8
put_mm=6
standard=standard/fsl/MNI152_T1_2mm_brain.nii.gz
binary=standard/fsl/MNI152_T1_2mm_brain_mask.nii

# ----- #
# HC > PD
R_PUT=(30 1 58 1 39 1) #`./MNItoFSLVox.sh 30 -10 6`
L_PUT=(60 1 59 1 37 1) #`./MNItoFSLVox.sh -30 -8 2`
L_PreCen=(62 1 52 1 67 1) #`./MNItoFSLVox.sh -34 -22 62`
R_PreCen=(27 1 53 1 72 1) #`./MNItoFSLVox.sh 36 -20 72`
L_SMA=(47 1 60 1 65 1) #`./MNItoFSLVox.sh -4 -6 58`
R_CBvi=(32 1 36 1 21 1) #`./MNItoFSLVox.sh 26 -54 -30`
fslmaths $standard -mul -0 Herz2021_HCgtPD -odt float
fslmaths Herz2021_HCgtPD -add 1 -roi `echo ${R_PUT[@]}` 0 1 R_PUT_Herz2021 -odt float
fslmaths Herz2021_HCgtPD -add 1 -roi `echo ${L_PUT[@]}` 0 1 L_PUT_Herz2021 -odt float
fslmaths Herz2021_HCgtPD -add 1 -roi `echo ${L_PreCen[@]}` 0 1 L_PreCen_Herz2021 -odt float
fslmaths Herz2021_HCgtPD -add 1 -roi `echo ${R_PreCen[@]}` 0 1 R_PreCen_Herz2021 -odt float
fslmaths Herz2021_HCgtPD -add 1 -roi `echo ${L_SMA[@]}` 0 1 L_SMA_Herz2021 -odt float
fslmaths Herz2021_HCgtPD -add 1 -roi `echo ${R_CBvi[@]}` 0 1 R_CBvi_Herz2021 -odt float
fslmaths R_PUT_Herz2021 -kernel sphere $put_mm -fmean -bin R_PUT_Herz2021 -odt float
fslmaths L_PUT_Herz2021 -kernel sphere $put_mm -fmean -bin L_PUT_Herz2021 -odt float
fslmaths L_PreCen_Herz2021 -kernel sphere $mm -fmean -bin L_PreCen_Herz2021 -odt float
fslmaths R_PreCen_Herz2021 -kernel sphere $mm -fmean -bin R_PreCen_Herz2021 -odt float
fslmaths L_SMA_Herz2021 -kernel sphere $mm -fmean -bin L_SMA_Herz2021 -odt float
fslmaths R_CBvi_Herz2021 -kernel sphere $mm -fmean -bin R_CBvi_Herz2021 -odt float
fslmaths R_PUT_Herz2021 \
-add L_PUT_Herz2021 \
-add L_PreCen_Herz2021 \
-add R_PreCen_Herz2021 \
-add L_SMA_Herz2021 \
-add R_CBvi_Herz2021 \
-mul $binary \
Herz2021_HCgtPD
# ----- #

# --------- #
# HC > PD-OFF
R_PUT=(30 1 58 1 39 1) #`./MNItoFSLVox.sh 30 -10 6`
L_PUT=(60 1 61 1 36 1) #`./MNItoFSLVox.sh -30 -4 0`
L_PreCen=(62 1 52 1 67 1) #`./MNItoFSLVox.sh -34 -22 62`
L_CBv=(48 1 33 1 29 1) #`./MNItoFSLVox.sh -6 -60 -14`
fslmaths $standard -mul -0 Herz2021_HCgtPDoff -odt float
fslmaths Herz2021_HCgtPDoff -add 1 -roi `echo ${R_PUT[@]}` 0 1 R_PUT_Herz2021 -odt float
fslmaths Herz2021_HCgtPDoff -add 1 -roi `echo ${L_PUT[@]}` 0 1 L_PUT_Herz2021 -odt float
fslmaths Herz2021_HCgtPDoff -add 1 -roi `echo ${L_PreCen[@]}` 0 1 L_PreCen_Herz2021 -odt float
fslmaths Herz2021_HCgtPDoff -add 1 -roi `echo ${L_CBv[@]}` 0 1 L_CBv_Herz2021 -odt float
fslmaths R_PUT_Herz2021 -kernel sphere $put_mm -fmean -bin R_PUT_Herz2021 -odt float
fslmaths L_PUT_Herz2021 -kernel sphere $put_mm -fmean -bin L_PUT_Herz2021 -odt float
fslmaths L_PreCen_Herz2021 -kernel sphere $mm -fmean -bin L_PreCen_Herz2021 -odt float
fslmaths L_CBv_Herz2021 -kernel sphere $mm -fmean -bin L_CBv_Herz2021 -odt float
fslmaths R_PUT_Herz2021 \
-add L_PUT_Herz2021 \
-add L_PreCen_Herz2021 \
-add L_CBv_Herz2021 \
-mul $binary \
Herz2021_HCgtPDoff
# --------- #

# ----- #
# PD > HC
L_pSMA=(46 1 64 1 65 1) #`./MNItoFSLVox.sh -2 2 58`
L_PreCen_MFG=(62 1 60 1 65 1) #`./MNItoFSLVox.sh -34 -6 58`
R_PreCen_MFG=(29 1 60 1 64 1) #`./MNItoFSLVox.sh 32 -6 56`
fslmaths $standard -mul -0 Herz2021_PDgtHC -odt float
fslmaths Herz2021_PDgtHC -add 1 -roi `echo ${L_pSMA[@]}` 0 1 L_pSMA_Herz2021 -odt float
fslmaths Herz2021_PDgtHC -add 1 -roi `echo ${L_PreCen_MFG[@]}` 0 1 L_PreCen_MFG_Herz2021 -odt float
fslmaths Herz2021_PDgtHC -add 1 -roi `echo ${R_PreCen_MFG[@]}` 0 1 R_PreCen_MFG_Herz2021 -odt float
fslmaths L_pSMA_Herz2021 -kernel sphere $mm -fmean -bin L_pSMA_Herz2021 -odt float
fslmaths L_PreCen_MFG_Herz2021 -kernel sphere $mm -fmean -bin L_PreCen_MFG_Herz2021 -odt float
fslmaths R_PreCen_MFG_Herz2021 -kernel sphere $mm -fmean -bin R_PreCen_MFG_Herz2021 -odt float
fslmaths L_pSMA_Herz2021 \
-add L_PreCen_MFG_Herz2021 \
-add R_PreCen_MFG_Herz2021 \
-mul $binary \
Herz2021_PDgtHC
# ----- #

# --------- #
# PD-OFF > HC
R_PreCen_MFG=(30 1 61 1 64 1) #`./MNItoFSLVox.sh 30 -4 56`
L_PreCen_MFG=(62 1 64 1 62 1) #`./MNItoFSLVox.sh -34 2 52`
fslmaths $standard -mul -0 Herz2021_PDoffgtHC -odt float
fslmaths Herz2021_PDoffgtHC -add 1 -roi `echo ${R_PreCen_MFG[@]}` 0 1 R_PreCen_MFG_Herz2021 -odt float
fslmaths Herz2021_PDoffgtHC -add 1 -roi `echo ${L_PreCen_MFG[@]}` 0 1 L_PreCen_MFG_Herz2021 -odt float
fslmaths R_PreCen_MFG_Herz2021 -kernel sphere $mm -fmean -bin R_PreCen_MFG_Herz2021 -odt float
fslmaths L_PreCen_MFG_Herz2021 -kernel sphere $mm -fmean -bin L_PreCen_MFG_Herz2021 -odt float
fslmaths R_PreCen_MFG_Herz2021 \
-add L_PreCen_MFG_Herz2021 \
-mul $binary \
Herz2021_PDoffgtHC
# --------- #

# ------------- #
#Overlapping mask
fslmaths Herz2021_HCgtPD \
-add Herz2021_HCgtPDoff \
-add Herz2021_PDgtHC \
-add Herz2021_PDoffgtHC \
-bin \
Herz2021_combined
gunzip Herz2021_combined.nii.gz
# ------------- #






