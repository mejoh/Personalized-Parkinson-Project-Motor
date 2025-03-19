clear all;
%==========================================================================
% --- Todo's --- %
%==========================================================================
concatenate_sess    = false;
create_VOIs         = true;
create_designmtx    = false;
specandest_dcm      = false; %specify and estimate DCM
 check_incomplete   = false;
 rerun_error        = false;
modelselect         = false;

%==========================================================================
% --- General settings --- %
%==========================================================================
conf.spmdir = '/home/common/matlab/spm12/';
conf.additionalsdir = '/home/action/frenie/Persoonlijk Post-Doc/Github-scripts/Additionals';
conf.dcmscriptdir = '/home/action/frenie/Persoonlijk Post-Doc/Github-scripts/DCM';

cluster_outputdir = '/project/3011164.01/2_Uitvoer/Data/Matlab/matlab_sub/clusteroutput/';
conf.firstlevel_rootdir = '/project/3011164.01/2_Uitvoer/Data/Processing/MRI/2_Analysis/zscorePmod_6mmSmooth_noGS_inclmotion_3Fcontrasts/';
conf.mri_root = '/project/3011164.01/2_Uitvoer/Data/Processing/MRI/';
conf.smth_dir = '/func/preproc/smooth/';
conf.subjects = { %subjectname,most affected side
    'D02'           'L'
    'D03'           'R'
    'D04_combined'	'R'
    'D05_combined'	'L'
    'D06_combined'	'R'
    'D10_2'         'R'
    'D18_combined'	'R'
    'D21'           'R'
    'D24'           'R'
    'D26_2'         'L'
    'D27_combined'	'L'
    'E08_combined'	'R'
    'E13_combined'	'R'
    'E15_combined'	'R'
    'E16_combined'	'R'
    'E17_2'         'R'
    'E20_combined'	'L'
    'E28_combined'	'L'
    'D31'           'R'
    'E32'           'L'
    'E34'           'L'
    'D35'           'R'
    'D37_combined'	'R'
    'D38'           'L'
    'D39_combined'	'L'
    'D40_combined'	'R'
    'D42_combined'	'L'
    };

%==========================================================================
% --- VOI Settings --- %
%==========================================================================
conf.VOI.DCMname = '1_DCM_VOIs';
conf.VOI.VOInames = {
    'BA4'
    'Thalamus'
%     'VLp'
    'CBL'
    'GPi'
    };
conf.VOI.ROIdir = '/project/3011164.01/2_Uitvoer/Data/Processing/MRI/2_Analysis/zscorePmod_6mmSmooth_noGS_inclmotion_3Fcontrasts/2_DCM_ROIs';
conf.VOI.ROInames = { %ROIfiles in same order as VOInames, 1th column right handed tremor, 2nd column left handed tremor
    'BA4_signTFCE_tremorelatedactivity.nii','LRflip_BA4_signTFCE_tremorelatedactivity.nii'
    'ThalamusTFCEp05fwe_binary.nii','LRflip_ThalamusTFCEp05fwe_binary.nii'
%     'VLp_left.nii','VLp_right.nii'
    'SUITTFCEp001fwe_and_somatomotorBuckner.nii','LRflip_SUITTFCEp001fwe_and_somatomotorBuckner.nii'
    'GPi_left.nii','GPi_right.nii'
    };
conf.VOI.DCM_correct = 7; %contrast number of EoI

%==========================================================================
% --- DCMDesign matrix settings --- %
%==========================================================================
% no specific settings required

%==========================================================================
% --- DCM parameters (specDCM, estDCM, illMod) --- %
%==========================================================================

conf.dir.save             = fullfile(conf.firstlevel_rootdir,'3_DCM_models');
conf.DCMpar.modelname     = 'testmodel';             % Modelname: e.g. "-" for single connections, "=" for double connection,'^' is and (if two connections), 'v' is or
conf.DCMpar.GLMmethod     = 'onestate';      % For every different design matrix you use you can use a different name
conf.DCMpar.input         = {[0 1],1,0};                                    % Input to your DCM model. % Examples: * without parametric modulations* : {1, 0, 1} includes inputs 1 and 3. * with parametric modulations* : {1,0,[0 0 1],[0 1]} includes the non-modulated first input, the second PM of the third input and the first PM of the fourth input. Note that this cell array only has to be specified up to the last input that is replaced.
conf.DCMpar.sess          = {1};                                        % Amount of Sessions (? Not sure if works, I only use one session)
conf.DCMpar.VOIname       = {'/VOI_/&/CurROI/&/CurSub/&/.mat/'};        % File name of VOIs for your DCM. See pf_findfile for entering search criteria
conf.DCMpar.fixconnect    = [
    % BA4 Thalamus CBL GPi            %DCM.A
    1   1   0   1   ; % BA4
    1   1   1   0   ; % Thalamus
    1   0   1   0   ; % CBL
    1   0   1   1   ; % GPi
    ];

% conf.DCMB_models = fn_DCM_generate_DCMBoptions(conf); % all possible DCM.B options
conf.DCMB_models.options = {zeros(4,4),zeros(4,4)}';
conf.DCMB_models.names = {
'none_DCMa_VIM'
'none_DCMa_VOP'
};

conf.DCMpar.modcon(:,:,1) = [
    0 0 0 0;              % Input 1 (tremor, will vary according to conf.DCMB_options)
    0 0 0 0;
    0 0 0 0;
    0 0 0 0;];
conf.DCMpar.modcon(:,:,2) = [
    0 0 0 0;              % Input 2 (onset movement, will remain stable all zeros)
    0 0 0 0;
    0 0 0 0;
    0 0 0 0;];

% conf.DCMC_options = eye(4); % all possible DCM.C options (each column one option)
conf.DCMC_options = zeros(4,1);
conf.DCMpar.inputconnect  = [ 0 0;      %column 1 = Input 1 (tremor, will remain stable)
    0 0;      %column 2 = Input 2 (onset movement, will vary according to conf.DCMC_options)
    0 0;
    0 0;];

conf.DCMpar.d             = double.empty(4,4,0);      % Non-linear modulations (if you don't use it: double.empty(4,4,0))
conf.DCMpar.TA            = [0.5;0.5;0.5;0.5;0.5;0.5];                % Fill in your slice time acquisition for every VOI. Note that if you did  slice time correction during your preprocessing, all these values have to be conf to  your reference slice.
conf.DCMpar.nonlinear     = 0;                        % 0 for bilinear, 1 for nonlinear
conf.DCMpar.twostate      = 0;                        % 0 for one state nodes, 1 for two state
conf.DCMpar.stochastic    = 0;                        % 0 for deterministic DCM, 1 for stochastic effects
conf.DCMpar.centre        = 1;                        % 0 for not centre input, 1 for centre input
conf.DCMpar.hiddennode    = [];                       % Index of the node which is to be hidden
conf.DCMpar.endogenous    = 0;
conf.dsmtx.scan.te        = 0.034;
conf.dsmtx.cond.name      = {'Tremor';'Onset'};

%==========================================================================
% --- Bayesian model selection settings --- %
%==========================================================================

conf.dir.BMS      = fullfile(conf.dir.save,'Bayesian Model Selection');                    
all_models = {
                                strcat('DCMc_BA4__DCMb_',conf.DCMB_models.names);
                                strcat('DCMc_Thalamus__DCMb_',conf.DCMB_models.names);
                                strcat('DCMc_CBL__DCMb_',conf.DCMB_models.names);
                                strcat('DCMc_GPi__DCMb_',conf.DCMB_models.names);
                                };
conf.DCMpar.BMS.models     = vertcat(all_models{:}); %all model names (2048)
conf.DCMpar.BMS.GLMmethods = {'onestate';}; 
conf.DCMpar.BMS.fam.name    =   { % BMS Families %
                                'DCMc_BA4';
                                'DCMc_Thalamus';
                                'DCMc_CBL';
                                'DCMc_GPi';
                                };
   
conf.DCMpar.BMS.fam.models  =   {
                            find(contains(conf.DCMpar.BMS.models,conf.DCMpar.BMS.fam.name{1}))';                                   
                            find(contains(conf.DCMpar.BMS.models,conf.DCMpar.BMS.fam.name{2}))'; 
                            find(contains(conf.DCMpar.BMS.models,conf.DCMpar.BMS.fam.name{3}))'; 
                            find(contains(conf.DCMpar.BMS.models,conf.DCMpar.BMS.fam.name{4}))'; 
                                 };

conf.DCMpar.BMS.name       = 'onestate'; % Choose a name for your model (this will be added to conf.DCMpar.BMS.models{1}vsset.DCMpar.BMS.models{2}vs... etc)                           
conf.DCMpar.BMS.method     = 'RFX';      % Choose RFX or FFX for your Bayesian Model Selection
conf.DCMpar.BMS.verifID    =  0;         % Verify ID options for BMS (1 means it will check if all models are based on same data).
conf.DCMpar.BMS.bma        = 'win';      % Perform BMA on on your BMS: 1) 'win': on winning family 2) 'all': perform BMA on all families 3) 'no': don't perform BMA 4) num: enter index of family you want to perform BMA on

%==========================================================================
% --- Run scripts --- %
%==========================================================================
addpath('/home/common/matlab/fieldtrip/qsub');
cd(cluster_outputdir);

%%
if concatenate_sess
    for sb=1:size(conf.subjects,1)
        if contains(conf.subjects{sb,1},'_combined')
            qsubfeval('fn_DCM_concatenatesess',conf.subjects{sb,1},conf,'memreq',10^10,'timreq',6*3600);
        end
    end
end

% After concatenation rename subjects
conf.subjects = cellfun(@(x) strrep(x,'_combined','_concatenated'),conf.subjects,'UniformOutput',false);

if create_VOIs
    for sb=1:size(conf.subjects,1)
        qsubfeval('fn_DCM_createVOI',conf.subjects{sb,1},conf,'memreq',1*1073741824,'timreq',1*3600);
%                 fn_DCM_createVOI(conf.subjects{sb,1},conf);
    end
end

if create_designmtx
    for sb=1:size(conf.subjects,1)
        qsubfeval('fn_DCM_createdesignmtx',conf.subjects{sb,1},conf,'memreq',10^10,'timreq',6*3600);
        %         fn_DCM_createdesignmtx(conf.subjects{sb,1},conf);
    end
end


%% Specifiy and estimate 74 seconds for each model. 2048*74=151552 seconds, 42.0978 hours
% max jobtime=48 hours, max running jobs=400, max cueable jobs=2000

% 4x27x2048 = 221.184 models
% 4*27*1=108 jobs if all models within one DCM.C option
% 4*27*10=1080 jobs, 4.2 hours for each job
% 4*27*3=324 jobs. 14 hours needed. Split DCM.B in 3

dcmbsplitamount = ceil(size(conf.DCMB_models.options,1) / 3);
dcmb_splittodo.options{:,1} =  conf.DCMB_models.options(1:dcmbsplitamount);
dcmb_splittodo.options{:,2} =  conf.DCMB_models.options(dcmbsplitamount+1:2*dcmbsplitamount);
dcmb_splittodo.options{:,3} = conf.DCMB_models.options(2*dcmbsplitamount+1:end);
dcmb_splittodo.names{:,1} =  conf.DCMB_models.names(1:dcmbsplitamount);
dcmb_splittodo.names{:,2} =  conf.DCMB_models.names(dcmbsplitamount+1:2*dcmbsplitamount);
dcmb_splittodo.names{:,3} = conf.DCMB_models.names(2*dcmbsplitamount+1:end);

% if specandest_dcm
%     for sb=1:size(conf.subjects,1)
%         conf.sub.name = conf.subjects(sb,1);
%         for c = 1:size(conf.DCMC_options,2)
%             conf.DCMpar.inputconnect(:,2) = conf.DCMC_options(:,c);
%             for b = 1:size(dcmb_splittodo.options,2)
%                 conf.DCMpar.modcontodo =  dcmb_splittodo.options{b};
%                 conf.DCMpar.modconnames = dcmb_splittodo.names{b};
%                 qsubfeval('fn_dcm_specandest',conf,'memreq',30*(10^9),'timreq',25*3600);
% %                 fn_dcm_specandest(conf);
%             end
%         end
%     end
% end

if specandest_dcm
    for sb=1:size(conf.subjects,1)
        conf.sub.name = conf.subjects(sb,1);
        for a=1:2
            conf.DCMpar.inputconnect(:,2) = zeros(4,1);
            conf.DCMpar.modcontodo =  dcmb_splittodo.options{a};
            conf.DCMpar.modconnames = dcmb_splittodo.names{a};
            if a==1
                conf.DCMpar.fixconnect    = [
                    % BA4 Thalamus CBL GPi            %DCM.A
                    1   1   0   1   ; % BA4
                    1   1   1   0   ; % Thalamus
                    1   0   1   0   ; % CBL
                    1   0   1   1   ; % GPi
                    ];
            elseif a==2
                conf.DCMpar.fixconnect    = [
                    % BA4 Thalamus CBL GPi            %DCM.A
                    1   1   1   0   ; % BA4
                    1   1   0   1   ; % Thalamus
                    1   0   1   0   ; % CBL
                    1   0   1   1   ; % GPi
                    ];
            end
            fn_dcm_specandest(conf);
        end
    end
end


max_jobs = 400;
models_perjob = 20; %maximum number of models per job
hours = models_perjob*(7/60);
if check_incomplete
    fprintf(['\n ------------ Max number of models per job = ' num2str(models_perjob) ' (Expected duration ' num2str(hours) ' hours) ------------ \n']);
    jobs=0;
        for sb=1:size(conf.subjects,1)
            conf.sub.name = conf.subjects(sb,1);
            for c = 1:size(conf.DCMC_options,2)
                conf.DCMpar.inputconnect(:,2) = conf.DCMC_options(:,c);
                models = strcat(['DCMc_' conf.VOI.VOInames{c} '__DCMb_'],conf.DCMB_models.names);
                filestockeck = strcat(conf.dir.save,'/',models,'/',conf.DCMpar.GLMmethod,'/',conf.subjects{sb},'/DCM_',conf.DCMpar.GLMmethod,'.mat');
                undone = cell2mat(cellfun(@fn_checkincomplete,filestockeck,'UniformOutput',false));
                if sum(undone) == 0
                    fprintf(['\n All models estimated for subject ' conf.subjects{sb} ', DCMc ' conf.VOI.VOInames{c}]);
                else
                    todo =  conf.DCMB_models.options(undone);
                    names = conf.DCMB_models.names(undone);
                    % split into desired number of models per job
                    add_to = ceil(numel(todo)/models_perjob)*models_perjob;
                    todo(end+1:add_to) = {[]};
                    names(end+1:add_to) = {[]};
                    todo_split = reshape(todo,models_perjob,[]);
                    names_split = reshape(names,models_perjob,[]);
                    for m=1:size(todo_split,2)
                        if jobs <= max_jobs
                            conf.DCMpar.modcontodo = todo_split(~cellfun(@isempty,todo_split(:,m)),m);
                            conf.DCMpar.modconnames = names_split(~cellfun(@isempty,names_split(:,m)),m);
                            fprintf(['\n Submitting job for ' conf.subjects{sb} ', DCMc ' conf.VOI.VOInames{c} ': ' num2str(numel(conf.DCMpar.modcontodo)) ' models -- ' ]);
                            qsubfeval('fn_dcm_specandest',conf,'memreq',1.5*1073741824,'timreq',20*3600); % submit to cluster
%                             fn_dcm_specandest(conf); % run interactively
                            jobs = jobs+1;
                        else
                            fprintf(['\n ------------ Max number of jobs reached (' num2str(max_jobs) ') ------------ \n']);
                        end
                    end
                end
            end
        end
end

if modelselect
    fnpf_dcm_exec_BMS(conf); % Do a Bayesian Model Selection for the estimated DCM models
end

if rerun_error
    toredo.files = fn_incompleteDCMmodels;
    for f=1:numel(toredo.files)
       [dir,file,ext] = fileparts(toredo.files{f});
       modelname = toredo.files{f}(strfind(toredo.files{f},'DCMb_')+5:strfind(toredo.files{f},'/onestate')-1);
       
       conf.sub.name = {toredo.files{f}(strfind(toredo.files{f},'state/')+6:strfind(toredo.files{f},'/DCM_onestate')-1)};
       conf.DCMpar.modcontodo = conf.DCMB_models.options(contains(conf.DCMB_models.names,modelname));
       conf.DCMpar.modconnames = {modelname};
       conf.DCMpar.inputconnect(:,2) = conf.DCMC_options(:,cellfun(@(x) contains(toredo.files{f},x),conf.DCMpar.BMS.fam.name));
       fn_dcm_specandest(conf); % run interactively
    end
    
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

