#!/bin/bash

# Bidscoin v4.0.0 adds a "bids::" tag to the beginning of the "Inteded for" field
# that describes the scans that fmaps belong to. QSIprep is not able to find fmaps
# with this tag. This script removes or re-inserts the "bids::" tag.

bidsdir=/project/3022026.01/pep/bids
cd $bidsdir
subs=`ls -d sub-POMU*`

for s in ${subs[@]}; do

 json_files=`ls $s/ses-*/fmap/*acq-MB3*_epi.json`

 for j in ${json_files[@]}; do

 echo "Altering $j"
 
 # Remove the "bids::" tag
 cat $j | sed 's/"bids::sub-/"sub-/g' > $(pwd)/${j}_x
 
 # Re-insert the "bids::" tag
 # cat $j | sed 's/"sub-/"bids::sub-/g' > $(pwd)/${j}_x

 # Replace old file
 mv $(pwd)/${j}_x $(pwd)/${j}

 done

done

