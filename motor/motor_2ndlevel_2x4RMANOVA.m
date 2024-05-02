% Contrast one group against another
% Run with matlab/R2020b

function motor_2ndlevel_2x4RMANOVA(Offstate, exclude_outliers)

%% Group to comapre against controls

if nargin<1 || isempty(Offstate)
    Offstate = false;
    exclude_outliers = false;
end

%% Paths

addpath('/home/common/matlab/spm12');
spm('defaults', 'FMRI');

%% Directories

ses = 'ses-Visit2';
if strcmp(ses, 'ses-Visit1')
    dirname = 'Baseline';
else
    dirname = 'FollowUp';
end
GroupFolder = 'Group';
ANALYSESDir = '/project/3024006.02/Analyses/motor_task';
ClinicalConfs = readtable('/project/3024006.02/Data/matlab/fmri-confs-taskclin_ses-all_groups-all_2024-02-07.csv');
% baseid = ClinicalConfs.TimepointNr == 0;
% ClinicalConfs = ClinicalConfs(baseid,:);
if Offstate
    g1 = string(ClinicalConfs.ParticipantType) == "HC_PIT";
    g2 = string(ClinicalConfs.ParticipantType) == "PD_PIT";
else
    g1 = string(ClinicalConfs.ParticipantType) == "HC_PIT";
    g2 = string(ClinicalConfs.ParticipantType) == "PD_POM";
end
ClinicalConfs = ClinicalConfs(logical(g1 + g2),:);
Sub = cellstr(spm_select('List', fullfile(ANALYSESDir, GroupFolder, 'con_0001', ses), '.*sub-POM.*'));
Sub = extractBetween(Sub, 1, 31);
fprintf('Number of subjects processed: %i\n', numel(Sub))

%% Selection

Sel = false(size(Sub));
for n = 1:numel(Sub)
    if istrue(Offstate) && (contains(Sub{n}, 'HC_PIT') || contains(Sub{n}, 'PD_PIT'))
        Sel(n) = true;
    elseif ~istrue(Offstate) && (contains(Sub{n}, 'HC_PIT') || contains(Sub{n}, 'PD_POM'))
        Sel(n) = true;
    end
end
Sub = Sub(Sel);

SubInfo.Sub = extractBetween(Sub, 8, 31);
SubInfo.Group = extractBetween(Sub, 1, 6);

% Quality control: outlier exclusion
Outliers = readtable('/project/3024006.02/Analyses/BRAIN_2023/fMRI/Quality_control/Exclusions.csv');
% Lenient option:
% baseid = contains(Outliers.visit, 'Visit1') & Outliers.definitive_exclusions == 1;
baseid = (contains(Outliers.visit, 'Visit2') + contains(Outliers.visit, 'Visit3')) & Outliers.definitive_exclusions == 1;
% Conservative option: 
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

% Exclude subjects with partial FOV
% subsWithPartial={'sub-POMU0AEE0E7E9F195659' 'sub-POMU4EFC0F78C5AE0D4D' 'sub-POMU08DC74B16BF4B68D'...
%     'sub-POMU9A6F4EBE996632F4' 'sub-POMU32C52AEA06F071F1' 'sub-POMU3227DABC7764ADB0' 'sub-POMU8067BDE54D1B1B4A'...
%     'sub-POMU022823FBC6EBD9D9' 'sub-POMUAC2513F0E5E32349' 'sub-POMUB8593E25A5D0A1A1' 'sub-POMUBA958B8183C9F612'...
%     'sub-POMUE27AD07D69403066' 'sub-POMUFAB8E98269745B2E' 'sub-POMUFEF5CB22166E0EB3'};
% Sel = true(size(SubInfo.Sub));
% for n = 1:numel(SubInfo.Sub)
%     if contains(SubInfo.Sub{n}, subsWithPartial)
%        Sel(n) = false;
%     fprintf('Excluding due to partial FOV: %s %s \n', SubInfo.Sub{n}, SubInfo.Group{n})
%     end
% end
% SubInfo = subset_subinfo(SubInfo, Sel);

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
SubInfo = subset_subinfo(SubInfo, Sel);

%% Control analysis: Right-handed MMP vs HC
% Table = readtable('/project/3024006.02/Data/matlab/right_hand_responders(MMP_HC).csv');
% Sel = false(size(SubInfo.Sub));
% for n = 1:numel(SubInfo.Sub)
%     if sum(contains(Table.pseudonym,SubInfo.Sub{n})) > 0
%         Sel(n) = true;
%     else
%         Sel(n) = false;
%     end
% end
% SubInfo = subset_subinfo(SubInfo, Sel);

%% Collect events.json and confound files

SubInfo.ConfFiles = cell(size(SubInfo.Sub));
for n = 1:numel(SubInfo.Sub)
    if contains(SubInfo.Group{n}, '_PIT')
        Session = 'ses-PITVisit2';
    else
        Session = 'ses-POMVisit3';
    end
%     SubInfo.ConfFiles{n} = spm_select('FPList', fullfile(ANALYSESDir, SubInfo.Sub{n}, Session), '^.*task-motor_acq-MB6_run-.*_desc-confounds_timeseries3.mat$');
%     if isempty(SubInfo.ConfFiles{n})
%         SubInfo.ConfFiles{n} = spm_select('FPList', fullfile(ANALYSESDir, SubInfo.Sub{n}, Session), '^.*task-motor_acq-MB6_run-.*_desc-confounds_timeseries2.mat$');
%     end
    confs = spm_select('FPList', fullfile(ANALYSESDir, SubInfo.Sub{n}, Session), '^.*task-motor_acq-MB6_run-.*_desc-confounds_timeseries.*.mat$');
    dims = size(confs);
    SubInfo.ConfFiles{n} = confs(dims(1),:);
end

%% Framewise displacement

SubInfo.FD = zeros(size(SubInfo.Sub));
for n = 1:numel(SubInfo.Sub)
    Confounds = spm_load(SubInfo.ConfFiles{n});
    FrameDisp = Confounds.R(:,strcmp(Confounds.names, 'framewise_displacement'));
    FrameDisp(isnan(FrameDisp)) = 0;
    SubInfo.FD(n) = mean(FrameDisp);
end

%% Confounders

% Interpolate age and gender
% SubInfo.Age = zeros(size(SubInfo.Sub));
% SubInfo.Gender = zeros(size(SubInfo.Sub));
% SubInfo.Education = zeros(size(SubInfo.Sub));
% SubInfo.HandDominance = zeros(size(SubInfo.Sub));
% for n = 1:numel(SubInfo.Sub)
%     
%     subid = find(contains(ClinicalConfs.pseudonym, SubInfo.Sub{n}));
%     
%     if isempty(subid) || isnan(ClinicalConfs.Age(subid)) || strcmp(ClinicalConfs.Gender(subid), 'NA')
%         fprintf('Missing values, interpolating...\n')
%         SubInfo.Age(n) = round(mean(ClinicalConfs.Age, 'omitnan'));
%         SubInfo.Gender{n} = cellstr('Male');
%     else
%         SubInfo.Age(n) = ClinicalConfs.Age(subid);
%         SubInfo.Gender{n} = ClinicalConfs.Gender(subid);
%     end
%     
% end

% Exclude subjects with missing Age and Gender
Sel = true(size(SubInfo.Sub));
SubInfo.Age = zeros(size(SubInfo.Sub));
SubInfo.Gender = zeros(size(SubInfo.Sub));
SubInfo.Education = zeros(size(SubInfo.Sub));
SubInfo.HandDominance = zeros(size(SubInfo.Sub));
for n = 1:numel(SubInfo.Sub)
    
    subid = find(contains(ClinicalConfs.pseudonym, SubInfo.Sub{n}));
    
    if isempty(subid) || isnan(ClinicalConfs.Age(subid)) || strcmp(ClinicalConfs.Gender(subid), 'NA') || isnan(ClinicalConfs.NpsEducYears(subid)) || isnan(ClinicalConfs.RespHandIsDominant_T0(subid))
        fprintf('Missing values, excluding %s...\n', SubInfo.Sub{n})
        Sel(n) = false;
    else
        SubInfo.Age(n) = ClinicalConfs.Age(subid);
        SubInfo.Gender(n) = ClinicalConfs.Gender(subid);
        SubInfo.Education(n) = ClinicalConfs.NpsEducYears(subid);
        SubInfo.HandDominance(n) = ClinicalConfs.RespHandIsDominant_T0(subid);
    end
    
end
fprintf('%i subjects have missing Age/Gender/Education/HandDominance, excluding...\n', length(Sel) - sum(Sel))
SubInfo = subset_subinfo(SubInfo, Sel);

%% Demean covars
SubInfo.FD = SubInfo.FD - mean(SubInfo.FD);
SubInfo.Age = SubInfo.Age - mean(SubInfo.Age);
SubInfo.Gender = SubInfo.Gender - mean(SubInfo.Gender);
SubInfo.Education = SubInfo.Education - mean(SubInfo.Education);
SubInfo.HandDominance = SubInfo.HandDominance - mean(SubInfo.HandDominance);

%% Examine correlation structure between relevant regressors

% CorrMat = zeros(4);
%     
% for n = 1:numel(Sub)
%     SPMmat = load(fullfile(ANALYSESDir, ['sub-' Sub{n}], '1st_level', 'SPM.mat'));
%     LastReg = find(contains(SPMmat.SPM.xX.name, 'Sn(1) Int3*bf(1)'));
%     CovMat = cov(SPMmat.SPM.xX.X(:,1:LastReg));
%     CorrMat = CorrMat + corrcov(CovMat);
%     
% end
% 
% AvgCorrMat = CorrMat / numel(Sub);
% heatmap(AvgCorrMat)

%% Select a subset
% % Sel = true(size(SubInfo.Sub,1),1);
% % % HC
% % btmhlf = 1:26;
% % tophlf = 27:52;
% % % PD
% % btmhlf = 52:187;
% % tophlf = 188:size(SubInfo.Sub,1);
% % idx = tophlf;
% % Sel(idx) = false;
% % SubInfo = subset_subinfo(SubInfo, Sel);

%% Assemble inputs
ConList = {'con_0001' 'con_0002' 'con_0003' 'con_0004'};
Inputs = cell(12,1);
if Offstate
    Inputs{1,1} = {fullfile(ANALYSESDir, GroupFolder, 'HcOff_x_ExtInt2Int3Catch')};
else
    Inputs{1,1} = {fullfile(ANALYSESDir, GroupFolder, 'HcOn_x_ExtInt2Int3Catch')};
end

if ~istrue(exclude_outliers) && istrue(Offstate)
    Inputs{1,1} = {fullfile(ANALYSESDir, GroupFolder, dirname, 'HcOff_x_ExtInt2Int3Catch')};
elseif ~istrue(exclude_outliers) && ~istrue(Offstate)
    Inputs{1,1} = {fullfile(ANALYSESDir, GroupFolder, dirname, 'HcOn_x_ExtInt2Int3Catch')};
elseif istrue(exclude_outliers) && istrue(Offstate)
    Inputs{1,1} = {fullfile(ANALYSESDir, GroupFolder, dirname, 'HcOff_x_ExtInt2Int3Catch_NoOutliers')};
elseif istrue(exclude_outliers) && ~istrue(Offstate)
    Inputs{1,1} = {fullfile(ANALYSESDir, GroupFolder, dirname, 'HcOn_x_ExtInt2Int3Catch_NoOutliers')};
end

ExtHc = dir(fullfile(ANALYSESDir, GroupFolder, ConList{1}, ses, 'HC*'));
ExtHc_files = {ExtHc.name}';
ExtHc_files = ExtHc_files(contains({ExtHc.name}, SubInfo.Sub));
Inputs{2,1} = fullfile(ANALYSESDir, GroupFolder, ConList{1}, ses, ExtHc_files);
Int2Hc = dir(fullfile(ANALYSESDir, GroupFolder, ConList{2}, ses, 'HC*'));
Int2Hc_files = {Int2Hc.name}';
Int2Hc_files = Int2Hc_files(contains({Int2Hc.name}, SubInfo.Sub));
Inputs{4,1} = fullfile(ANALYSESDir, GroupFolder, ConList{2}, ses, Int2Hc_files);
Int3Hc = dir(fullfile(ANALYSESDir, GroupFolder, ConList{3}, ses, 'HC*'));
Int3Hc_files = {Int3Hc.name}';
Int3Hc_files = Int3Hc_files(contains({Int3Hc.name}, SubInfo.Sub));
Inputs{6,1} = fullfile(ANALYSESDir, GroupFolder, ConList{3}, ses, Int3Hc_files);
CatchHc = dir(fullfile(ANALYSESDir, GroupFolder, ConList{4}, ses, 'HC*'));
CatchHc_files = {CatchHc.name}';
CatchHc_files = CatchHc_files(contains({CatchHc.name}, SubInfo.Sub));
Inputs{8,1} = fullfile(ANALYSESDir, GroupFolder, ConList{4}, ses, CatchHc_files);

if Offstate
    Pd = 'PD_PIT*';
else
    Pd = 'PD_POM*';
end
ExtPd = dir(fullfile(ANALYSESDir, GroupFolder, ConList{1}, ses, Pd));
ExtPd_files = {ExtPd.name}';
ExtPd_files = ExtPd_files(contains({ExtPd.name}, SubInfo.Sub));
Inputs{3,1} = fullfile(ANALYSESDir, GroupFolder, ConList{1}, ses, ExtPd_files);
Int2Pd = dir(fullfile(ANALYSESDir, GroupFolder, ConList{2}, ses, Pd));
Int2Pd_files = {Int2Pd.name}';
Int2Pd_files = Int2Pd_files(contains({Int2Pd.name}, SubInfo.Sub));
Inputs{5,1} = fullfile(ANALYSESDir, GroupFolder, ConList{2}, ses, Int2Pd_files);
Int3Pd = dir(fullfile(ANALYSESDir, GroupFolder, ConList{3}, ses, Pd));
Int3Pd_files = {Int3Pd.name}';
Int3Pd_files = Int3Pd_files(contains({Int3Pd.name}, SubInfo.Sub));
Inputs{7,1} = fullfile(ANALYSESDir, GroupFolder, ConList{3}, ses, Int3Pd_files);
CatchPd = dir(fullfile(ANALYSESDir, GroupFolder, ConList{4}, ses, Pd));
CatchPd_files = {CatchPd.name}';
CatchPd_files = CatchPd_files(contains({CatchPd.name}, SubInfo.Sub));
Inputs{9,1} = fullfile(ANALYSESDir, GroupFolder, ConList{4}, ses, CatchPd_files);

FD_hc = SubInfo.FD(strcmp(SubInfo.Group, 'HC_PIT'));
Age_hc = SubInfo.Age(strcmp(SubInfo.Group, 'HC_PIT'));
Gender_hc = SubInfo.Gender(strcmp(SubInfo.Group, 'HC_PIT'));
Educ_hc = SubInfo.Education(strcmp(SubInfo.Group, 'HC_PIT'));
Hand_hc = SubInfo.HandDominance(strcmp(SubInfo.Group, 'HC_PIT'));
if Offstate
    FD_pd = SubInfo.FD(strcmp(SubInfo.Group, 'PD_PIT'));
    Age_pd = SubInfo.Age(strcmp(SubInfo.Group, 'PD_PIT'));
    Gender_pd = SubInfo.Gender(strcmp(SubInfo.Group, 'PD_PIT'));
    Educ_pd = SubInfo.Education(strcmp(SubInfo.Group, 'PD_PIT'));
    Hand_pd = SubInfo.HandDominance(strcmp(SubInfo.Group, 'PD_PIT'));
else
    FD_pd = SubInfo.FD(strcmp(SubInfo.Group, 'PD_POM'));
    Age_pd = SubInfo.Age(strcmp(SubInfo.Group, 'PD_POM'));
    Gender_pd = SubInfo.Gender(strcmp(SubInfo.Group, 'PD_POM'));
    Educ_pd = SubInfo.Education(strcmp(SubInfo.Group, 'PD_POM'));
    Hand_pd = SubInfo.HandDominance(strcmp(SubInfo.Group, 'PD_POM'));
end
Inputs{10,1} = [FD_hc; FD_hc; FD_hc; FD_hc; FD_pd; FD_pd; FD_pd; FD_pd];
Inputs{11,1} = [Age_hc; Age_hc; Age_hc; Age_hc; Age_pd; Age_pd; Age_pd; Age_pd];
Inputs{12,1} = [Gender_hc; Gender_hc; Gender_hc; Gender_hc; Gender_pd; Gender_pd; Gender_pd; Gender_pd];
Inputs{13,1} = [Educ_hc; Educ_hc; Educ_hc; Educ_hc; Educ_pd; Educ_pd; Educ_pd; Educ_pd];
Inputs{14,1} = [Hand_hc; Hand_hc; Hand_hc; Hand_hc; Hand_pd; Hand_pd; Hand_pd; Hand_pd];

%% Run

JobFile = {spm_file(mfilename('fullpath'), 'suffix','_job', 'ext','.m')};

delete(fullfile(char(Inputs{1}), '*.*'))
spm_jobman('run', JobFile, Inputs{:});

filename = char(fullfile(Inputs{1,1}, 'Inputs.mat'));
save(filename, 'Inputs')

end
