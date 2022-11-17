function motor_2ndlevel_OneSampleTtests(BaselineOnly, Subscore, exclude_outliers, Subtype)
% Subscores
% Total AppendicularSum CompositeTremorSum
% PIGDSum ActionTremorSum TotalOnOffDelta BradySumOnOffDelta RestTremAmpSumOnOffDelta RestTremAmpSum BradySum RigiditySum 

if nargin < 1 || isempty(BaselineOnly)
    BaselineOnly = true;
end
if nargin < 1 || isempty(Subscore)
    Subscore = 'BradySum';
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

ses = 'ses-Visit1';
GroupFolder = 'Group';
ANALYSESDir = '/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem';
ClinicalConfs = readtable('/project/3024006.02/Data/matlab/ClinVars_select_mri6.csv');
baseid = ClinicalConfs.TimepointNr == 0;
ClinicalConfs = ClinicalConfs(baseid,:);
g2 = string(ClinicalConfs.ParticipantType) == "PD_POM";
ClinicalConfs = ClinicalConfs(logical(g2),:);
Sub = cellstr(spm_select('List', fullfile(ANALYSESDir, GroupFolder, 'con_0001', ses), '.*sub-POM.*'));
Sub = extractBetween(Sub, 1, 31);
fprintf('Number of subjects processed: %i\n', numel(Sub))

%% Selection

% Select variables and remove missing values
Colnames = {'pseudonym' 'ParticipantType' 'Subtype_DiagEx3_DisDurSplit' ['Up3Of' Subscore]...
    'Age' 'Gender' 'non_pd_diagnosis_at_ba_or_fu'};
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
Outliers = readtable('/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Exclusions.csv');
% Lenient
baseid = contains(Outliers.visit, 'Visit1') & Outliers.definitive_exclusions == 1;
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
    
    if ClinicalConfs.non_pd_diagnosis_at_ba_or_fu(subid)
        fprintf('Misdiagnosis as non-PD, excluding %s...\n', SubInfo.Sub{n})
        Sel(n) = false;
    end
    
end
fprintf('%i subjects have a non-PD diagnosis, excluding these now...\n', length(Sel) - sum(Sel))
tabulate(SubInfo.Type)
SubInfo = subset_subinfo(SubInfo, Sel);

%% Collect events.json and confound files

SubInfo.ConfFiles = cell(size(SubInfo.Sub));
for n = 1:numel(SubInfo.Sub)
    Session = 'ses-POMVisit1';
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

%% Age, Gender, Score
Sel = true(size(SubInfo.Sub));
SubInfo.Age = zeros(size(SubInfo.Sub));
SubInfo.Gender = zeros(size(SubInfo.Sub));
SubInfo.Score = zeros(size(SubInfo.Sub));
for n = 1:numel(SubInfo.Sub)
    
    subid = find(contains(ClinicalConfs.pseudonym, SubInfo.Sub{n}));
    
    if isempty(subid)
        fprintf('Missing values, excluding %s...\n', SubInfo.Sub{n})
        Sel(n) = false;
    else
        SubInfo.Age(n) = ClinicalConfs.Age(subid);
        SubInfo.Gender(n) = ClinicalConfs.Gender(subid);
        cID = ismember(ClinicalConfs.Properties.VariableNames, ['Up3Of' Subscore]);
        SubInfo.Score(n) = table2array(ClinicalConfs(subid,cID));
    end
    
end
fprintf('%i subjects have missing values, excluding...\n', length(Sel) - sum(Sel))
SubInfo = subset_subinfo(SubInfo, Sel);

%% Demean covars
SubInfo.Age = SubInfo.Age - mean(SubInfo.Age);
SubInfo.Gender = SubInfo.Gender - mean(SubInfo.Gender);
SubInfo.FD = SubInfo.FD - mean(SubInfo.FD);
SubInfo.Score = SubInfo.Score - mean(SubInfo.Score);

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
ConList = {'con_0012' 'con_0013' 'con_0008' 'con_0010'};
ConNames= {'Int2gtExt' 'Int3gtExt' 'Int3gtInt2'  'Mean_ExtInt'};

if ~istrue(BaselineOnly)
    inputs = cell(8, 1);
    JobFile = '/home/sysneu/marjoh/scripts/Personalized-Parkinson-Project-Motor/motor/motor_2ndlevel_OneSampleTtests_prog_job.m';
else
    inputs = cell(7, 1);
    JobFile = '/home/sysneu/marjoh/scripts/Personalized-Parkinson-Project-Motor/motor/motor_2ndlevel_OneSampleTtests_ba_job.m';
end

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
    
    if ~istrue(BaselineOnly)
        inputs{1,1} = {fullfile(ANALYSESDir, GroupFolder, 'Baseline', ['OneSampleTtest_ClinCorr-Off-Prog-' Subscore], ConNames{c})};
    else
        inputs{1,1} = {fullfile(ANALYSESDir, GroupFolder, 'Baseline', ['OneSampleTtest_ClinCorr-Off-BA' Subscore], ConNames{c})};
    end
    searchnames = insertBefore(SubInfo.Sub, 1, 'PD_POM_');
    inputs{2,1} = find_contrast_files(searchnames, fullfile(ANALYSESDir, GroupFolder, ConList{c}, ses));
    inputs{3,1} = SubInfo.Score;
    inputs{4,1} = SubInfo.Age;
    inputs{5,1} = SubInfo.Gender;
    inputs{6,1} = SubInfo.FD;
    inputs{7,1} = Mask;
    
%     % Disease progression regressed against brain activity (BA severity treated as a covariate of non-interest)
%     % Find images based on pseudos in clinical vars
%     ConDir = fullfile(ANALYSESDir, GroupFolder, ConList{c}, 'ses-Visit1');
%     PdIms = struct2table(dir(fullfile(ConDir, 'PD_POM*')));
%     rID = contains(PdIms.name, ClinVars_subset.pseudonym);
%     PdIms_subset = PdIms(rID,1);
%     PdIms_subset.pseudonym = extractBetween(PdIms_subset.name, 'PD_POM_', '_ses');
%     inputs{2,1} = fullfile(ConDir,PdIms_subset.name);
%     % Find pseudos in clinical vars that match with found images
%     rID = contains(ClinVars_subset.pseudonym, PdIms_subset.pseudonym);
%     fprintf('Number of pseudonyms that have both clinical and fmri data: %i\n', sum(rID))
%     ClinVars_subset = ClinVars_subset(rID,:);
%     rID = contains(SubInfo.Sub, ClinVars_subset.pseudonym);
%     ClinVars_subset.FD = SubInfo.FD(rID);
%     inputs{3,1} = table2array(ClinVars_subset(:,5));
%     if ~istrue(BaselineOnly)
%         inputs{1,1} = {fullfile(ANALYSESDir, GroupFolder, ['OneSampleTtest_ClinCorr-Off-Prog-' Subscore], ConNames{c})};
%         inputs{4,1} = table2array(ClinVars_subset(:,6));
%         inputs{5,1} = ClinVars_subset.Age;
%         inputs{6,1} = grp2idx(ClinVars_subset.Gender)-1;
%         inputs{7,1} = ClinVars_subset.FD;
%         inputs{8,1} = Mask;
%     else
%         inputs{1,1} = {fullfile(ANALYSESDir, GroupFolder, ['OneSampleTtest_ClinCorr-Off-BA' Subscore], ConNames{c})};
%         inputs{4,1} = ClinVars_subset.Age;
%         inputs{5,1} = grp2idx(ClinVars_subset.Gender)-1;
%         inputs{6,1} = ClinVars_subset.FD;
%         inputs{7,1} = Mask;
%     end
    if exclude_outliers
        inputs{1,1} = insertAfter(inputs{1,1}, Subscore, '_NoOutliers');
    end
    if ~isempty(Subtype)
        inputs{1,1} = insertBefore(inputs{1,1}, 'OneSampleTtest', [Subtype '_']);
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