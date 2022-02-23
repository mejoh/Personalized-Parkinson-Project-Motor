function motor_tfce(spmmat, contrastnr, nrperms)

%     jobfile = {'/home/sysneu/marjoh/scripts/Personalized-Parkinson-Project-Motor/motor/motor_tfce_job.m'};
    jobfile = {spm_file(mfilename('fullpath'), 'suffix','_job', 'ext','.m')};
    inputs = cell(3,1);
%     inputs{1, 1} = {'/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/TFCE/IndependentTtest_TFCE_HcVsOff/Mean_ExtInt/HCgtPD/SPM.mat'}; % spmmat
%     inputs{2, 1} = 2; % Contrast
%     inputs{3, 1} = 100; % Nr permutations
    inputs{1, 1} = {spmmat}; % spmmat
    inputs{2, 1} = contrastnr; % Contrast
    inputs{3, 1} = nrperms; % Nr permutations
    spm('defaults', 'FMRI');
    
    startdir = pwd;
    workdir = extractBefore(char(inputs{1,1}),'SPM.mat');
    
    cd(workdir)
%     spm_jobman('run', jobfile, inputs{:});
    qsubfeval('spm_jobman', 'run', jobfile, inputs{:}, 'memreq', 8*1024^3, 'timreq',8*60*60, 'options', '-o /project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/TFCE/IndependentTtest_TFCE_HcVsOff -e /project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/TFCE/IndependentTtest_TFCE_HcVsOff');
    cd(startdir)

end