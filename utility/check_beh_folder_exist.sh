#!/bin/bash
cd /project/3022026.01/raw
subs=`ls -d sub-POM*`
for s in ${subs[@]}; do
	c=$(pwd)
	cd $s
	ses=`ls -d ses-*`
	for v in ${ses[@]}; do
		cd $v
		# Test presence of BEH folder
		#if [ ! -d beh ]; then
		#	echo $s $v
		#fi
		# Test presence of log files
		#if [ -d beh ]; then
		#	cd beh
		#fi
		#nlogs=`ls | grep *.log | wc -l`
		#if [ $nlogs -lt 1 ]; then
		#	echo $s $v
		#fi
		# Test presence of EMG folder
		#if [ ! -d emg ]; then
		#	echo $s $v
		#fi
		# Test presence of emg files
		if [ -d emg ]; then
			cd emg
		fi
		nlogs=`ls | grep *task1.eeg | wc -l`
		if [ $nlogs -lt 1 ]; then
			echo $s $v
		fi
	done
	cd $c
done
