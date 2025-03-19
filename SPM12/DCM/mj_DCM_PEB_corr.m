function mj_DCM_PEB_corr(conf)

%--------------------------------------------------------------------------
% mj_DCM_PEB_corr
% 20241126 - Martin E. Johansson
%
% Compute correlations between individual differences in effective
% connectivity and clinical/behavioral scores. The following questions are
% addressed:
% - What is the overall association between effective connectivity and
% scores?
% - Do associations differ in strength between sessions?
%
% Note that these questions do not address the issue of whether
% longitudinal changes in connectivity correlate with longitudinal changes
% in scores. To address this, you would need to extract parameters and
% analyze elsewhere.
%--------------------------------------------------------------------------

% Select covariates
cID = ismember(conf.PEB_corr.covars.Properties.VariableNames, conf.PEB_corr.covars_names1);
X_T0 = conf.PEB_corr.covars(:,cID);
cID = ismember(conf.PEB_corr.covars.Properties.VariableNames, conf.PEB_corr.covars_names2);
X_T1 = conf.PEB_corr.covars(:,cID);

% Load GCMs
dcmtype = [conf.PEB_corr.dcmname,'_PEB-', num2str(conf.PEB_corr.peb)];
gcms_mat                   = cellstr(spm_select('FPList',conf.PEB_corr.gcmdir,['GCM_ses-.*',dcmtype,'.mat']));
gcms_txt                   = cellstr(spm_select('FPList',conf.PEB_corr.gcmdir,['GCM_ses-.*',dcmtype,'.txt']));
GCM1_pre_mat     = gcms_mat(contains(gcms_mat,conf.PEB_corr.sesnames{1}));                   % Patients, T0
GCM1_pre_txt = readtable(char(gcms_txt(contains(gcms_txt,conf.PEB_corr.sesnames{1}))));  % Patients, T0
GCM1_post_mat    = gcms_mat(contains(gcms_mat,conf.PEB_corr.sesnames{2}));                   % Patients, T1
GCM1_post_txt= readtable(char(gcms_txt(contains(gcms_txt,conf.PEB_corr.sesnames{2}))));  % Patients, T1

% Design matrix building blocks per group and session
pseudos = GCM1_pre_txt.pseudonym;
pID = contains(X_T0.pseudonym, pseudos);
X_G1_pre = X_T0(pID,:);
pseudos = GCM1_post_txt.pseudonym;
pID = contains(X_T1.pseudonym, pseudos);
X_G1_post = X_T1(pID,:);

% Deal with missing values
X_G1_pre_rmm_i = rmmissing(X_G1_pre);
X_G1_post_rmm_i = rmmissing(X_G1_post);
pseudonym_intersect = intersect(X_G1_pre_rmm_i.pseudonym, X_G1_post_rmm_i.pseudonym);
X_G1_pre_rmm = X_G1_pre_rmm_i(contains(X_G1_pre_rmm_i.pseudonym,pseudonym_intersect),:);
X_G1_post_rmm = X_G1_post_rmm_i(contains(X_G1_post_rmm_i.pseudonym,pseudonym_intersect),:);
gcm_full_list = [GCM1_pre_txt;GCM1_post_txt];
gcm_rmm_idx = contains(gcm_full_list.pseudonym,pseudonym_intersect);

%% Second-level PEB: option 1
% Is there an overall relationship between variables?
% Analysis is done in two levels
% 1. Estimation of DCMs
% 2. PEB to test brain-clinical associations, focusing on relationships
% between between-subject sources of variability after regressing out
% within-subject variability.
% Intentionally allow each predictor of interest to be time-varying.
% How to deal with separation of within- and between-subject variability?
%  - Time as covariate to soak up within-subject variance in both
%  connectivity and clinical scores. The clinical score will be specific to
%  between-subject variability, i.e. the correlation between mean
%  connectivity and mean score
%  - Time-invariant baseline scores as additional predictor to ensure
%  specificity of time-varying clinical score. PROBLEM: Does not ensure
%  specificity towards within-subject differences in connectivity, which
%  would require an additional covariate of baseline connectivity. This is
%  not feasible in a PEB scheme and we therefore omit this option here.

% PEB on both sessions
% Specify GCM
GCM = [spm_dcm_load(char(GCM1_pre_mat))
    spm_dcm_load(char(GCM1_post_mat))];
GCM = GCM(gcm_rmm_idx);
% save(fullfile(conf.PEB_corr.gcmdir,'GMC_corr_OP1.mat'),'GCM')
% Design matrix
covars = vertcat(table2array(X_G1_pre_rmm(:,2:end)),table2array(X_G1_post_rmm(:,2:end)));
covars = covars - mean(covars);
X_mean = ones(length(covars),1);
X_time = [-ones(size(X_G1_pre_rmm,1),1); ones(size(X_G1_post_rmm,1),1)];
X_time = X_time - mean(X_time);
X_OP1 = [X_mean X_time covars];

% % Subset a group
% idx = [1 2 3 4 5 6 7 8 9 10];
% GCM = GCM(idx,:);
% X_OP1 = X_OP1(idx,:);
% %

conf.PEB_corr.M.X = X_OP1;

% PEB
if conf.PEB_corr.per_field
    % PEB per field
    for i = 1:numel(conf.PEB_corr.field)
        PEB = spm_dcm_peb(GCM, conf.PEB_corr.M, cellstr(conf.PEB_corr.field{i}));
        save(fullfile(conf.PEB_corr.pebdir,['PEB_corr_OP1-field',conf.PEB_corr.field{i}]),'PEB');
        BMA = spm_dcm_peb_bmc(PEB);
        save(fullfile(conf.PEB_corr.pebdir,['PEB_corr_OP1-field',conf.PEB_corr.field{i},'_BMA']),'BMA');
        % spm_dcm_peb_review(BMA,GCM);
    end
else
    % PEB for all fields simultaneously
    PEB = spm_dcm_peb(GCM, conf.PEB_corr.M, conf.PEB_corr.field);
    save(fullfile(conf.PEB_corr.pebdir,['PEB_corr_OP1-field',cell2mat(conf.PEB_corr.field)]),'PEB');
    BMA = spm_dcm_peb_bmc(PEB);
    save(fullfile(conf.PEB_corr.pebdir,['PEB_corr_OP1-field',cell2mat(conf.PEB_corr.field),'_BMA']),'BMA');
end

%% Second-level PEB: option 2
% Is there a relationship between variables within each session, and does
% it differ between sessions?
% Analysis is done in three levels
% 1. Estimation of DCMs
% 2. PEB to test brain-clinical associations for each session, separately
% 3. PEB-of-PEBs to test for differences in associations between sessions

% PEB per session, followed by PEB-of-PEBs

% Group 1
% Specify GCMs
GCM1 = spm_dcm_load(char(GCM1_pre_mat));
gcm1_rmm_idx = contains(GCM1_pre_txt.pseudonym,pseudonym_intersect);
GCM1 = GCM1(gcm1_rmm_idx,:);
% save(fullfile(conf.PEB_corr.gcmdir,'GMC_corr_OP2_1.mat'),'GCM1')
% 2nd-level design matrix
X1_mean = ones(size(GCM1,1),1);
covars1 = table2array(X_G1_pre_rmm(:,2:end));
covars1 = covars1 - mean(covars1);
X1_OP2 = [X1_mean covars1];
    
% Group 2
% Specify GCMs
GCM2 = spm_dcm_load(char(GCM1_post_mat));
gcm2_rmm_idx = contains(GCM1_post_txt.pseudonym,pseudonym_intersect);
GCM2 = GCM2(gcm2_rmm_idx,:);
% save(fullfile(conf.PEB_corr.gcmdir,'GMC_corr_OP2_2.mat'),'GCM2')
% 2nd-level design matrix
X2_mean = ones(size(GCM2,1),1);
covars2 = table2array(X_G1_post_rmm(:,2:end));
covars2 = covars2 - mean(covars2);
X2_OP2 = [X2_mean covars2];

% % Subset a group
% idx = [1 2 3 4 5];
% GCM2 = GCM2(idx,:);
% X2_OP2 = X2_OP2(idx,:);
% %

% 3rd-level design matrix
X_OP2_3 = [1 -1; 1 1];

% PEB
if conf.PEB_corr.per_field
    % PEB per field
    for i = 1:numel(conf.PEB_corr.field)
 
        conf.PEB_corr.M.X = X1_OP2;
        PEB1 = spm_dcm_peb(GCM1, conf.PEB_corr.M, cellstr(conf.PEB_corr.field{i}));
        save(fullfile(conf.PEB_corr.pebdir,['PEB_corr_OP2-1-field',conf.PEB_corr.field{i}]),'PEB1');
        BMA1 = spm_dcm_peb_bmc(PEB1);
        save(fullfile(conf.PEB_corr.pebdir,['PEB_corr_OP2-1-field',conf.PEB_corr.field{i},'_BMA']),'BMA1');
    %     spm_dcm_peb_review(BMA1,GCM1);
    
        conf.PEB_corr.M.X = X2_OP2;
        PEB2 = spm_dcm_peb(GCM2, conf.PEB_corr.M, cellstr(conf.PEB_corr.field{i}));
        save(fullfile(conf.PEB_corr.pebdir,['PEB_corr_OP2-2-field',conf.PEB_corr.field{i}]),'PEB2');
        BMA2 = spm_dcm_peb_bmc(PEB2);
        save(fullfile(conf.PEB_corr.pebdir,['PEB_corr_OP2-2-field',conf.PEB_corr.field{i},'_BMA']),'BMA2');
    %     spm_dcm_peb_review(BMA2,GCM2);
    
        % Third level
        PEBs = {PEB1; PEB2};
        PEB3 = spm_dcm_peb(PEBs, X_OP2_3);
        save(fullfile(conf.PEB_corr.pebdir,['PEB_corr_OP2-3-field',conf.PEB_corr.field{i}]),'PEB3');
        BMA3 = spm_dcm_peb_bmc(PEB3);
        save(fullfile(conf.PEB_corr.pebdir,['PEB_corr_OP2-3-field',conf.PEB_corr.field{i},'_BMA']),'BMA3');
    %     spm_dcm_peb_review(BMA3);

    end
else
    % PEB for both all, simultaneously
    conf.PEB_corr.M.X = X1_OP2;
    PEB1 = spm_dcm_peb(GCM1, conf.PEB_corr.M, conf.PEB_corr.field);
    save(fullfile(conf.PEB_corr.pebdir,['PEB_corr_OP2-1-field',cell2mat(conf.PEB_corr.field)]),'PEB1');
    BMA1 = spm_dcm_peb_bmc(PEB1);
    save(fullfile(conf.PEB_corr.pebdir,['PEB_corr_OP2-1-field',cell2mat(conf.PEB_corr.field),'_BMA']),'BMA1');

    conf.PEB_corr.M.X = X2_OP2;
    PEB2 = spm_dcm_peb(GCM2, conf.PEB_corr.M, conf.PEB_corr.field);
    save(fullfile(conf.PEB_corr.pebdir,['PEB_corr_OP2-2-field',cell2mat(conf.PEB_corr.field)]),'PEB2');
    BMA2 = spm_dcm_peb_bmc(PEB2);
    save(fullfile(conf.PEB_corr.pebdir,['PEB_corr_OP2-2-field',cell2mat(conf.PEB_corr.field),'_BMA']),'BMA2');

    PEBs = {PEB1; PEB2};
    PEB3 = spm_dcm_peb(PEBs, X_OP2_3);
    save(fullfile(conf.PEB_corr.pebdir,['PEB_corr_OP2-3-field',cell2mat(conf.PEB_corr.field)]),'PEB3');
    BMA3 = spm_dcm_peb_bmc(PEB3);
    save(fullfile(conf.PEB_corr.pebdir,['PEB_corr_OP2-3-field',cell2mat(conf.PEB_corr.field),'_BMA']),'BMA3');
end

%% Second-level PEB: option 3
% Is there a relationship between variables within each session?
% The difference with option 2 is that the sessions are defined by their
% own list of subjects (i.e., not complete-case).

% Group 1
% Specify GCMs
GCM1 = spm_dcm_load(char(GCM1_pre_mat));
gcm1_rmm_idx = contains(GCM1_pre_txt.pseudonym,X_G1_pre_rmm_i.pseudonym);
GCM1 = GCM1(gcm1_rmm_idx,:);
% save(fullfile(conf.PEB_corr.gcmdir,'GMC_corr_OP3_1.mat'),'GCM1')
% 2nd-level design matrix
X1_mean = ones(size(GCM1,1),1);
covars1 = table2array(X_G1_pre_rmm_i(:,2:end));
covars1 = covars1 - mean(covars1);
X1_OP3 = [X1_mean covars1];
    
% Group 2
% Specify GCMs
GCM2 = spm_dcm_load(char(GCM1_post_mat));
gcm2_rmm_idx = contains(GCM1_post_txt.pseudonym,X_G1_post_rmm_i.pseudonym);
GCM2 = GCM2(gcm2_rmm_idx,:);
% save(fullfile(conf.PEB_corr.gcmdir,'GMC_corr_OP3_2.mat'),'GCM2')
% 2nd-level design matrix
X2_mean = ones(size(GCM2,1),1);
covars2 = table2array(X_G1_post_rmm_i(:,2:end));
covars2 = covars2 - mean(covars2);
X2_OP3 = [X2_mean covars2];

% PEB
if conf.PEB_corr.per_field
    % PEB per field
    for i = 1:numel(conf.PEB_corr.field)
 
        conf.PEB_corr.M.X = X1_OP3;
        PEB1 = spm_dcm_peb(GCM1, conf.PEB_corr.M, cellstr(conf.PEB_corr.field{i}));
        save(fullfile(conf.PEB_corr.pebdir,['PEB_corr_OP3-1-field',conf.PEB_corr.field{i}]),'PEB1');
        BMA1 = spm_dcm_peb_bmc(PEB1);
        save(fullfile(conf.PEB_corr.pebdir,['PEB_corr_OP3-1-field',conf.PEB_corr.field{i},'_BMA']),'BMA1');
    %     spm_dcm_peb_review(BMA1,GCM1);
    
        conf.PEB_corr.M.X = X2_OP3;
        PEB2 = spm_dcm_peb(GCM2, conf.PEB_corr.M, cellstr(conf.PEB_corr.field{i}));
        save(fullfile(conf.PEB_corr.pebdir,['PEB_corr_OP3-2-field',conf.PEB_corr.field{i}]),'PEB2');
        BMA2 = spm_dcm_peb_bmc(PEB2);
        save(fullfile(conf.PEB_corr.pebdir,['PEB_corr_OP3-2-field',conf.PEB_corr.field{i},'_BMA']),'BMA2');
    %     spm_dcm_peb_review(BMA2,GCM2);

    end
else
    % PEB for all, simultaneously
    conf.PEB_corr.M.X = X1_OP3;
    PEB1 = spm_dcm_peb(GCM1, conf.PEB_corr.M, conf.PEB_corr.field);
    save(fullfile(conf.PEB_corr.pebdir,['PEB_corr_OP3-1-field',cell2mat(conf.PEB_corr.field)]),'PEB1');
    BMA1 = spm_dcm_peb_bmc(PEB1);
    save(fullfile(conf.PEB_corr.pebdir,['PEB_corr_OP3-1-field',cell2mat(conf.PEB_corr.field),'_BMA']),'BMA1');

    conf.PEB_corr.M.X = X2_OP3;
    PEB2 = spm_dcm_peb(GCM2, conf.PEB_corr.M, conf.PEB_corr.field);
    save(fullfile(conf.PEB_corr.pebdir,['PEB_corr_OP3-2-field',cell2mat(conf.PEB_corr.field)]),'PEB2');
    BMA2 = spm_dcm_peb_bmc(PEB2);
    save(fullfile(conf.PEB_corr.pebdir,['PEB_corr_OP3-2-field',cell2mat(conf.PEB_corr.field),'_BMA']),'BMA2');
end

%% Compare free energy between option 1 and option 2. (not meaningful here)
% % % % Option with highest free energy performs best
% % % FE_PEB = PEB.F - PEB3.F;
% % % if FE_PEB > 0
% % %     msg = '>>> Winning approach: OP1\n';
% % % else
% % %     msg = '>>> Winning approach: OP2\n';
% % % end
% % % fprintf('>>> Comparing free energy between OP1 (%f) and OP2 (%f)\n',PEB.F,PEB3.F)
% % % fprintf('>>> Difference: %f\n', FE_PEB)
% % % fprintf(msg)
