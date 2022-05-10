% Copy 1st-level contrasts to group directory in analysis folder

function motor_copycontrasts(session, Swap)
%% Swap

if nargin<1 || isempty(Swap)
	Swap = true;               % A left-right swap of the con-images
end

%% Directories

consession = [session(1:4) session(8:13)];
FDThresh = 1;
ConList = {'con_0012', 'con_0013', 'con_0014', 'con_0015', 'con_0001' 'con_0002' 'con_0003' 'con_0004' 'con_0005' 'con_0006' 'con_0007'  'con_0008'  'con_0009'  'con_0010'};
ANALYSESDir = '/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem';
BIDSDir = '/project/3022026.01/pep/bids';
ClinicalConfs = readtable('/project/3024006.02/Data/matlab/ClinVars_select_mri3.csv');
Sub = cellstr(spm_select('List', fullfile(ANALYSESDir), 'dir', '^sub-POM.*'));
fprintf('Number of subjects processed: %i\n', numel(Sub))

Sel = true(numel(Sub),1);
for n = 1:numel(Sub)
    dir = spm_select('FPList', fullfile(ANALYSESDir, Sub{n}), 'dir', session);
    if ~exist(dir,'dir')
        Sel(n) = false;
    end
end
Sub = Sub(Sel);


%% Selection

% Take the last run for each participant's session(s)
% (necessary for finding the correct json and conf files)
Run = {};
Session = {};
Sub2 = {};
for n = 1:numel(Sub)
    Visit = cellstr(spm_select('List', fullfile(ANALYSESDir, Sub{n}), 'dir', session));
    for v = 1:numel(Visit)
        Sub2 = [Sub2; {Sub{n}}];
        Session = [Session; {Visit{v}}];
        Run = [Run; {num2str(FindLastRun(BIDSDir, Sub{n}, Visit{v}, 'motor', 'MB6'))}];
    end
end
SubInfo.Sub = Sub2;
SubInfo.Session = Session;
SubInfo.Run = Run;

%% Collect events.json and confound files

SubInfo.JsonFiles = cell(size(SubInfo.Sub));
SubInfo.ConfFiles = cell(size(SubInfo.Sub));

for n = 1:numel(SubInfo.Sub)
    SubInfo.JsonFiles{n} = spm_select('FPList', fullfile(BIDSDir, SubInfo.Sub{n}, SubInfo.Session{n}, 'beh'), ['.*task-motor_acq-MB6_run-' SubInfo.Run{n} '_events\.json$']);
    SubInfo.ConfFiles{n} = spm_select('FPList', fullfile(ANALYSESDir, SubInfo.Sub{n}, SubInfo.Session{n}), ['^.*task-motor_acq-MB6_run-' SubInfo.Run{n} '_desc-confounds_timeseries3.mat$']);
    if isempty(SubInfo.ConfFiles{n})
        SubInfo.ConfFiles{n} = spm_select('FPList', fullfile(ANALYSESDir, SubInfo.Sub{n}, SubInfo.Session{n}), ['^.*task-motor_acq-MB6_run-' SubInfo.Run{n} '_desc-confounds_timeseries2.mat$']);
    end
end

%% Group and handedness

SubInfo.Group = strings(size(SubInfo.Sub));
SubInfo.RespondingHand = strings(size(SubInfo.Sub));
SubInfo.PercentageCorrect = strings(size(SubInfo.Sub));

for n = 1:numel(SubInfo.Sub)
    Json = fileread(SubInfo.JsonFiles{n});
    DecodedJson = jsondecode(Json);
    if exist(spm_select('FPList', fullfile(BIDSDir, SubInfo.Sub{n}, SubInfo.Session{n}), 'dir', 'dwi'), 'dir') && contains(SubInfo.Session{n}, 'PIT')
        SubInfo.Group(n) = 'HC_PIT';
    elseif ~exist(spm_select('FPList', fullfile(BIDSDir, SubInfo.Sub{n}, SubInfo.Session{n}), 'dir', 'dwi'), 'dir') && contains(SubInfo.Session{n}, 'PIT')
        SubInfo.Group(n) = 'PD_PIT';
    else
        SubInfo.Group(n) = 'PD_POM';
    end
%     SubInfo.Group(n) = DecodedJson.Group.Value;
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

fprintf('%i subjects will be copied\n', length(SubInfo.Sub))

%% Copy and flip

for c = 1:numel(ConList)
    
    ConDir = fullfile(ANALYSESDir, 'Group', ConList{c});
    if ~exist(ConDir, 'dir')
        mkdir(ConDir);
%     else
%         delete(fullfile(ConDir, '*.*'));
    end
    if ~exist(fullfile(ConDir, consession), 'dir')
        mkdir(fullfile(ConDir, consession))
%     else
%         delete(fullfile(ConDir, consession, '*.*'));
    end
    
    for n = 1:numel(SubInfo.Sub)
        InputConFile = fullfile(ANALYSESDir, SubInfo.Sub{n}, session, '1st_level', [ConList{c} '.nii']);
        if exist(InputConFile, 'file')
            if contains(InputConFile, 'Visit1')
                OutputConFile = fullfile(ConDir, 'ses-Visit1', [char(SubInfo.Group(n)) '_' SubInfo.Sub{n} '_' session '_' ConList{c} '.nii']);
            elseif contains(InputConFile, 'Visit2') || contains(InputConFile, 'Visit3')
                OutputConFile = fullfile(ConDir, 'ses-Visit2', [char(SubInfo.Group(n)) '_' SubInfo.Sub{n} '_' session '_' ConList{c} '.nii']);
            end
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