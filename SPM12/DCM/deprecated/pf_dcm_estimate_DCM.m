function pf_dcm_estimate_DCM(conf)
%
% Estimate the specified DCM files for all subjects, according to your 
% configuration.
%
% ©Michiel Dirkx, 2014
% $ParkFunC

%% Loop through all subjects

fprintf('\n%s\n',['% ----- Estimating DCM model "' conf.DCMpar.modelname '" ----- %'])

nSub        =   length(conf.sub.name);

for i = 1:nSub
    
    CurSub      = conf.sub.name{i};
    fprintf('\n%s\n',['Working on ' CurSub]);
    CurDCMdir   = fullfile(conf.dir.save,conf.DCMpar.modelname,conf.DCMpar.GLMmethod,CurSub);
    
    spm_dcm_estimate(fullfile(CurDCMdir,['DCM_' conf.DCMpar.GLMmethod '.mat']));
    
end