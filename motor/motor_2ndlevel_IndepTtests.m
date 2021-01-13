% Move contrast images from PIT and POM to a single location within the POM
% project folder and label them according to group.

function motor_2ndlevel_IndepTtests(Offstate)

%% Swap

%% Group to comapre against controls

if nargin < 1 || isempty(Offstate)
    Offstate = false;
end

%% Paths

addpath('/home/common/matlab/fieldtrip/qsub');
addpath('/home/common/matlab/spm12');
spm('defaults', 'FMRI');

%% Directories

ses = 'ses-Visit1';
ANALYSESDir = '/project/3022026.01/analyses/motor/DurAvg_ReAROMA_PMOD_TimeDer';
% ANALYSESDir = '/project/3022026.01/analyses/motor/fMRI_EventRelated_BRCtrl';
Sub = cellstr(spm_select('List', fullfile(ANALYSESDir, 'Group', 'con_0001', 'ses-Visit1'), '.*sub-POM.*'));
Sub = extractBetween(Sub, 1, 31);
fprintf('Number of subjects processed: %i\n', numel(Sub))
CurrentDir = pwd;
cd(ANALYSESDir);

%% Selection

Sel = false(size(Sub));
for n = 1:numel(Sub)
    if istrue(Offstate) && (contains(Sub{n}, 'HC_PIT') || contains(Sub{n}, 'PD_PIT'))
        Sel(n) = true;
    elseif ~istrue(Offstate) && (contains(Sub{n}, 'HC_PIT') || contains(Sub{n}, 'PD_POM'))
        Sel(n) = true;
    else
        fprintf('Excluding %s due to group\n', Sub{n})
    end
end
Sub = Sub(Sel);

SubInfo.Sub = extractBetween(Sub, 8, 31);
SubInfo.Group = extractBetween(Sub, 1, 6);

%% Collect events.json and confound files

SubInfo.ConfFiles = cell(size(SubInfo.Sub));
for n = 1:numel(SubInfo.Sub)
    if contains(SubInfo.Group{n}, '_PIT')
        Session = 'ses-Visit1_PIT';
    else
        Session = 'ses-Visit1';
    end
    SubInfo.ConfFiles{n} = spm_select('FPList', fullfile(ANALYSESDir, SubInfo.Sub{n}, Session), '^.*task-motor_acq-MB6_run-.*_desc-confounds_regressors3.mat$');
    if isempty(SubInfo.ConfFiles{n})
        SubInfo.ConfFiles{n} = spm_select('FPList', fullfile(ANALYSESDir, SubInfo.Sub{n}, Session), '^.*task-motor_acq-MB6_run-.*_desc-confounds_regressors2.mat$');
    end
end

%% Framewise displacement

SubInfo.FD = zeros(size(SubInfo.Sub));
for n = 1:numel(SubInfo.Sub)
    Confounds = spm_load(SubInfo.ConfFiles{n});
    FrameDisp = Confounds.R(:,strcmp(Confounds.names, 'framewise_displacement'));
    FrameDisp(isnan(FrameDisp)) = 0;
    SubInfo.FD(n) = mean(FrameDisp);
end

%% Assemble inputs

ConList = {'con_0001' 'con_0002' 'con_0003' 'con_0004' 'con_0005' 'con_0006' 'con_0007' 'con_0008' 'con_0009' 'con_0010'};
ConNames   = {'Ext' 'Int2' 'Int3' 'Catch' 'Int' 'Ext>Int' 'Int>Ext' 'Int3>Int2' 'Int2>Int3' 'Mean_ExtInt'};

inputs = cell(5, 1);
JobFile = {spm_file(mfilename('fullpath'), 'suffix','_job', 'ext','.m')};

for n = 1:numel(ConList)
    ConDir = fullfile(ANALYSESDir, 'Group', ConList{n}, ses);
    if Offstate
        inputs{1,1} = {fullfile(ANALYSESDir, 'Group', 'IndependentTtest_TFCE_HcVsOff', ConNames{n})};
        HcIms = dir(fullfile(ConDir, 'HC_PIT*'));
        inputs{2,1} = fullfile(ConDir, {HcIms.name}');
        PdIms = dir(fullfile(ConDir, 'PD_PIT*'));
        inputs{3,1} = fullfile(ConDir, {PdIms.name}');
        FD2 = [SubInfo.FD(strcmp(SubInfo.Group, 'HC_PIT')); SubInfo.FD(strcmp(SubInfo.Group, 'PD_PIT'))];
    else
        inputs{1,1} = {fullfile(ANALYSESDir, 'Group', 'IndependentTtest_TFCE_HcVsOn', ConNames{n})};
        HcIms = dir(fullfile(ConDir, 'HC_PIT*'));
        inputs{2,1} = fullfile(ConDir, {HcIms.name}');
        PdIms = dir(fullfile(ConDir, 'PD_POM*'));
        inputs{3,1} = fullfile(ConDir, {PdIms.name}');
        FD2 = [SubInfo.FD(strcmp(SubInfo.Group, 'HC_PIT')); SubInfo.FD(strcmp(SubInfo.Group, 'PD_POM'))];
    end
    inputs{4,1} = FD2';%(FD2 - mean(FD2) / std(FD2))';       %Normalize FD
    inputs{5,1} = {'/project/3022026.01/analyses/motor/Masks/standard/group_mask.nii,1'};
    %Start with new directory
    if ~exist(char(inputs{1,1}), 'dir')
        mkdir(char(inputs{1,1}));
    else
        delete(fullfile(char(inputs{1,1}), '*.*'));
    end
    
    filename = char(fullfile(inputs{1,1}, 'Inputs.mat'));
    save(filename, 'inputs')
    
%     spm_jobman('run', JobFile, inputs{:});
    jobs{n} =  qsubfeval('spm_jobman','run',JobFile, inputs{:},'memreq',15*1024^3,'timreq',20*60*60);
end

%% Write output files

% File for jobs
task.jobs = jobs;
task.submittime = datestr(clock);
task.mfile = mfilename;
task.mfiletext = fileread([task.mfile '.m']);

% File for analyzed subjects
AnalyzedSubs = extractBetween(inputs{2,1}, 'HC_PIT_', '_ses');      % Check for pseudonyms included in analysis
if ~istrue(Offstate)
    AnalyzedSubs = [AnalyzedSubs; extractBetween(inputs{3,1}, 'PD_POM_', '_ses')];
else
    AnalyzedSubs = [AnalyzedSubs; extractBetween(inputs{3,1}, 'PD_PIT_', '_ses')];
end
SubInfo.Analyzed = contains(SubInfo.Sub, AnalyzedSubs);         % Write to SubInfo
SubInfo2 = struct2table(SubInfo);                               % Create a second SubInfo to store only analyzed subjects
SubInfo2 = SubInfo2(SubInfo2.Analyzed,:);
if ~istrue(Offstate)                                            % Remove duplicates depending on 'Offstate'
    SubInfo2 = SubInfo2(SubInfo2.Group ~= "PD_PIT",:);
else
    SubInfo2 = SubInfo2(SubInfo2.Group ~= "PD_POM",:);
end

% Write files
if ~istrue(Offstate)
    save([fullfile(ANALYSESDir, 'Group', 'IndependentTtest_TFCE_HcVsOn') '/jobs___' task.mfile  '___' datestr(clock) '.mat'],'task');
    save([fullfile(ANALYSESDir, 'Group', 'IndependentTtest_TFCE_HcVsOn') '/AllSubs___' task.mfile  '___' datestr(clock) '.mat'],'SubInfo');
    save([fullfile(ANALYSESDir, 'Group', 'IndependentTtest_TFCE_HcVsOn') '/AnalyzedSubs___' task.mfile  '___' datestr(clock) '.mat'],'SubInfo2');
    writetable(struct2table(SubInfo), [fullfile(ANALYSESDir, 'Group', 'IndependentTtest_TFCE_HcVsOn') '/AllSubs___' task.mfile  '___' datestr(clock) '.csv'])
    writetable(SubInfo2, [fullfile(ANALYSESDir, 'Group', 'IndependentTtest_TFCE_HcVsOn') '/AnalyzedSubs___' task.mfile  '___' datestr(clock) '.csv'])
else
    save([fullfile(ANALYSESDir, 'Group', 'IndependentTtest_TFCE_HcVsOff') '/jobs___' task.mfile  '___' datestr(clock) '.mat'],'task');
    save([fullfile(ANALYSESDir, 'Group', 'IndependentTtest_TFCE_HcVsOff') '/AllSubs___' task.mfile  '___' datestr(clock) '.mat'],'SubInfo');
    save([fullfile(ANALYSESDir, 'Group', 'IndependentTtest_TFCE_HcVsOff') '/AnalyzedSubs___' task.mfile  '___' datestr(clock) '.mat'],'SubInfo2');
    writetable(struct2table(SubInfo), [fullfile(ANALYSESDir, 'Group', 'IndependentTtest_TFCE_HcVsOff') '/AllSubs___' task.mfile  '___' datestr(clock) '.csv'])
    writetable(SubInfo2, [fullfile(ANALYSESDir, 'Group', 'IndependentTtest_TFCE_HcVsOff') '/AnalyzedSubs___' task.mfile  '___' datestr(clock) '.csv'])
end

cd(CurrentDir)

end

