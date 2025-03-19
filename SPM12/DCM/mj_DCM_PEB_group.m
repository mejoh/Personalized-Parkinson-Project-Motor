function mj_DCM_PEB_group(conf)

%--------------------------------------------------------------------------
% mj_DCM_PEB_group
% 20241125 - Martin E. Johansson
%
% Hierarchical design for comparing effects of time (baseline, follow-up)
% across groups (healthy, patient). The analysis is done in two different
% ways, both equivalent to a 2-way RM-ANOVA on complete case data:
%
% Option 1: 2-level hierarchy. Fits time, group and interaction effects 
% in a single model. Then final PEB has at least 4 covariates:
% - Covariate 1: Mean
% - Covariate 2: Group
% - Covariate 3: Time
% - Covariate 4: Group x Time
% - Covariate 5-end: Additional covars
%
% Option 2: 3-level hierarchy. Uses PEBs at the 2nd level to encode time 
% effects separately for each level of group. A PEB-of-PEBs analysis is 
% then conducted at a 3rd level to compare groups. The final 3rd-level 
% PEB has 2 covariates, with parameters corresponding to covariates encoded 
% in 2nd-level PEBs (mean, time, covars).
% - Covariate 1: Commonalities (cov1=mean, cov2=effect of time)
% - Covariate 2: Between-group differences (cov1=effect of group, cov2 = effect of group on effect of time)
% 
% Notes on interpreting parameters from the final PEBs, particularly for
% option 2, where you can't load a sample DCM to define parameter names:

%         FROM
%          C1   C2   C3
% TO  R1 [(1,1)(1,2)(1,3)]
%     R2 [(2,1)(2,2)(2,3)]
%     R3 [(3,1)(3,2)(3,3)]
% 
% Column idx specifies origin. Row idx specifies target. You can verify
% this by opening the DCM GUI and specifying a test DCM with 3 VOIs.
% 
% Example:
% Parameter (1,2) = From R2 to R1
% Parameter (2,1) = From R1 to R2
% Parameter (3,2) = From R2 to R3
% 
% Figuring out what each parameter corresponds to in the final PEB of
% option 2 can be a hassle. See Peter's interpretation of parameter indices
% here: https://www.jiscmail.ac.uk/cgi-bin/wa-jisc.exe?A2=ind2003&L=SPM&P=R39278
%
%--------------------------------------------------------------------------

% Select covariates
X = conf.PEB_group.covars;

% Load GCMs
dcmtype = [conf.PEB_group.dcmname,'_PEB-', num2str(conf.PEB_group.peb)];
gcms_mat                    = cellstr(spm_select('FPList',conf.PEB_group.gcmdir,['GCM_ses-.*',dcmtype,'.mat']));
gcms_txt                    = cellstr(spm_select('FPList',conf.PEB_group.gcmdir,['GCM_ses-.*',dcmtype,'.txt']));
GCM1_pre_mat     = gcms_mat(contains(gcms_mat,conf.PEB_group.sesnames{1}));  % Controls, T0
GCM1_pre_txt = readtable(char(gcms_txt(contains(gcms_txt,conf.PEB_group.sesnames{1}))));  % Controls, T0
GCM1_post_mat    = gcms_mat(contains(gcms_mat,conf.PEB_group.sesnames{2}));  % Controls, T1
GCM1_post_txt= readtable(char(gcms_txt(contains(gcms_txt,conf.PEB_group.sesnames{2}))));  % Controls, T1
GCM2_pre_mat    = gcms_mat(contains(gcms_mat,conf.PEB_group.sesnames{3}));  % Patients, T0
GCM2_pre_txt = readtable(char(gcms_txt(contains(gcms_txt,conf.PEB_group.sesnames{3}))));  % Patients, T0
GCM2_post_mat    = gcms_mat(contains(gcms_mat,conf.PEB_group.sesnames{4}));  % Patients, T1
GCM2_post_txt= readtable(char(gcms_txt(contains(gcms_txt,conf.PEB_group.sesnames{4}))));  % Patients, T1

% Design matrix building blocks per group and session
pseudos = GCM1_pre_txt.pseudonym;
pID = contains(X.pseudonym, pseudos);
X_G1_pre = X(pID,:);
pseudos = GCM1_post_txt.pseudonym;
pID = contains(X.pseudonym, pseudos);
X_G1_post = X(pID,:);
pseudos = GCM2_pre_txt.pseudonym;
pID = contains(X.pseudonym, pseudos);
X_G2_pre = X(pID,:);
pseudos = GCM2_post_txt.pseudonym;
pID = contains(X.pseudonym, pseudos);
X_G2_post = X(pID,:);

% Remove missing values
% X = rmmissing(X);
% Replace missing values
% <in progress>

%% Second-level PEB: Option 1
% Analysis is done in two levels:
% Level 1: Estimation of DCMs
% Level 2: PEB to test group x time effects

% Specify GCM. Be careful with how you concatenate!
GCM = [spm_dcm_load(char(GCM1_pre_mat))
    spm_dcm_load(char(GCM1_post_mat))
    spm_dcm_load(char(GCM2_pre_mat))
    spm_dcm_load(char(GCM2_post_mat))];
% save(fullfile(conf.PEB_group.gcmdir,'GMC_group_OP1.mat'),'GCM')
% Design matrix
covars = vertcat(X_G1_pre,X_G1_post,X_G2_pre,X_G2_post);
covars = table2array(covars(:,2:end));
covars = covars - mean(covars);
X_mean = ones(length(covars),1);
X_group = [-ones(size(X_G1_pre,1),1); -ones(size(X_G1_post,1),1);...
    ones(size(X_G2_pre,1),1); ones(size(X_G2_post,1),1)];
X_group = X_group - mean(X_group);
X_time = [-ones(size(X_G1_pre,1),1); ones(size(X_G1_post,1),1);...
    -ones(size(X_G2_pre,1),1); ones(size(X_G2_post,1),1)];
X_time = X_time - mean(X_time);
X_groupxtime = X_group .* X_time;
X_OP1 = [X_mean X_group X_time X_groupxtime covars];
conf.PEB_group.M.X = X_OP1;

% PEB per field
if conf.PEB_group.per_field
    for i = 1:numel(conf.PEB_group.field)
        PEB = spm_dcm_peb(GCM, conf.PEB_group.M, cellstr(conf.PEB_group.field{i}));
        save(fullfile(conf.PEB_group.pebdir,['PEB_group_OP1-field',conf.PEB_group.field{i}]),'PEB');
        BMA = spm_dcm_peb_bmc(PEB);
        save(fullfile(conf.PEB_group.pebdir,['PEB_group_OP1-field',conf.PEB_group.field{i},'_BMA']),'BMA');
        % spm_dcm_peb_review(BMA,GCM);
    end
end

% PEB for all fields simultaneously
PEB = spm_dcm_peb(GCM, conf.PEB_group.M, conf.PEB_group.field);
save(fullfile(conf.PEB_group.pebdir,['PEB_group_OP1-field',cell2mat(conf.PEB_group.field)]),'PEB');
BMA = spm_dcm_peb_bmc(PEB);
save(fullfile(conf.PEB_group.pebdir,['PEB_group_OP1-field',cell2mat(conf.PEB_group.field),'_BMA']),'BMA');

%% Second-level PEB: Option 2
% Analysis is done in three levels:
% Level 1: Estimation of DCMs
% Level 2: PEB to characterize time effects in each separate group
% Level 3: PEB to test group x time effects

% Group 1
% Specify GCMs
GCM1 = [
    spm_dcm_load(char(GCM1_pre_mat))
    spm_dcm_load(char(GCM1_post_mat))
    ];
% save(fullfile(conf.PEB_group.gcmdir,'GMC_group_OP2_1.mat'),'GCM1')
% 2nd-level design matrix
X1_mean = ones(size(GCM1,1),1);
X1_time = [-ones(size(X_G1_pre,1),1); ones(size(X_G1_post,1),1)];
X1_time = X1_time - mean(X1_time);
covars1 = vertcat(X_G1_pre,X_G1_post);
covars1 = table2array(covars1(:,2:end));
covars1 = covars1 - mean(covars1);
X1_OP2 = [X1_mean X1_time covars1];
    
% Group 2
% Specify GCMs
GCM2 = [
    spm_dcm_load(char(GCM2_pre_mat))
    spm_dcm_load(char(GCM2_post_mat))
    ];
% save(fullfile(conf.PEB_group.gcmdir,'GMC_group_OP2_2.mat'),'GCM2')
% 2nd-level design matrix
X2_mean = ones(size(GCM2,1),1);
X2_time = [-ones(size(X_G2_pre,1),1); ones(size(X_G2_post,1),1)];
X2_time = X2_time - mean(X2_time);
covars2 = vertcat(X_G2_pre,X_G2_post);
covars2 = table2array(covars2(:,2:end));
covars2 = covars2 - mean(covars2);
X2_OP2 = [X2_mean X2_time covars2];

% % Subset a group
% % idx = [1 2 3 6 7 8];
% idx = [1 2 3 4 5 6 7 8 9 10];
% GCM2 = GCM2(idx,:);
% X2_OP2 = X2_OP2(idx,:);
% %

% 3rd-level design matrix
X_OP2_3 = [1 -1; 1 1];

% PEB per field
if conf.PEB_group.per_field
    for i = 1:numel(conf.PEB_group.field)
 
        conf.PEB_group.M.X = X1_OP2;
        PEB1 = spm_dcm_peb(GCM1, conf.PEB_group.M, cellstr(conf.PEB_group.field{i}));
        save(fullfile(conf.PEB_group.pebdir,['PEB_group_OP2-1-field',conf.PEB_group.field{i}]),'PEB1');
        BMA1 = spm_dcm_peb_bmc(PEB1);
        save(fullfile(conf.PEB_group.pebdir,['PEB_group_OP2-1-field',conf.PEB_group.field{i},'_BMA']),'BMA1');
    %     spm_dcm_peb_review(BMA1,GCM1);
    
        conf.PEB_group.M.X = X2_OP2;
        PEB2 = spm_dcm_peb(GCM2, conf.PEB_group.M, cellstr(conf.PEB_group.field{i}));
        save(fullfile(conf.PEB_group.pebdir,['PEB_group_OP2-2-field',conf.PEB_group.field{i}]),'PEB2');
        BMA2 = spm_dcm_peb_bmc(PEB2);
        save(fullfile(conf.PEB_group.pebdir,['PEB_group_OP2-2-field',conf.PEB_group.field{i},'_BMA']),'BMA2');
    %     spm_dcm_peb_review(BMA2,GCM2);
    
        % Third level
        PEBs = {PEB1; PEB2};
        PEB3 = spm_dcm_peb(PEBs, X_OP2_3);
        save(fullfile(conf.PEB_group.pebdir,['PEB_group_OP2-3-field',conf.PEB_group.field{i}]),'PEB3');
        BMA3 = spm_dcm_peb_bmc(PEB3);
        save(fullfile(conf.PEB_group.pebdir,['PEB_group_OP2-3-field',conf.PEB_group.field{i},'_BMA']),'BMA3');
    %     spm_dcm_peb_review(BMA3);
    
    % Compare free energy between option 1 and option 2.
    % Option with highest free energy performs best
    FE_PEB = PEB.F - PEB3.F;
    if FE_PEB > 0
        msg = '>>> Winning approach: OP1\n';
    else
        msg = '>>> Winning approach: OP2\n';
    end
    fprintf('>>> Comparing free energy between OP1 (%f) and OP2 (%f)\n',PEB.F,PEB3.F)
    fprintf('>>> Difference: %f\n', FE_PEB)
    fprintf(msg)

    end
else
    
    % PEB for both fields, simultaneously
    conf.PEB_group.M.X = X1_OP2;
    PEB1 = spm_dcm_peb(GCM1, conf.PEB_group.M, conf.PEB_group.field);
    save(fullfile(conf.PEB_group.pebdir,['PEB_group_OP2-1-field',cell2mat(conf.PEB_group.field)]),'PEB1');
    BMA1 = spm_dcm_peb_bmc(PEB1);
    save(fullfile(conf.PEB_group.pebdir,['PEB_group_OP2-1-field',cell2mat(conf.PEB_group.field),'_BMA']),'BMA1');
    
    conf.PEB_group.M.X = X2_OP2;
    PEB2 = spm_dcm_peb(GCM2, conf.PEB_group.M, conf.PEB_group.field);
    save(fullfile(conf.PEB_group.pebdir,['PEB_group_OP2-2-field',cell2mat(conf.PEB_group.field)]),'PEB2');
    BMA2 = spm_dcm_peb_bmc(PEB2);
    save(fullfile(conf.PEB_group.pebdir,['PEB_group_OP2-2-field',cell2mat(conf.PEB_group.field),'_BMA']),'BMA2');
    
    PEBs = {PEB1; PEB2};
    PEB3 = spm_dcm_peb(PEBs, X_OP2_3);
    save(fullfile(conf.PEB_group.pebdir,['PEB_group_OP2-3-field',cell2mat(conf.PEB_group.field)]),'PEB3');
    BMA3 = spm_dcm_peb_bmc(PEB3);
    save(fullfile(conf.PEB_group.pebdir,['PEB_group_OP2-3-field',cell2mat(conf.PEB_group.field),'_BMA']),'BMA3');
    
    % Compare free energy between option 1 and option 2.
    % Option with highest free energy performs best
    FE_PEB = PEB.F - PEB3.F;
    if FE_PEB > 0
        msg = '>>> Winning approach: OP1\n';
    else
        msg = '>>> Winning approach: OP2\n';
    end
    fprintf('>>> Comparing free energy between OP1 (%f) and OP2 (%f)\n',PEB.F,PEB3.F)
    fprintf('>>> Difference: %f\n', FE_PEB)
    fprintf(msg)
    
end

    

