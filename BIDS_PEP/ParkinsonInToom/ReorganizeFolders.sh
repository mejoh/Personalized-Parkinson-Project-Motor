#!/bin/bash

cd /project/3024006.01/raw

# make a list of sub-PIT1MR participants

list=$(find sub-PIT1MR[0-9]* -maxdepth 0 | cut -c 5-)

# create beh, emg, eye folders

for i in ${list[@]}; do
mkdir -p sub-${i}/ses-mri01/beh
mkdir -p sub-${i}/ses-mri01/emg
mkdir -p sub-${i}/ses-mri01/eye
done

# move data from *behav to beh
# move data from *physio to emg
# delete old behav, physio, and eye folders (ONLY DO THIS IF SURE)

for i in ${list[@]}; do
cp -R sub-${i}/ses-mri01/*motor_behav/. sub-${i}/ses-mri01/beh
cp -R sub-${i}/ses-mri01/*reward_behav/. sub-${i}/ses-mri01/beh

cp -R sub-${i}/ses-mri01/*motor_physio/. sub-${i}/ses-mri01/emg
cp -R sub-${i}/ses-mri01/*reward_physio/. sub-${i}/ses-mri01/emg
cp -R sub-${i}/ses-mri01/*rest_physio/. sub-${i}/ses-mri01/emg

#rm -r sub-${i}/ses-mri01/0*_behav
#rm -r sub-${i}/ses-mri01/0*_physio
#rm -r sub-${i}/ses-mri01/0*_eye
done

