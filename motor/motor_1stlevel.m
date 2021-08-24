function Inputs = motor_1stlevel(Force, Subset, preAROMA)

% No arguments: Runs 1st-level for participants who have not been processed
% Force: Reruns 1st-levelsM
% Subset: Number of jobs to send to the cluster
% preAROMA: Run 1st-levels to prepare for AROMA reclassification

if nargin<1 || isempty(Force)
	Force = false;
end

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

session = 'ses-PITVisit2';
Root = '/project/3022026.01';
BIDSDir  = fullfile(Root, 'pep', 'bids');
FMRIPrep = fullfile(BIDSDir, 'derivatives/fmriprep');
ANALYSESDir   = '/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem';
Sub = cellstr(spm_select('List', fullfile(BIDSDir), 'dir', '^sub-POMU.*'));
% Sub = {'sub-POMU0C177BAE3D332846'; 'sub-POMU1EDD7C2E9E8DF70C'; 'sub-POMU4CC057B13DBB2927'; 'sub-POMU8067BDE54D1B1B4A'; 'sub-POMU862289F885891BCF'; 'sub-POMU98768D0FB5B292BF'; 'sub-POMUA2417117F868F087'; 'sub-POMUAC2513F0E5E32349'};
fprintf('Found %i subjects \n', numel(Sub))

% Check data for each subject's visits and exclude where necessary
Sel = true(size(Sub,1),1);
for n = 1:numel(Sub)
    Visit = cellstr(spm_select('List', fullfile(BIDSDir, Sub{n}), 'dir', session));
    for v = 1:numel(Visit)
        
        % Fmriprep report
        ReportFile = cellstr(spm_select('FPList', FMRIPrep, [Sub{n} '.html']));
        % Preprocessed functional image
        dFunc = fullfile(FMRIPrep, Sub{n}, Visit{v}, 'func');
        FuncImg = cellstr(spm_select('FPList', dFunc, [Sub{n}, '.*task-motor_acq-MB6_run-', '.*_desc-preproc_bold.nii']));
        FuncImg = cellstr(FuncImg{size(FuncImg,1)}); % Takes the last run
        ConfTs = cellstr(spm_select('FPList', dFunc, [Sub{n}, '.*task-motor_acq-MB6_run-', '.*_desc-confounds_timeseries.tsv']));
        ConfTs = cellstr(ConfTs{size(ConfTs,1)}); % Takes the last run
        % Events file
        dBeh = fullfile(BIDSDir, Sub{n}, Visit{v}, 'beh');
        EventsTsv = cellstr(spm_select('FPList', dBeh, [Sub{n}, '.*task-motor_acq-MB6_run-', '.*_events.tsv']));
        EventsTsv = cellstr(EventsTsv{size(EventsTsv,1)});
        % Preexisting 1st level results
        FirstLevelCon = spm_select('List', fullfile(ANALYSESDir, Sub{n}, Visit{v}, '1st_level'), '^con.*\.nii$');
        
        % Exclude participants
        TaskID = extractBetween(EventsTsv{1}, '_task-', '_acq');
        if ~isempty(EventsTsv{1}) && contains(TaskID, 'motor')      % Select participants with motor task and existing events.tsv file
            fileID = EventsTsv{1};
            fID = fopen(fileID, 'r');
            Trials = textscan(fID, '%f%f%d%s%s%f%s%s%s%*s%*s%*s', 'HeaderLines', 1, 'Delimiter', '\t', 'TreatAsEmpty', 'n/a');
            fclose(fID);
            onsets{1}	 = Trials{1,1}(logical(strcmp(Trials{1,4}, 'cue') .* strcmp(Trials{1,5}, 'Catch') .* strcmp(Trials{1,9}, 'Hit')))';
            onsets{2}	 = Trials{1,1}(logical(strcmp(Trials{1,4}, 'cue') .* strcmp(Trials{1,5}, 'Ext') .* strcmp(Trials{1,9}, 'Hit')))';
            onsets{3}	 = Trials{1,1}(logical(strcmp(Trials{1,4}, 'cue') .* strcmp(Trials{1,5}, 'Int2') .* strcmp(Trials{1,9}, 'Hit')))';
            onsets{4}	 = Trials{1,1}(logical(strcmp(Trials{1,4}, 'cue') .* strcmp(Trials{1,5}, 'Int3') .* strcmp(Trials{1,9}, 'Hit')))';
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
                fprintf('Onsets: %f, Report: %f, FuncImage: %f, ConfTs: %f \n', ex1, ex2, ex3, ex4)
                Sel(n) = false;
            end
            % 5: Lack of run correspondece between beh and func image, or between func image and confound timeseries
            if ~isempty(FuncImg{1}) && ~isempty(ConfTs{1})        % Participants whose runs of task and fmri do not correspond with each other
                taskRunID = extractBetween(EventsTsv{1}, '_run-', '_events');
                fmriRunID = extractBetween(FuncImg{1}, '_run-', '_space');
                conftsRunID = extractBetween(ConfTs{1}, '_run-', '_desc');
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
        Files = [Files; cellstr(FuncImg{size(FuncImg,1)})]; % Selects the last run if there are multiple ones!
    end
end

% % 7: Fewer volumes than recorded pulses (time consuming)
% Sel = true(size(Files,1),1);
% for n = 1:numel(Files)
%     s = char(extractBetween(Files{n}, 'fmriprep/', '/ses'));    % Pseudonym
%     v = char(extractBetween(Files{n}, [s '_'], '_task'));       % Visit
%     r = char(extractBetween(Files{n}, 'run-', '_space'));       % Run
%     TaskDir             = fullfile(BIDSDir, s, v, 'beh');
%     EventsJsonFile      = spm_select('FPList', TaskDir, [s, '_', v, '_task-motor_acq-MB6_run-', r, '_events.json']);
%     ConfFile            = spm_select('FPList', fileparts(Files{n}), ['.*_task-motor_acq-MB6_run-' r '.*desc-confounds_timeseries.tsv']);
%     [NrPulses, NrConf] = checkpulsediff(EventsJsonFile, ConfFile);
%     if NrPulses > NrConf
%         fprintf('Number of recorded pulses exceeds volumes in func img. Skipping %s %s \n', s, v)
%         Sel(n) = false;
%     end
% end
% Files = Files(Sel);

Inputs	= cell(6,1);
JobFile = {spm_file(mfilename('fullpath'), 'suffix','_job', 'ext','.m')};
%JobFile = {'/home/sysneu/marjoh/scripts/Personalized-Parkinson-Project-Motor/motor/motor_1stlevel_job.m'};
% Specify inputs to 1st-level analyses
for n = 1:numel(Files)
    s = char(extractBetween(Files{n}, 'fmriprep/', '/ses'));    % Pseudonym
    v = char(extractBetween(Files{n}, [s '_'], '_task'));       % Visit
    r = char(extractBetween(Files{n}, 'run-', '_space'));       % Run
    if ~istrue(preAROMA)
        ConfFile            = spm_select('FPList', fileparts(Files{n}), ['.*_task-motor_acq-MB6_run-' r '.*desc-confounds_timeseries3.tsv']);
        if isempty(ConfFile)
            ConfFile            = spm_select('FPList', fileparts(Files{n}), ['.*_task-motor_acq-MB6_run-' r '.*desc-confounds_timeseries2.tsv']);
        end
    else
        ConfFile            = spm_select('FPList', fileparts(Files{n}), ['.*_task-motor_acq-MB6_run-' r '.*desc-confounds_timeseries.tsv']);
    end
    SourceNii           = Files{n};
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
    
    % Copy functional image
    copyfile(SourceNii, SPMDir)
    InputNii = strrep(SourceNii, strcat(FMRIPrep, ['/' s '/' v], '/func'), SPMDir);
    
    [~, ~, Ext] = fileparts(SourceNii);
    if strcmp(Ext, '.gz')
        gunzip(InputNii)
        delete(InputNii)
        InputNii = strrep(InputNii, 'nii.gz', 'nii');
    end
	
	% Change Directory: Directory - cfg_files
    Inputs{1}{n} = {SPMStatDir};
	
	% Smooth: Images to smooth - cfg_files
    Inputs{2}{n} = {InputNii};
	
	% fMRI model specification: Directory - cfg_files
    Inputs{3}{n} = {SPMStatDir};

	% fMRI model specification: Interscan interval - cfg_entry
    Inputs{4}{n} = 1;
	
	% fMRI model specification: Multiple conditions - cfg_files
    StimulusEvents	= extract_onsets_and_duration_pm(EventsTsvFile, 1);
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
    
end

% Run jobs interactively
%for n = 1:numel(Files)
%    spm_jobman('run', JobFile, Inputs{1}{n}, Inputs{2}{n}, Inputs{3}{n}, Inputs{4}{n}, Inputs{5}{n}, Inputs{6}{n})
%end

% Submit to cluster
if numel(Files)==1
	spm_jobman('run', JobFile, Inputs{1}{1}, Inputs{2}{1}, Inputs{3}{1}, Inputs{4}{1}, Inputs{5}{1}, Inputs{6}{1});
else
  	qsubcellfun('spm_jobman', repmat({'run'},[1 numel(Files)]), repmat(JobFile,[1 numel(Files)]), Inputs{:}, 'memreq',5*1024^3, 'timreq',3*60*60, 'StopOnError',false, 'options','-l gres=bandwidth:1000');
end

% Clean up copied functional images
for n = 1:numel(Inputs{2})
    dImg = cell2mat(Inputs{2}{n});
    ImagesToDelete = cellstr(spm_select('FPList', fileparts(dImg), '^sub.*.nii'));
    if ~isempty(ImagesToDelete)
        for i = 1:numel(ImagesToDelete)
            delete(ImagesToDelete{i})
        end
    end
end

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