function modeldiag = fn_diagmodels(conf)

% dcm.dir = '/project/3011164.01/2_Uitvoer/Data/Processing/MRI/2_Analysis/zscorePmod_6mmSmooth_noGS_inclmotion_3Fcontrasts/3_DCM_models/DCMc_BA4__DCMb_10_11_12_14_16/onestate_Fall';
% dcm.file = 'DCM_onestate_Fall.mat';
if ~exist('spm') %add required paths
    addpath(conf.spmdir);
    spm fmri
    addpath(conf.dcmscriptdir);
    addpath(conf.additionalsdir);
end

FullDirs = strcat(conf.dir.save,'/',conf.DCMpar.BMS.models,'/',conf.DCMpar.GLMmethod)';
diagnostics_output.modelnames = conf.DCMpar.BMS.models(conf.diagnostics.models);
diagnostics_output.subjects = conf.subjects(:,1);

fileID = fopen(fullfile(conf.dir.BMS,conf.DCMpar.GLMmethod,[conf.diagnostics.summarysavename '.txt']),'w');
for m=1:numel(conf.diagnostics.models)
    
    fprintf(['Working on model '  num2str(m) ' out of '  num2str(numel(conf.diagnostics.models)) ' for ' num2str(size(conf.subjects,1)) ' subjects (' num2str(m/numel(conf.diagnostics.models)*100)   ' %%)\n']);
    fprintf(fileID,['Diagnostics model #' num2str(conf.diagnostics.models(m)) ' ('  diagnostics_output.modelnames{m} ')\n']);
    
    for sb=1:size(conf.subjects,1)
        
        sub_modelfile = fullfile(FullDirs{conf.diagnostics.models(m)},conf.subjects{sb,1},['/DCM_',conf.DCMpar.BMS.name,'.mat'] );
        load(sub_modelfile);
        diag = spm_dcm_fmri_check(DCM,conf.diagnostics.suppressdisplay);
        diagnostics_output.diagnostics{m}(sb,:) = diag.diagnostics;              
    end
    
    diagnostics_output.diagsummary(m).mean = mean(diagnostics_output.diagnostics{m});
    diagnostics_output.diagsummary(m).std = std(diagnostics_output.diagnostics{m});
    diagnostics_output.diagsummary(m).min = min(diagnostics_output.diagnostics{m});
    diagnostics_output.diagsummary(m).max = max(diagnostics_output.diagnostics{m});
    
    fprintf(fileID,['---' num2str(diagnostics_output.diagsummary(m).mean(1)) '(' num2str(diagnostics_output.diagsummary(m).std(1))  ') %% Explained variance (mean(std)), range = '  num2str(diagnostics_output.diagsummary(m).min(1)) '-' num2str(diagnostics_output.diagsummary(m).max(1)) ', ' num2str(numel(find(diagnostics_output.diagnostics{m}(:,1) >= 10))) ' out of ' num2str(size(conf.subjects,1)) ' subjects with >= 10%% explained variance\n']);
    fprintf(fileID,['---' num2str(diagnostics_output.diagsummary(m).mean(1)) '(' num2str(diagnostics_output.diagsummary(m).std(1))  ') Largest absolute parameter estimate (mean(std)), range = '  num2str(diagnostics_output.diagsummary(m).min(1)) '-' num2str(diagnostics_output.diagsummary(m).max(1)) ', ' num2str(numel(find(diagnostics_output.diagnostics{m}(:,2) >= 0.1250))) ' out of ' num2str(size(conf.subjects,1)) ' subjects with largest parameter estimate >= 1/8\n']);
    fprintf(fileID,['---' num2str(diagnostics_output.diagsummary(m).mean(1)) '(' num2str(diagnostics_output.diagsummary(m).std(1))  ') Effective number of parameters estimated (mean(std)), range = '  num2str(diagnostics_output.diagsummary(m).min(1)) '-' num2str(diagnostics_output.diagsummary(m).max(1)) '\n']); 
end

fclose(fileID);
save(fullfile(conf.dir.BMS,conf.DCMpar.GLMmethod,conf.diagnostics.summarysavename),'diagnostics_output');
cd(fullfile(conf.dir.BMS,conf.DCMpar.GLMmethod));