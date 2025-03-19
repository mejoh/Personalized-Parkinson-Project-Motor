#!/bin/bash

project="3022026.01"
dRoot="/project/"; dRoot+="$project"; echo "Root dir: $dRoot"
dRaw="$dRoot/raw"; echo "Raw dir: $dRaw"
dBIDS="$dRoot/bids"; echo "BIDS dir: $dBIDS"
dFmriprep="$dBIDS/derivatives/fmriprep"; echo "Fmriprep dir: $dFmriprep"
# Todo: Mriqc?

# Check whether participants in raw have a folder in bids
cd $dRaw
Raw_sub=$(find sub-P*[0-9]* -maxdepth 0 -type d | cut -c 1-) 		# Finds subjects, format 'sub-P...'
cd $dBIDS
BIDS_sub=$(find sub-P*[0-9]* -maxdepth 0 -type d | cut -c 1-)

for n in ${Raw_sub[@]}; do 			# Which participants in Raw does not directory in BIDS?
  if [[ $BIDS_sub != *"$n"* ]]; then
    echo "$n in Raw not found in BIDS directory"
    echo "Fix by bidscoining"
  fi
done

# Check whether participants in bids have a folder in fmriprep
#cd $dFmriprep
#Fmriprep_sub=$(find sub-P*[0-9]*.html -maxdepth 0 | cut -c 1-17)

#for n in ${BIDS_sub[@]}; do 			# Which participants in BIDS does not directory in Fmriprep?
#  if [[ $Fmriprep_sub != *"$n"* ]]; then
#    echo "$n in BIDS not found in Fmriprep directory"
#    echo "Fix by fmriprepping"
 # fi
#done

# Check whether participants in raw have a folder in fmriprep
#for n in ${Raw_sub[@]}; do 			# Which participants in Raw does not directory in Fmriprep?
 # if [[ $Fmriprep_sub != *"$n"* ]]; then
 #   echo "$n in Raw not found in Fmriprep directory"
 #   echo "Fix by bidscoining and fmriprepping"
#  fi
#done


# Check participants backwards as well
for n in ${BIDS_sub[@]}; do 			# Which participants in BDIS does not directory in Raw?
  if [[ $Raw_sub != *"$n"* ]]; then
    echo "$n in BIDS not found in Raw directory"
    echo "Why?"
  fi
done

#for n in ${Fmriprep_sub[@]}; do 			# Which participants in Fmriprep does not directory in BIDS?
#  if [[ $BIDS_sub != *"$n"* ]]; then
#    echo "$n in Fmriprep not found in BIDS directory"
 #   echo "Why?"
#  fi
#done

#for n in ${Fmriprep_sub[@]}; do 		# Which participants in Fmriprep does not directory in Raw?
#  if [[ $Raw_sub != *"$n"* ]]; then
#    echo "$n in Fmriprep not found in Raw directory"
#    echo "Why?"
#  fi
#done



