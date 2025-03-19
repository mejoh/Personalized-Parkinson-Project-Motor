#!/bin/bash

wd=/project/3022026.01/pep/download_2023_07_25
cd ${wd}

subs=`ls -d POMU*`

# Loop over subjects
for s in ${subs}; do 

	echo "Processing ${s}"

	# Step into subjects dir
	cd ${wd}/${s}
	
	# Locate func dirs
	fdir=`ls -d Visit*.MRI.Func`

	# Loop over func dirs
	for v in ${fdir}; do

		# Step into func dir
		cd ${wd}/${s}/${v}
		
		# Locate pseudonym folder
		pseudonymdir=`ls -d sub-POMU*`
		
		# ----------------------------------------------------------- #
		# - Fix potentially misnamed pseudonym directory ------------ #
		# ----------------------------------------------------------- #
		
		# Define new name
		name_fix=sub-${s}
		
		if [ ${#pseudonymdir} -lt 24 ]; then 
		
			# Fix name of folder
			echo "${pseudonymdir}: incorrect length"
			echo "Renaming to ${name_fix}"
			mv ${pseudonymdir} ${name_fix}
			
		else
		
			echo "${pseudonymdir}: correct length"
		
		fi
		
		# ----------------------------------------------------------- #
		# - Fix potentially incorrect participants.tsv information -- #
		# ----------------------------------------------------------- #
		
		# Fix name of participants.tsv file
		tsvses=`cat participants.tsv | grep MVisit | awk '{print $2}' | cut -c -12`
		
		if [ "${tsvses}" != "ses-POMVisit" ]; then
		
			echo "Incorrect participants.tsv session label, editing"
			sed -i 's/MVisit/\tses-POMVisit/' participants.tsv
			cat participants.tsv
		
		else
		
			echo "Correct participants.tsv session label identified"
		
		fi

		# Step into the fixed folder
		cd ${wd}/${s}/${v}/${name_fix}
		
		# Step into visit folder
		sesdir=`ls -d ses-POM*`
		cd ${wd}/${s}/${v}/${name_fix}/${sesdir}
		
		# ----------------------------------------------------------- #
		# - Fix potentially incorrect file names -------------------- #
		# ----------------------------------------------------------- #
		
		# Loop over modalities
		for mod in "func" "beh" "eeg"; do
		
			echo "Checking modality: ${mod}"

			if [ ! -d "${mod}" ]; then

				echo "${mod}-folder does not exist, continuing..."
				continue

			fi

			# Step into modality folder
			cd ${mod}

				# Locate all files
				files=`ls sub-POMU*`
				
				# Define correct name of file
				corrected="sub-${s}_${sesdir}"

				# Loop over files
				for f in ${files[@]}; do
				
					echo "File: ${f}"
				
					findlabel=`echo ${f} | grep -o ses-POMVisit`
					if [ ${#findlabel} -eq 0 ]; then
					
						echo "ses-POMVisit label missing, renaming file"
						oldname=`echo ${f}`
						fpart=`echo ${oldname} | grep -o '\_.*'`
						newname=${corrected}${fpart}
						echo "${newname}"
						mv ${f} ${newname}
						
					else
					
						echo "Label found, doing nothing..."
					
					fi
					
					# ----------------------------------------------------------- #
					# - Fix potentially incorrect EEG VHDR/VMRK contents -------- #
					# ----------------------------------------------------------- #
					# DataFile and MarkerFile fields of .vhdr and .vmrk files have also
					# been subjected to renaming and need to be fixed.
					
					# Find .vhdr file extensions
				  vhdrext=`echo ${f} | grep '.vhdr'`
					
					if [ ${#vhdrext} -gt 0 ]; then
						
						echo "VHDR file: checking contents..."
						
						# Test whether DataFile and MarkerFile have 'ses-POMVisit' in their names
						# If not, edit.
						vhdrses=`cat ${f} | grep -o ses-POMVisit`
						
						if [ ${#vhdrses} -eq 0 ]; then
						
							echo "Faulty contents found, editing DataFile and MarkerFile..."
							sed -i 's/MVisit/_ses-POMVisit/' ${f}
							
						else
						
							echo "DataFile and MarkerFile correctly named, doing nothing..."
							
						fi
						
					fi
					
					# Find .vmrk file extensions
				  vmrkext=`echo ${f} | grep '.vmrk'`
					
					if [ ${#vmrkext} -gt 0 ]; then
						
						echo "VMRK file: checking contents..."
						
						# Test whether DataFile and MarkerFile have 'ses-POMVisit' in their names
						# If not, edit.
						vmrkses=`cat ${f} | grep -o ses-POMVisit`
						
						if [ ${#vmrkses} -eq 0 ]; then
						
							echo "Faulty contents found, editing DataFile and MarkerFile..."
							sed -i 's/MVisit/_ses-POMVisit/' ${f}
							
						else
						
							echo "DataFile and MarkerFile correctly named, doing nothing..."
							
						fi
						
					fi

				done

			# Step back out and continue with other modalities...
			cd ../

		done

	done

done

