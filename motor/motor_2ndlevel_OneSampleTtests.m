function motor_2ndlevel_OneSampleTtests(Subscore, exclude_outliers, Subtype)

% subscores = {'Up3OfBradySum_T0' 'Up3OfTotal_T0' 'MoCASum_T0' 'CognitiveComposite_T0' 'Motor_T0' 'Select2_T0' 'Select3_T0'}
% for i = 1:numel(subscores)
%     motor_2ndlevel_OneSampleTtests(subscores{i}, true, [])
% end

if nargin < 1 || isempty(Subscore)
%     Subscore = {'Up3OfBradySum_T0'};
%     Subscore = 'Up3OnBradySum_T0';
%     Subscore = 'Up3OfTotal_T0';
%     Subscore = 'Up3OnTotal_T0';
%     Subscore = {'z_MoCA__total_T0'};
%     Subscore = {'z_CognitiveComposite2_T0'};
%     Subscore = {'CognitiveComposite_T0'};
%     Subscore = 'Motor_T0';
%     Subscore = 'Select2_T0';
%     Subscore = 'Select3_T0';
    Subscore = {'Up3OfBradySum_T2' 'z_CognitiveComposite_T2'};
end
if nargin < 1 || isempty(exclude_outliers)
    exclude_outliers = true;
end
if nargin < 1 || isempty(Subtype)
    Subtype = [];
end

%% Paths

addpath('/home/common/matlab/fieldtrip/qsub');
addpath('/home/common/matlab/spm12');
spm('defaults', 'FMRI');

%% Directories

ses = 'ses-Visit2';
sesname = 'ses-POMVisit3';
if strcmp(ses, 'ses-Visit1')
    dirname = 'Baseline';
else
    dirname = 'FollowUp';
end
GroupFolder = 'Group';
ANALYSESDir = '/project/3024006.02/Analyses/motor_task';
ClinicalConfs = readtable('/project/3024006.02/Data/matlab/fmri-confs-taskclin_ses-all_groups-all_2024-02-07.csv');
% ClinicalConfs = readtable('/project/3024006.02/Analyses/BRAIN_2023/Clin/fmri-confs-taskclin_ses-all_groups-all_2023-06-19.csv');
% baseid = ClinicalConfs.TimepointNr == 0;
% ClinicalConfs = ClinicalConfs(baseid,:);
g2 = string(ClinicalConfs.ParticipantType) == "PD_POM";
ClinicalConfs = ClinicalConfs(logical(g2),:);
Sub = cellstr(spm_select('List', fullfile(ANALYSESDir, GroupFolder, 'con_0001', ses), '.*sub-POM.*'));
Sub = extractBetween(Sub, 1, 31);
fprintf('Number of subjects processed: %i\n', numel(Sub))

%% Selection

% Select variables and remove missing values
% if contains(Subscore, 'RawChange')
%     clinscore1=Subscore;
%     clinscore2=strrep(Subscore,'RawChange','T0');
% else
%     clinscore1=Subscore;
%     clinscore2='NULL';
% end
if numel(Subscore)>1
    clinscore1=Subscore{1};
    clinscore2=Subscore{2};
else
    clinscore1=Subscore{1};
    clinscore2='NULL';
end

% Colnames = {'pseudonym', 'ParticipantType', 'Subtype_DiagEx3_DisDurSplit', clinscore1, clinscore2...
%     'Age', 'Gender', 'Misdiagnosis', 'NpsEducYears', 'RespHandIsDominant_T0', 'BMI',...
%     'SmokingHistory'};
% Colnames = {'pseudonym', 'ParticipantType', 'Subtype_DiagEx3_DisDurSplit', clinscore1, clinscore2...
%     'Age', 'Gender', 'Misdiagnosis', 'NpsEducYears', 'RespHandIsDominant_T0', 'BMI',...
%     'SmokingHistory', 'PASE'};
% Colnames = {'pseudonym', 'ParticipantType', 'Subtype_DiagEx3_DisDurSplit', clinscore1, clinscore2...
%     'Age', 'Gender', 'Misdiagnosis', 'NpsEducYears', 'RespHandIsDominant_T0', 'BMI',...
%     'SmokingHistory', 'PASE'};
Colnames = {'pseudonym', 'ParticipantType', 'Subtype_DiagEx3_DisDurSplit', clinscore1, clinscore2...
    'Age', 'Gender', 'Misdiagnosis', 'NpsEducYears', 'RespHandIsDominant_T0'};
cID = ismember(ClinicalConfs.Properties.VariableNames, Colnames);
ClinicalConfs = rmmissing(ClinicalConfs(:,cID));

Sel = false(size(Sub));
for n = 1:numel(Sub)
    if contains(Sub{n}, 'PD_POM')
        Sel(n) = true;
    end
end
Sub = Sub(Sel);

SubInfo.Sub = extractBetween(Sub, 8, 31);
SubInfo.Group = extractBetween(Sub, 1, 6);

Sel = false(size(Sub));
for n = 1:height(ClinicalConfs)
    if strcmp(ClinicalConfs.ParticipantType(n), 'PD_POM')
        Sel(n) = true;
    end
end
ClinicalConfs = ClinicalConfs(Sel,:);

SubInfo.Type = cell(size(SubInfo.Sub));
for n = 1:numel(SubInfo.Sub)
    if strcmp(SubInfo.Group{n}, 'PD_POM')
        idx = strcmp(ClinicalConfs.pseudonym, SubInfo.Sub{n});
        if sum(idx)>0
            t = ClinicalConfs.Subtype_DiagEx3_DisDurSplit{idx};
            if(strcmp(t,'NA') || contains(t,'Undefined'))
                t = '4_Undefined';
            end
            SubInfo.Type{n} = t;
        else
            SubInfo.Type{n} = '4_Undefined';
        end
    end
end
tabulate(SubInfo.Type)

% Sel = true(size(SubInfo.Sub));
% for n = 1:numel(SubInfo.Sub)
%     if strcmp(SubInfo.Type{n}, '4_Undefined') || strcmp(SubInfo.Type{n}, 'Undefined') || strcmp(SubInfo.Type{n}, 'NA')
%         Sel(n) = false;
%     end
% end
% SubInfo = subset_subinfo(SubInfo,Sel);
% tabulate(SubInfo.Type)

% Quality control: outlier exclusion
Outliers = readtable('/project/3024006.02/Analyses/BRAIN_2023/fMRI/Quality_control/Exclusions.csv');
% Lenient
% baseid = contains(Outliers.visit, 'Visit1') & Outliers.definitive_exclusions == 1;
baseid = (contains(Outliers.visit, 'Visit2') + contains(Outliers.visit, 'Visit3')) & Outliers.definitive_exclusions == 1;
% Conservative
% baseid = contains(Outliers.visit, 'Visit1');
Outliers = Outliers(baseid,:);

if istrue(exclude_outliers)
    Sel = true(size(SubInfo.Sub));
    for n = 1:numel(SubInfo.Sub)
        if contains(SubInfo.Sub{n}, Outliers.pseudonym)
           Sel(n) = false;
        fprintf('Excluding outlier: %s %s \n', SubInfo.Sub{n}, SubInfo.Group{n})
        end
    end
    fprintf('%i outliers have been excluded \n', length(Sel) - sum(Sel))
    SubInfo = subset_subinfo(SubInfo, Sel);
end
tabulate(SubInfo.Type)

% Exclusion of non-PD patients
Sel = true(size(SubInfo.Sub));
for n = 1:numel(SubInfo.Sub)
    
    subid = find(contains(ClinicalConfs.pseudonym, SubInfo.Sub{n}));
    
    if ClinicalConfs.Misdiagnosis(subid)
        fprintf('Misdiagnosis as non-PD, excluding %s...\n', SubInfo.Sub{n})
        Sel(n) = false;
    end
    
end
fprintf('%i subjects have a non-PD diagnosis, excluding these now...\n', length(Sel) - sum(Sel))
tabulate(SubInfo.Type)
SubInfo = subset_subinfo(SubInfo, Sel);

% Exclusion of non-old subs
% Sel = true(size(SubInfo.Sub));
% for n = 1:numel(SubInfo.Sub)
%     
%     old_names = load('/project/3024006.02/Analyses/BRAIN_2023/fMRI/Group_comparisons/ClinCorr-BA_Up3OfBradySum_T0_NoOutliers/Int3gtExt/Inputs.mat');
%     old_names = extractBetween(old_names.inputs{2,1}, 'PD_POM_', '_ses');
%     subid = find(contains(old_names, SubInfo.Sub{n}));
%     
%     if isempty(subid)
%         fprintf('%s was not part of old analyses\n', SubInfo.Sub{n})
%         Sel(n) = false;
%     end
%     
% end
% fprintf('%i subjects were not part of the old analyses...\n', length(Sel) - sum(Sel))
% tabulate(SubInfo.Type)
% SubInfo = subset_subinfo(SubInfo, Sel);

%% Collect events.json and confound files

SubInfo.ConfFiles = cell(size(SubInfo.Sub));
for n = 1:numel(SubInfo.Sub)
    SubInfo.ConfFiles{n} = spm_select('FPList', fullfile(ANALYSESDir, SubInfo.Sub{n}, sesname), '^.*task-motor_acq-MB6_run-.*_desc-confounds_timeseries3.mat$');
    if isempty(SubInfo.ConfFiles{n})
        SubInfo.ConfFiles{n} = spm_select('FPList', fullfile(ANALYSESDir, SubInfo.Sub{n}, sesname), '^.*task-motor_acq-MB6_run-.*_desc-confounds_timeseries2.mat$');
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

%% Age, Gender, Education, Hand dominance, Scores
Sel = true(size(SubInfo.Sub));
SubInfo.Age = zeros(size(SubInfo.Sub));
SubInfo.Gender = zeros(size(SubInfo.Sub));
SubInfo.Education = zeros(size(SubInfo.Sub));
SubInfo.HandDominance = zeros(size(SubInfo.Sub));
% SubInfo.SmokingHistory = zeros(size(SubInfo.Sub));
% SubInfo.BMI = zeros(size(SubInfo.Sub));
% SubInfo.PASE = zeros(size(SubInfo.Sub));
% SubInfo.Up1Total = zeros(size(SubInfo.Sub));
% SubInfo.RBDSQSum = zeros(size(SubInfo.Sub));
% SubInfo.BDI2 = zeros(size(SubInfo.Sub));
SubInfo.Score = zeros(size(SubInfo.Sub));
% if contains(Subscore,'RawChange')
    SubInfo.Score_BA = zeros(size(SubInfo.Sub));
% end
for n = 1:numel(SubInfo.Sub)
    
    subid = find(contains(ClinicalConfs.pseudonym, SubInfo.Sub{n}));
    
    if isempty(subid)
        fprintf('Missing values, excluding %s...\n', SubInfo.Sub{n})
        Sel(n) = false;
    else
        SubInfo.Age(n) = ClinicalConfs.Age(subid);
        SubInfo.Gender(n) = ClinicalConfs.Gender(subid);
        SubInfo.Education(n) = ClinicalConfs.NpsEducYears(subid);
        SubInfo.HandDominance(n) = ClinicalConfs.RespHandIsDominant_T0(subid);
%         SubInfo.BMI(n) = ClinicalConfs.BMI(subid);
%         SubInfo.SmokingHistory(n) = ClinicalConfs.SmokingHistory(subid);
%         SubInfo.PASE(n) = ClinicalConfs.PASE(subid);
%         SubInfo.Up1Total(n) = ClinicalConfs.Up1Total(subid);
%         SubInfo.RBDSQSum(n) = ClinicalConfs.RBDSQSum(subid);
%         SubInfo.BDI2(n) = ClinicalConfs.BDI2Sum(subid);
        cID = ismember(ClinicalConfs.Properties.VariableNames, clinscore1);
        SubInfo.Score(n) = table2array(ClinicalConfs(subid,cID));
%         if contains(Subscore,'RawChange')
            cID = ismember(ClinicalConfs.Properties.VariableNames, clinscore2);
            SubInfo.Score_BA(n) = table2array(ClinicalConfs(subid,cID));
%         end
    end
    
end
fprintf('%i subjects have missing values, excluding...\n', length(Sel) - sum(Sel))
SubInfo = subset_subinfo(SubInfo, Sel);

%% Demean covars
SubInfo.Age = SubInfo.Age - mean(SubInfo.Age);
SubInfo.Gender = SubInfo.Gender - mean(SubInfo.Gender);
SubInfo.FD = SubInfo.FD - mean(SubInfo.FD);
SubInfo.Education = SubInfo.Education - mean(SubInfo.Education);
SubInfo.HandDominance = SubInfo.HandDominance - mean(SubInfo.HandDominance);
% SubInfo.BMI = SubInfo.BMI - mean(SubInfo.BMI);
% SubInfo.SmokingHistory = SubInfo.SmokingHistory - mean(SubInfo.SmokingHistory);
% SubInfo.PASE = SubInfo.PASE - mean(SubInfo.PASE);
% SubInfo.Up1Total = SubInfo.Up1Total - mean(SubInfo.Up1Total);
% SubInfo.RBDSQSum = SubInfo.RBDSQSum - mean(SubInfo.RBDSQSum);
% SubInfo.BDI2 = SubInfo.BDI2 - mean(SubInfo.BDI2);
SubInfo.Score = SubInfo.Score - mean(SubInfo.Score);
% if contains(Subscore,'RawChange')
    SubInfo.Score_BA = SubInfo.Score_BA - mean(SubInfo.Score_BA);
% end

%% Subset data by subtype (optional)

% Subtype = 'Mild-Motor';
if ~isempty(Subtype)
    % Select patients from the clinical data file that have the selected
    % subtype
    Sel = contains(SubInfo.Type, Subtype);
    SubInfo = subset_subinfo(SubInfo, Sel);
    fprintf('Analyzing subtype: %s, n = %i \n', Subtype, numel(SubInfo.Type))
end

%% Assemble inputs
% 'con_0008' 'Int3gtInt2' 
ConList = {'con_0011' 'con_0012' 'con_0007' 'con_0010'};
ConNames= {'Int2gtExt' 'Int3gtExt' 'IntgtExt' 'Mean_ExtInt'};
inputs = cell(9, 1);
% if contains(Subscore, 'RawChange')
    JobFile = '/home/sysneu/marjoh/scripts/Personalized-Parkinson-Project-Motor/motor/motor_2ndlevel_OneSampleTtests_prog_job.m';
% else
%     JobFile = '/home/sysneu/marjoh/scripts/Personalized-Parkinson-Project-Motor/motor/motor_2ndlevel_OneSampleTtests_ba_job.m';
% end

for c = 1:numel(ConList)
    
%     if strcmp(ConNames{c}, 'Int>Ext')
%         Mask = {'/project/3024006.02/Analyses/Masks/WholeBrain.nii'};
%     elseif strcmp(ConNames{c}, 'Ext>Int')
%         Mask = {'/project/3024006.02/Analyses/Masks/WholeBrain.nii'};
%     elseif strcmp(ConNames{c}, 'Mean_ExtInt')
%         Mask = {'/project/3024006.02/Analyses/Masks/WholeBrain.nii'};
%     end
%     Mask = {'/project/3024006.02/Analyses/Masks/JuBrain_ROIs/Frontoparietal_BasalGanglia_Cerebellum_mask.nii'};
    Mask = {''};
    
    searchnames = insertBefore(SubInfo.Sub, 1, 'PD_POM_');
%     if contains(Subscore, 'RawChange')
        inputs{1,1} = {fullfile(ANALYSESDir, GroupFolder, dirname, ['ClinCorr-BA_BradyCogCom'], ConNames{c})};
        inputs{2,1} = find_contrast_files(searchnames, fullfile(ANALYSESDir, GroupFolder, ConList{c}, ses));
        inputs{3,1} = SubInfo.Score;
        inputs{4,1} = SubInfo.Score_BA;
        inputs{5,1} = SubInfo.Age;
        inputs{6,1} = SubInfo.Gender;
%         inputs{7,1} = SubInfo.FD;
        inputs{7,1} = SubInfo.Education;
        inputs{8,1} = SubInfo.HandDominance;
%         inputs{10,1} = SubInfo.BMI;
%         inputs{11,1} = SubInfo.SmokingHistory;
%         inputs{12,1} = SubInfo.PASE;
%         inputs{12,1} = SubInfo.Up1Total;
%         inputs{13,1} = SubInfo.RBDSQSum;
%         inputs{14,1} = SubInfo.BDI2;
        inputs{9,1} = Mask;
%     else
%         inputs{1,1} = {fullfile(ANALYSESDir, GroupFolder, 'Baseline', ['ClinCorr-BA_' Subscore{1}], ConNames{c})};
%         inputs{2,1} = find_contrast_files(searchnames, fullfile(ANALYSESDir, GroupFolder, ConList{c}, ses));
%         inputs{3,1} = SubInfo.Score;
%         inputs{4,1} = SubInfo.Age;
%         inputs{5,1} = SubInfo.Gender;
% %         inputs{6,1} = SubInfo.FD;
%         inputs{6,1} = SubInfo.Education;
%         inputs{7,1} = SubInfo.HandDominance;
%         inputs{8,1} = Mask;
%     end
    
    if exclude_outliers
        inputs{1,1} = insertAfter(inputs{1,1}, 'BradyCogCom', '_NoOutliers');
    end
    if ~isempty(Subtype)
        inputs{1,1} = insertBefore(inputs{1,1}, 'ClinCorr', [Subtype '_']);
    end
    %Start with new directory
    if ~exist(char(inputs{1,1}), 'dir')
        mkdir(char(inputs{1,1}));
    else
        delete(fullfile(char(inputs{1,1}), '*.*'));
    end
    filename = char(fullfile(inputs{1,1}, 'Inputs.mat'));
    save(filename, 'inputs')
    spm_jobman('run', JobFile, inputs{:});
%     jobs{c} =  qsubfeval('spm_jobman','run',JobFile, inputs{:},'memreq',15*1024^3,'timreq',20*60*60);
    
end
end