#!/bin/bash

wd=/project/3022026.01/pep/bids
cd ${wd}

subs=`ls -d sub-POMU*`

for s in ${subs}; do 

  echo "Processing ${s}"

	# Step into subjects dir
	cd ${wd}/${s}
	
	# Locate func dirs
	fdir=`ls -d ses-POMVisit*`
	
	for v in ${fdir}; do
	
		# Step into func dir
		echo "Visit: ${v}"
		cd ${wd}/${s}/${v}
		
		if [ -d "eeg" ]; then
		
			echo "EEG folder found"
			
		  cd eeg
			
			vhdrfiles=`ls sub-POMU*.vmrk`
			
			for f in ${vhdrfiles[@]}; do
				
				echo $f
			
				vhdrses=`cat ${f} | grep -o ses-POMVisit`
				
				if [ ${#vhdrses} -eq 0 ]; then
						
					echo "Faulty contents found, editing DataFile"
					sed -i 's/MVisit/_ses-POMVisit/' ${f}
							
				else
						
					echo "DataFile correctly named, doing nothing..."
							
				fi
			
			done
		
		fi
	
	done

done
