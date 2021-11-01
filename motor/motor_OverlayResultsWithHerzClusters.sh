#!/bin/bash

### Description ###
### Overlays a mask of Herz's meta analysis results on an MNI template
### Stats are then shown on top, indicting overlap with the Herz-mask
### through higher intensity values

statimg=("stat_HcOff_x_ExtInt2Int3_Catch_NoOutliers.nii.gz" "stat_OneSampleTtest_ClinCorr-Off-BAAppendicularSum_NoOutliers.nii.gz" "stat_OneSampleTtest_ClinCorr-Off-Prog-AppendicularSum_NoOutliers.nii.gz")

background="/project/3024006.02/Analyses/Masks/standard/fsl/MNI152_T1_2mm_brain.nii.gz"
Herz2021="/project/3024006.02/Analyses/Masks/Herz2021_combined.nii"
Herz2014="/project/3024006.02/Analyses/Masks/leftSPL_Herz2014.nii"
outputdir="/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/visualization/OverlayWithHerz/"
colors="/opt/fsl/6.0.0/etc/luts/renderhot.lut"

cd $outputdir
fslmaths $background -add 0 backgroundimg -odt float
fslmaths $Herz2021 -add 0 Herz2021 -odt float
fslmaths $Herz2014 -add 0 Herz2014 -odt float
fslmaths Herz2021 -add Herz2014 -bin Herz -odt float

for i in ${statimg[@]}; do
minmax=(`fslstats $i -n -R`)
overlay 1 0 backgroundimg 1000 8500 Herz 0.1 3 $i 0.01 ${minmax[1]} overlayimg
slicer overlayimg -L -n -t -l $colors \
	-z 0.20 sl1.png -z 0.21 sl2.png -z 0.22 sl3.png -z 0.23 sl4.png -z 0.24 sl5.png \
	-z 0.25 sl6.png -z 0.26 sl7.png -z 0.27 sl8.png -z 0.28 sl9.png -z 0.29 sl10.png \
	-z 0.30 sla.png -z 0.31 slb.png -z 0.32 slc.png -z 0.33 sld.png -z 0.34 sle.png \
	-z 0.35 sla1.png -z 0.36 slb1.png -z 0.37 slc1.png -z 0.38 sld1.png -z 0.39 sle1.png \
	-z 0.40 slf.png -z 0.41 slg.png -z 0.42 slh.png -z 0.43 sli.png -z 0.44 slj.png \
	-z 0.45 slf1.png -z 0.46 slg1.png -z 0.47 slh1.png -z 0.48 sli1.png -z 0.49 slj1.png \
	-z 0.50 slk.png -z 0.51 sll.png -z 0.52 slm.png -z 0.53 sln.png -z 0.54 slo.png \
	-z 0.55 slk1.png -z 0.56 sll1.png -z 0.57 slm1.png -z 0.58 sln1.png -z 0.59 slo1.png \
	-z 0.60 slp.png -z 0.61 slq.png -z 0.62 slr.png -z 0.63 sls.png -z 0.64 slt.png \
	-z 0.65 slp1.png -z 0.66 slq1.png -z 0.67 slr1.png -z 0.68 sls1.png -z 0.69 slt1.png \
	-z 0.70 slu.png -z 0.71 slv.png -z 0.72 slw.png -z 0.73 slx.png -z 0.74 sly.png \
	-z 0.75 slu1.png -z 0.76 slv1.png -z 0.77 slw1.png -z 0.78 slx1.png -z 0.79 sly1.png
	
pngappend sl1.png + sl2.png + sl3.png + sl4.png + sl5.png -\
	sl6.png + sl7.png + sl8.png + sl9.png + sl10.png -\
	sla.png + slb.png + slc.png + sld.png + sle.png - \
	sla1.png + slb1.png + slc1.png + sld1.png + sle1.png - \
	slf.png + slg.png + slh.png + sli.png + slj.png - \
	slf1.png + slg1.png + slh1.png + sli1.png + slj1.png - \
	slk.png + sll.png + slm.png + sln.png + slo.png - \
	slk1.png + sll1.png + slm1.png + sln1.png + slo1.png - \
	slp.png + slq.png + slr.png + sls.png + slt.png - \
	slp1.png + slq1.png + slr1.png + sls1.png + slt1.png - \
	slu.png + slv.png + slw.png + slx.png + sly.png -\
	slu1.png + slv1.png + slw1.png + slx1.png + sly1.png \
	${i}_sl.png

rm sl?*.png

done

