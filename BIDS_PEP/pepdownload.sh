#qsub -I -l 'walltime=72:00:00,mem=40gb'
# qsub -o /project/3022026.01/pep/logs -e /project/3022026.01/pep/logs -N pepdownload-pit -l 'walltime=72:00:00,mem=30gb' /home/sysneu/marjoh/scripts/pepdownload.sh

module unload apptainer; module load apptainer

accessdoc=/project/3022026.01/pep/ColumnAccess.txt
token=/home/sysneu/marjoh/PEP/OAuthToken_Download.json
nrupdates=4 	# 4 is pretty much the max for walltime

# Check access
apptainer run \
	/project/3022026.01/pep/pepcli/pep-client-ppp.simg /app/pepcli \
	--client-working-directory /config \
	--oauth-token $token \
	query column-access > $accessdoc

#-C Covid -C DondersMRI -C InternalDataFeedbackMRI
#-c Pit.Visit1.MRI.Anat -c Pit.Visit1.MRI.Func -c Pit.Visit3.MRI.Anat -c Pit.Visit3.MRI.Func
#-c Visit1.MRI.Anat -c Visit1.MRI.Func -c Visit3.MRI.Anat -c Visit3.MRI.Func

# Start the download
	# All
outputfolder=/project/3022026.01/pep/test
apptainer run \
	/project/3022026.01/pep/pepcli/pep-client-ppp.simg /app/pepcli \
	--client-working-directory /config \
	--oauth-token $token \
	pull -P all-ppp -C DondersMRI -C Covid -C DD_InflammationMarkers_Blood -C DD_InflammationMarkers_Blood_Date -C DD_InflammationMarkers_CSF_RewardTask -C DD_Johansson2023_ClinicalSubtyping -C DD_plasma_cfDNA_MedSeq -C POMFolUpYearly \
	-o $outputfolder

# Restart the download after it automatically stops (12h)
# The --assume-pristine argument can be used to override errors resulting from detection of local changes
for i in `seq $nrupdates`; do
echo "Running update nr $i"
apptainer run \
	/project/3022026.01/pep/pepcli/pep-client-ppp.simg /app/pepcli \
	--client-working-directory /config \
	--oauth-token $token \
	pull \
	-o $outputfolder \
	--update --resume --assume-pristine
sleep 30
done



