% Move contrast images from PIT and POM to a single location within the POM
% project folder and label them according to group.

function motor_2ndlevel_Ttests(Swap,Offstate)

%% Swap

if nargin<1 || isempty(Swap)
	Swap = false;               % A left-right swap of the con-images
end

%% Group to comapre against controls

if isempty(Offstate)
    Offstate = false;
end

%% Paths

addpath('/home/common/matlab/fieldtrip/qsub');
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
    SubPIT = spm_BIDS(PITBIDSDir, 'subjects', 'task', 'motor');
    SubPOM = spm_BIDS(POMBIDSDir, 'subjects', 'task', 'motor');
    Sub = [SubPIT SubPOM];
end
fprintf('Number of subjects processed: %i\n', numel(Sub))

CurrentDir = pwd;
cd(ANALYSESDir);

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

%% Copy and flip

% ConList = {'con_0006' 'con_0007' 'con_0009'};
ConList = {'con_0001' 'con_0002' 'con_0003' 'con_0006' 'con_0007' 'con_0009'};
NrCon = numel(ConList);

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
        if strcmp(Group(n), 'PD_PIT')
            OutputConFile = fullfile(ConDir, ['PD_PIT_' Sub{n} '_' ConList{c} '.nii']);
        elseif strcmp(Group(n), 'PD_POM')
            OutputConFile = fullfile(ConDir, ['PD_POM_' Sub{n} '_' ConList{c} '.nii']);
        else
            OutputConFile = fullfile(ConDir, ['HC_PIT_' Sub{n} '_' ConList{c} '.nii']);
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

inputs = cell(5, 1);
JobFile = {spm_file(mfilename('fullpath'), 'suffix','_job', 'ext','.m')};
ConNames   = {'Ext' 'Int2' 'Int3' 'Ext>Int' 'Int>Ext' 'Int3>Int2'};

for n = 1:NrCon
    ConDir = fullfile(ANALYSESDir, 'Group', ConList{n});
    if Offstate
        inputs{1,1} = {fullfile(ANALYSESDir, 'Group', 'Ttests_HcVsOff', ConNames{n})};
        HcIms = dir(fullfile(ConDir, 'HC_PIT*'));
        inputs{2,1} = fullfile(ConDir, {HcIms.name}');
        PdIms = dir(fullfile(ConDir, 'PD_PIT*'));
        inputs{3,1} = fullfile(ConDir, {PdIms.name}');
        inputs{5,1} = {fullfile(ANALYSESDir, 'Group', 'Ttests_HcVsOff', ConNames{n}, 'mask.nii,1')};
        FD = [FD(strcmp(Group, 'HC_PIT')) FD(strcmp(Group, 'PD_PIT'))];
    else
        inputs{1,1} = {fullfile(ANALYSESDir, 'Group', 'Ttests_HcVsOn', ConNames{n})};
        HcIms = dir(fullfile(ConDir, 'HC_PIT*'));
        inputs{2,1} = fullfile(ConDir, {HcIms.name}');
        PdIms = dir(fullfile(ConDir, 'PD_POM*'));
        inputs{3,1} = fullfile(ConDir, {PdIms.name}');
        inputs{5,1} = {fullfile(ANALYSESDir, 'Group', 'Ttests_HcVsOn', ConNames{n}, 'mask.nii,1')};
        FD = [FD(strcmp(Group, 'HC_PIT')) FD(strcmp(Group, 'PD_POM'))];
    end
    inputs{4,1} = (FD - mean(FD) / std(FD))';       %Normalize FD
    delete(fullfile(char(inputs{1}), '*.*'))
    %     spm_jobman('run', JobFile, inputs{:});
    jobs{n} =  qsubfeval('spm_jobman','run',JobFile, inputs{:},'memreq',5*1024^3,'timreq',8*60*60);
end

task.jobs = jobs;
task.submittime = datestr(clock);
task.mfile = mfilename;
task.mfiletext = fileread([task.mfile '.m']);
save([ANALYSESDir 'jobs___' task.mfile  '___' datestr(clock) '.mat'],'task');

cd(CurrentDir)

end

