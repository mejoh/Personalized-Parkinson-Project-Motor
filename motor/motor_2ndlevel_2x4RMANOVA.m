% Move contrast images from PIT and POM to a single location within the POM
% project folder and label them according to group.

function motor_2ndlevel_2x4RMANOVA(Swap,Offstate)
%% Swap

if nargin<1 || isempty(Swap)
	Swap = false;               % A left-right swap of the con-images
end

%% Group to comapre against controls

if isempty(Offstate)
    Offstate = false;
end

%% Paths

addpath('/home/common/matlab/spm12');
spm('defaults', 'FMRI');

%% Directories

FDThresh = 0.3;
ANALYSESDir = '/project/3022026.01/analyses/motor/fMRI_EventRelated_Main';
% ANALYSESDir = '/project/3022026.01/analyses/motor/fMRI_EventRelated_BRCtrl';
PITBIDSDir = '/project/3024006.01/bids';
POMBIDSDir = '/project/3022026.01/bids';
if Offstate
    Sub = spm_BIDS(PITBIDSDir, 'subjects', 'task', 'motor');
else
    Sub = spm_BIDS(POMBIDSDir, 'subjects', 'task', 'motor');
end
fprintf('Number of subjects processed: %i\n', numel(Sub))

%% Selection

SubSel = false(size(Sub));

% Exclude participants without 1st-level analyses
for n = 1:numel(Sub)
    if spm_select('List', fullfile(ANALYSESDir, ['sub-' Sub{n}], '1st_level'), '^con.*\.nii$')
        fprintf('Including sub-%s with previous SPM output\n', Sub{n})
        SubSel(n) = true;
    else
        fprintf('Excluding sub-%s without previous SPM output\n', Sub{n})
    end
end

% Take the last run for each participant if you're analzying POM data
Run = num2str(ones(numel(Sub),1));
if ~Offstate
    for MultRunSub = spm_BIDS(POMBIDSDir, 'subjects', 'run','2', 'task','motor')
        if ~isempty(MultRunSub)
            fprintf('Altering run-number for sub-%s with run-2 data\n', char(MultRunSub))
            index = strcmp(Sub,MultRunSub);
            Run(index,1) = '2';
        else
            fprintf('No subjects with run-2 data\n')
        end
    end
    for MultRunSub = spm_BIDS(POMBIDSDir, 'subjects', 'run','3', 'task','motor')
        if ~isempty(MultRunSub)
            fprintf('Altering run-number for sub-%s with run-3 data\n', char(MultRunSub))
            index = strcmp(Sub,MultRunSub);
            Run(index,1) = '3';
        else
            fprintf('No subjects with run-3 data\n')
        end
    end
end

Sub = Sub(SubSel);
Run = Run(SubSel);

%% Collect events.json and confound files

JsonFiles = cell(size(Sub));
ConfFiles = cell(size(Sub));

for n = 1:numel(Sub)
    if strncmp('PIT',Sub{n},3)
        JsonFiles{n} = spm_select('FPList', fullfile(PITBIDSDir, ['sub-', Sub{n}], 'func'), ['.*task-motor_acq-MB6_run-' Run(n) '_events\.json$']);
    else
        JsonFiles{n} = spm_select('FPList', fullfile(POMBIDSDir, ['sub-', Sub{n}], 'func'), ['.*task-motor_acq-MB6_run-' Run(n) '_events\.json$']);
    end
    ConfFiles{n} = spm_select('FPList', fullfile(ANALYSESDir, ['sub-' Sub{n}]), ['^.*task-motor_acq-MB6_run-' Run(n) '.*desc-confounds_regressors2.mat$']);
end

%% Group and handedness

Group = strings(size(Sub));
RespondingHand = strings(size(Sub));

for n = 1:numel(Sub)
    Json = fileread(JsonFiles{n});
    DecodedJson = jsondecode(Json);
    Group(n) = DecodedJson.Group.Value;
    RespondingHand(n) = DecodedJson.RespondingHand.Value;
end

%% Framewise displacement

FD = zeros(size(Sub));
for n = 1:numel(Sub)
    Confounds = spm_load(ConfFiles{n});
    FrameDisp = Confounds.R(:,strcmp(Confounds.names, 'framewise_displacement'));
    FrameDisp(isnan(FrameDisp)) = 0;
    FD(n) = mean(FrameDisp);
end

%% Exclusion

SubSel = false(size(Sub));

for n = 1:numel(Sub)
    if FD(n) < FDThresh
        SubSel(n) = true;
    else
        sprintf('Excluding %s (%s) due to %f mean framewise displacement (Threshold = %f)', Sub{n}, Group(n), FD(n), FDThresh)
    end
end

Sub = Sub(SubSel);
Group = Group(SubSel);
RespondingHand = RespondingHand(SubSel);
FD = FD(SubSel);

%% Examine correlation structure between relevant regressors

% CorrMat = zeros(4);
%     
% for n = 1:numel(Sub)
%     SPMmat = load(fullfile(ANALYSESDir, ['sub-' Sub{n}], '1st_level', 'SPM.mat'));
%     LastReg = find(contains(SPMmat.SPM.xX.name, 'Sn(1) Int3*bf(1)'));
%     CovMat = cov(SPMmat.SPM.xX.X(:,1:LastReg));
%     CorrMat = CorrMat + corrcov(CovMat);
%     
% end
% 
% AvgCorrMat = CorrMat / numel(Sub);
% heatmap(AvgCorrMat)

%% Copy and left-to-right swap

ConList = {'con_0001' 'con_0002' 'con_0003' 'con_0004'};% 'con_0005'};
InputFiles = cell(numel(Sub), numel(ConList));
for c = 1:numel(ConList)
    
    ConDir = fullfile(ANALYSESDir, 'Group', ConList{c});
    if ~exist(ConDir, 'dir')
        mkdir(ConDir);
    else
        delete(fullfile(ConDir, '*.*'));
    end
    
    for n = 1:numel(Sub)
        InputConFile = fullfile(ANALYSESDir, ['sub-' Sub{n}], '1st_level', [ConList{c} '.nii']);
        if ~strcmp(Group(n), 'Healthy') && Offstate
            OutputConFile = fullfile(ConDir, ['Off_' Sub{n} '_' ConList{c} '.nii']);
        elseif ~strcmp(Group(n), 'Healthy') && ~Offstate
            OutputConFile = fullfile(ConDir, ['On_' Sub{n} '_' ConList{c} '.nii']);
        else
            OutputConFile = fullfile(ConDir, ['Hc_' Sub{n} '_' ConList{c} '.nii']);
        end
        copyfile(InputConFile, OutputConFile)
        if strcmp(RespondingHand(n), 'Left') && Swap
            fprintf('LR-swapping: %s\n', OutputConFile)
			Hdr		  = spm_vol(OutputConFile);
			Vol		  = spm_read_vols(Hdr);
			Hdr.fname = spm_file(OutputConFile, 'suffix', 'LRswap');
			spm_write_vol(Hdr, flipdim(Vol,1));		% LR is the first dimension in MNI space
            delete(OutputConFile);
            InputFiles{n,c} = Hdr.fname;
        else
            InputFiles{n,c} = OutputConFile;
        end
    end
end

%% Assemble inputs
Inputs = cell(11,1);
if Offstate
    Inputs{1,1} = {fullfile(ANALYSESDir, 'Group', 'HcOff x ExtInt2Int3Catch')};
else
    Inputs{1,1} = {fullfile(ANALYSESDir, 'Group', 'HcOn x ExtInt2Int3Catch')};
end

ExtHc = dir(fullfile(ANALYSESDir, 'Group', ConList{1}, 'Hc*'));
Inputs{2,1} = fullfile(ANALYSESDir, 'Group', ConList{1}, {ExtHc.name}');
Int2Hc = dir(fullfile(ANALYSESDir, 'Group', ConList{2}, 'Hc*'));
Inputs{4,1} = fullfile(ANALYSESDir, 'Group', ConList{2}, {Int2Hc.name}');
Int3Hc = dir(fullfile(ANALYSESDir, 'Group', ConList{3}, 'Hc*'));
Inputs{6,1} = fullfile(ANALYSESDir, 'Group', ConList{3}, {Int3Hc.name}');
CatchHc = dir(fullfile(ANALYSESDir, 'Group', ConList{4}, 'Hc*'));
Inputs{8,1} = fullfile(ANALYSESDir, 'Group', ConList{4}, {CatchHc.name}');

if Offstate
    Pd = 'Off*';
else
    Pd = 'On*';
end
ExtPd = dir(fullfile(ANALYSESDir, 'Group', ConList{1}, Pd));
Inputs{3,1} = fullfile(ANALYSESDir, 'Group', ConList{1}, {ExtPd.name}');
Int2Pd = dir(fullfile(ANALYSESDir, 'Group', ConList{2}, Pd));
Inputs{5,1} = fullfile(ANALYSESDir, 'Group', ConList{2}, {Int2Pd.name}');
Int3Pd = dir(fullfile(ANALYSESDir, 'Group', ConList{3}, Pd));
Inputs{7,1} = fullfile(ANALYSESDir, 'Group', ConList{3}, {Int3Pd.name}');
CatchPd = dir(fullfile(ANALYSESDir, 'Group', ConList{4}, Pd));
Inputs{9,1} = fullfile(ANALYSESDir, 'Group', ConList{4}, {CatchPd.name}');

FD_hc = FD(find(ismember(Group, 'Healthy')));
if Offstate
    FD_pd = FD(find(ismember(Group, 'PDoff')));
else
    FD_pd = FD(find(ismember(Group, 'PDon')));
end
Inputs{10,1} = [FD_hc FD_hc FD_hc FD_hc FD_pd FD_pd FD_pd FD_pd]';

%% Run

JobFile = {spm_file(mfilename('fullpath'), 'suffix','_job', 'ext','.m')};

delete(fullfile(char(Inputs{1}), '*.*'))
spm_jobman('run', JobFile, Inputs{:});

end
