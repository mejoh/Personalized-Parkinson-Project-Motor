#!/bin/bash

#qsub -o /project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/logs -e /project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/logs -N 3dLMEr -l 'nodes=1:ppn=24,walltime=10:00:00,mem=20gb' ~/scripts/Personalized-Parkinson-Project-Motor/motor/motor_afni_3dLME.sh

#analysis=disease
analysis=subtype
#analysis=severity

cd /project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/3dLMEr_$analysis
nohup tcsh -x 3dLMEr_$analysis.txt |& tee diary.txt &
