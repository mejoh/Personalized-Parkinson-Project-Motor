function motor_2ndlevel_PairedTtests()

%% Paths

addpath('/home/common/matlab/spm12');
spm('defaults', 'FMRI');

ses = 'ses-Visit1';
ConList = {'con_0001' 'con_0002' 'con_0003' 'con_0004' 'con_0005' 'con_0006' 'con_0007' 'con_0008' 'con_0009' 'con_0010'};
ConNames   = {'Ext' 'Int2' 'Int3' 'Catch' 'Int' 'Ext>Int' 'Int>Ext' 'Int3>Int2' 'Int2>Int3' 'Mean_ExtInt'};
ANALYSESDir = '/project/3022026.01/analyses/motor/DurAvg_ReAROMA_PMOD_TimeDer';
% ANALYSESDir = '/project/3022026.01/analyses/motor/fMRI_EventRelated_BRCtrl';
Sub = cellstr(spm_select('List', fullfile(ANALYSESDir, 'Group', 'con_0001', 'ses-Visit1'), '.*sub-POM.*'));
Sub = extractBetween(Sub, 1, 31);
fprintf('Number of subjects processed: %i\n', numel(Sub))

%% Selection

% Exclude healthy controls
Sel = false(size(Sub));
for n = 1:numel(Sub)
    if (contains(Sub{n}, 'PD_PIT') || contains(Sub{n}, 'PD_POM'))
        Sel(n) = true;
    else
        Sel(n) = false;
    end
end
Sub = Sub(Sel);

SubInfo.Sub = extractBetween(Sub, 8, 31);
SubInfo.Group = extractBetween(Sub, 1, 6);

% Find patients that are included in both PIT and P
[~, ind] = unique(SubInfo.Sub);   % indices to unique subs
duplicate_ind = setdiff(1:size(SubInfo.Sub, 1), ind);   % duplicate indices
duplicate_subs = SubInfo.Sub(duplicate_ind);   % duplicate values

Sel = true(size(Sub));
for n = 1:numel(SubInfo.Sub)
    if contains(SubInfo.Sub{n}, duplicate_subs)
        Sel(n) = true;
    else
        Sel(n) = false;
    end
end
SubInfo.Sub = SubInfo.Sub(Sel);
SubInfo.Group = SubInfo.Group(Sel);

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

fprintf('%i subjects will be analyzed. Does this match your job.m file?! \n', numel(unique(SubInfo.Sub)))
tabulate(SubInfo.Group)
if length(SubInfo.Group(strcmp(SubInfo.Group,'PD_PIT'))) ~= length(SubInfo.Group(strcmp(SubInfo.Group, 'PD_POM')))
    msg = 'Length of groups are not equal, exiting...';
    error(msg)
end
Inputs = cell(49, 1);
jobs = cell(numel(ConList),1);

for c = 1:numel(ConList)
    
    % Start with clean analysis folder
    Inputs{1,1} = {fullfile(ANALYSESDir, 'Group', 'PairedTtest_OffOn', ConNames{c})};
    if ~exist(char(Inputs{1,1}), 'dir')
        mkdir(char(Inputs{1,1}));
    else
        delete(fullfile(char(Inputs{1,1}), '*.*'));
    end
    
    % Assemble paired scans
    for n = 1:numel(unique(SubInfo.Sub))
        Img_off = dir(fullfile(ANALYSESDir, 'Group', ConList{c}, ses, ['PD_PIT_' SubInfo.Sub{n} '*' ConList{c} '*.nii']));
        Img_off = strcat(Img_off.folder, '/', Img_off.name);
        Img_on = dir(fullfile(ANALYSESDir, 'Group', ConList{c}, ses, ['PD_POM_' SubInfo.Sub{n} '*' ConList{c} '*.nii']));
        Img_on = strcat(Img_on.folder, '/', Img_on.name);
        Inputs{n+1,1} = {Img_off;Img_on};
    end
    
    % Assemble confound regressors
    Inputs{49,1} = SubInfo.FD;
    
    filename = char(fullfile(Inputs{1,1}, 'Inputs.mat'));
    save(filename, 'Inputs')

%% Run

    JobFile = {spm_file(mfilename('fullpath'), 'suffix','_job', 'ext','.m')};
    delete(fullfile(char(Inputs{1}), '*.*'))
%     spm_jobman('run', JobFile, Inputs{:});
    jobs{n} =  qsubfeval('spm_jobman','run',JobFile, Inputs{:},'memreq',5*1024^3,'timreq',6*60*60);     % approx ~4.5 hours
end

task.jobs = jobs;
task.submittime = datestr(clock);
task.mfile = mfilename;
task.mfiletext = fileread([task.mfile '.m']);
save([fullfile(ANALYSESDir, 'Group', 'PairedTtest_OffOn') '/jobs___' task.mfile  '___' datestr(clock) '.mat'],'task');

end