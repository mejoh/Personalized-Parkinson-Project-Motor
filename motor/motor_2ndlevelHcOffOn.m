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
ANALYSESDir = '/project/3022026.01/analyses/motor/DurAvg_ReAROMA_PMOD_TimeDer';
% ANALYSESDir = '/project/3022026.01/analyses/motor/fMRI_EventRelated_BRCtrl';
BIDSDir = '/project/3022026.01/pep/bids';
BIDSDir_PIT = '/project/3022026.01/pep/bids_PIT';
Sub = cellstr(spm_select('List', fullfile(ANALYSESDir), 'dir', '^sub-POM.*'));
fprintf('Number of subjects processed: %i\n', numel(Sub))


%% Selection

Sel = false(size(Sub));
% Exclude participants without 1st-level analyses for visit 1
for n = 1:numel(Sub)
    d = dir(fullfile(ANALYSESDir, Sub{n}, 'ses-Visit1*'));
    for v = 1:length(d)
        if spm_select('List', fullfile(d(v).folder, d(v).name, '1st_level'), '^con.*\.nii$')
            Sel(n) = true;
        else
            fprintf('Excluding %s without previous SPM output for Visit1\n', Sub{n})
        end
    end
end
Sub = Sub(Sel);

% Take the last run for each participant's session(s)
Run = {};
Session = {};
Sub2 = {};
for n = 1:numel(Sub)
    Visit = cellstr(spm_select('List', fullfile(ANALYSESDir, Sub{n}), 'dir', 'ses-Visit1*'));
    for v = 1:numel(Visit)
        if strcmp(Visit{v}, 'ses-Visit1_PIT')
            d = BIDSDir_PIT;
        elseif strcmp(Visit{v}, 'ses-Visit1')
            d = BIDSDir;
        end
        Sub2 = [Sub2; {Sub{n}}];
        Session = [Session; {Visit{v}}];
        Run = [Run; {num2str(FindLastRun(d, char(Sub{n}), 'ses-Visit1', 'motor', 'MB6'))}];
    end
end
SubInfo.Sub = Sub2;
SubInfo.Session = Session;
SubInfo.Run = Run;

% Exclude Visit3
Sel = true(size(SubInfo.Sub));
for n = 1:numel(SubInfo.Sub)
    if contains(SubInfo.Session{n}, 'ses-Visit3')
        Sel(n) = false;
        fprintf('Excluding Visit3 SPM output for %s \n', SubInfo.Sub{n})
    end
end
fprintf('%i Visit3 excluded \n', sum(Sel == 0))

SubInfo.Sub = SubInfo.Sub(Sel);
SubInfo.Session = SubInfo.Session(Sel);
SubInfo.Run = SubInfo.Run(Sel);

%% Collect events.json and confound files

JsonFiles = cell(size(SubInfo.Sub));
ConfFiles = cell(size(SubInfo.Sub));

for n = 1:numel(SubInfo.Sub)
    if contains(SubInfo.Session{n}, 'PIT')
        JsonFiles{n} = spm_select('FPList', fullfile(BIDSDir_PIT, SubInfo.Sub{n}, 'ses-Visit1', 'beh'), ['.*task-motor_acq-MB6_run-' SubInfo.Run{n} '_events\.json$']);
    else
        JsonFiles{n} = spm_select('FPList', fullfile(BIDSDir, SubInfo.Sub{n}, 'ses-Visit1', 'beh'), ['.*task-motor_acq-MB6_run-' SubInfo.Run{n} '_events\.json$']);
    end
    ConfFiles{n} = spm_select('FPList', fullfile(ANALYSESDir, SubInfo.Sub{n}, SubInfo.Session{n}), ['^.*task-motor_acq-MB6_run-' SubInfo.Run{n} '_desc-confounds_regressors3.mat$']);
    if isempty(ConfFiles{n})
        ConfFiles{n} = spm_select('FPList', fullfile(ANALYSESDir, SubInfo.Sub{n}, SubInfo.Session{n}), ['^.*task-motor_acq-MB6_run-' SubInfo.Run{n} '_desc-confounds_regressors2.mat$']);
    end
end

%% Group and handedness

Group = strings(size(SubInfo.Sub));
RespondingHand = strings(size(SubInfo.Sub));
PercentageCorrect = strings(size(SubInfo.Sub));

for n = 1:numel(SubInfo.Sub)
    Json = fileread(JsonFiles{n});
    DecodedJson = jsondecode(Json);
    Group(n) = DecodedJson.Group.Value;
    if contains(SubInfo.Session{n}, 'PIT')
        d = BIDSDir_PIT;
        Group(n) = FindGroup(d, SubInfo.Sub{n}, 'ses-Visit1', 'dwi');
    else
        Group(n) = 'PD_POM';
    end
    RespondingHand(n) = DecodedJson.RespondingHand.Value;
    PercentageCorrect(n) = DecodedJson.ExtCorrResp.Value;
end

%% Framewise displacement

FD = zeros(size(SubInfo.Sub));
for n = 1:numel(SubInfo.Sub)
    Confounds = spm_load(ConfFiles{n});
    FrameDisp = Confounds.R(:,strcmp(Confounds.names, 'framewise_displacement'));
    FrameDisp(isnan(FrameDisp)) = 0;
    FD(n) = mean(FrameDisp);
end

%% Exclusion

% FD
Sel = true(size(SubInfo.Sub));
for n = 1:numel(SubInfo.Sub)
    if FD(n) > FDThresh
        Sel(n) = false;
        sprintf('Excluding %s (%s) due to %f mean framewise displacement (Threshold = %f) \n', SubInfo.Sub{n}, Group(n), FD(n), FDThresh)
    end
end
fprintf('%i participants excluded due to excessive motion \n', sum(Sel == 0))
SubInfo.Sub = SubInfo.Sub(Sel);
SubInfo.Session = SubInfo.Session(Sel);
SubInfo.Run = SubInfo.Run(Sel);
Group = Group(Sel);
RespondingHand = RespondingHand(Sel);
FD = FD(Sel);
PercentageCorrect = PercentageCorrect(Sel);

% Percentage correct responses in external
Sel = true(size(SubInfo.Sub));
for n = 1:numel(SubInfo.Sub)
    if double(PercentageCorrect(n)) <= 0.25
        Sel(n) = false;
        sprintf('Excluding %s (%s) due to %f percentage correct responses in External (Threshold = 25%) \n', SubInfo.Sub{n}, Group(n), PercentageCorrect(n))
    end
end
fprintf('%i participants excluded due to poor performance \n', sum(Sel == 0))
SubInfo.Sub = SubInfo.Sub(Sel);
SubInfo.Session = SubInfo.Session(Sel);
SubInfo.Run = SubInfo.Run(Sel);
Group = Group(Sel);
RespondingHand = RespondingHand(Sel);
FD = FD(Sel);

%% Copy and flip

ConList = {'con_0001' 'con_0002' 'con_0003' 'con_0004'};% 'con_0005'};
SessionList = {'ses-Visit1' 'ses-Visit1_PIT'};
for c = 1:numel(ConList)
    ConDir = fullfile(ANALYSESDir, 'Group', ConList{c});
    if ~exist(ConDir, 'dir')
        mkdir(ConDir);
    else
        delete(fullfile(ConDir, '*.*'));
    end
    for s = 1:numel(SessionList)
        for n = 1:numel(SubInfo.Sub)
            if strcmp(SessionList{s}, SubInfo.Session{n})
                InputConFile = fullfile(ANALYSESDir, SubInfo.Sub{n}, SubInfo.Session{n}, '1st_level', [ConList{c} '.nii']);
                if exist(InputConFile, 'file')
                    OutputConFile = fullfile(ConDir, [char(Group(n)) '_' SubInfo.Sub{n} '_' SubInfo.Session{1} '_' ConList{c} '.nii']);
                    copyfile(InputConFile, OutputConFile)
                            if strcmp(RespondingHand(n), 'Left') && Swap
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

%% Assemble inputs

Inputs = cell(14, 1);
Inputs{1,1} = {fullfile(ANALYSESDir, 'Group', 'HcOffOn x ExtInt2Int3Catch')};

ExtHc = dir(fullfile(ANALYSESDir, 'Group', ConList{1}, 'HC_PIT*'));
Inputs{2,1} = fullfile(ANALYSESDir, 'Group', ConList{1}, {ExtHc.name}');
Int2Hc = dir(fullfile(ANALYSESDir, 'Group', ConList{2}, 'HC_PIT*'));
Inputs{3,1} = fullfile(ANALYSESDir, 'Group', ConList{2}, {Int2Hc.name}');
Int3Hc = dir(fullfile(ANALYSESDir, 'Group', ConList{3}, 'HC_PIT*'));
Inputs{4,1} = fullfile(ANALYSESDir, 'Group', ConList{3}, {Int3Hc.name}');
CatchHc = dir(fullfile(ANALYSESDir, 'Group', ConList{4}, 'HC_PIT*'));
Inputs{5,1} = fullfile(ANALYSESDir, 'Group', ConList{4}, {CatchHc.name}');

ExtPd = dir(fullfile(ANALYSESDir, 'Group', ConList{1}, 'PD_PIT*'));
Inputs{6,1} = fullfile(ANALYSESDir, 'Group', ConList{1}, {ExtPd.name}');
Int2Pd = dir(fullfile(ANALYSESDir, 'Group', ConList{2}, 'PD_PIT*'));
Inputs{7,1} = fullfile(ANALYSESDir, 'Group', ConList{2}, {Int2Pd.name}');
Int3Pd = dir(fullfile(ANALYSESDir, 'Group', ConList{3}, 'PD_PIT*'));
Inputs{8,1} = fullfile(ANALYSESDir, 'Group', ConList{3}, {Int3Pd.name}');
CatchPd = dir(fullfile(ANALYSESDir, 'Group', ConList{4}, 'PD_PIT*'));
Inputs{9,1} = fullfile(ANALYSESDir, 'Group', ConList{4}, {CatchPd.name}');

ExtPd = dir(fullfile(ANALYSESDir, 'Group', ConList{1}, 'PD_POM*'));
Inputs{10,1} = fullfile(ANALYSESDir, 'Group', ConList{1}, {ExtPd.name}');
Int2Pd = dir(fullfile(ANALYSESDir, 'Group', ConList{2}, 'PD_POM*'));
Inputs{11,1} = fullfile(ANALYSESDir, 'Group', ConList{2}, {Int2Pd.name}');
Int3Pd = dir(fullfile(ANALYSESDir, 'Group', ConList{3}, 'PD_POM*'));
Inputs{12,1} = fullfile(ANALYSESDir, 'Group', ConList{3}, {Int3Pd.name}');
CatchPd = dir(fullfile(ANALYSESDir, 'Group', ConList{4}, 'PD_POM*'));
Inputs{13,1} = fullfile(ANALYSESDir, 'Group', ConList{4}, {CatchPd.name}');

FD_HC_PIT = FD(strcmp(Group, 'HC_PIT'))';
FD_PD_PIT = FD(strcmp(Group, 'PD_PIT'))';
FD_PD_POM = FD(strcmp(Group, 'PD_POM'))';

Inputs{14,1} = [FD_HC_PIT FD_HC_PIT  FD_HC_PIT FD_HC_PIT FD_PD_PIT FD_PD_PIT FD_PD_PIT FD_PD_PIT FD_PD_POM FD_PD_POM FD_PD_POM FD_PD_POM]';

%% Run

JobFile = {spm_file(mfilename('fullpath'), 'suffix','_job', 'ext','.m')};

delete(fullfile(char(Inputs{1}), '*.*'))
spm_jobman('run', JobFile, Inputs{:});

end

