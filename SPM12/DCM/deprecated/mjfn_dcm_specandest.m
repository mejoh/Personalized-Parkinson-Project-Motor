function mjfn_dcm_specandest(conf)

%% Specify and estimate models
if ~exist('spm') %add required paths
    addpath(conf.spmdir);
    spm fmri
    addpath(conf.dcmscriptdir);
    addpath(conf.additionalsdir);
end

for b = 1:size(conf.DCMpar.modcontodo,1)
    conf.DCMpar.modcon(:,:,2) = conf.DCMpar.modcontodo{b};
    DCMc_name = conf.DCMC_models.names{cell2mat(cellfun(@(x) isequal(x,conf.DCMpar.inputconnect), conf.DCMC_models.options, 'UniformOutput', false))};
    conf.DCMpar.modelname = ['DCMc_' DCMc_name '__DCMb_' conf.DCMpar.modconnames{b}];
    mjfnpf_dcm_specify_DCM(conf);
    pf_dcm_estimate_DCM(conf);
    fnpf_dcm_addillus(conf); %create image of tested model
end
end