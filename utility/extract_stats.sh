#!/bin/bash

cd /project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/
mkdir -p clusterstats

contrasts=("con_0001" "con_0002" "con_0003")
visit=("ses-Visit1")
cluster="/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/HcOff_x_ExtInt2Int3Catch_NoOutliers/Cluster_HCgtPD_Mean_Putamen.nii"
#cluster="/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/HcOff_x_ExtInt2Int3Catch_NoOutliers/Cluster_HCgtPD_Mean_CB.nii"

for con in ${contrasts[@]}; do

  start=`pwd`
  cd $con/$visit
  mkdir -p tmp

  ##### Write mean activity in cluster to file #####
  files=`ls *${con}*.nii`
  fslmerge -t tmp/merged $files
  fslmaths tmp/merged -nan tmp/merged

  fslmaths $cluster -nan -bin tmp/cluster

  name=`basename $cluster .nii`
  fslstats -t tmp/merged -k tmp/cluster -n -m > tmp/stats_${name}.txt
  echo ${files[@]} | sed 's/ /\n/g' > tmp/merged_files.txt
  paste tmp/stats_${name}.txt tmp/merged_files.txt | column -s $'\t' -t > tmp/${name}_${con}_${visit}.txt
  mv tmp/${name}_${con}_${visit}.txt ../../clusterstats
  #####

  rm -r tmp
  cd $start

done

##### Utilities for future use #####

#${FSLDIR}/bin/fslstats \
#	-t \
#	-K ${cluster_index} \
#	${data} \
#	-M > ${stats2}

#nclust=`${FSLDIR}/bin/fslstats $cluster_index -R | cut -c 10-`
#nclust=`seq $nclust`
#echo "Number of clusters: ${nclust[@]}"
#clustdir=`dirname $cluster_index`
#for n in ${nclust[@]}; do

#	${FSLDIR}/bin/fslmaths $cluster_index -thr $n -uthr $n -bin $clustdir/cluster_${n}.nii.gz
#	touch $clustdir/cluster_${n}.txt
#	${FSLDIR}/bin/atlasquery -a 'Juelich Histological Atlas' -m $clustdir/cluster_${n}.nii.gz >> $clustdir/cluster_${n}.txt

# For motor: 'Juelich Histological Atlas'
# For frontal: 'Sallet Dorsal Frontal connectivity-based parcellation'

#done







# Create a mask from thresholded p-image
#mask=${image_path}/mask
#${FSLDIR}/bin/fslmaths \
#	${p_image} \
#	-thr 0.95 \
#	-bin \
#	${mask}
#
# Mask the t-stat image. This is what you present
#t_mask=${image_path}/t
#${FSLDIR}/bin/fslmaths \
#	${t_image} \
#	-mas ${mask} \
#	${t_mask}

# Define cluster mask
#cluster_stats=${image_path}/cluster.txt
#${FSLDIR}/bin/cluster \
#	-i ${p_image} \
#	-t 0.95 \
#	-o ${image_path}/cluster_index \
#	> ${cluster_stats}
#cluster_index=${image_path}/cluster_index
