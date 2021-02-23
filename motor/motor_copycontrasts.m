% Copy 1st-level contrasts to group directory in analysis folder

function motor_copycontrasts(Swap)
%% Swap

if nargin<1 || isempty(Swap)
	Swap = false;               % A left-right swap of the con-images
end

%% Paths

addpath('/home/common/matlab/spm12');
spm('defaults', 'FMRI');

%% Directories

FDThresh = 1;
ConList = {'con_0001' 'con_0002' 'con_0003' 'con_0004' 'con_0005' 'con_0006'};%  'con_0007'  'con_0008'  'con_0009'  'con_0010' 'con_0011'};
SessionList = {'ses-Visit1' 'ses-Visit3'};
% ANALYSESDir = '/project/3022026.01/analyses/motor/DurAvg_ReAROMA_PMOD_TimeDer';
ANALYSESDir = '/project/3022026.01/analyses/motor/DurAvg_ReAROMA_NoPMOD_TimeDer_BPCtrl';
BIDSDir = '/project/3022026.01/pep/bids';
BIDSDir_PIT = '/project/3022026.01/pep/bids_PIT';
Sub = cellstr(spm_select('List', fullfile(ANALYSESDir), 'dir', '^sub-POM.*'));
fprintf('Number of subjects processed: %i\n', numel(Sub))


%% Selection

% Take the last run for each participant's session(s)
% (necessary for finding the correct json and conf files)
Run = {};
Session = {};
Sub2 = {};
for n = 1:numel(Sub)
    Visit = cellstr(spm_select('List', fullfile(ANALYSESDir, Sub{n}), 'dir', 'ses-Visit*'));
    for v = 1:numel(Visit)
        if strcmp(Visit{v}, 'ses-Visit1_PIT')
            d = BIDSDir_PIT;
        elseif strcmp(Visit{v}, 'ses-Visit1') || strcmp(Visit{v}, 'ses-Visit3')
            d = BIDSDir;
        end
        Sub2 = [Sub2; {Sub{n}}];
        Session = [Session; {Visit{v}}];
        Run = [Run; {num2str(FindLastRun(d, Sub{n}, Visit{v}(1:10), 'motor', 'MB6'))}];
    end
end
SubInfo.Sub = Sub2;
SubInfo.Session = Session;
SubInfo.Run = Run;

%% Collect events.json and confound files

SubInfo.JsonFiles = cell(size(SubInfo.Sub));
SubInfo.ConfFiles = cell(size(SubInfo.Sub));

for n = 1:numel(SubInfo.Sub)
    if contains(SubInfo.Session{n}, 'PIT')
        SubInfo.JsonFiles{n} = spm_select('FPList', fullfile(BIDSDir_PIT, SubInfo.Sub{n}, SubInfo.Session{n}(1:10), 'beh'), ['.*task-motor_acq-MB6_run-' SubInfo.Run{n} '_events\.json$']);
    else
        SubInfo.JsonFiles{n} = spm_select('FPList', fullfile(BIDSDir, SubInfo.Sub{n}, SubInfo.Session{n}, 'beh'), ['.*task-motor_acq-MB6_run-' SubInfo.Run{n} '_events\.json$']);
    end
    SubInfo.ConfFiles{n} = spm_select('FPList', fullfile(ANALYSESDir, SubInfo.Sub{n}, SubInfo.Session{n}), ['^.*task-motor_acq-MB6_run-' SubInfo.Run{n} '_desc-confounds_regressors3.mat$']);
    if isempty(SubInfo.ConfFiles{n})
        SubInfo.ConfFiles{n} = spm_select('FPList', fullfile(ANALYSESDir, SubInfo.Sub{n}, SubInfo.Session{n}), ['^.*task-motor_acq-MB6_run-' SubInfo.Run{n} '_desc-confounds_regressors2.mat$']);
    end
end

%% Group and handedness

SubInfo.Group = strings(size(SubInfo.Sub));
SubInfo.RespondingHand = strings(size(SubInfo.Sub));
SubInfo.PercentageCorrect = strings(size(SubInfo.Sub));

for n = 1:numel(SubInfo.Sub)
    Json = fileread(SubInfo.JsonFiles{n});
    DecodedJson = jsondecode(Json);
    SubInfo.Group(n) = DecodedJson.Group.Value;
    if contains(SubInfo.Session{n}, 'PIT')
        d = BIDSDir_PIT;
        SubInfo.Group(n) = FindGroup(d, SubInfo.Sub{n}, SubInfo.Session{n}(1:10), 'dwi');
    else
        SubInfo.Group(n) = 'PD_POM';
    end
    SubInfo.RespondingHand(n) = DecodedJson.RespondingHand.Value;
    SubInfo.PercentageCorrect(n) = DecodedJson.ExtCorrResp.Value;
end

%% Framewise displacement

SubInfo.FD = zeros(size(SubInfo.Sub));
for n = 1:numel(SubInfo.Sub)
    Confounds = spm_load(SubInfo.ConfFiles{n});
    FrameDisp = Confounds.R(:,strcmp(Confounds.names, 'framewise_displacement'));
    FrameDisp(isnan(FrameDisp)) = 0;
    SubInfo.FD(n) = mean(FrameDisp);
end

%% Exclusion

% FD
Sel = true(size(SubInfo.Sub));
for n = 1:numel(SubInfo.Sub)
    if SubInfo.FD(n) > FDThresh
        Sel(n) = false;
        sprintf('Excluding %s (%s) due to %f mean framewise displacement (Threshold = %f) \n', SubInfo.Sub{n}, SubInfo.Group(n), SubInfo.FD(n), FDThresh)
    end
end
fprintf('%i participants excluded due to excessive motion \n', sum(Sel == 0))
SubInfo.Sub = SubInfo.Sub(Sel);
SubInfo.Session = SubInfo.Session(Sel);
SubInfo.Run = SubInfo.Run(Sel);
SubInfo.JsonFiles = SubInfo.JsonFiles(Sel);
SubInfo.ConfFiles = SubInfo.ConfFiles(Sel);
SubInfo.Group = SubInfo.Group(Sel);
SubInfo.RespondingHand = SubInfo.RespondingHand(Sel);
SubInfo.FD = SubInfo.FD(Sel);
SubInfo.PercentageCorrect = SubInfo.PercentageCorrect(Sel);

% Percentage correct responses in external
Sel = true(size(SubInfo.Sub));
for n = 1:numel(SubInfo.Sub)
    if double(SubInfo.PercentageCorrect(n)) <= 0.25
        Sel(n) = false;
        sprintf('Excluding %s (%s) due to %f percentage correct responses in External (Threshold = 25%) \n', SubInfo.Sub{n}, SubInfo.Group(n), SubInfo.PercentageCorrect(n))
    end
end
fprintf('%i participants excluded due to poor performance \n', sum(Sel == 0))
SubInfo.Sub = SubInfo.Sub(Sel);
SubInfo.Session = SubInfo.Session(Sel);
SubInfo.Run = SubInfo.Run(Sel);
SubInfo.JsonFiles = SubInfo.JsonFiles(Sel);
SubInfo.ConfFiles = SubInfo.ConfFiles(Sel);
SubInfo.Group = SubInfo.Group(Sel);
SubInfo.RespondingHand = SubInfo.RespondingHand(Sel);
SubInfo.FD = SubInfo.FD(Sel);
SubInfo.PercentageCorrect = SubInfo.PercentageCorrect(Sel);

%% Copy and flip

for c = 1:numel(ConList)
    ConDir = fullfile(ANALYSESDir, 'Group', ConList{c});
    if ~exist(ConDir, 'dir')
        mkdir(ConDir);
    else
        delete(fullfile(ConDir, '*.*'));
    end
    if ~exist(fullfile(ConDir, 'ses-Visit1'), 'dir')
        mkdir(fullfile(ConDir, 'ses-Visit1'))
    else
        delete(fullfile(ConDir, 'ses-Visit1', '*.*'));
    end
    if ~exist(fullfile(ConDir, 'ses-Visit3'), 'dir')
        mkdir(fullfile(ConDir, 'ses-Visit3'))
    else
        delete(fullfile(ConDir, 'ses-Visit3', '*.*'));
    end
    for s = 1:numel(SessionList)
        for n = 1:numel(SubInfo.Sub)
            if strcmp(SessionList{s}, SubInfo.Session{n}(1:10))
                InputConFile = fullfile(ANALYSESDir, SubInfo.Sub{n}, SubInfo.Session{n}, '1st_level', [ConList{c} '.nii']);
                if exist(InputConFile, 'file')
                    OutputConFile = fullfile(ConDir, SubInfo.Session{n}(1:10), [char(SubInfo.Group(n)) '_' SubInfo.Sub{n} '_' SubInfo.Session{n}(1:10) '_' ConList{c} '.nii']);
                    copyfile(InputConFile, OutputConFile)
                            if strcmp(SubInfo.RespondingHand(n), 'Left') && Swap
                                fprintf('LR-swapping: %s\n', OutputConFile)
                                Hdr		  = spm_vol(OutputConFile);
                                Vol		  = spm_read_vols(Hdr);
                                Hdr.fname = spm_file(OutputConFile, 'suffix', 'L2Rswap');
                                spm_write_vol(Hdr, flipdim(Vol,1));		% LR is the first dimension in MNI space
                                delete(OutputConFile);
                            end
                else
                    fprintf('%s: Confile not available \n', SubInfo.Sub{n})
                end
            end
        end
    end
end