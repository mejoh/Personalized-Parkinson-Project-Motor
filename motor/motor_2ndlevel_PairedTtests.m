function motor_2ndlevel_PairedTtests(exclude_outliers)

if nargin<1
    exclude_outliers = true;
end

%% Paths

addpath('/home/common/matlab/spm12');
spm('defaults', 'FMRI');

ses = 'ses-Visit1';
ConList =    {'con_0010',    'con_0007', 'con_0012',  'con_0013',   'con_0008',   'con_0006', 'con_0014',  'con_0015',  'con_0009'};
ConNames   = {'Mean_ExtInt', 'INTgtEXT', 'INT2gtEXT', 'INT3gtEXT',  'INT3gtINT2', 'EXTgtINT', 'EXTgtINT2', 'EXTgtINT3', 'INT2gtINT3'};
ANALYSESDir = '/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem';
% ANALYSESDir = '/project/3022026.01/analyses/motor/fMRI_EventRelated_BRCtrl';
ClinicalConfs = readtable('/project/3024006.02/Data/matlab/ClinVars_select_mri.csv');
baseid = ClinicalConfs.TimepointNr == 0;
ClinicalConfs = ClinicalConfs(baseid,:);
g1 = string(ClinicalConfs.ParticipantType) == "PD_POM";
ClinicalConfs = ClinicalConfs(logical(g1),:);
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

% Exclude outliers
mriqc_outliers = readtable('/project/3024006.02/Analyses/mriqc_outliers.txt');
Con1 = '/project/3024006.02/Analyses/QC/1st_level/con_0001/Group.txt';
Con2 = '/project/3024006.02/Analyses/QC/1st_level/con_0002/Group.txt';
Con3 = '/project/3024006.02/Analyses/QC/1st_level/con_0003/Group.txt';
ResMS = '/project/3024006.02/Analyses/QC/1st_level/ResMS/Group.txt';
Con1_f = readtable(Con1);
Con1_f_s = Con1_f(Con1_f.Outlier==1,:);
Con2_f = readtable(Con2);
Con2_f_s = Con2_f(Con2_f.Outlier==1,:);
Con3_f = readtable(Con3);
Con3_f_s = Con3_f(Con3_f.Outlier==1,:);
ResMS_f = readtable(ResMS);
ResMS_f_s = ResMS_f(ResMS_f.Outlier==1,:);
outliers = unique([Con1_f_s.Sub; Con2_f_s.Sub; Con3_f_s.Sub; ResMS_f_s.Sub; mriqc_outliers]);
if istrue(exclude_outliers)
    Sel = true(size(SubInfo.Sub));
    for n = 1:numel(SubInfo.Sub)
        if contains(SubInfo.Sub{n}, string(table2array(outliers)))
           Sel(n) = false;
        fprintf('Excluding outlier: %s %s \n', SubInfo.Sub{n}, SubInfo.Group{n})
        end
    end
    SubInfo = subset_subinfo(SubInfo, Sel);
end

%% Collect events.json and confound files

SubInfo.ConfFiles = cell(size(SubInfo.Sub));
for n = 1:numel(SubInfo.Sub)
    if contains(SubInfo.Group{n}, '_PIT')
        Session = 'ses-PITVisit1';
    else
        Session = 'ses-POMVisit1';
    end
    SubInfo.ConfFiles{n} = spm_select('FPList', fullfile(ANALYSESDir, SubInfo.Sub{n}, Session), '^.*task-motor_acq-MB6_run-.*_desc-confounds_timeseries3.mat$');
    if isempty(SubInfo.ConfFiles{n})
        SubInfo.ConfFiles{n} = spm_select('FPList', fullfile(ANALYSESDir, SubInfo.Sub{n}, Session), '^.*task-motor_acq-MB6_run-.*_desc-confounds_timeseries2.mat$');
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

%% Age and Gender

% Interpolate age and gender
SubInfo.Age = zeros(size(SubInfo.Sub));
SubInfo.Gender = cell(size(SubInfo.Sub));
for n = 1:numel(SubInfo.Sub)
    
    subid = find(contains(ClinicalConfs.pseudonym, SubInfo.Sub{n}));
    
    if isempty(subid) || isnan(ClinicalConfs.Age(subid)) || strcmp(ClinicalConfs.Gender(subid), 'NA')
        fprintf('Missing values, interpolating...\n')
        SubInfo.Age(n) = round(mean(ClinicalConfs.Age, 'omitnan'));
        SubInfo.Gender{n} = cellstr('Male');
    else
        SubInfo.Age(n) = ClinicalConfs.Age(subid);
        SubInfo.Gender{n} = ClinicalConfs.Gender(subid);
    end
    
end


% Exclude subjects with missing Age and Gender
% Sel = true(size(SubInfo.Sub));
% SubInfo.Age = zeros(size(SubInfo.Sub));
% SubInfo.Gender = cell(size(SubInfo.Sub));
% for n = 1:numel(SubInfo.Sub)
%     
%     subid = find(contains(ClinicalConfs.pseudonym, SubInfo.Sub{n}));
%     
%     if isempty(subid) || isnan(ClinicalConfs.Age(subid)) || strcmp(ClinicalConfs.Gender(subid), 'NA')
%         fprintf('Missing values, excluding %s...\n', SubInfo.Sub{n})
%         Sel(n) = false;
%     else
%         SubInfo.Age(n) = ClinicalConfs.Age(subid);
%         SubInfo.Gender{n} = ClinicalConfs.Gender(subid);
%     end
%     
% end
% fprintf('%i subjects have missing Age/Gender, excluding...\n', length(Sel) - sum(Sel))
% SubInfo = subset_subinfo(SubInfo, Sel);


SubInfo.Gender_num = zeros(size(SubInfo.Gender));
for n = 1:numel(SubInfo.Gender)
    if strcmp(SubInfo.Gender{n}, 'Male')
        SubInfo.Gender_num(n) = 0;
    else
        SubInfo.Gender_num(n) = 1;
    end
end

%% Assemble inputs

fprintf('%i subjects will be analyzed. Does this match your job.m file?! \n', numel(unique(SubInfo.Sub)))
tabulate(SubInfo.Group)
if length(SubInfo.Group(strcmp(SubInfo.Group,'PD_PIT'))) ~= length(SubInfo.Group(strcmp(SubInfo.Group, 'PD_POM')))
    msg = 'Length of groups are not equal, exiting...';
    error(msg)
end
Inputs = cell(52, 1);
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
    Inputs{50,1} = SubInfo.FD;
    Inputs{51,1} = SubInfo.Age;
    Inputs{52,1} = SubInfo.Gender_num;

%% Run

    JobFile = {spm_file(mfilename('fullpath'), 'suffix','_job', 'ext','.m')};
    delete(fullfile(char(Inputs{1}), '*.*'))
    spm_jobman('run', JobFile, Inputs{:});
%     jobs{n} =  qsubfeval('spm_jobman','run',JobFile, Inputs{:},'memreq',5*1024^3,'timreq',6*60*60);     % approx ~4.5 hours

    filename = char(fullfile(Inputs{1,1}, 'Inputs.mat'));
    save(filename, 'Inputs')

end

task.jobs = jobs;
task.submittime = datestr(clock);
task.mfile = mfilename;
task.mfiletext = fileread([task.mfile '.m']);
save([fullfile(ANALYSESDir, 'Group', 'PairedTtest_OffOn') '/jobs___' task.mfile  '___' datestr(clock) '.mat'],'task');

end