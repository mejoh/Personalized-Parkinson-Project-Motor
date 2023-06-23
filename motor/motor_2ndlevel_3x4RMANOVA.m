% Contrast one group against another
% Run with matlab/R2020b

function motor_2ndlevel_3x4RMANOVA(exclude_outliers)

%% Group to comapre against controls

if nargin<1
    exclude_outliers = true;
end

%% Directories

ses = 'ses-Visit1';
GroupFolder = 'Group';
ANALYSESDir = '/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem';
ClinicalConfs = readtable('/project/3024006.02/Data/matlab/fmri-confs-taskclin_ses-all_groups-all_2023-06-19.csv');
% baseid = ClinicalConfs.TimepointNr == 0;
% ClinicalConfs = ClinicalConfs(baseid,:);
g2 = string(ClinicalConfs.ParticipantType) == "PD_POM";
ClinicalConfs = ClinicalConfs(logical(g2),:);
Sub = cellstr(spm_select('List', fullfile(ANALYSESDir, GroupFolder, 'con_0001', ses), '.*sub-POM.*'));
Sub = extractBetween(Sub, 1, 31);
fprintf('Number of subjects processed: %i\n', numel(Sub))

%% Selection

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

Sel = true(size(SubInfo.Sub));
for n = 1:numel(SubInfo.Sub)
    if strcmp(SubInfo.Type{n}, '4_Undefined') || strcmp(SubInfo.Type{n}, 'Undefined') || strcmp(SubInfo.Type{n}, 'NA')
        Sel(n) = false;
    end
end
SubInfo = subset_subinfo(SubInfo,Sel);

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

%% Age, Gender, 

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
SubInfo.SmokingHistory = zeros(size(SubInfo.Sub));
SubInfo.BMI = zeros(size(SubInfo.Sub));
SubInfo.PASE = zeros(size(SubInfo.Sub));
SubInfo.Up1Total = zeros(size(SubInfo.Sub));
for n = 1:numel(SubInfo.Sub)
    
    subid = find(contains(ClinicalConfs.pseudonym, SubInfo.Sub{n}));
    
    if isempty(subid) || isnan(ClinicalConfs.Age(subid)) || strcmp(ClinicalConfs.Gender(subid), 'NA') || isnan(ClinicalConfs.NpsEducYears(subid)) || isnan(ClinicalConfs.RespHandIsDominant_T0(subid)) || isnan(ClinicalConfs.SmokingHistory(subid)) || isnan(ClinicalConfs.BMI(subid)) || isnan(ClinicalConfs.PASE(subid)) || isnan(ClinicalConfs.Up1Total(subid))
        fprintf('Missing values, excluding %s...\n', SubInfo.Sub{n})
        Sel(n) = false;
    else
        SubInfo.Age(n) = ClinicalConfs.Age(subid);
        SubInfo.Gender(n) = ClinicalConfs.Gender(subid);
        SubInfo.Education(n) = ClinicalConfs.NpsEducYears(subid);
        SubInfo.HandDominance(n) = ClinicalConfs.RespHandIsDominant_T0(subid);
        SubInfo.SmokingHistory(n) = ClinicalConfs.SmokingHistory(subid);
        SubInfo.BMI(n) = ClinicalConfs.BMI(subid);
        SubInfo.PASE(n) = ClinicalConfs.PASE(subid);
        SubInfo.Up1Total(n) = ClinicalConfs.Up1Total(subid);
    end
    
end
fprintf('%i subjects have missing covariates, excluding...\n', length(Sel) - sum(Sel))
SubInfo = subset_subinfo(SubInfo, Sel);

%% Demean covars
SubInfo.Age = SubInfo.Age - mean(SubInfo.Age);
SubInfo.Gender = SubInfo.Gender - mean(SubInfo.Gender);
SubInfo.FD = SubInfo.FD - mean(SubInfo.FD);
SubInfo.Education = SubInfo.Education - mean(SubInfo.Education);
SubInfo.HandDominance = SubInfo.HandDominance - mean(SubInfo.HandDominance);
SubInfo.BMI = SubInfo.BMI - mean(SubInfo.BMI);
SubInfo.SmokingHistory = SubInfo.SmokingHistory - mean(SubInfo.SmokingHistory);
SubInfo.PASE = SubInfo.PASE - mean(SubInfo.PASE);
SubInfo.Up1Total = SubInfo.Up1Total - mean(SubInfo.Up1Total);

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

%% Assemble inputs
tabulate(SubInfo.Type)
ConList = {'con_0001' 'con_0002' 'con_0003' 'con_0004'};
Inputs = cell(12,1);
if ~exclude_outliers 
    Inputs{1,1} = {fullfile(ANALYSESDir, GroupFolder, 'Baseline', 'ReserveControl_Subtypes_x_ExtInt2Int3Catch')};
else
    Inputs{1,1} = {fullfile(ANALYSESDir, GroupFolder, 'Baseline', 'ReserveControl_Subtypes_x_ExtInt2Int3Catch_NoOutliers')};
end

MildMotor.idx = contains(SubInfo.Type, 'Mild-Motor');
MildMotor.Sub = SubInfo.Sub(MildMotor.idx);
MildMotor.Sub = insertBefore(MildMotor.Sub, 1, 'PD_POM_');
Inputs{2,1} = find_contrast_files(MildMotor.Sub, fullfile(ANALYSESDir, GroupFolder, ConList{1}, ses));
Inputs{5,1} = find_contrast_files(MildMotor.Sub, fullfile(ANALYSESDir, GroupFolder, ConList{2}, ses));
Inputs{8,1} = find_contrast_files(MildMotor.Sub, fullfile(ANALYSESDir, GroupFolder, ConList{3}, ses));
Inputs{11,1} = find_contrast_files(MildMotor.Sub, fullfile(ANALYSESDir, GroupFolder, ConList{4}, ses));
MildMotor.FD = repmat(SubInfo.FD(MildMotor.idx),4,1);
MildMotor.Age  = repmat(SubInfo.Age(MildMotor.idx),4,1);
MildMotor.Gender  = repmat(SubInfo.Gender(MildMotor.idx),4,1);
MildMotor.Educ  = repmat(SubInfo.Education(MildMotor.idx),4,1);
MildMotor.Hand  = repmat(SubInfo.HandDominance(MildMotor.idx),4,1);
MildMotor.BMI  = repmat(SubInfo.BMI(MildMotor.idx),4,1);
MildMotor.SmokingHistory  = repmat(SubInfo.SmokingHistory(MildMotor.idx),4,1);
MildMotor.PASE  = repmat(SubInfo.PASE(MildMotor.idx),4,1);
MildMotor.Up1Total  = repmat(SubInfo.Up1Total(MildMotor.idx),4,1);

Intermediate.idx = contains(SubInfo.Type, 'Intermediate');
Intermediate.Sub = SubInfo.Sub(Intermediate.idx);
Intermediate.Sub = insertBefore(Intermediate.Sub, 1, 'PD_POM_');
Inputs{3,1} = find_contrast_files(Intermediate.Sub, fullfile(ANALYSESDir, GroupFolder, ConList{1}, ses));
Inputs{6,1} = find_contrast_files(Intermediate.Sub, fullfile(ANALYSESDir, GroupFolder, ConList{2}, ses));
Inputs{9,1} = find_contrast_files(Intermediate.Sub, fullfile(ANALYSESDir, GroupFolder, ConList{3}, ses));
Inputs{12,1} = find_contrast_files(Intermediate.Sub, fullfile(ANALYSESDir, GroupFolder, ConList{4}, ses));
Intermediate.FD = repmat(SubInfo.FD(Intermediate.idx),4,1);
Intermediate.Age  = repmat(SubInfo.Age(Intermediate.idx),4,1);
Intermediate.Gender  = repmat(SubInfo.Gender(Intermediate.idx),4,1);
Intermediate.Educ  = repmat(SubInfo.Education(Intermediate.idx),4,1);
Intermediate.Hand  = repmat(SubInfo.HandDominance(Intermediate.idx),4,1);
Intermediate.BMI  = repmat(SubInfo.BMI(Intermediate.idx),4,1);
Intermediate.SmokingHistory  = repmat(SubInfo.SmokingHistory(Intermediate.idx),4,1);
Intermediate.PASE  = repmat(SubInfo.PASE(Intermediate.idx),4,1);
Intermediate.Up1Total  = repmat(SubInfo.Up1Total(Intermediate.idx),4,1);

DiffuseMalignant.idx = contains(SubInfo.Type, 'Diffuse-Malignant');
DiffuseMalignant.Sub = SubInfo.Sub(DiffuseMalignant.idx);
DiffuseMalignant.Sub = insertBefore(DiffuseMalignant.Sub, 1, 'PD_POM_');
Inputs{4,1} = find_contrast_files(DiffuseMalignant.Sub, fullfile(ANALYSESDir, GroupFolder, ConList{1}, ses));
Inputs{7,1} = find_contrast_files(DiffuseMalignant.Sub, fullfile(ANALYSESDir, GroupFolder, ConList{2}, ses));
Inputs{10,1} = find_contrast_files(DiffuseMalignant.Sub, fullfile(ANALYSESDir, GroupFolder, ConList{3}, ses));
Inputs{13,1} = find_contrast_files(DiffuseMalignant.Sub, fullfile(ANALYSESDir, GroupFolder, ConList{4}, ses));
DiffuseMalignant.FD = repmat(SubInfo.FD(DiffuseMalignant.idx),4,1);
DiffuseMalignant.Age  = repmat(SubInfo.Age(DiffuseMalignant.idx),4,1);
DiffuseMalignant.Gender  = repmat(SubInfo.Gender(DiffuseMalignant.idx),4,1);
DiffuseMalignant.Educ  = repmat(SubInfo.Education(DiffuseMalignant.idx),4,1);
DiffuseMalignant.Hand  = repmat(SubInfo.HandDominance(DiffuseMalignant.idx),4,1);
DiffuseMalignant.BMI  = repmat(SubInfo.BMI(DiffuseMalignant.idx),4,1);
DiffuseMalignant.SmokingHistory  = repmat(SubInfo.SmokingHistory(DiffuseMalignant.idx),4,1);
DiffuseMalignant.PASE  = repmat(SubInfo.PASE(DiffuseMalignant.idx),4,1);
DiffuseMalignant.Up1Total  = repmat(SubInfo.Up1Total(DiffuseMalignant.idx),4,1);

Inputs{14,1} = [MildMotor.FD; Intermediate.FD; DiffuseMalignant.FD];
Inputs{15,1} = [MildMotor.Age; Intermediate.Age; DiffuseMalignant.Age];
Inputs{16,1} = [MildMotor.Gender; Intermediate.Gender; DiffuseMalignant.Gender];
Inputs{17,1} = [MildMotor.Educ; Intermediate.Educ; DiffuseMalignant.Educ];
Inputs{18,1} = [MildMotor.Hand; Intermediate.Hand; DiffuseMalignant.Hand];
Inputs{19,1} = [MildMotor.BMI; Intermediate.BMI; DiffuseMalignant.BMI];
Inputs{20,1} = [MildMotor.SmokingHistory; Intermediate.SmokingHistory; DiffuseMalignant.SmokingHistory];
Inputs{21,1} = [MildMotor.PASE; Intermediate.PASE; DiffuseMalignant.PASE];
Inputs{22,1} = [MildMotor.Up1Total; Intermediate.Up1Total; DiffuseMalignant.Up1Total];

%% Run

JobFile = {spm_file(mfilename('fullpath'), 'suffix','_job', 'ext','.m')};

delete(fullfile(char(Inputs{1}), '*.*'))
spm_jobman('run', JobFile, Inputs{:});

filename = char(fullfile(Inputs{1,1}, 'Inputs.mat'));
save(filename, 'Inputs')

end
