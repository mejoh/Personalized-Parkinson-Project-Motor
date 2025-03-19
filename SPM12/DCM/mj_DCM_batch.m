function mj_DCM_batch()

%-------------------------------------------------------------------------
% mj_DCM_batch
% 20241121 - Martin E. Johansson
% This wrapper script provides all the functionality necessary to conduct a
% full DCM analyses of functional MRI data from the Personalized Parkinson Project:
%
% Currently implemented fetures:
% - Concatenation of 1st-level analyses
% - VOI extraction and QC
% - Replication of DCM templates (defined manually in the GUI!)
% - DCM estimation
% - Collating and grouping
% - Group comparison (hierarchical PEB)
% - Brain-behavior correlation (hierarchical PEB)
% - Parameter extraction
%
% Note on the structure of the script: The code is written to be modular
% and sequential. That is, different parts can be run independently, but
% they need to be completed in a specific order. Each module has its own
% settings, which are stored in conf.<module>.<setting>. Some settings are
% specified using the same values multiple times throughout the script.
% This is intentional. From experience, using parameters specified for one
% module in the code for another module creates a tangle that makes
% debugging very difficult. Keep this in mind if you add more modules
% to this script and try to follow the current structure.
%-------------------------------------------------------------------------

%% To do
todo.initialize                     = false;
todo.concatenate_sess               = false;
todo.VOI_extraction                 = false;
todo.VOI_qc_01                      = false;
todo.VOI_qc_02                      = false;
todo.DCM_replicate                  = false;
todo.DCM_estimate                   = false;
todo.DCM_collate_stoch              = false;
todo.DCM_complete_cases             = false;
todo.DCM_split_subgroups            = false;
todo.DCM_group_comparison           = false;
todo.DCM_clin_corr                  = false;
todo.DCM_param_extract              = false;
todo.DCM_param_qc                   = false;

%% Top-level settings
conf.spmdir                         = '/project/3024006.02/Users/marjoh/SPM/own_copy/spm12';
conf.dcmscriptdir                   = '/home/sysneu/marjoh/scripts/proj_DCM';
conf.firstleveldir                  = '/project/3024006.02/Analyses/motor_task_dcm_03';
conf.dcmdir                         = fullfile(conf.firstleveldir, 'DCM');
conf.dcmdir_subdirs                 = {'00_VOI';'01_Templates';'02_GCM';'02_GCM_individual';'02_GCMcc';'03_PEB';'04_Param';'concat'};
conf.clinicalfile                   = '/project/3024006.02/Data/matlab/fmri-confs-taskclin_ses-all_groups-all_2024-11-25.csv';
conf.clinicalfile_opts              = detectImportOptions(conf.clinicalfile);
conf.taskfile                       = '/project/3022026.01/pep/bids/derivatives/manipulated_collapsed_merged_motor_task_mri_2023-09-15.csv';
conf.taskfile_opts                  = detectImportOptions(conf.taskfile);
conf.subjects                       = cellstr(spm_select('List',conf.firstleveldir,'dir','sub-POMU.*'));
conf.backend                        = 'slurm';

% Common recurring values
DCMname                             = 'c-full_r-M1-PMd-PUT_spectral';
runPEB                              = false;

%% Initialize DCM analysis
% Create directories for different steps of the DCM analysis

if todo.initialize
    for sb=1:size(conf.dcmdir_subdirs,1)
        mkdir(conf.dcmdir, conf.dcmdir_subdirs{sb,1});
    end
end

%% Concatenate sessions (in progress)
% No settings to specify... yet.

if todo.concatenate_sess
    for sb=1:size(conf.subjects,1)
%         qsubfeval('mj_DCM_concatenatesess',conf.subjects{sb,1},conf,'memreq',1*1073741824,'timreq',1*3600);
        mj_DCM_concatenatesess(conf.subjects{sb,1},conf);
    end
end

%% Volumes-of-interest
% Define VOIs for 1st-level analyses. VOIs are either fixed spheres at
% pre-defined coordinates or moving spheres initiated on pre-defined
% coordinates but moved to local maxima of activation patterns.

% Run on session-specific or concatenated 1st-level analyses
% conf.VOI.concat                     = false;      % TO DO

% Fixed or moving (i.e., independent or dependent on statistical map)
conf.VOI.fixed_sphere               = true;

% Pre-defined coordinates
conf.VOI.roi_coordinates            = {
    [31 -27 62];   [-31 -27 62];        % Johansson et al., 2024: HC>PD
    [27 -15 6];    [-27 -15 6];         % Johansson et al., 2024: HC>PD
    [17 -47 -20];  [-17 -47 -20];       % Johansson et al., 2024: HC>PD
    [29 -5 56];    [-29 -5 56];         % Johansson et al., 2024: Center of gravity of 6a clusters
    [15 15 68];    [-15 15 68];         % Johansson et al., 2024: Center of gravity of 6ma clusters
    [9 -61 54];    [-9 -61 54]};        % Johansson et al., 2024: Center of gravity of 7Am clusters 

% Labels
conf.VOI.roi_labs                   = {
    'R_M1';       'L_M1'
    'R_PUT';      'L_PUT'
    'R_CB';       'L_CB'
    'R_PMd';      'L_PMd'
    'R_SMA';      'L_SMA'
    'R_SPL';      'L_SPL'};

% Size of VOIs (can afford to make them big given that we're using a
% restriction mask)
conf.VOI.roi_inner_radius           = [
    6;            6
    10;           10
    8;            8
    6;            6
    6;            6
    6;            6];

% Mask that restricts the boundaries of VOIs
conf.VOI.restriction_mask           = {
    '/project/3024006.02/Analyses/motor_task/Group/Longitudinal/Masks/bi_brady_clincorr_bg_mask_cropped.nii,1'};

% --Moving VOI-specific settings--
% Contrast map to threshold (Cue=2, Selection=3)
conf.VOI.roi_contrasts              = [
    2;            2
    3;            3
    2;            2
    3;            3
    3;            3
    3;            3];

% Cycle through p-thresholds until a cluster is detected
conf.VOI.pthresh                    = [0.001; 0.01; 0.05; 0.1];

if todo.VOI_extraction
    for sb=1:size(conf.subjects,1)
        qsubfeval('mj_VOI_extraction',conf.subjects{sb,1},conf,'memreq',3*1073741824,'timreq',0.5*3600,'backend',conf.backend);
%                 mj_VOI_extraction(conf.subjects{sb,1},conf);
    end
end

% Quality control (relies on the BrainSlicer toolbox)
% https://www.fil.ion.ucl.ac.uk/spm/ext/#BrainSlicer

% Background image and slices in the z-direction
conf.VOI.mni_template               = '/project/3024006.02/templates/templateflow/tpl-MNI152NLin6Asym_res-02_desc-brain_T1w_resampled.nii';
conf.VOI.roi_z_slices               = [
    67;67 
    37;37 
    26;26 
    64;64 
    70;70
    63;63];    % For QC purposes. Derived manually from fsleyes based on coordinates above (voxel locations)

if todo.VOI_qc_01
    for sb=1:size(conf.subjects,1)
        % Slicer does not seem to work appropriately within the slurm job
        % submission environment. Tries to get screenresolution, but the
        % environment does not support a display: 
        % https://stackoverflow.com/questions/21343529/all-my-java-applications-now-throw-a-java-awt-headlessexception
%           qsubfeval('mj_DCM_VOI_qc',conf.subjects{sb,1},conf,'memreq',1*1073741824,'timreq',0.5*3600,'backend',conf.backend);
        mj_DCM_VOI_qc(conf.subjects{sb,1},conf)
    end
end

if todo.VOI_qc_02
    % Collate .png files to single report
% % %     for ll = 1:size(conf.VOI.roi_labs)
% % %         pngfiles = cellstr(spm_select('FPListRec', fullfile(conf.firstleveldir), ['slicer_VOI_',conf.VOI.roi_labs{ll,1},'.png']));
% % %         collated_img = [];
% % %         for ii = 1:size(pngfiles,1)
% % %             img = imread(pngfiles{ii,1});
% % %             collated_img = [collated_img;img];
% % %         end
% % %         imwrite(collated_img, fullfile(conf.dcmdir,'00_VOI',['VOI_', conf.VOI.roi_labs{ll,1}, '.png']), 'PNG')
% % %     end
    % For each subject, check whether VOIs exist or not
    VOI_QC_table_files  = cellstr(spm_select('FPListRec',conf.firstleveldir, 'VOI_QC_exist.csv'));
    VOI_QC_table        = table();
    for ff = 1:size(VOI_QC_table_files)
        tmp = readtable(VOI_QC_table_files{ff,1});
        VOI_QC_table = vertcat(VOI_QC_table,tmp);
    end
    writetable(VOI_QC_table, fullfile(conf.dcmdir,'00_VOI','VOI_QC_exist.csv'));
end

%% DCM specification (MANUAL!)

% MANUAL STEP: 
% Using the 1st-level output of a single subject and session, specify a DCM
% with all relevant connections turned on. The anatomy of the DCM will
% differ depending on your needs. I would suggest starting with a DCM that
% contains, at least, the M1-PMd-PUT VOIs and the following connections:
% A: Everything.
% B: Selection-related modulation of all A connections (don't use this
% modulation as an input!)
% C: Cues go as input into every node (don't use cues on any fixed
% connection!).
% Move the specified DCMs to the template directory so that it can be replicated:
% /project/3024006.02/Analyses/motor_task_dcm_02/DCM/01_DCMtemplates

%% Replicate DCMs across subjects and sessions
conf.replicate.outputdir            = {fullfile(conf.dcmdir,'02_GCM')};
conf.replicate.tmpltdir             = fullfile(conf.dcmdir,'01_Templates');
conf.replicate.model_name           = DCMname;  % Name of the template you wish to replicate
conf.replicate.fulldcm              = {fullfile(conf.replicate.tmpltdir,['DCM_', conf.replicate.model_name, '.mat'])};
conf.replicate.altdcm               = ''; % A set of alternative DCMs
conf.replicate.VOI_labs             = {'M1';'PMd';'PUT'};
conf.replicate.spmmats              = cellstr(spm_select('FPListRec', fullfile(conf.firstleveldir,conf.subjects), 'SPM.mat'));
opts                                = conf.taskfile_opts;
opts.SelectedVariableNames          = ["pseudonym","Timepoint","RespondingHand"];
conf.replicate.resphand             = readtable(conf.taskfile,opts);
conf.replicate.resphand             = unique(conf.replicate.resphand,'rows');

if todo.DCM_replicate
    for sb=1:size(conf.subjects,1)
        qsubfeval('mj_DCM_replicate_model',conf.subjects{sb,1},conf,'memreq',1*1073741824,'timreq',0.5*3600,'backend',conf.backend);
%         mj_DCM_replicate_model(conf.subjects{sb,1}, conf)
    end
end

%% DCM estimation
% Estimation takes place by session to enable hierarchical designs at the
% second-level. For deterministic DCM, it is relatively simple to compute
% the PEBs necessary for such designs. Stochastic DCMs require so much
% computational time that estimating them per session is not possible.
% Therefore, stochastic DCMs are estimated by subject and later collated
% into GCMs.
%
% Resource estimation:
% Deterministic, no PEB, 3-region model: n=300 takes ~2h and uses <5gb
% Deterministic, with PEB, 3-region model: n=300 takes ~7h and uses <5gb
% Stochastic, no PEB, 3-region model: n=1 takes 10-15 min
% Stochastic, with PEB, 3-region model: computationally intractable
% Spectral, no PEB, 3-region model (no input): n=300 takes ~25min and uses <5gb
% Spectral, with PEB, 3-region model (no input): n=300 takes ~? and uses <5gb
conf.estimate.ses.names             = {'ses-PITVisit1'; 'ses-PITVisit2'; 'ses-POMVisit1'; 'ses-POMVisit3'};
conf.estimate.run_by_ses            = true;   % Run separately for each session. If false, runs per subject
conf.estimate.dcmname               = DCMname;
conf.estimate.peb                   = runPEB;
conf.estimate.outputdir             = {fullfile(conf.dcmdir,'02_GCM')};
if ~conf.estimate.run_by_ses
    conf.estimate.outputdir = {[conf.estimate.outputdir{1},'_individual']};
end

if todo.DCM_estimate
    if conf.estimate.run_by_ses
        for sb=1:size(conf.estimate.ses.names,1)
            qsubfeval('mj_DCM_estimate',conf.estimate.ses.names{sb,1},conf,'memreq',3*1073741824,'timreq',10*3600,'backend',conf.backend);
            %         mj_DCM_estimate(conf.estimate.ses.names{sb,1},conf);
        end
    else
        for sb=1:size(conf.subjects,1)
            qsubfeval('mj_DCM_estimate',conf.subjects{sb,1},conf,'memreq',3*1073741824,'timreq',2*3600,'backend',conf.backend);
            %         mj_DCM_estimate(conf.subjects{sb,1},conf);
        end
    end
end

%% Collate stochastic DCMs by session
if todo.DCM_collate_stoch
    
    conf.DCM_collate_stoch.dcmname       = DCMname;
    conf.DCM_collate_stoch.peb           = runPEB;
    conf.DCM_collate_stoch.ses.names     = {'ses-PITVisit1'; 'ses-PITVisit2'; 'ses-POMVisit1'; 'ses-POMVisit3'};
    conf.DCM_collate_stoch.gcmdir        = '/project/3024006.02/Analyses/motor_task_dcm_03/DCM/02_GCM_individual';
    
    for sb=1:size(conf.estimate.ses.names,1)
        mj_DCM_collate_stochastic(conf.DCM_collate_stoch.ses.names{sb,1},conf);
    end
    
end


%% Derive complete-case GCMs
% Finds participants who have complete baseline and follow-up data.

conf.DCM_complete_cases.gcmdir          = fullfile(conf.dcmdir,'02_GCM');
conf.DCM_complete_cases.outputdir       = fullfile(conf.dcmdir,'02_GCMcc');
conf.DCM_complete_cases.sespairs        = [{'ses-PITVisit1' 'ses-PITVisit2'};{'ses-POMVisit1' 'ses-POMVisit3'}];
conf.DCM_complete_cases.dcmname         = DCMname;
conf.DCM_complete_cases.peb             = runPEB;

if todo.DCM_complete_cases
    
    for sb=1:size(conf.DCM_complete_cases.sespairs,1)
        mj_DCM_complete_cases(conf.DCM_complete_cases.sespairs(sb,:),conf)
    end
    
end

%% Separate subgroups in GCMs
% Separates healthy controls from OFF-state patients in the first session and 
% finds corresponding ON-state patients in the second session

conf.DCM_split_subgroups.gcmdir         = fullfile(conf.dcmdir,'02_GCM');
conf.DCM_split_subgroups.dcmname        = DCMname;
conf.DCM_split_subgroups.peb            = runPEB;
conf.DCM_split_subgroups.sessions       = {'ses-PITVisit1','ses-POMVisit1'};
opts                                    = conf.clinicalfile_opts;
opts.SelectedVariableNames              = ["pseudonym","ParticipantType"];
conf.DCM_split_subgroups.ptype          = readtable(conf.clinicalfile,opts);

if todo.DCM_split_subgroups
    mj_DCM_split_subgroups(conf)
end


%% Reduced models for hypothesis testing

% MANUAL STEP, OPTIONAL: 
% Specify reduced DCMs, corresponding to specific
% hypotheses. This step is optional, as it is also possible to let SPM
% prune parameters to arrive at the most likely model (see below).
% EXAMPLE CODE:
% Get an existing model. We'll use the first subject's DCM as a template
% DCM_full = '/project/3024006.02/Analyses/motor_task_dcm_02/DCM/01_DCMtemplates/DCM_m-full.mat';
% IMPORTANT: If the model has already been estimated, clear out the old priors, or changes to DCM.a,b,c will be ignored
% if isfield(DCM_full,'M')
%     DCM_full = rmfield(DCM_full ,'M');
% end
% Specify candidate models that differ in particular A-matrix connections, e.g.
% DCM_model1 = DCM_full;
% DCM_model1.a(1,2) = 0; % Switching off the connection from region 2 to region 1
% DCM_model2 = DCM_full;
% DCM_model2.a(3,4) = 0; % Switching off the connection from region 4 to region 3
% NOTE: May be worth looking into Freek's fn_DCM_generate_DCMBoptions if
% you anticipate having to create many models.

%% Second-level PEB: group analysis
conf.PEB_group.gcmdir                   = fullfile(conf.dcmdir,'02_GCMcc');
conf.PEB_group.pebdir                   = fullfile(conf.dcmdir,'03_PEB');
conf.PEB_group.sesnames                 = {'ses-PITVisit1'; 'ses-PITVisit2'; 'ses-POMVisit1'; 'ses-POMVisit3'};
opts                                    = conf.clinicalfile_opts;
opts.SelectedVariableNames              = ["pseudonym","Age","Gender"];
conf.PEB_group.covars                   = readtable(conf.clinicalfile,opts);
conf.PEB_group.dcmname                  = DCMname;
conf.PEB_group.peb                      = runPEB;
% Specify PEB model settings
conf.PEB_group.M                        = struct();
conf.PEB_group.M.Q                      = 'all';             % estimate between-subject variability of each connection individually
if contains(DCMname,'spectral')
    conf.PEB_group.field                = {'A'};%,'B','C'};   % select DCM matrices of interest
else
    conf.PEB_group.field                = {'A','B','C'};
end
conf.PEB_group.per_field                = true;       % estimate separate PEBs for each DCM matrix. Peter comments here https://www.jiscmail.ac.uk/cgi-bin/wa-jisc.exe?A2=ind1708&L=SPM&P=R104017 that separating the fields may be better, because you might have a dilution of evidence effect otherwise.

if todo.DCM_group_comparison
    mj_DCM_PEB_group(conf)
end

%% Second-level PEB: correlations
conf.PEB_corr.gcmdir                    = fullfile(conf.dcmdir,'02_GCMcc');
conf.PEB_corr.pebdir                    = fullfile(conf.dcmdir,'03_PEB');
conf.PEB_corr.sesnames                  = {'ses-POMVisit1'; 'ses-POMVisit3'};
conf.PEB_corr.covars                    = readtable(conf.clinicalfile);
conf.PEB_corr.covars_names1             = {'pseudonym', 'Up3OnBradySum_T0_imp'};%, 'Age', 'Gender', 'NpsEducYears','RespHandIsDominant_T0'};
conf.PEB_corr.covars_names2             = {'pseudonym', 'Up3OnBradySum_T2_imp'};%, 'Age', 'Gender', 'NpsEducYears','RespHandIsDominant_T0'};
conf.PEB_corr.dcmname                   = DCMname;
conf.PEB_corr.peb                       = runPEB;
% Specify PEB model settings
conf.PEB_corr.M                         = struct();
conf.PEB_corr.M.Q                       = 'all';             % estimate between-subject variability of each connection individually
if contains(DCMname,'spectral')
    conf.PEB_group.field                = {'A'};%,'B','C'};   % select DCM matrices of interest
else
    conf.PEB_group.field                = {'A','B','C'};
end
conf.PEB_corr.per_field    = true;       % estimate separate PEBs for each DCM matrix.

if todo.DCM_clin_corr
    mj_DCM_PEB_corr(conf)
end

%% DCM parameter extraction

conf.par_ex.ses.names                   = {'ses-PITVisit1'; 'ses-PITVisit2'; 'ses-POMVisit1'; 'ses-POMVisit3'};
conf.par_ex.gcmdir                      = fullfile(conf.dcmdir,'02_GCM');
conf.par_ex.outputdir                   = fullfile(conf.dcmdir,'04_Param');
conf.par_ex.dcmname                     = DCMname;
conf.par_ex.peb                         = runPEB;

if todo.DCM_param_extract
    
    % Extract params per sessions
    for  sb=1:size(conf.par_ex.ses.names,1)
        mj_DCM_param_extract(conf.par_ex.ses.names{sb,1},conf)
    end
    
    % Collate params
    par_tabs = cellstr(spm_select('FPList', conf.par_ex.outputdir, ['^DCMpar.*',conf.par_ex.dcmname,'_PEB-',num2str(conf.par_ex.peb),'.csv']));
    tab = [];
    for sb=1:size(par_tabs,1)
        tab = [tab;readtable(par_tabs{sb,1})];
    end
    writetable(tab, fullfile(conf.par_ex.outputdir,['DCMpar_ses-collated_',conf.par_ex.dcmname,'_PEB-',num2str(conf.par_ex.peb),'.csv']));
    
end

%% Quality control of DCM parameters

conf.par_qc.ses.names                   = {'ses-PITVisit1'; 'ses-PITVisit2'; 'ses-POMVisit1'; 'ses-POMVisit3'};
conf.par_qc.outputdir                   = {fullfile(conf.dcmdir,'04_Param')};

if todo.DCM_param_qc
    for sb=1:size(conf.par_qc.ses.names,1)
%         qsubfeval('mj_DCM_param_qc',conf.par_qc.ses.names{sb,1},conf,'memreq',2*1073741824,'timreq',2*3600,'backend',conf.backend);
        mj_DCM_param_qc(conf.par_qc.ses.names{sb,1},conf);
    end
end

%% CODE DUMP

%% Model estimation
% % General DCM parameters
% conf.DCMpar.GLMmethod     = 'Full';                  % Give different 1st-level designs different names
% conf.DCMpar.modelname     = 'model001';
% conf.DCMpar.VOIname       = {
%     'VOI_uniM1_1.mat'
%     'VOI_uniPUT_1.mat'
%     'VOI_uniCB_1.mat'
%     'VOI_uniFEF_1.mat'
%     'VOI_uniSPL_1.mat'};                             % File name of VOIs for your DCM. See pf_findfile for entering search criteria
% conf.DCMpar.nr_VOIs = size(conf.DCMpar.VOIname,1);
% conf.DCMpar.input         = {[1 0],[1 0]};           % Inputs to the DCM. Examples: *without parametric modulations*: {1, 0, 1} includes inputs 1 and 3. *with parametric modulations*: {1,0,[0 0 1],[0 1]} includes the non-modulated first input, the second PM of the third input and the first PM of the fourth input. Note that this cell array only has to be specified up to the last input that is replaced.
% conf.DCMpar.TA            = repmat(0.45,size(conf.DCMpar.nr_VOIs,1),1)';                  % Fill in your slice time acquisition for every VOI. Note that if you did  slice time correction during your preprocessing, all these values have to be conf to  your reference slice.
% conf.DCMpar.nonlinear     = 0;                        % 0 for bilinear, 1 for nonlinear
% conf.DCMpar.d             = double.empty(conf.DCMpar.nr_VOIs,conf.DCMpar.nr_VOIs,0);      % Non-linear modulations (if you don't use it: double.empty(nr_VOIs,nr_VOIs,0))
% conf.DCMpar.twostate      = 0;                        % 0 for one state nodes, 1 for two state
% conf.DCMpar.stochastic    = 0;                        % 0 for deterministic DCM, 1 for stochastic effects
% conf.DCMpar.centre        = 1;                        % 0 for not centre input, 1 for centre input
% conf.DCMpar.hiddennode    = [];                       % Index of the node which is to be hidden
% conf.DCMpar.endogenous    = 0;
% 
% % DCM.A: A-matrix specifying fixed connections
% conf.DCMpar.fixconnect    = [
%   % M1  PUT CB  FEF SPL        
%     1   1   1   1   1; % M1                           % Upper diag: From column to row
%     1   1   1   1   1; % PUT                          % Lower diag: From row to column
%     1   1   1   1   1; % CB
%     1   1   1   1   1; % FEF
%     1   1   1   1   1; % SPL
%     ];
% 
% % DCM.B: B-matrix specifying modulations of connections
% conf.DCMpar.modcon(:,:,1) = [
%     0   0   0   0   0;                               % Modulation 1 (Cue, will not vary)
%     0   0   0   0   0;
%     0   0   0   0   0;
%     0   0   0   0   0;
%     0   0   0   0   0;];
% conf.DCMpar.modcon(:,:,2) = [
%     0   0   0   0   0;                               % Modulation 2 (Selection, varies according to DCM.B options)
%     0   0   0   0   0;
%     0   0   0   0   0;
%     0   0   0   0   0;
%     0   0   0   0   0;];
% % All possible DCM.B options
% % conf.DCMB_models = fn_DCM_generate_DCMBoptions(conf);
% % Defined subset of DCM.B options
% conf.DCMB_models = [];
% conf.DCMB_models.options{1,1} = [                   % Selection modulates COMP
%     0   0   0   0   0;
%     0   0   0   0   0;
%     0   0   0   0   0;
%     0   0   0   1   0;
%     0   0   0   0   1;
%     ];
% conf.DCMB_models.options{2,1} = [                   % Selection modulates COMP > DYSFUNC connections
%     0   0   0   1   1;
%     0   0   0   1   1;
%     0   0   0   1   1;
%     0   0   0   1   0;
%     0   0   0   0   1;
%     ];
% conf.DCMB_models.names{1,1} = '19_25x';
% conf.DCMB_models.names{2,1} = '4_5_9_10_14_15_19_25x';
% 
% % DCM.C: C-matrix specifying where inputs should go
% conf.DCMC_options = eye(size(conf.DCMpar.fixconnect,1)); % all possible DCM.C options (each column one option)
% conf.DCMpar.inputconnect  = [ 
%     0 0;      %column 1 = Input 1 (Cue, will remain stable)
%     0 0;      %column 2 = Placeholder, is not altered
%     0 0;
%     0 0;
%     0 0;];
% % Subset of DCM.C options
% conf.DCMC_models = [];
% conf.DCMC_models.options{1,1} = [1 0; 1 0; 1 0; 0 0; 0 0];  % Input only to DYSFUNC
% conf.DCMC_models.options{2,1} = [1 0; 1 0; 1 0; 1 0; 1 0];  % Input to DYSFUNC  + COMP
% conf.DCMC_models.names{1,1} = '1_2_3x';
% conf.DCMC_models.names{2,1} = '1_2_3_4_5x';

%% Bayesian model selection
% conf.bmsdir      = fullfile(conf.dcmdir,'BMS');                    
% all_models = { 
%   strcat('DCMc_',conf.DCMC_models.names{1},'__DCMb_',conf.DCMB_models.names);
%   strcat('DCMc_',conf.DCMC_models.names{2},'__DCMb_',conf.DCMB_models.names);
%   };
% conf.DCMpar.BMS.models     = vertcat(all_models{:}); %all model names (2048)
% conf.DCMpar.BMS.GLMmethods = {'Full';}; 
% conf.DCMpar.BMS.fam.name    =   { % BMS Families %
% %                                   % Input models
%                                 'DCMc_1_2_3x__';
%                                 'DCMc_1_2_3_4_5x__';
%                                 
% %                                 % Modulation models
%                                 'DCMb_19_25x';
%                                 'DCMb_4_5_9_10_14_15_19_25x';
%                                 };
%    
% conf.DCMpar.BMS.fam.models  =   {
%                             find(contains(conf.DCMpar.BMS.models,conf.DCMpar.BMS.fam.name{1}))';                                   
%                             find(contains(conf.DCMpar.BMS.models,conf.DCMpar.BMS.fam.name{2}))'; 
%                             find(contains(conf.DCMpar.BMS.models,conf.DCMpar.BMS.fam.name{3}))'; 
%                             find(contains(conf.DCMpar.BMS.models,conf.DCMpar.BMS.fam.name{4}))'; 
%                                  };
% 
% conf.DCMpar.BMS.name       =  conf.DCMpar.GLMmethod; % Choose a name for your model (this will be added to conf.DCMpar.BMS.models{1}vsset.DCMpar.BMS.models{2}vs... etc)                           
% conf.DCMpar.BMS.dirname    = 'CueSel_MOD1';
% conf.DCMpar.BMS.method     = 'FFX';      % Choose RFX or FFX for your Bayesian Model Selection
% conf.DCMpar.BMS.verifID    =  0;         % Verify ID options for BMS (1 means it will check if all models are based on same data).
% conf.DCMpar.BMS.bma        = 'win';      % Perform BMA on on your BMS: 1) 'win': on winning family 2) 'all': perform BMA on all families 3) 'no': don't perform BMA 4) num: enter index of family you want to perform BMA on

