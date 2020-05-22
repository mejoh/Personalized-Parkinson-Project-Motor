function Inputs = motor_1stlevel(Force, ParkinsonOpMaat, Subset)

% No arguments: Runs 1st-level for PIT participants who have not been processed
% Force: Reruns 1st-levels
% POM: Leave empty to process PIT, fill to process POM
% Subset: Number of jobs to send to the cluster

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

PIT = '3024006.01';
POM = '3022026.01';

if nargin <1 || isempty(ParkinsonOpMaat)
    Project = PIT;
else
    Project = POM;
end
fprintf('Processing data in project: %s\n', Project)
Root = strcat('/project/', Project);
BIDSDir  = fullfile(Root, 'bids');
FMRIPrep = fullfile(BIDSDir, 'derivatives/fmriprep');
ANALYSESDir   = strcat('/project/', POM, '/analyses/motor/fMRI_EventRelated_Main');  %<< DurAvg, ReAROMA, no time der, no PMOD, no BPreg
%ANALYSESDir   = strcat('/project/', POM, '/analyses/motor/fMRI_EventRelated_BPCtrl');  %<< DurAvg, ReAROMA, BPreg, no time der, no PMOD
BIDS     = spm_BIDS(BIDSDir);
Sub      = spm_BIDS(BIDS, 'subjects', 'task','motor');
fprintf('Found %i subjects with task=motor\n', numel(Sub))

% Account for subjects with multiple runs (maximum of 3 runs, check whether this is appropriate beforehand)
Run = num2str(ones(numel(Sub),1));
for MultRunSub = spm_BIDS(BIDS, 'subjects', 'run','2', 'task','motor')
    if ~isempty(MultRunSub)
        fprintf('Altering run-number for sub-%s with run-2 data\n', char(MultRunSub))
        index = strcmp(Sub,MultRunSub);
        Run(index,1) = '2';
    else
        fprintf('No subjects with run-2 data\n')
    end
end
for MultRunSub = spm_BIDS(BIDS, 'subjects', 'run','3', 'task','motor')
    if ~isempty(MultRunSub)
        fprintf('Altering run-number for sub-%s with run-3 data\n', char(MultRunSub))
        index = strcmp(Sub,MultRunSub);
        Run(index,1) = '3';
    else
        fprintf('No subjects with run-3 data\n')
    end
end

% % Skip ambiguous multiple runs/series cases (for now)
% for AmbigSub = spm_BIDS(BIDS, 'subjects', 'run','2', 'task','motor')
% 	fprintf('Skipping sub-%s with ambiguous run-2 data\n', char(AmbigSub))
% 	Sub(strcmp(char(AmbigSub), Sub)) = [];
% end

% Skip subs with missing events.tsv file
Sel = true(size(Sub));
for n = 1:numel(Sub)
    
    TaskDir = fullfile(BIDSDir, ['sub-' Sub{n}], 'func');
    EventsTsvFile = spm_select('FPList', TaskDir, ['sub-' Sub{n} '_task-motor_acq-MB6_run-' Run(n) '_events.tsv']);
	
    if size(EventsTsvFile,1) ~= 1
		fprintf('Skipping sub-%s with %i events.tsv files:\n', Sub{n}, size(EventsTsvFile,1))
		disp(EventsTsvFile)
		Sel(n) = false;
    end
    
end

% Skip unfinished frmiprep jobs
for n = 1:numel(Sub)
	Report = spm_select('FPList', FMRIPrep, ['sub-' Sub{n} '.*\.html$']);
	if size(Report,1)~=1
		fprintf('Skipping sub-%s with no fmriprep output\n', Sub{n})
		disp(Report)
		Sel(n) = false;
    end
	
	SourceNii = spm_select('FPList', fullfile(FMRIPrep, ['sub-' Sub{n}], 'func'), ['sub-' Sub{n} '_task-motor_acq-MB6_run-' Run(n) '_space-MNI152NLin6Asym_desc-preproc_bold.nii$']);
	if size(SourceNii,1)~=1
		fprintf('Skipping sub-%s with no fmriprep images\n', Sub{n})
		Sel(n) = false;
    end
    
    ConfFile = spm_select('FPList', fullfile(FMRIPrep, ['sub-' Sub{n}], 'func'), ['sub-' Sub{n} '_task-motor_acq-MB6_run-' Run(n) '_desc-confounds_regressors2.tsv$']);
	if size(ConfFile,1)~=1
		fprintf('Skipping sub-%s with no (customized) fmriprep confounds\n', Sub{n})
		Sel(n) = false;
	end
end

% Skip already processed jobs
if ~Force
	for n = 1:numel(Sub)
		if spm_select('List', fullfile(ANALYSESDir, ['sub-' Sub{n}], '1st_level'), '^con.*\.nii$')
			fprintf('Skipping sub-%s with previous SPM output\n', Sub{n})
			Sel(n) = false;
		end
	end
end
Sub = Sub(Sel);
Run = Run(Sel);

Files   = spm_BIDS(BIDS, 'data', 'sub', Sub, 'task', 'motor', 'type', 'bold');
Meta	= spm_BIDS(BIDS, 'metadata', 'sub', Sub, 'task', 'motor', 'type', 'bold');

Inputs	= cell(6,1);
JobFile = {spm_file(mfilename('fullpath'), 'suffix','_job', 'ext','.m')};

NrSub	= numel(Sub);
if ~isempty(Subset)
    if Subset > NrSub
        fprintf('Subset > Total nr participants. Processing total nr participants instead')
    else
        NrSub = Subset;
    end
end

fprintf('Analyzing %i subjects\n', NrSub)
for n = 1:NrSub

	% Collect files
	ConfFile        = strrep(strrep(Files{n}, BIDSDir, FMRIPrep), '_bold.nii.gz', '_desc-confounds_regressors2.tsv');
    SourceNii	    = strrep(strrep(Files{n}, BIDSDir, FMRIPrep), '_bold.nii.gz', '_space-MNI152NLin6Asym_desc-preproc_bold.nii');
    SPMDir          = fullfile(ANALYSESDir, ['sub-' Sub{n}]);
    SPMStatDir      = fullfile(ANALYSESDir, ['sub-' Sub{n}], '1st_level');
    TaskDir         = fullfile(BIDSDir, ['sub-' Sub{n}], 'func');
    EventsTsvFile   = spm_select('FPList', TaskDir, ['sub-' Sub{n} '_task-motor_acq-MB6_run-' Run(n) '_events.tsv']);
    EventsJsonFile   = spm_select('FPList', TaskDir, ['sub-' Sub{n} '_task-motor_acq-MB6_run-' Run(n) '_events.json']);
	InMat           = spm_file(EventsTsvFile, 'path',SPMDir, 'ext','.mat');

	% Start with a clean stats output directory
    if ~exist(SPMStatDir,'dir')
 		mkdir(SPMStatDir)
 	else
 		delete(fullfile(SPMStatDir,'*.*'))
    end
    
    % Copy functional image
    copyfile(SourceNii, SPMDir)
    InputNii = strrep(SourceNii, strcat(FMRIPrep, ['/sub-' Sub{n}], '/func'), SPMDir);
	
	% Change Directory: Directory - cfg_files
    Inputs{1}{n} = {SPMStatDir};
	
	% Smooth: Images to smooth - cfg_files
    Inputs{2}{n} = {InputNii};
	
	% fMRI model specification: Directory - cfg_files
    Inputs{3}{n} = {SPMStatDir};

	% fMRI model specification: Interscan interval - cfg_entry
    Inputs{4}{n} = Meta{n}.RepetitionTime;
	
	% fMRI model specification: Multiple conditions - cfg_files
    InMat		 = extract_onsets_and_duration_pm(EventsTsvFile, InMat, Meta{n}.RepetitionTime);
    Inputs{5}{n} = {InMat};
	
	% fMRI model specification: Multiple regressors - cfg_files
	NrPulses	 = getnrpulses(EventsJsonFile);
    Covar		 = non_gm_covariates_fmriprep(ConfFile, InMat, NrPulses);
    
    Inputs{6}{n} = {Covar};
	
end

if NrSub==1
	spm_jobman('run', JobFile, Inputs{1}{1}, Inputs{2}{1}, Inputs{3}{1}, Inputs{4}{1}, Inputs{5}{1}, Inputs{6}{1});
else
 	qsubcellfun('spm_jobman', repmat({'run'},[1 NrSub]), repmat(JobFile,[1 NrSub]), Inputs{:}, 'memreq',3.5*1024^3, 'timreq',3*60*60, 'StopOnError',false, 'options','-l gres=bandwidth:1000');
end

% Clean up copied functional images
for n = 1:NrSub
    Orig = cell2mat(Inputs{2}{n});
    Smoothed = cell2mat(strrep(Inputs{2}{n}, strcat(['sub-', Sub{n}], '_task-motor_acq-MB6'), strcat(['ssub-', Sub{n}], '_task-motor_acq-MB6')));
    if exist(Orig, 'file') || exist(Smoothed, 'file')
        delete(Orig)
        delete(Smoothed)
    end
end


function NrPulses = getnrpulses(EventsJsonFile)

Json = fileread(EventsJsonFile);
DecodedJson = jsondecode(Json);
NrPulses = DecodedJson.NPulses.Value;
