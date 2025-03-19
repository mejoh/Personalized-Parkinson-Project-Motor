function mjfnpf_dcm_exec_BMS(conf)
%
% exec_BMS(conf) makes and runs a matlabbatch of Bayesian Model Selection 
% of all the specified models in your configuration file. It saves the
% matlabbatch, BMS.mat and modelspace.mat file.
%
% �Michiel Dirkx, 2014
% $ParkFunC
if ~exist('spm') %add required paths
    addpath(conf.spmdir);
    spm fmri
    addpath(conf.dcmscriptdir);
    addpath(conf.additionalsdir);
end


%% Initializing directories / checking parameters

fprintf('\n%s\n','% ----- Executing Bayesian Model Selection ----- %')

% ----- Initialize save directory  ----- %

if exist(conf.dir.BMS,'dir') ~= 7; mkdir(conf.dir.BMS); end   % Make BMS main folder if necessary

% ----- Check if enough models     ----- %

if length(conf.DCMpar.BMS.models) < 2 && length(conf.DCMpar.BMS.GLMmethods) < 2
    error('execBMS:nModels','Not enough models specified, select at least 2 models')
end

%% Initialize loop parameters

nSub    =   length(conf.subjects(:,1));
nMod    =   length(conf.DCMpar.BMS.models);                   % Number of models
nGLMm   =   length(conf.DCMpar.BMS.GLMmethods(1,:));          % number of GLM methods

BMSname  =   '';                                              % initialize BMSdir (subfolder)
cnt      =   1; 

%% Find the right model folder and GLM method (subfolder of modelfolder)

FullDirs = strcat(conf.dir.save,'/',conf.DCMpar.BMS.models,'/',conf.DCMpar.GLMmethod)';

% for e = 1:nMod
%     
%     CurMod   =   conf.DCMpar.BMS.models{e};              % Model Code
%     Fold     =   pf_findfile(conf.dir.save,CurMod); % Find your model
%     
%     modeldir =   fullfile(conf.dir.save,char(Fold));
%     
%     for f = 1:nGLMm
%         
%         if length(conf.DCMpar.BMS.GLMmethods(:,1)) == 1     % If you entered only one GLMmethod for more than one model
%             CurGLM  =   conf.DCMpar.BMS.GLMmethods{1,f};
%         else
%             CurGLM  =   conf.DCMpar.BMS.GLMmethods{e,f};
%         end
%         
%         if isempty(CurGLM) == 0
%             
%             FinFold         =   pf_findfile(modeldir,['/' CurGLM '/*/']);        % Final folder
%             
%             FullDirs{cnt}   =   fullfile(modeldir,FinFold);        % Ah, so we now got our final model/GLM directories
% %             DCMnames{cnt}   =   ['DCM_' FinFold '.mat'];           % Because first i didn't use the prefix number
% %             
% %             mn  =  strfind(CurMod,'_');
% %             gn  =  strfind(CurGLM,'-');
%             
% %             if cnt == 1
% %                 BMSname = [CurMod(1:mn-1) '-' CurGLM(1:gn-1)];
% %             elseif cnt > 1
% %                 BMSname = [BMSname 'vs' CurMod(1:mn-1) '-' CurGLM(1:gn-1) ];
% %             end
%             
%             cnt =   cnt + 1;
%         end
%         
%     end
%     fprintf(['\n Adding models to batch: ' num2str(e) '/' num2str(nMod) ' - ' num2str(e/nMod*100,'%4.2f') '%%']);
% end

%% Creating the main Matlabbatch 

fprintf('\n%s\n','Creating the matlabbatch')
% nDirs   =   length(FullDirs);

% --- Include all DCM.mat files --- %

for h = 1:nSub
     
    CurSub      =   conf.subjects{h,1};
    
    matlabbatch{1}.spm.stats.bms.bms_dcm.sess_dcm{h}.mod_dcm = strcat(FullDirs,'/',CurSub,'/DCM_',conf.DCMpar.BMS.name,'.mat')';
    
%     for g = 1:nDirs
%         
%         CurDir      =   FullDirs{g};
%         CurFile     =   pf_findfile(fullfile(CurDir,CurSub),'/|DCM_/*/');
%         CurFile     =   fullfile(CurDir,CurSub,CurFile);
% 
%         matlabbatch{1}.spm.stats.bms.bms_dcm.sess_dcm{h}.mod_dcm{g,1} = CurFile;
%         
%     end
     
end

% --- Choose if Bayesian Model Averaging --- %

if strcmp(conf.DCMpar.BMS.bma,'win')
    matlabbatch{1}.spm.stats.bms.bms_dcm.bma.bma_yes.bma_famwin = 'fanwin';               % Winning family
elseif strcmp(conf.DCMpar.BMS.bma,'all')
    matlabbatch{1}.spm.stats.bms.bms_dcm.bma.bma_yes.bma_all    = 'famwin';               % All families
elseif strcmp(conf.DCMpar.BMS.bma,'no')
    matlabbatch{1}.spm.stats.bms.bms_dcm.bma.bma_no             = 0;                      % No BMA
elseif isnumeric(conf.DCMpar.BMS.bma)
    matlabbatch{1}.spm.stats.bms.bms_dcm.bma.bma_yes.bma_part   = conf.DCMpar.BMS.bma;    % Choose family
end

% --- Fill in additional options --- %

matlabbatch{1}.spm.stats.bms.bms_dcm.model_sp   = {''};                         % Load Model Space
matlabbatch{1}.spm.stats.bms.bms_dcm.load_f     = {''};                         % Load log-evidence
matlabbatch{1}.spm.stats.bms.bms_dcm.method     = conf.DCMpar.BMS.method;       % FFX vs RFX

matlabbatch{1}.spm.stats.bms.bms_dcm.verify_id  = conf.DCMpar.BMS.verifID;      % Verify if models are based on same data

% --- Include families if present --- %

if isfield(conf.DCMpar.BMS,'fam')

    nFam    =   length(conf.DCMpar.BMS.fam.name);
    
    for j = 1:nFam
        
        CurFam      =   conf.DCMpar.BMS.fam.name{j};
        CurModels   =   conf.DCMpar.BMS.fam.models{j};
        
%         if j == 1
% %             BMSname =   ['FamCmpr_' CurFam];
%               BMSname =   'FamCmpr';
% %         else
% %             BMSname =   [BMSname 'vs' CurFam]; %#ok<AGROW>
%         end
        
        matlabbatch{1}.spm.stats.bms.bms_dcm.family_level.family(j).family_name     = CurFam;
        matlabbatch{1}.spm.stats.bms.bms_dcm.family_level.family(j).family_models   = CurModels;

    end
else 
    matlabbatch{1}.spm.stats.bms.bms_dcm.family_level.family_file = {''};       
end

%% Save the Batch 

BMSname  =   conf.DCMpar.BMS.name;
BMSdir   =   fullfile(conf.dir.BMS,conf.DCMpar.BMS.dirname);

matlabbatch{1}.spm.stats.bms.bms_dcm.dir = {BMSdir};                        % directory where BMS model will be saved
if exist(BMSdir,'dir') ~= 7; mkdir(BMSdir); end                             % Make savedir if necessary

save(fullfile(BMSdir,['Batch_BMS_' BMSname ]),'matlabbatch');
disp(['Done. Saved batch to ' fullfile(BMSdir,['Batch_BMS_' BMSname ])])

%% Run the batch

% K   =   input('Do you want to run the BMS batch now? 1 = yes');

% if K == 1
    fprintf('\n%s\n','Running batch now')
    
    clear matlabbatch
    load(fullfile(BMSdir,['Batch_BMS_' BMSname ]))
    
    spm_jobman('initcfg');
    spm_jobman('run',matlabbatch)
% end
