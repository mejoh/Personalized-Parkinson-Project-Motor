% Contrast one group against another
% Run with matlab/R2020b

function motor_2ndlevel_4x3RMANOVA(exclude_outliers)

%% Group to comapre against controls

if nargin<1
    exclude_outliers = true;
end

%% Directories

ses = 'ses-Visit1';
GroupFolder = 'Group';
ANALYSESDir = '/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem';
ClinicalConfs = readtable('/project/3024006.02/Data/matlab/ClinVars_select_mri.csv');
baseid = ClinicalConfs.TimepointNr == 0;
ClinicalConfs = ClinicalConfs(baseid,:);
g1 = string(ClinicalConfs.ParticipantType) == "HC_PIT";
g2 = string(ClinicalConfs.ParticipantType) == "PD_POM";
ClinicalConfs = ClinicalConfs(logical(g1 + g2),:);
% Subtypes = readtable('/project/3022026.01/pep/deprecated_ClinVars/derivatives/Subtypes_2021-04-12.csv');
Sub = cellstr(spm_select('List', fullfile(ANALYSESDir, GroupFolder, 'con_0001', ses), '.*sub-POM.*'));
Sub = extractBetween(Sub, 1, 31);
fprintf('Number of subjects processed: %i\n', numel(Sub))

%% Selection

Sel = false(size(Sub));
for n = 1:numel(Sub)
    if contains(Sub{n}, 'HC_PIT') || contains(Sub{n}, 'PD_POM')
        Sel(n) = true;
    end
end
Sub = Sub(Sel);

SubInfo.Sub = extractBetween(Sub, 8, 31);
SubInfo.Group = extractBetween(Sub, 1, 6);

Sel = false(size(Sub));
for n = 1:height(ClinicalConfs)
    if strcmp(ClinicalConfs.ParticipantType(n), 'PD_POM') || strcmp(ClinicalConfs.ParticipantType(n), 'HC_PIT')
        Sel(n) = true;
    end
end
ClinicalConfs = ClinicalConfs(Sel,:);

SubInfo.Type = cell(size(SubInfo.Sub));
for n = 1:numel(SubInfo.Sub)
    if strcmp(SubInfo.Group{n}, 'PD_POM')
        idx = strcmp(ClinicalConfs.pseudonym, SubInfo.Sub{n});
        if sum(idx)>0
            t = ClinicalConfs.Subtype_Imputed_DisDurSplit{idx};
            SubInfo.Type{n} = t;
        else
            SubInfo.Type{n} = 'Undefined';
        end
    elseif strcmp(SubInfo.Group{n}, 'HC_PIT')
        SubInfo.Type{n} = 'HealthyControl';
    end
end
tabulate(SubInfo.Type)

Sel = true(size(SubInfo.Sub));
for n = 1:numel(SubInfo.Sub)
    if strcmp(SubInfo.Type{n}, '4_Undefined') || strcmp(SubInfo.Type{n}, 'Undefined')
        Sel(n) = false;
    end
end
SubInfo = subset_subinfo(SubInfo,Sel);

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
ConList = {'con_0001' 'con_0002' 'con_0003'};
Inputs = cell(16,1);
if ~exclude_outliers 
    Inputs{1,1} = {fullfile(ANALYSESDir, GroupFolder, 'HcSubtypes_x_ExtInt2Int3')};
else
    Inputs{1,1} = {fullfile(ANALYSESDir, GroupFolder, 'HcSubtypes_x_ExtInt2Int3_NoOutliers')};
end

HealthyControl.idx = strcmp(SubInfo.Type, 'HealthyControl');
HealthyControl.Sub = SubInfo.Sub(HealthyControl.idx);
HealthyControl.Sub = insertBefore(HealthyControl.Sub, 1, 'HC_PIT_');
Inputs{2,1} = find_contrast_files(HealthyControl.Sub, fullfile(ANALYSESDir, GroupFolder, ConList{1}, ses));
Inputs{6,1} = find_contrast_files(HealthyControl.Sub, fullfile(ANALYSESDir, GroupFolder, ConList{2}, ses));
Inputs{10,1} = find_contrast_files(HealthyControl.Sub, fullfile(ANALYSESDir, GroupFolder, ConList{3}, ses));
% Inputs{14,1} = find_contrast_files(HealthyControl.Sub, fullfile(ANALYSESDir, GroupFolder, ConList{4}, ses));
HealthyControl.FD = repmat(SubInfo.FD(HealthyControl.idx),3,1);
HealthyControl.Age  = repmat(SubInfo.Age(HealthyControl.idx),3,1);
HealthyControl.Gender  = repmat(SubInfo.Gender_num(HealthyControl.idx),3,1);

MildMotor.idx = strcmp(SubInfo.Type, '1_Mild-Motor');
MildMotor.Sub = SubInfo.Sub(MildMotor.idx);
MildMotor.Sub = insertBefore(MildMotor.Sub, 1, 'PD_POM_');
Inputs{3,1} = find_contrast_files(MildMotor.Sub, fullfile(ANALYSESDir, GroupFolder, ConList{1}, ses));
Inputs{7,1} = find_contrast_files(MildMotor.Sub, fullfile(ANALYSESDir, GroupFolder, ConList{2}, ses));
Inputs{11,1} = find_contrast_files(MildMotor.Sub, fullfile(ANALYSESDir, GroupFolder, ConList{3}, ses));
% Inputs{15,1} = find_contrast_files(MildMotor.Sub, fullfile(ANALYSESDir, GroupFolder, ConList{4}, ses));
MildMotor.FD = repmat(SubInfo.FD(MildMotor.idx),3,1);
MildMotor.Age  = repmat(SubInfo.Age(MildMotor.idx),3,1);
MildMotor.Gender  = repmat(SubInfo.Gender_num(MildMotor.idx),3,1);

Intermediate.idx = strcmp(SubInfo.Type, '2_Intermediate');
Intermediate.Sub = SubInfo.Sub(Intermediate.idx);
Intermediate.Sub = insertBefore(Intermediate.Sub, 1, 'PD_POM_');
Inputs{4,1} = find_contrast_files(Intermediate.Sub, fullfile(ANALYSESDir, GroupFolder, ConList{1}, ses));
Inputs{8,1} = find_contrast_files(Intermediate.Sub, fullfile(ANALYSESDir, GroupFolder, ConList{2}, ses));
Inputs{12,1} = find_contrast_files(Intermediate.Sub, fullfile(ANALYSESDir, GroupFolder, ConList{3}, ses));
% Inputs{16,1} = find_contrast_files(Intermediate.Sub, fullfile(ANALYSESDir, GroupFolder, ConList{4}, ses));
Intermediate.FD = repmat(SubInfo.FD(Intermediate.idx),3,1);
Intermediate.Age  = repmat(SubInfo.Age(Intermediate.idx),3,1);
Intermediate.Gender  = repmat(SubInfo.Gender_num(Intermediate.idx),3,1);

DiffuseMalignant.idx = strcmp(SubInfo.Type, '3_Diffuse-Malignant');
DiffuseMalignant.Sub = SubInfo.Sub(DiffuseMalignant.idx);
DiffuseMalignant.Sub = insertBefore(DiffuseMalignant.Sub, 1, 'PD_POM_');
Inputs{5,1} = find_contrast_files(DiffuseMalignant.Sub, fullfile(ANALYSESDir, GroupFolder, ConList{1}, ses));
Inputs{9,1} = find_contrast_files(DiffuseMalignant.Sub, fullfile(ANALYSESDir, GroupFolder, ConList{2}, ses));
Inputs{13,1} = find_contrast_files(DiffuseMalignant.Sub, fullfile(ANALYSESDir, GroupFolder, ConList{3}, ses));
% Inputs{17,1} = find_contrast_files(DiffuseMalignant.Sub, fullfile(ANALYSESDir, GroupFolder, ConList{4}, ses));
DiffuseMalignant.FD = repmat(SubInfo.FD(DiffuseMalignant.idx),3,1);
DiffuseMalignant.Age  = repmat(SubInfo.Age(DiffuseMalignant.idx),3,1);
DiffuseMalignant.Gender  = repmat(SubInfo.Gender_num(DiffuseMalignant.idx),3,1);

% Inputs{15,1} = [HealthyControl.FD; MildMotor.FD; Intermediate.FD; DiffuseMalignant.FD];
Inputs{14,1} = [HealthyControl.Age; MildMotor.Age; Intermediate.Age; DiffuseMalignant.Age];
Inputs{15,1} = [HealthyControl.Gender; MildMotor.Gender; Intermediate.Gender; DiffuseMalignant.Gender];
Inputs{16,1} = {'/project/3024006.02/Analyses/Masks/WholeBrain.nii'};
% Inputs{16,1} = {'/project/3024006.02/Analyses/Masks/juelich_cb_striatum/Juelich-Cerebellar-Imanova.nii'};

%% Run

JobFile = {spm_file(mfilename('fullpath'), 'suffix','_job', 'ext','.m')};

delete(fullfile(char(Inputs{1}), '*.*'))
spm_jobman('run', JobFile, Inputs{:});

filename = char(fullfile(Inputs{1,1}, 'Inputs.mat'));
save(filename, 'Inputs')

end
