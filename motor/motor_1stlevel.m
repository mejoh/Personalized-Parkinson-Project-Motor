function Inputs = motor_1stlevel(Force, Subset, dcm, session)

%% Description
% Estimates activity during performance of action selection task
% Main reference: https://doi.org/10.1093/brain/awad325
% No arguments: Runs 1st-level for participants who have not been processed
% Force: Reruns 1st-levels
% Subset: Number of jobs to send to the cluster

% JOB SUBMISSION TO CLUSTER
%
% If batch submission (X jobs submitted in parallel): 
% iterations=30;
% for i = 1:iterations
%     fprintf("Iteration #%i \n", i)
%     motor_1stlevel(false,15,false,'ses-POMVisit1')
%     ZipOrUnzip
% end

% If sequential job submission (one job submitted at a time):
% motor_1stlevel(false,[],false,'ses-POMVisit1')
% ZipOrUnzip()
% motor_copycontrasts('ses-POMVisit1',true)
% 
% motor_1stlevel(false,[],false,'ses-POMVisit3')
% ZipOrUnzip()
% motor_copycontrasts('ses-POMVisit3',true)
% 
% motor_1stlevel(false,[],false,'ses-PITVisit1')
% ZipOrUnzip()
% motor_copycontrasts('ses-PITVisit1',true)
% 
% motor_1stlevel(false,[],false,'ses-PITVisit2')
% ZipOrUnzip()
% motor_copycontrasts('ses-PITVisit2',true)

%%
if nargin<1 || isempty(Force)
	Force = false;
    Subset = [];
    dcm = false;
    session='ses-POMVisit1';
end
do_mni = 1;

% Fills the list of open Inputs and submit the jobs to the cluster
%
% List of open inputs
% Change Directory: Directory - cfg_files
% Smooth: Images to smooth - cfg_files
% fMRI model specification: Directory - cfg_files
% fMRI model specification: Interscan interval - cfg_entry
% fMRI model specification: Multiple conditions - cfg_files
% fMRI model specification: Multiple regressors - cfg_files

addpath('/home/common/matlab/fieldtrip/qsub');
addpath('/home/common/matlab/spm12');

%session = 'ses-POMVisit3';
prefix = ''; %'[A-Z]'; %'[0-9]';
Root = '/project/3022026.01';
BIDSDir  = fullfile(Root, 'pep', 'bids');
FMRIPrep = fullfile(BIDSDir, 'derivatives/fmriprep_v23.0.2/motor');
ANALYSESDir   = '/project/3024006.02/Analyses/motor_task_dcm_03';
Sub = cellstr(spm_select('List', fullfile(FMRIPrep), 'dir', ['^sub-POMU', prefix, '.*']));
% Sub = {'sub-POMU4A7727F13B26E411'; 'sub-POMU4E60B43DDEFC32ED'; 'sub-POMU9A08794D78B1E1A0'; 'sub-POMU7AABE759AC531D35'; 'sub-POMU0C7CB0F2155DE5AB'; 'sub-POMU1E5A12AA97C57B45'; 'sub-POMU1A50F30F4A977983'}; % PD
% Sub = {'sub-POMU6EAC387509F0A349'; 'sub-POMU12F1F23A498674A9'; 'sub-POMU88EC9E198C36CDED'; 'sub-POMU5EA053BA9D2D4E54'; 'sub-POMU4CAA883EA0687CF6'; 'sub-POMU3E2A2E638B42B398'; 'sub-POMU50F6AD7CEEA7D448'}; % HC
fprintf('Found %i subjects \n', numel(Sub))

% Check data for each subject's visits and exclude where necessary
Sel = true(size(Sub,1),1);
for n = 1:numel(Sub)
    Visit = cellstr(spm_select('List', fullfile(FMRIPrep, Sub{n}), 'dir', session));
    for v = 1:numel(Visit)
        
        % Fmriprep report
        ReportFile = cellstr(spm_select('FPList', FMRIPrep, [Sub{n} '.html']));
        % Preprocessed functional image
        dFunc = fullfile(FMRIPrep, Sub{n}, Visit{v}, 'func');
        FuncImg = cellstr(spm_select('FPList', dFunc, [Sub{n}, '.*task-motor_acq-MB6_run-1', '.*_desc-preproc_bold.nii']));
        
        if(~isempty(FuncImg{1}))
            if do_mni == 1
                FuncImg = FuncImg(contains(FuncImg, 'space-MNI152NLin6Asym'));
            else
                FuncImg = FuncImg(contains(FuncImg, 'space-SST'));
            end
        end
        
%         FuncImg = cellstr(FuncImg{sFilesize(FuncImg,1)}); % Takes the last run
        ConfTs = cellstr(spm_select('FPList', dFunc, [Sub{n}, '.*task-motor_acq-MB6_run-1', '.*_desc-confounds_timeseries.tsv']));
        ConfTs = cellstr(ConfTs{size(ConfTs,1)}); % Takes the last run
        % Events file
        dBeh = fullfile(BIDSDir, Sub{n}, Visit{v}, 'beh');
        EventsTsv = cellstr(spm_select('FPList', dBeh, [Sub{n}, '.*task-motor_acq-MB6_run-1', '.*_events.tsv']));
        EventsTsv = cellstr(EventsTsv{size(EventsTsv,1)});
        % Preexisting 1st level results
        FirstLevelCon = spm_select('List', fullfile(ANALYSESDir, Sub{n}, Visit{v}, '1st_level'), '^con.*3\.nii$');
        
        % Exclude participants
        TaskID = extractBetween(EventsTsv{1}, '_task-', '_acq');
        if ~isempty(EventsTsv{1}) && contains(TaskID, 'motor')      % Select participants with motor task and existing events.tsv file
            fileID = EventsTsv{1};
            fID = fopen(fileID, 'r');
            Trials = textscan(fID, '%f%f%d%s%s%f%s%s%s%*s%*s%*s', 'HeaderLines', 1, 'Delimiter', '\t', 'TreatAsEmpty', 'n/a');
            fclose(fID);
%             onsets{1}	 = Trials{1,1}(logical(strcmp(Trials{1,4}, 'cue') .* strcmp(Trials{1,5}, 'Catch') .* strcmp(Trials{1,9}, 'Hit')))';
            onsets{1}	 = Trials{1,1}(logical(strcmp(Trials{1,4}, 'cue') .* strcmp(Trials{1,5}, 'NChoice1') .* strcmp(Trials{1,9}, 'Hit')))';
            onsets{2}	 = Trials{1,1}(logical(strcmp(Trials{1,4}, 'cue') .* strcmp(Trials{1,5}, 'NChoice2') .* strcmp(Trials{1,9}, 'Hit')))';
            onsets{3}	 = Trials{1,1}(logical(strcmp(Trials{1,4}, 'cue') .* strcmp(Trials{1,5}, 'NChoice3') .* strcmp(Trials{1,9}, 'Hit')))';
            CheckMissing = cellfun(@isempty, onsets);
            % Exclusion:
            % 1: Missing onsets in at least one condition (poor performance)
            % 2: Missing fmriprep html report
            % 3: Missing preprocessed functional image
            % 4: Missing confounds timeseries file
            ex1 = sum(CheckMissing) > 0;
            ex2 = isempty(ReportFile{1});
            ex3 = isempty(FuncImg{1});
            ex4 = isempty(ConfTs{1});
            if ex1 || ex2 || ex3 || ex4
                fprintf('Excluding %s %s\n', Sub{n}, Visit{v})
                fprintf('Onsets: %i, Report: %i, FuncImage: %i, ConfTs: %i \n', ex1, ex2, ex3, ex4)
                Sel(n) = false;
            end
            % 5: Lack of run correspondece between beh and func image, or between func image and confound timeseries
            if ~isempty(FuncImg{1}) && ~isempty(ConfTs{1})        % Participants whose runs of task and fmri do not correspond with each other
                taskRunID = extractBetween(EventsTsv{1}, '_run-', '_');
                fmriRunID = extractBetween(FuncImg{1}, '_run-', '_');
                conftsRunID = extractBetween(ConfTs{1}, '_run-', '_');
                if ~strcmp(taskRunID{1}, fmriRunID{1}) || ~strcmp(fmriRunID{1}, conftsRunID{1})
                    fprintf('Excluding %s %s: run numbers are not identical \n', Sub{n}, Visit{v})
                    Sel(n) = false;
                end
            end
            % 6: Already processed
            if ~isempty(FirstLevelCon) && ~istrue(Force)        % Participants who have already been processed
                fprintf('Excluding %s %s: has preexisting 1st level data \n', Sub{n}, Visit{v})
                Sel(n) = false;
            end
        else
            %fprintf('%s excluded: %s lacks motor task data \n', Sub{n}, Visit{v})
            Sel(n) = false;
        end

    end
%     if strcmp(Sub{n}, 'sub-POMUC2917FBF8466577F')       % too few volumes
%         Sel(n) = false;
%     end
end
Sub = Sub(Sel);

% Subset
if isempty(Subset)
    fprintf('Subset not specified, processing all %i subjects! \n', numel(Sub))
    NrSub = numel(Sub);
elseif Subset > numel(Sub)
    fprintf('Subset has %i more participants than is available. Processing the remaining ones instead! \n', Subset - numel(Sub))
    NrSub = numel(Sub);
else
    NrSub = Subset;
end
if NrSub >0
    fprintf('%i participants included for further processing \n', NrSub)
else
    fprintf('No more participants to process. Exiting... \n')
    return
end

% Collect all functional images
Files = {};
for n = 1:NrSub
    Visit = cellstr(spm_select('List', fullfile(BIDSDir, Sub{n}), 'dir', session));
    for v = 1:numel(Visit)
        dFunc = fullfile(FMRIPrep, Sub{n}, Visit{v}, 'func');
        FuncImg = cellstr(spm_select('FPList', dFunc, [Sub{n}, '.*task-motor_acq-MB6_run-', '.*_desc-preproc_bold.nii']));
        if do_mni == 1
%             FuncImg = FuncImg(contains(FuncImg, 'space-SST'));
            FuncImg = FuncImg(contains(FuncImg, 'space-MNI152NLin6Asym'));
        else
            FuncImg = FuncImg(~contains(FuncImg, '_space-'));
        end
        Files = [Files; cellstr(FuncImg{size(FuncImg,1)})]; % Selects the last run if there are multiple ones!
    end
end

% % 7: Fewer volumes than recorded pulses (time consuming)
Sel = true(size(Files,1),1);
for n = 1:numel(Files)
    s = char(extractBetween(Files{n}, 'fmriprep_v23.0.2/motor/', '/ses'));    % Pseudonym
    v = char(extractBetween(Files{n}, [s '_'], '_task'));       % Visit
    r = char(extractBetween(Files{n}, 'run-', '_'));       % Run
    TaskDir             = fullfile(BIDSDir, s, v, 'beh');
    EventsJsonFile      = spm_select('FPList', TaskDir, [s, '_', v, '_task-motor_acq-MB6_run-', r, '_events.json']);
    ConfFile            = spm_select('FPList', fileparts(Files{n}), ['.*_task-motor_acq-MB6_run-' r '.*desc-confounds_timeseries.tsv']);
    [NrPulses, NrConf] = checkpulsediff(EventsJsonFile, ConfFile);
    if NrPulses > NrConf
        fprintf('Number of recorded pulses exceeds volumes in func img. Skipping %s %s \n', s, v)
        Sel(n) = false;
    end
end
Files = Files(Sel);

Inputs	= cell(6,1);
if ~dcm
    JobFile = {spm_file(mfilename('fullpath'), 'suffix','_job', 'ext','.m')};
elseif dcm
    JobFile = {spm_file(mfilename('fullpath'), 'suffix','_dcm_job', 'ext','.m')};
end
% Specify inputs to 1st-level analyses
for n = 1:numel(Files)
    s = char(extractBetween(Files{n}, 'fmriprep_v23.0.2/motor/', '/ses'));    % Pseudonym
    v = char(extractBetween(Files{n}, [s '_'], '_task'));       % Visit
    r = char(extractBetween(Files{n}, 'run-', '_'));       % Run
    ConfFile            = spm_select('FPList', fileparts(Files{n}), ['.*_task-motor_acq-MB6_run-' r '.*desc-confounds_timeseries3.tsv']);
    if isempty(ConfFile)
        ConfFile            = spm_select('FPList', fileparts(Files{n}), ['.*_task-motor_acq-MB6_run-' r '.*desc-confounds_timeseries2.tsv']);
        if isempty(ConfFile)
            ConfFile            = spm_select('FPList', fileparts(Files{n}), ['.*_task-motor_acq-MB6_run-' r '.*desc-confounds_timeseries.tsv']);
        end
    end
    SourceNii               = Files{n};
    SourceJson              = strrep(SourceNii, '.nii.gz', '.json');
    if do_mni == 0
        SourceMaskNii       = strrep(SourceNii, 'echo-1_desc-preproc_bold', 'desc-brain_mask');
    else
        SourceMaskNii       = strrep(SourceNii, 'echo-1_space-MNI152NLin6Asym_desc-preproc_bold', 'space-MNI152NLin6Asym_desc-brain_mask');
    end
    SPMDir              = fullfile(ANALYSESDir, s, v);
    SPMStatDir          = fullfile(ANALYSESDir, s, v, '1st_level');
    TaskDir             = fullfile(BIDSDir, s, v, 'beh');
    EventsTsvFile       = spm_select('FPList', TaskDir, [s, '_', v, '_task-motor_acq-MB6_run-', r, '_events.tsv']);
    EventsJsonFile      = spm_select('FPList', TaskDir, [s, '_', v, '_task-motor_acq-MB6_run-', r, '_events.json']);
    InMat               = spm_file(EventsTsvFile, 'path', SPMDir, 'ext', '.mat');
    
    % Start with a clean stats output directory
    if ~exist(SPMStatDir,'dir')
 		mkdir(SPMStatDir)
 	else
 		delete(fullfile(SPMStatDir,'*.*'))
    end
    
    % Copy functional image and mask
    copyfile(SourceNii, SPMDir)
    copyfile(SourceMaskNii, SPMDir)
    copyfile(SourceJson, SPMDir)
    InputNii = strrep(SourceNii, strcat(FMRIPrep, ['/' s '/' v], '/func'), SPMDir);
    MaskNii = strrep(SourceMaskNii, strcat(FMRIPrep, ['/' s '/' v], '/func'), SPMDir);
    [~, ~, Ext] = fileparts(SourceNii);
    if strcmp(Ext, '.gz')
        gunzip(InputNii)
        delete(InputNii)
        InputNii = strrep(InputNii, 'nii.gz', 'nii');
    end
    [~, ~, Ext] = fileparts(SourceMaskNii);
    if strcmp(Ext, '.gz')
        gunzip(MaskNii)
        delete(MaskNii)
        MaskNii = strrep(MaskNii, 'nii.gz', 'nii');
    end
    
    % Determine TR and start time for image
    filetext = fileread(SourceJson);
    expr = '[^\n]*RepetitionTime[^\n]*';
    matches = regexp(filetext,expr,'match');
    TR = cell2num_my(extractBetween(matches, ': ', ','));
    expr = '[^\n]*StartTime[^\n]*';
    matches = regexp(filetext,expr,'match');
    stime = cell2num_my(extractBetween(matches, ': ', ','));
    fprintf('%s %s start time: %f\n', s, v, stime)
	
	% Change Directory: Directory - cfg_files
    Inputs{1}{n} = {SPMStatDir};
	
	% Smooth: Images to smooth - cfg_files
    Inputs{2}{n} = {InputNii};
	
	% fMRI model specification: Directory - cfg_files
    Inputs{3}{n} = {SPMStatDir};

	% fMRI model specification: Interscan interval - cfg_entry
    Inputs{4}{n} = 1;
	
	% fMRI model specification: Multiple conditions - cfg_files
    StimulusEvents	= extract_onsets_and_duration_pm(EventsTsvFile, TR, stime, dcm);
    names = StimulusEvents.names;
    onsets = StimulusEvents.onsets;
    durations = StimulusEvents.durations;
    pmod = StimulusEvents.pmod;
    disp(['Saving stimulus / response events in: ' InMat])
    save(InMat, 'names', 'onsets', 'durations', 'pmod')
    Inputs{5}{n} = {InMat};
	
	% fMRI model specification: Multiple regressors - cfg_files
	NrPulses	 = getnrpulses(EventsJsonFile);
    Covar		 = non_gm_covariates_fmriprep(ConfFile, InMat, NrPulses);
    Inputs{6}{n} = {Covar};
    
    % fMRI model specification: Explicit mask
%     Inputs{7}{n} = {MaskNii};
    Inputs{7}{n} = {'/project/3024006.02/templates/spm/mask_ICV_resampled.nii'};

%     spm_jobman('run', JobFile, Inputs{1}{n}, Inputs{2}{n}, Inputs{3}{n}, Inputs{4}{n}, Inputs{5}{n}, Inputs{6}{n}, Inputs{7}{n})
    qsubfeval(@spm_jobman, 'run', JobFile, Inputs{1}{n}, Inputs{2}{n}, Inputs{3}{n}, Inputs{4}{n}, Inputs{5}{n}, Inputs{6}{n}, Inputs{7}{n}, 'memreq',9*1024^3,'timreq',2*60*60);
    
end

% Run jobs interactively
% for n = 1:numel(Files)
%    spm_jobman('run', JobFile, Inputs{1}{n}, Inputs{2}{n}, Inputs{3}{n}, Inputs{4}{n}, Inputs{5}{n}, Inputs{6}{n})
% end

% Submit to cluster
% if numel(Files)==1
% 	spm_jobman('run', JobFile, Inputs{1}{1}, Inputs{2}{1}, Inputs{3}{1}, Inputs{4}{1}, Inputs{5}{1}, Inputs{6}{1});%, Inputs{7}{1});
% else
%   	qsubcellfun('spm_jobman', repmat({'run'},[1 numel(Files)]), repmat(JobFile,[1 numel(Files)]), Inputs{:}, 'memreq',9*1024^3, 'timreq',2*60*60, 'StopOnError',false, 'options','-l gres=bandwidth:1000');
% end

% Clean up copied functional images
% for n = 1:numel(Inputs{2})
%     dImg = cell2mat(Inputs{2}{n});
%     ImagesToDelete = cellstr(spm_select('FPList', fileparts(dImg), '^sub.*desc-preproc_bold.nii'));
%     if ~isempty(ImagesToDelete)
%         for i = 1:numel(ImagesToDelete)
%             delete(ImagesToDelete{i})
%         end
%     end
% end

% Concatenate residuals and clean up 3d images
% Remember to turn on residual writing in motor_1stlevel_job first!
% for n = 1:numel(Inputs{1})
%     d1st = cell2mat(Inputs{1}{n});
%     fprintf('Writing residuals for %s\n', char(extractBetween(d1st,'sub-','/ses-')))
%     resids = cellstr(spm_select('FPList', d1st, 'Res_.*'));
%     output = fullfile(d1st, 'Res4d.nii');
%     spm_file_merge(resids, output);
%     gzip(output);
%     delete(output);
%     cellfun(@delete, resids)
% end

end

function [NrPulses, NrConf] = checkpulsediff(EventsJsonFile, ConfFile)

    % Number of pulses in events json file
    Json = fileread(EventsJsonFile);
    DecodedJson = jsondecode(Json);
    NrPulses = DecodedJson.NPulses.Value;
    
    % Number of timepoints in confounds file
    Confounds = spm_load(char(ConfFile));
    NrConf = length(Confounds.csf);

end

function NrPulses = getnrpulses(EventsJsonFile)
    Json = fileread(EventsJsonFile);
    DecodedJson = jsondecode(Json);
    NrPulses = DecodedJson.NPulses.Value;
end