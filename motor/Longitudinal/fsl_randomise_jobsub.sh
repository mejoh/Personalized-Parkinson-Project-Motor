#!/bin/bash

# ~/scripts/Personalized-Parkinson-Project-Motor/motor/Longitudinal/fsl_randomise_jobsub.sh

statsdir="/project/3024006.02/Analyses/motor_task/Group/Longitudinal/FSL/stats"
logsdir="/project/3024006.02/Analyses/motor_task/Group/Longitudinal/FSL/logs"
# ses=("delta" "posthoc" "ba" "fu")
ses=("ses-Visit1" "ses-Visit2")
for s in ${ses[@]}; do
	# jobscripts=( $(ls ${statsdir}/*/cmd_rand_${s}*.txt) )
	jobscripts=( $(ls ${statsdir}/*/by_session/${s}/cmd_rand_*.txt) )
	for(( i=0; i<${#jobscripts[@]}; i++ )); do

		JNAME=`basename -- "${jobscripts[i]}" .txt`

		qsub \
			-o ${logsdir} \
			-e ${logsdir} \
			-N "rand_${s}_${JNAME}" \
			-l "nodes=1:ppn=4,walltime=12:00:00,mem=12gb" \
			${jobscripts[i]}

	done
done
