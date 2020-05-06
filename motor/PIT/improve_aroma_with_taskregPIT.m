%%%%% ----- Description ----- %%%%%
% Based on motor_1st level.m
% Generates first-level task regressors
% 1. Extract onsets
% 2. Convolve with HRF
% 3. Store in SPM.mat

function Inputs = improve_aroma_with_taskreg(Force)

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

addpath('/project/3024006.01/bids/code/spm');
addpath('/home/common/matlab/fieldtrip/qsub');
addpath('/home/common/matlab/spm12');
spm('defaults', 'FMRI');

Root	 = '/project/3024006.01';
BIDSDir  = fullfile(Root, 'bids');
%TaskDir  = fullfile(Root, 'DataTask');             % POM
FMRIPrep = fullfile(BIDSDir, 'derivatives/motor/fmriprep');
SPMder   = fullfile(BIDSDir, 'derivatives/motor/spm');
BIDS     = spm_BIDS(BIDSDir);
AllSub      = spm_BIDS(BIDS, 'subjects', 'ses','mri01', 'task','motor');
Session  = ['ses-mri01'];
fprintf('Found %i subjects with ses=mri01 and task=motor\n', numel(AllSub))
% Skip ambiguous multiple runs/series cases (for now)
for AmbigSub = spm_BIDS(BIDS, 'subjects', 'run','2', 'task','motor')
	fprintf('Skipping sub-%s with ambiguous run-2 data\n', char(AmbigSub))
	AllSub(strcmp(char(AmbigSub), AllSub)) = [];
end

% Skip ambiguous POM identifiers
Sel = true(size(AllSub));
for n = 1:numel(AllSub)
    SearchDir    = fullfile(Root, 'raw', ['sub-' AllSub{n}], Session,  '*motor_behav');            % PIT
    BehavDir = dir(SearchDir);
    TaskDir = fullfile(Root, 'raw', ['sub-' AllSub{n}], Session, BehavDir.name);
	PresLog    = spm_select('FPList', TaskDir, [AllSub{n} '_(t|T)ask.*_logfile\.txt$']);		% TODO: solve multiple files cases
	PresLogRaw = spm_select('FPList', TaskDir, [AllSub{n} '_(t|T)ask.*-MotorTaskEv_.*\.log$']);
	if size(PresLog,1) ~= 1
		fprintf('Skipping sub-%s with %i logfile(s):\n', AllSub{n}, size(PresLog,1))
		disp(PresLog)
		Sel(n) = false;
	end
	if size(PresLogRaw,1) ~= 1
		fprintf('Skipping sub-%s with %i logfile(s):\n', AllSub{n}, size(PresLogRaw,1))
		disp(PresLogRaw)
		Sel(n) = false;
	end
end

% Skip unfinished frmiprep jobs
for n = 1:numel(AllSub)
	Report = spm_select('FPList', FMRIPrep, ['sub-' AllSub{n} '.*\.html$']);
	if size(Report,1)~=1
		fprintf('Skipping sub-%s with no fmriprep output\n', AllSub{n})
		disp(Report)
		Sel(n) = false;
	end
	
	ConfFile = spm_select('FPList', fullfile(FMRIPrep, ['sub-' AllSub{n}], 'ses-mri01', 'func'), ['sub-' AllSub{n} '.*task-motor.*_desc-confounds_regressors.tsv$']);
	if size(ConfFile,1)~=1
		fprintf('Skipping sub-%s with no fmriprep confounds\n', AllSub{n})
		Sel(n) = false;
	end
	
	SrcNii = spm_select('FPList', fullfile(FMRIPrep, ['sub-' AllSub{n}], 'ses-mri01', 'func'), ['sub-' AllSub{n} '.*task-motor.*_space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz$']);
	if size(SrcNii,1)~=1
		fprintf('Skipping sub-%s with no fmriprep images\n', AllSub{n})
		Sel(n) = false;
	end
end

% Skip already processed jobs
Sel1 = Sel;
if ~Force
	for n = 1:numel(AllSub)
		if spm_select('List', fullfile(SPMder, ['sub-' AllSub{n}], 'motor'), '^SPM.*\.mat$')
			fprintf('Skipping sub-%s with SPM.mat file\n', AllSub{n})
			Sel1(n) = false;
		end
	end
end
Sub = AllSub(Sel1);
Files   = spm_BIDS(BIDS, 'data', 'sub',Sub, 'ses','mri01', 'task','motor');
Meta	= spm_BIDS(BIDS, 'metadata', 'sub',Sub, 'ses','mri01', 'task','motor', 'type','bold');
Inputs	= cell(6,1);
JobFile = {spm_file(mfilename('fullpath'), 'suffix','_job', 'ext','.m')};
NrSub	= numel(Sub);
fprintf('Analyzing %i subjects\n', NrSub)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%% Generate taskregressors %%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for n = 1:NrSub
    SearchDir    = fullfile(Root, 'raw', ['sub-' Sub{n}], Session,  '*motor_behav');            
    BehavDir = dir(SearchDir);
    TaskDir = fullfile(Root, 'raw', ['sub-' Sub{n}], Session, BehavDir.name);
	% Collect the sub/ses/files
	ConfFile   = strrep(strrep(Files{n}, BIDSDir, FMRIPrep), '_bold.nii.gz', '_desc-confounds_regressors.tsv');
	SrcNii	   = strrep(strrep(Files{n}, BIDSDir, FMRIPrep), '_bold.nii.gz', '_space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz');
	InNii      = strrep(strrep(SrcNii,'.gz',''), FMRIPrep, SPMder);
	SPMDir     = fullfile(SPMder, ['sub-' Sub{n}], 'motor');
	PresLog    = spm_select('FPList', TaskDir, [Sub{n} '_(t|T)ask.*_logfile\.txt$']);
	PresLogRaw = spm_select('FPList', TaskDir, [Sub{n} '_(t|T)ask.*-MotorTaskEv_.*\.log$']);
	InMat      = spm_file(PresLog, 'path',SPMDir, 'ext','.mat');

	% Start with a clean SPM output directory
	if ~exist(SPMDir,'dir')
		mkdir(SPMDir)
	else
		delete(fullfile(SPMDir,'*.*'))
	end
	
	% Reuse a previously unzipped source/input file or unzip it
	if ~exist(InNii, 'file')
		disp(['Unzipping: ' SrcNii])
		gunzip(SrcNii, fileparts(InNii))
	end
	
	% Change Directory: Directory - cfg_files
    Inputs{1}{n} = {SPMDir};
	
	% fMRI model specification: Directory - cfg_files
    Inputs{2}{n} = {SPMDir};

	% fMRI model specification: Interscan interval - cfg_entry
    Inputs{3}{n} = Meta{n}.RepetitionTime;
    
    % fMRI model specification: Scans - cfg_files
    Inputs{4}{n} = {InNii};
	
	% fMRI model specification: Multiple conditions - cfg_files
    InMat		 = extract_onsets_and_duration(PresLog, InMat, Meta{n}.RepetitionTime);
    Inputs{5}{n} = {InMat};
	
	% fMRI model specification: Multiple regressors - cfg_files
	NrPulses	 = getnrpulses(PresLogRaw);
	Covar		 = non_gm_covariates_fmriprep(ConfFile, InMat, NrPulses);
    Inputs{6}{n} = {Covar};
    
    spm_jobman('run', JobFile, Inputs{1}{n}, Inputs{2}{n}, Inputs{3}{n}, Inputs{4}{n}, Inputs{5}{n}, Inputs{6}{n});
    
end

% Skip already processed jobs
Sel2 = Sel;
if ~Force
	for n = 1:numel(AllSub)
		if spm_select('FPList', fullfile(SPMder, ['sub-' AllSub{n}], 'motor'), '.*taskregAROMA_table.*\.txt$')
			fprintf('Skipping sub-%s with previous multiple regression output\n', AllSub{n})
			Sel2(n) = false;
		end
	end
end
Sub = AllSub(Sel2);
Files   = spm_BIDS(BIDS, 'data', 'sub',Sub, 'ses','mri01', 'task','motor');
NrSub	= numel(Sub);
fprintf('Analyzing %i subjects\n', NrSub)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%% Motion ~ Task regressors %%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for n = 1:NrSub
    % Load necessary data
    SPMmatFile          = fullfile(SPMder, ['sub-' Sub{n}], 'motor',  'SPM.mat');
    SPMvar              = load(SPMmatFile);
    MixingMatrixFile    = strrep(strrep(Files{n}, BIDSDir, FMRIPrep), '_bold.nii.gz', '_desc-MELODIC_mixing.tsv');
    NoiseCompFile       = strrep(strrep(Files{n}, BIDSDir, FMRIPrep), '_bold.nii.gz', '_AROMAnoiseICs.csv');
    
    TaskRegs        = SPMvar.SPM.xX.X(:,1:4);
    MixingMatrix    = spm_load(MixingMatrixFile);
    CompMotionClass = csvread(NoiseCompFile);
    
    % Extract motion-classified components from mixing matrix
    for t = 1:numel(CompMotionClass)
        
        RegNr               = CompMotionClass(t);
        RegTS               = MixingMatrix(:,RegNr);
        CompMotionTS(:,t)   = RegTS;
        
    end
    
    % Multiple regression of task regressors on motion comp tss
    for r = 1:numel(CompMotionClass)
        
        Corrmat(r,1) = corr(TaskRegs(:,1),CompMotionTS(:,r));
        Corrmat(r,2) = corr(TaskRegs(:,2),CompMotionTS(:,r));
        Corrmat(r,3) = corr(TaskRegs(:,3),CompMotionTS(:,r));
        Corrmat(r,4) = corr(TaskRegs(:,4),CompMotionTS(:,r));
        
%         CorrmatMax(r,:) = max(Corrmat(r,:));
        
        Fitted        = fitlm(TaskRegs, CompMotionTS(:,r));
        CorrmatRSquared(r,:)  = Fitted.Rsquared.Adjusted;
        
    end
    
    FigFileName = fullfile(SPMder, ['sub-' Sub{n}], 'motor', ['sub-' Sub{n} '_' Session '_task-motor_taskregAROMA.png']);
    Figure = figure('visible','off','Position',[10 10 1000 800]);
    subplot(1,3,1);
    imagesc(abs(Corrmat));
    set(gca, 'XTick', 1:4);
    xnames = {'Catch';'Ext';'Int2';'Int3'};
    set(gca, 'XTickLabel', xnames);
    title('r');
    xlabel('Condition');
    ylabel('Component classified as noise')
    colormap('hot');
    colorbar;
    subplot(1,3,2);
    imagesc(abs(CorrmatRSquared));              % Display absolute values
    set(gca, 'XTick', 0);
    title('Adj. R²');
    ylabel('Component classified as noise')
    colormap('hot');
    colorbar;
    saveas(Figure, FigFileName);
%     subplot(1,3,3);
%     imagesc(abs(CorrmatMax));              % Display absolute values
%     set(gca, 'XTick', 0);
%     title('Maximum r');
%     ylabel('Component classified as noise')
%     colormap('hot');
%     colorbar;
    saveas(Figure, FigFileName);
    
    TableFileName = fullfile(SPMder, ['sub-' Sub{n}], 'motor', ['sub-' Sub{n} '_' Session '_task-motor_taskregAROMA_table']);
    Thr = 0.05;
    Component = CompMotionClass(CorrmatRSquared > Thr)';
    AdjRSquared = CorrmatRSquared(CorrmatRSquared > Thr);
    RnCompAboveThr = table(Component,AdjRSquared);
    writetable(RnCompAboveThr,TableFileName);
 	clear vars CompMotionTS Corrmat CorrmatRSquared CorrmatMax
end

% if NrSub==1
% 	spm_jobman('run', JobFile, Inputs{1}{1}, Inputs{2}{1}, Inputs{3}{1}, Inputs{4}{1}, Inputs{5}{1}, Inputs{6}{1});
% else
%  	qsubcellfun('spm_jobman', repmat({'run'},[1 NrSub]), repmat(JobFile,[1 NrSub]), Inputs{:}, 'memreq',2*1024^3, 'timreq',3*60*60, 'StopOnError',false, 'options','-l gres=bandwidth:1000');
% end


function NrPulses = getnrpulses(LogFile)

% Read in the raw Presentation logfile
HeaderLines = 5;
Type		= 3;									% Column number containg event type
Time		= 5;									% Column number containg time
FID			= fopen(LogFile);
Events		= textscan(FID, '%s\t%f\t%s\t%s\t%f\t%*f\t%*f\t%*f\t%*f\t%*f\t%*s\t%s\t%*f', 'HeaderLines',HeaderLines, 'Delimiter','\t', 'TreatAsEmpty','NA');	% POM1FM0226304_task1	1	Picture	5				10333	0	1	139622	2	0	next	hit		2
fclose(FID);

% Count the nr of scanner pulses
NrPulses = numel(Events{Time}(strcmp(Events{Type},'Pulse')));
