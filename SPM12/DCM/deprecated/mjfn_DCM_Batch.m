clear;
cd
%% To script:
% -- check how to handle models outside of occam window in one sample t-test, for those models BMS.DCM.rfx.bma.mEps{subject}.B = 0)

%==========================================================================
% --- Todo's --- %
%==========================================================================
todo.concatenate_sess    = false;
todo.create_VOIs         = false;
todo.create_designmtx    = false;
todo.specandest_dcm      = false; %specify and estimate DCM
todo.modelselect         = false;
todo.diagmodels          = false;
todo.longitudinal_PEB    = false;

%==========================================================================
% --- General settings --- %
%==========================================================================
conf.spmdir = '/project/3024006.02/Users/marjoh/SPM/own_copy/spm12';
conf.additionalsdir = '/groupshare/sysneu/Scripts/Additionals';
conf.dcmscriptdir = '/home/sysneu/marjoh/scripts/proj_DCM';

cluster_outputdir = '/project/3024006.02/Analyses/motor_task_dcm_02/';
conf.firstlevel_rootdir = '/project/3024006.02/Analyses/motor_task_dcm_02/';
conf.mri_root = '/project/3022026.01/pep/bids/derivatives/fmriprep_v23.0.2/motor/';
conf.smth_dir = '/func/';
conf.subjects = cellstr(spm_select('List',conf.firstlevel_rootdir,'dir','sub-.*'));
conf.dominant_side = {'R';'R';'R';'R';'R';'R'};
conf.subjects = [conf.subjects, conf.dominant_side];
conf.TR = 1;

% conf.sub.name = {
%     'sub-POMU12F1F23A498674A9'};
% conf.sub.hand = {
%     'R'};

%==========================================================================
% --- VOI Settings --- %
%==========================================================================
conf.VOI.DCMname = '01_VOIs';
conf.VOI.VOInames = {
    'M1'
    'PUT'
    'CB'
    'FEF'
    'SPL'
    };
conf.VOI.ROIdir = '/project/3024006.02/Analyses/motor_task_dcm_02/masks/';
% conf.VOI.ROInames = { %ROIfiles in same order as VOInames, 1th column right handed tremor, 2nd column left handed tremor
%     's_R_M1.nii','s_L_M1.nii'
%     's_R_PUT.nii','s_L_PUT.nii'
%     's_R_CB.nii','s_L_CB.nii'
%     's_R_FEF.nii','s_L_FEF.nii'
%     's_R_SPL.nii','s_L_SPL.nii'
%     };
conf.VOI.ROInames = { %ROIfiles in same order as VOInames, 1th column right handed tremor, 2nd column left handed tremor
    's_bi_M1.nii'
    's_bi_PUT.nii'
    's_bi_CB.nii'
    's_bi_FEF.nii'
    's_bi_SPL.nii'
    };
conf.VOI.DCM_correct = 1; %contrast number of EoI

%==========================================================================
% --- DCMDesign matrix settings --- %
%==========================================================================

conf.dir.save             = fullfile(conf.firstlevel_rootdir,'02_DCMtemplates');
conf.dsmtx.scan.te        = 0.034;
conf.dsmtx.cond.name      = {'Cue';'Selection'};

%==========================================================================
% --- DCM parameters (specDCM, estDCM, illMod) --- %
%==================================c========================================

conf.DCMpar.modelname     = 'testmodel';             % Modelname: e.g. "-" for single connections, "=" for double connection,'^' is and (if two connections), 'v' is or
conf.DCMpar.GLMmethod     = 'Full';      % For every different design matrix you use you can use a different name
conf.DCMpar.input         = {[1 0],[1 0]};                                    % Input to your DCM model. % Examples: * without parametric modulations* : {1, 0, 1} includes inputs 1 and 3. * with parametric modulations* : {1,0,[0 0 1],[0 1]} includes the non-modulated first input, the second PM of the third input and the first PM of the fourth input. Note that this cell array only has to be specified up to the last input that is replaced.
conf.DCMpar.sess          = {1};                                        % Amount of Sessions (? Not sure if works, I only use one session)
conf.DCMpar.VOIname       = {'/VOI_/&/CurROI/&/CurSub/&/.mat/'};        % File name of VOIs for your DCM. See pf_findfile for entering search criteria
conf.DCMpar.fixconnect    = [
  % CB  FEF M1  PUT SPL        % DCM.A
    1   1   1   1   1; % CB    % Upper diag: From column to row
    1   1   1   1   1; % FEF   % Lower diag: From row to column
    1   1   1   1   1; % M1
    1   1   1   1   1; % PUT
    1   1   1   1   1; % SPL
    ];

conf.DCMpar.modcon(:,:,1) = [
    0 0 0;              % Input 1 (Cue, will not vary)
    0 0 0;
    0 0 0;];
conf.DCMpar.modcon(:,:,2) = [
    0 0 0;              % Input 2 (Selection, varies according to DCM.B options)
    0 0 0;
    0 0 0;];

% conf.DCMB_models = fn_DCM_generate_DCMBoptions(conf); % all possible DCM.B options
conf.DCMB_models = [];
conf.DCMB_models.options{1,1} = [0,0,1;0,0,0;1,0,1];
conf.DCMB_models.options{2,1} = [0,0,1;0,0,0;0,0,0];
conf.DCMB_models.options{3,1} = [0,0,0;0,0,0;1,0,0];
conf.DCMB_models.options{4,1} = [0,0,0;0,0,0;0,0,1];
conf.DCMB_models.options{5,1} = [0,0,1;0,0,0;1,0,0];
conf.DCMB_models.options{6,1} = [0,0,1;0,0,0;0,0,1];
conf.DCMB_models.options{7,1} = [0,0,0;0,0,0;1,0,1];
conf.DCMB_models.names{1,1} = '3_7_9x';
conf.DCMB_models.names{2,1} = '3x';
conf.DCMB_models.names{3,1} = '7x';
conf.DCMB_models.names{4,1} = '9x';
conf.DCMB_models.names{5,1} = '3_7x';
conf.DCMB_models.names{6,1} = '3_9x';
conf.DCMB_models.names{7,1} = '7_9x';


conf.DCMC_options = eye(3); % all possible DCM.C options (each column one option)
conf.DCMpar.inputconnect  = [ 
    0 0;      %column 1 = Input 1 (Cue, will remain stable)
    0 0;      %column 2 = Placeholder, is not altered
    0 0;];
conf.DCMC_models = [];
conf.DCMC_models.options{1,1} = [1,0;1,0;1,0];
conf.DCMC_models.options{2,1} = [1,0;0,0;0,0];
conf.DCMC_models.options{3,1} = [0,0;1,0;0,0];
conf.DCMC_models.options{4,1} = [0,0;0,0;1,0];
conf.DCMC_models.options{5,1} = [1,0;1,0;0,0];
conf.DCMC_models.options{6,1} = [1,0;0,0;1,0];
conf.DCMC_models.options{7,1} = [0,0;1,0;1,0];
conf.DCMC_models.names{1,1} = '1_2_3x';
conf.DCMC_models.names{2,1} = '1x';
conf.DCMC_models.names{3,1} = '2x';
conf.DCMC_models.names{4,1} = '3x';
conf.DCMC_models.names{5,1} = '1_2x';
conf.DCMC_models.names{6,1} = '1_3x';
conf.DCMC_models.names{7,1} = '2_3x';

conf.DCMpar.d             = double.empty(4,4,0);      % Non-linear modulations (if you don't use it: double.empty(4,4,0))
conf.DCMpar.TA            = [0.45;0.45;0.45];                % Fill in your slice time acquisition for every VOI. Note that if you did  slice time correction during your preprocessing, all these values have to be conf to  your reference slice.
conf.DCMpar.nonlinear     = 0;                        % 0 for bilinear, 1 for nonlinear
conf.DCMpar.twostate      = 0;                        % 0 for one state nodes, 1 for two state
conf.DCMpar.stochastic    = 0;                        % 0 for deterministic DCM, 1 for stochastic effects
conf.DCMpar.centre        = 1;                        % 0 for not centre input, 1 for centre input
conf.DCMpar.hiddennode    = [];                       % Index of the node which is to be hidden
conf.DCMpar.endogenous    = 0;

%==========================================================================
% --- Bayesian model selection settings --- %
%==========================================================================

conf.dir.BMS      = fullfile(conf.dir.save,'BayesianModelSelection');                    
all_models = { 
%     % Single models
%     strcat('DCMc_BA4__DCMb_',conf.DCMB_models.names(cellfun(@(x) length(x)==1 ||  length(x)==2,conf.DCMB_models.names)));
%     strcat('DCMc_Thalamus__DCMb_',conf.DCMB_models.names(cellfun(@(x) length(x)==1 ||  length(x)==2,conf.DCMB_models.names)));
%     strcat('DCMc_CBL__DCMb_',conf.DCMB_models.names(cellfun(@(x) length(x)==1 ||  length(x)==2,conf.DCMB_models.names)));
%     strcat('DCMc_GPi__DCMb_',conf.DCMB_models.names(cellfun(@(x) length(x)==1 ||  length(x)==2,conf.DCMB_models.names)));
%     };
    % All models (7 per DCMc)
  strcat('DCMc_1x__DCMb_',conf.DCMB_models.names);
  strcat('DCMc_2x__DCMb_',conf.DCMB_models.names);
  strcat('DCMc_3x__DCMb_',conf.DCMB_models.names);
  strcat('DCMc_1_2x__DCMb_',conf.DCMB_models.names);
  strcat('DCMc_1_3x__DCMb_',conf.DCMB_models.names);
  strcat('DCMc_2_3x__DCMb_',conf.DCMB_models.names);
  strcat('DCMc_1_2_3x__DCMb_',conf.DCMB_models.names);
  };
conf.DCMpar.BMS.models     = vertcat(all_models{:}); %all model names (2048)
conf.DCMpar.BMS.GLMmethods = {'onsetate_Fall';}; 
conf.DCMpar.BMS.fam.name    =   { % BMS Families %
%                                   % Input models
%                                 'DCMc_1x__';
%                                 'DCMc_2x__';
%                                 'DCMc_3x__';
%                                 'DCMc_1_2x__';
%                                 'DCMc_1_3x__';
%                                 'DCMc_2_3x__';
%                                 'DCMc_1_2_3x__'
                                
%                                 % Modulation models
                                'DCMb_3x';
                                'DCMb_7x';
                                'DCMb_9x';
                                'DCMb_3_7x';
                                'DCMb_3_9x';
                                'DCMb_7_9x';
                                'DCMb_3_7_9x';
                                };
   
conf.DCMpar.BMS.fam.models  =   {
                            find(contains(conf.DCMpar.BMS.models,conf.DCMpar.BMS.fam.name{1}))';                                   
                            find(contains(conf.DCMpar.BMS.models,conf.DCMpar.BMS.fam.name{2}))'; 
                            find(contains(conf.DCMpar.BMS.models,conf.DCMpar.BMS.fam.name{3}))'; 
                            find(contains(conf.DCMpar.BMS.models,conf.DCMpar.BMS.fam.name{4}))'; 
                            find(contains(conf.DCMpar.BMS.models,conf.DCMpar.BMS.fam.name{5}))'; 
                            find(contains(conf.DCMpar.BMS.models,conf.DCMpar.BMS.fam.name{6}))'; 
                            find(contains(conf.DCMpar.BMS.models,conf.DCMpar.BMS.fam.name{7}))';
                                 };

conf.DCMpar.BMS.name       =  conf.DCMpar.GLMmethod; % Choose a name for your model (this will be added to conf.DCMpar.BMS.models{1}vsset.DCMpar.BMS.models{2}vs... etc)                           
conf.DCMpar.BMS.dirname    = 'CueSel_MOD1';
conf.DCMpar.BMS.method     = 'FFX';      % Choose RFX or FFX for your Bayesian Model Selection
conf.DCMpar.BMS.verifID    =  0;         % Verify ID options for BMS (1 means it will check if all models are based on same data).
conf.DCMpar.BMS.bma        = 'win';      % Perform BMA on on your BMS: 1) 'win': on winning family 2) 'all': perform BMA on all families 3) 'no': don't perform BMA 4) num: enter index of family you want to perform BMA on

%==========================================================================
% --- Model diagnostics settings --- %
%==========================================================================

conf.diagnostics.models = [43]; %conf.DCMpar.BMS.fam.models{1}; %Numbers of models for which you want to run diagnostics (corresponding with conf.DCMpar.BMS.fam.name and conf.DCMpar.BMS.fam.models)
conf.diagnostics.suppressdisplay = true; %suppress SPM output figures (true) or display the figures (false)
conf.diagnostics.summarysavename = 'diagnostics_best5models';
%==========================================================================
% --- Run scripts --- %
%==========================================================================
addpath('/home/common/matlab/fieldtrip/qsub');
cd(cluster_outputdir);

%%
if todo.concatenate_sess
    for sb=1:size(conf.subjects,1)
        qsubfeval('mjfn_DCM_concatenatesess',conf.subjects{sb,1},conf,'memreq',10^10,'timreq',6*3600);
%               mjfn_DCM_concatenatesess(conf.subjects{sb,1},conf);
    end
end

% After concatenation rename subjects
conf.subjects = cellfun(@(x) strrep(x,'_combined','_concatenated'),conf.subjects,'UniformOutput',false);

if todo.create_VOIs
    for sb=1:size(conf.subjects,1)
        qsubfeval('mjfn_DCM_createVOI',conf.subjects{sb,1},conf,'memreq',1*1073741824,'timreq',2*3600);
%                 mjfn_DCM_createVOI(conf.subjects{sb,1},conf);
    end
end

if todo.create_designmtx
    for sb=1:size(conf.subjects,1)
        qsubfeval('mjfn_DCM_createdesignmtx',conf.subjects{sb,1},conf,'memreq',2*1073741824,'timreq',6*3600);
        %         mjfn_DCM_createdesignmtx(conf.subjects{sb,1},conf);
    end
end


%% Specifiy and estimate
% https://dccn-hpc-wiki.readthedocs.io/en/latest/docs/cluster_howto/compute_torque.html?highlight=400#cluster-wise-policies
% max jobtime=48 hours, max running jobs=400, max cueable jobs=2000

max_jobs = 2000;
models_perjob = 4; %maximum number of models per job
hours = (models_perjob*20)/60;
if todo.specandest_dcm
    fprintf(['\n ------------ Max number of models per job = ' num2str(models_perjob) ' (Expected duration ' num2str(hours) ' hours) ------------ \n']);
    jobs=0;
        for sb=1:size(conf.subjects,1)
            conf.sub.name = conf.subjects(sb,1);
            for c = 1:numel(conf.DCMC_models.options)
                conf.DCMpar.inputconnect = conf.DCMC_models.options{c};
                models = strcat(['DCMc_' conf.DCMC_models.names{c} '__DCMb_'],conf.DCMB_models.names);
                filestocheck = strcat(conf.dir.save,'/',models,'/',conf.DCMpar.GLMmethod,'/',conf.subjects{sb},'/DCM_',conf.DCMpar.GLMmethod,'.mat');
                undone = cell2mat(cellfun(@fn_checkincomplete,filestocheck,'UniformOutput',false));
                if sum(undone) == 0
                    fprintf(['\n All models estimated for subject ' conf.subjects{sb} ', DCMc ' conf.VOI.VOInames{c}]);
                else
                    mtodo =  conf.DCMB_models.options(undone);
                    names = conf.DCMB_models.names(undone);
                    % split into desired number of models per job
                    add_to = ceil(numel(mtodo)/models_perjob)*models_perjob;
                    mtodo(end+1:add_to) = {[]};
                    names(end+1:add_to) = {[]};
                    todo_split = reshape(mtodo,models_perjob,[]);
                    names_split = reshape(names,models_perjob,[]);
                    for m=1:size(todo_split,2)
                        if jobs <= max_jobs
                            conf.DCMpar.modcontodo = todo_split(~cellfun(@isempty,todo_split(:,m)),m);
                            conf.DCMpar.modconnames = names_split(~cellfun(@isempty,names_split(:,m)),m);
                            fprintf(['\n Submitting job for ' conf.subjects{sb} ', DCMc ' conf.DCMC_models.names{c} ': ' num2str(numel(conf.DCMpar.modcontodo)) ' models -- \n' ]);
                            qsubfeval('mjfn_dcm_specandest',conf,'memreq',4*1024^3,'timreq',2*60*60); % submit to cluster
%                             mjfn_dcm_specandest(conf); % run interactively
                            jobs = jobs+1;
                        else
                            fprintf(['\n ------------ Max number of jobs reached (' num2str(max_jobs) ') ------------ \n']);
                        end
                    end
                end
            end  
        end
end

if todo.modelselect
    mjfnpf_dcm_exec_BMS(conf); % Do a Bayesian Model Selection for the estimated DCM models
end

if todo.diagmodels
    fn_diagmodels(conf)
end


%% small additional functions
function incomplete = fn_checkincomplete(filetocheck)
warning('off');
incomplete = false;
try load(filetocheck,'Cp','Ep','F')
    if ~exist('Cp','var') || ~exist('Ep','var') || ~exist('F','var')
        incomplete = true; %if variables in file do not exist
    end
catch
    incomplete = true; % if file does not exist
end
warning('on');
end

