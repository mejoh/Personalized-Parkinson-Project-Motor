function fnpf_dcm_addillus(conf)

% pf_dcm_addillus adds a DCM model illustration to your save directory.
% 
% � Michiel Dirkx, 2014
% $ParkFunC

%% Make SaveDir

modelfolder =  fullfile(conf.dir.save,conf.DCMpar.modelname,conf.DCMpar.GLMmethod); % Make model folder to save your visualization
if exist(modelfolder,'dir') ~= 7; mkdir(modelfolder); end

%% Plot Models

fnpf_dcm_illus_models([conf.DCMpar.modelname '_' conf.DCMpar.GLMmethod],conf.DCMpar.fixconnect,conf.DCMpar.inputconnect,...
                     conf.DCMpar.modcon,conf.VOI.VOInames,{''},conf.dsmtx.cond.name,modelfolder)