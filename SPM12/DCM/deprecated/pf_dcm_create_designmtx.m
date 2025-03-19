function pf_dcm_create_designmtx(conf)
%
% pf_dcm_create_designmtx(conf) creates the design matrix for your DCM
% model, based on your configuration file. This may differ from your first
% level GLM. 

% �Michiel Dirkx, 2014
% $ParkFunC

%--------------------------------------------------------------------------

%% Initializing parameters
%--------------------------------------------------------------------------

fprintf('\n%s\n',['% ----- Creating SPM.mat file (Design Matrix) of ' conf.DCMpar.modelname ' ----- %'])

nSub        =   length(conf.sub.name);
nCond       =   length(conf.dsmtx.cond.name);
nScan       =   length(conf.dir.scans_sub);

%--------------------------------------------------------------------------

%% Creating the Matlabbatch
%--------------------------------------------------------------------------

% --- For every Subject --- %

for h = 1:nSub
    
    CurSub      =   conf.sub.name{h};
    CurSess1    =   conf.sub.sess1{h};
    CurSave     =   fullfile(conf.dir.save,conf.DCMpar.modelname,conf.DCMpar.GLMmethod,CurSub);
    fprintf('\n%s\n',['Making matlabbatch of ' CurSub])
    
    % --- Add Conditions --- %
    
    fprintf('%s\n','1) Adding conditions')
    
    for i = 1:nCond
        
        CurCond     =   conf.dsmtx.cond.name{i};
        CurOns      =   conf.dsmtx.cond.ons{i};
        CurDur      =   conf.dsmtx.cond.dur{i};
        
        % --- Determine session for files and change search string --- %
        
        if strcmp(conf.dsmtx.cond.sess{2},CurSess1)
            CurSess = conf.dsmtx.cond.sess{3};
        else
            CurSess = conf.dsmtx.cond.sess{4};
        end
        
        stridx = strfind(conf.dsmtx.cond.emg.file,'CurSess');
        
        if ~isempty(stridx)
            conf.dsmtx.cond.emg.file = conf.dsmtx.cond.emg.file([1:stridx-1 stridx+7:end]);
            conf.dsmtx.cond.emg.file = [conf.dsmtx.cond.emg.file(1:stridx-1) CurSess conf.dsmtx.cond.emg.file(stridx:end)];
        end
        
        stridx = strfind(conf.dsmtx.cond.cond.file,'CurSess');
        
        if ~isempty(stridx)
            conf.dsmtx.cond.cond.file = conf.dsmtx.cond.cond.file([1:stridx-1 stridx+7:end]);
            conf.dsmtx.cond.cond.file = [conf.dsmtx.cond.cond.file(1:stridx-1) CurSess conf.dsmtx.cond.cond.file(stridx:end)];
        end

        % --- Add the predefined conditions to the DSMTX --- %
        
        switch CurCond
            case 'EMGRegr'
                
                % --- Find/load the EMG File --- %
                
                
                CurEMG  =   pf_findfile(conf.dir.EMG,conf.dsmtx.cond.emg.file,'conf',conf,'CurSub',h);
                
                emg     =   load(fullfile(conf.dir.EMG,CurEMG));
                fn      =   fieldnames(emg);
                
                % --- Add condition specific parameters to batch --- %
                
                try 
                    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(i).pmod.name  = emg.names{conf.dsmtx.cond.emg.idx};   % Name of parametric modulator
                    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(i).pmod.param = emg.R(:,conf.dsmtx.cond.emg.idx);     % So these are the values for parametric modulation
                catch % compatibility for regressors with no names/R (such as concatTS)
                    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(i).pmod.name  = fn{:};   % Name of parametric modulator
                    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(i).pmod.param = emg.(fn{:});     % So these are the values for parametric modulation
                end
                matlabbatch{1}.spm.stats.fmri_spec.sess.cond(i).pmod.poly  = 1;                                    % Polynomial expansion (default 1)
                
                % --- Determine condition specific parameters --- %
                
                nScans = length(matlabbatch{1}.spm.stats.fmri_spec.sess.cond(i).pmod.param);
                if strcmp(CurOns,'nScan')
                    CurOns = 1:1:nScans;
                end
                
                % --- Condition messages --- %
                
                fprintf('%s\n',['- Added condition ' num2str(i) ': ' CurCond])
                try
                    fprintf('%s\n',['-- File: ' emg.names{conf.dsmtx.cond.emg.idx} ' (containing ' num2str(nScans) ' values)'])
                catch
                    fprintf('%s\n',['-- File: ' CurEMG ' (containing ' num2str(nScans) ' values)'])
                end
                fprintf('%s\n','-- Polynomial: 1st order (linear)')
                
            case 'Dopa'
                
                % --- Add condition specific parameters to batch --- %
                
                matlabbatch{1}.spm.stats.fmri_spec.sess.cond(i).pmod = struct('name', {}, 'param', {}, 'poly', {});
                
                % --- Condition messages --- %
                
                fprintf('%s\n',['- Added condition ' num2str(i) ': ' CurCond])
                fprintf('%s\n',['-- start condition: scan ' num2str(CurOns)])
                fprintf('%s\n',['-- duration condition: ' num2str(CurDur) ' scans'])
                
            case 'COCO'
                
                % --- Load condition file --- %
                
                nStr = length(conf.dir.cond);
                
                for a = 1:nStr
                    CurStr = conf.dir.cond{a};
                    if strcmp(CurStr,'rootdir')
                        CurStr = conf.dir.root;
                    elseif strcmp(CurStr,'CurSub')
                        CurStr = CurSub;
                    elseif strcmp(CurStr,'CurSess')
                        CurStr = CurSess;
                    end
                    
                    if a==1
                        CurDir = [CurStr];
                    else
                        CurDir = [CurDir '/' CurStr];
                    end
                end
                
                CondFile =   pf_findfile(CurDir,conf.dsmtx.cond.cond.file,'conf',conf,'CurSub',h);
                cond     =   load(fullfile(CurDir,CondFile));
                
                % --- Add condition specific parameters to batch --- %
                
                matlabbatch{1}.spm.stats.fmri_spec.sess.cond(i).pmod = struct('name', {}, 'param', {}, 'poly', {});
                CurOns = cond.onsets{1};
                CurDur = cond.durations{1};
                
                % --- Condition messages --- %
                
                fprintf('%s\n',['- Added condition ' num2str(i) ': ' CurCond])
                fprintf('%s\n',['-- start condition: scan ' num2str(CurOns)])
                fprintf('%s\n',['-- duration condition: ' num2str(CurDur) ' scans'])
                
        end
        
        % --- Add general condition parameters --- %
        
        matlabbatch{1}.spm.stats.fmri_spec.sess.cond(i).name       = CurCond;         % Condition Name
        matlabbatch{1}.spm.stats.fmri_spec.sess.cond(i).onset      = CurOns;          % Onsets of condition
        matlabbatch{1}.spm.stats.fmri_spec.sess.cond(i).duration   = CurDur;          % Durations of your condition (default = 0)
        matlabbatch{1}.spm.stats.fmri_spec.sess.cond(i).tmod       = 0;               % No time modulation, change this to batch!!!
        
        matlabbatch{1}.spm.stats.fmri_spec.sess.cond(i).orth       = 1;
        
        % --- General Condition messages --- %
        
        fprintf('%s\n','-- No time modulation of condition')
        
    end
    
    % --- Add Scans --- %
    
    fprintf('%s\n','2) Adding scans')
    
    for j = 1:nScan
        
        if iscell(conf.dir.scans_sub{j})
            CurSess1    =   conf.sub.sess1{h};
            if strcmp(CurSess1,conf.dir.scans_sub{j}(2))
                CurDir  =   fullfile(conf.dir.scans_main,CurSub,conf.dir.scans_sub{j}{3});
            else
                CurDir  =   fullfile(conf.dir.scans_main,CurSub,conf.dir.scans_sub{j}{4});
            end
        else
            CurDir      =   fullfile(conf.dir.scans_main,CurSub,conf.dir.scans_sub{j});
        end
        CurScan     =   pf_findfile(CurDir,conf.dsmtx.scan.name,'msgM',0,'fullfile');
        CurScan     =   CurScan(conf.dsmtx.scan.nDummy+1:end);                  % Remove dummy scan(s)
        
        if j == 1
        scan        =   CurScan;
        else
        scan        =   vertcat(scan,CurScan);
        end
        
    end
    
    % --- Scan Messages --- %
    
    fprintf('%s\n',['- Added ' num2str(length(scan)) ' scans'])
    fprintf('%s\n',['-- first: ' scan{1}])
    fprintf('%s\n',['-- last: ' scan{end}])
    
    % -- Make rest of Matlabbatch --%
    
    matlabbatch{1}.spm.stats.fmri_spec.dir                  = {CurSave};            % Save directory
    matlabbatch{1}.spm.stats.fmri_spec.timing.units         = conf.dsmtx.cond.unit; % Units of design
    matlabbatch{1}.spm.stats.fmri_spec.timing.RT            = conf.dsmtx.scan.tr;   % conf.dsmtx.TR
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t        = 16;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0       = 1;
    matlabbatch{1}.spm.stats.fmri_spec.sess.scans           = scan;                 % Scans
    matlabbatch{1}.spm.stats.fmri_spec.sess.multi           = {''};
    matlabbatch{1}.spm.stats.fmri_spec.sess.regress         = struct('name', {}, 'val', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess.multi_reg       = {''};
    matlabbatch{1}.spm.stats.fmri_spec.sess.hpf             = 128;
    matlabbatch{1}.spm.stats.fmri_spec.fact                 = struct('name', {}, 'levels', {});
    matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs     = [0 0];
    matlabbatch{1}.spm.stats.fmri_spec.volt                 = 1;
    matlabbatch{1}.spm.stats.fmri_spec.global               = 'None';
    matlabbatch{1}.spm.stats.fmri_spec.mask                 = {''};
    matlabbatch{1}.spm.stats.fmri_spec.cvi                  = 'AR(1)';
    
    % --- Save the Batch --- %
    
    fprintf('%s\n','3) Saving batch')
    if exist(CurSave,'dir') ~= 7; mkdir(CurSave); end                    % Make all the save directories if neccessary
    save(fullfile(CurSave,['Batch_SpecDesMtx_' conf.DCMpar.GLMmethod '_' conf.DCMpar.modelname '_' CurSub]),'matlabbatch');
    
    fprintf('%s\n',['- Saved to ' CurSave])
    
end

%--------------------------------------------------------------------------

%% Run the batches
%--------------------------------------------------------------------------

fprintf('\n%s\n','Now running all the batches')

for h = 1:nSub
    
    clear matlabbatch
    CurSub      =   conf.sub.name{h};
    CurDir      =   fullfile(conf.dir.save,conf.DCMpar.modelname,conf.DCMpar.GLMmethod,CurSub);
    load(fullfile(CurDir,['Batch_SpecDesMtx_' conf.DCMpar.GLMmethod '_' conf.DCMpar.modelname '_' CurSub]));
    
    CurSub = conf.sub.name{h};
    disp(['Specifying model of ' CurSub])
    spm_jobman('initcfg')
    spm_jobman('run',matlabbatch)
    
end

