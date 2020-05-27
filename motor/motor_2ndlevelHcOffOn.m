% Move contrast images from PIT and POM to a single location within the POM
% project folder and label them according to group.

function motor_2ndlevelHcOffOn(Swap)
%% Swap

if nargin<1 || isempty(Swap)
	Swap = false;               % A left-right swap of the con-images
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
SubPIT = spm_BIDS(PITBIDSDir, 'subjects', 'task', 'motor');
SubPOM = spm_BIDS(POMBIDSDir, 'subjects', 'task', 'motor');
Sub = [SubPIT SubPOM];
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

%% Copy and flip

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
        if strcmp(Group(n), 'PDoff')
            OutputConFile = fullfile(ConDir, ['PDoff_' Sub{n} '_' ConList{c} '.nii']);
        elseif strcmp(Group(n), 'PDon')
            OutputConFile = fullfile(ConDir, ['PDon_' Sub{n} '_' ConList{c} '.nii']);
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

Inputs = cell(14, 1);
Inputs{1,1} = {fullfile(ANALYSESDir, 'Group', 'HcOffOn x ExtInt2Int3Catch')};

ExtHc = dir(fullfile(ANALYSESDir, 'Group', ConList{1}, 'Hc*'));
Inputs{2,1} = fullfile(ANALYSESDir, 'Group', ConList{1}, {ExtHc.name}');
Int2Hc = dir(fullfile(ANALYSESDir, 'Group', ConList{2}, 'Hc*'));
Inputs{5,1} = fullfile(ANALYSESDir, 'Group', ConList{2}, {Int2Hc.name}');
Int3Hc = dir(fullfile(ANALYSESDir, 'Group', ConList{3}, 'Hc*'));
Inputs{8,1} = fullfile(ANALYSESDir, 'Group', ConList{3}, {Int3Hc.name}');
CatchHc = dir(fullfile(ANALYSESDir, 'Group', ConList{4}, 'Hc*'));
Inputs{11,1} = fullfile(ANALYSESDir, 'Group', ConList{4}, {CatchHc.name}');

ExtPd = dir(fullfile(ANALYSESDir, 'Group', ConList{1}, 'PDoff*'));
Inputs{3,1} = fullfile(ANALYSESDir, 'Group', ConList{1}, {ExtPd.name}');
Int2Pd = dir(fullfile(ANALYSESDir, 'Group', ConList{2}, 'PDoff*'));
Inputs{6,1} = fullfile(ANALYSESDir, 'Group', ConList{2}, {Int2Pd.name}');
Int3Pd = dir(fullfile(ANALYSESDir, 'Group', ConList{3}, 'PDoff*'));
Inputs{9,1} = fullfile(ANALYSESDir, 'Group', ConList{3}, {Int3Pd.name}');
CatchPd = dir(fullfile(ANALYSESDir, 'Group', ConList{4}, 'PDoff*'));
Inputs{12,1} = fullfile(ANALYSESDir, 'Group', ConList{4}, {CatchPd.name}');

ExtPd = dir(fullfile(ANALYSESDir, 'Group', ConList{1}, 'PDon*'));
Inputs{4,1} = fullfile(ANALYSESDir, 'Group', ConList{1}, {ExtPd.name}');
Int2Pd = dir(fullfile(ANALYSESDir, 'Group', ConList{2}, 'PDon*'));
Inputs{7,1} = fullfile(ANALYSESDir, 'Group', ConList{2}, {Int2Pd.name}');
Int3Pd = dir(fullfile(ANALYSESDir, 'Group', ConList{3}, 'PDon*'));
Inputs{10,1} = fullfile(ANALYSESDir, 'Group', ConList{3}, {Int3Pd.name}');
CatchPd = dir(fullfile(ANALYSESDir, 'Group', ConList{4}, 'PDon*'));
Inputs{13,1} = fullfile(ANALYSESDir, 'Group', ConList{4}, {CatchPd.name}');

FD_hc = FD(strcmp(Group, 'Healthy'));
FD_PDoff = FD(strcmp(Group, 'PDoff'));
FD_PDon = FD(strcmp(Group, 'PDon'));
Inputs{14,1} = [FD_hc FD_hc FD_hc FD_hc FD_PDoff FD_PDoff FD_PDoff FD_PDoff FD_PDon FD_PDon FD_PDon FD_PDon]';

%% Run

JobFile = {spm_file(mfilename('fullpath'), 'suffix','_job', 'ext','.m')};

delete(fullfile(char(Inputs{1}), '*.*'))
spm_jobman('run', JobFile, Inputs{:});

end

