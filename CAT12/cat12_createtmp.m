cd /project/3024006.02/Analyses/CAT12/shooting_template/mri/
Algorithm = 'SHOOT';

if contains(Algorithm, 'DARTEL')
    % Dartel: Approx 8h
    JobFile = {'/home/sysneu/marjoh/scripts/Personalized-Parkinson-Project-Motor/motor/motor_cat12_createtmp_DARTEL.m'};
else
    % Shooting: Approx 20h
    JobFile = {'/home/sysneu/marjoh/scripts/Personalized-Parkinson-Project-Motor/motor/motor_cat12_createtmp_SHOOT.m'};
end

% spm_jobman('run', JobFile);
qsubfeval('spm_jobman', 'run', JobFile, 'memreq',10*1024^3,'timreq',47.9*60*60);