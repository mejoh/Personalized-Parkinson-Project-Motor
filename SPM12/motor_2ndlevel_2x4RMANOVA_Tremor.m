% Contrast one group against another
% Comparison takes one of the following three strings:
% 1. 'TremorHc'
% 2. 'NonTremorHc'
% 3. 'TremorNonTremor'
% TremorClassification takes one of the two following string:
% 1. 'TremorRegressors'
% 2. 'ClinVars'
% Classification takes on one of 4 values:
% For TremorRegressors option: 1 = Healthy, 2 = No tremor, 3 = Tremor, >2Hz, <8Hz, 4 = Unclear
% For ClinVars opttion: 1 = Healthy, 2 = Tremor<1, 3 = Tremor>=2, 4 = Tremor=1
% Tremor is considered in the on-state, on the 'study watch side', whatever that means...

function motor_2ndlevel_2x4RMANOVA_Tremor(Comparison, TremorClassification, exclude_outliers)

if nargin<1
    Comparison = 'TremorNonTremor';
    TremorClassification = 'TremorRegressors';
    exclude_outliers = true;
end

%% Group to comapre against controls

%% Paths

addpath('/home/common/matlab/spm12');
spm('defaults', 'FMRI');

%% Directories

ses = 'ses-Visit1';
GroupFolder = 'Group';
ANALYSESDir = '/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem';
ClinicalConfs = readtable('/project/3022026.01/pep/ClinVars/derivatives/database_clinical_confounds_fmri_2021-08-25.csv');
Sub = cellstr(spm_select('List', fullfile(ANALYSESDir, GroupFolder, 'con_0001', ses), '.*sub-POM.*'));
Sub = extractBetween(Sub, 1, 31);
fprintf('Number of subjects processed: %i\n', numel(Sub))

%% Selection

Sel = false(size(Sub));
for n = 1:numel(Sub)
    if (contains(Sub{n}, 'HC_PIT') || contains(Sub{n}, 'PD_POM'))
        Sel(n) = true;
    end
end
Sub = Sub(Sel);

% This little piece allows you to split the analysis based on some pattern.
% Good for testing whether there are undeteced outliers in your data.
RemovalPattern = '';
Sub = remove_subs(Sub,RemovalPattern);

SubInfo.Sub = extractBetween(Sub, 8, 31);
SubInfo.Group = extractBetween(Sub, 1, 6);

Sel = false(size(Sub));
for n = 1:height(ClinicalConfs)
    if (strcmp(Comparison, 'NonTremorHc') || strcmp(Comparison, 'TremorHc')) && (strcmp(ClinicalConfs.Group(n), 'PD_POM') || strcmp(ClinicalConfs.Group(n), 'HC_PIT'))
        Sel(n) = true;
    elseif strcmp(Comparison, 'TremorNonTremor') && strcmp(ClinicalConfs.Group(n), 'PD_POM')
        Sel(n) = true;
    end
end
ClinicalConfs = ClinicalConfs(Sel,:);

if strcmp(TremorClassification, 'TremorRegressors')
    SubInfo = TremorClassificationByRegressors(SubInfo);
elseif strcmp(TremorClassification, 'ClinVars')
    SubInfo = TremorClassificationByClinVars(SubInfo);
else
    msg = 'TremorClassification was not defined properly';
    error(msg)
end

fSubInfo = char(fullfile(ANALYSESDir, GroupFolder, 'SubInfo.csv'));
tSubInfo = struct2table(SubInfo);
writetable(tSubInfo, fSubInfo);
    

Sel = false(size(SubInfo.Sub));
for n = 1:numel(SubInfo.Sub)
    if strcmp(Comparison, 'TremorHc')
        if SubInfo.Selection(n) == 3 || SubInfo.Selection(n) == 1
            Sel(n) = true;
        end
    elseif strcmp(Comparison, 'NonTremorHc')
        if SubInfo.Selection(n) == 2 || SubInfo.Selection(n) == 1
            Sel(n) = true;
        end
    elseif strcmp(Comparison, 'TremorNonTremor')
        if SubInfo.Selection(n) == 3 || SubInfo.Selection(n) == 2
            Sel(n) = true;
        end
    end
end
SubInfo.Sub = SubInfo.Sub(Sel);
SubInfo.Group = SubInfo.Group(Sel);
SubInfo.Selection = SubInfo.Selection(Sel);

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
        if contains(SubInfo.Sub{n}, outliers)
           Sel(n) = false;
        fprintf('Excluding outlier: %s %s \n', SubInfo.Sub{n}, SubInfo.Group{n})
        end
    end
    SubInfo = subset_subinfo(SubInfo,Sel);
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

%% Age and gender
% Exclude subjects with missing Age and Gender
Sel = true(size(SubInfo.Sub));
SubInfo.Age = zeros(size(SubInfo.Sub));
SubInfo.Gender = cell(size(SubInfo.Sub));
for n = 1:numel(SubInfo.Sub)
    
    subid = find(contains(ClinicalConfs.pseudonym, SubInfo.Sub{n}));
    
    if isempty(subid) || isnan(ClinicalConfs.Age(subid)) || strcmp(ClinicalConfs.Gender(subid), 'NA')
        fprintf('Missing values, excluding %s...\n', SubInfo.Sub{n})
        Sel(n) = false;
    else
        SubInfo.Age(n) = ClinicalConfs.Age(subid);
        SubInfo.Gender{n} = ClinicalConfs.Gender(subid);
    end
    
end
fprintf('%i subjects have missing Age/Gender, excluding...\n', length(Sel) - sum(Sel))
SubInfo = subset_subinfo(SubInfo, Sel);

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
ConList = {'con_0001' 'con_0002' 'con_0003' 'con_0004'};

SubInfo.con_0001 = cell(size(SubInfo.Sub));
SubInfo.con_0002 = cell(size(SubInfo.Sub));
SubInfo.con_0003 = cell(size(SubInfo.Sub));
SubInfo.con_0004 = cell(size(SubInfo.Sub));
for n = 1:numel(SubInfo.Sub)
    if strcmp(SubInfo.Group{n}, 'PD_POM')
        SubInfo.con_0001{n} = spm_select('FPList', fullfile(ANALYSESDir, GroupFolder, ConList{1}, 'ses-Visit1'), ['PD_POM.*' SubInfo.Sub{n} '.*' ConList{1} '.*.nii']);
        SubInfo.con_0002{n} = spm_select('FPList', fullfile(ANALYSESDir, GroupFolder, ConList{2}, 'ses-Visit1'), ['PD_POM.*' SubInfo.Sub{n} '.*' ConList{2} '.*.nii']);
        SubInfo.con_0003{n} = spm_select('FPList', fullfile(ANALYSESDir, GroupFolder, ConList{3}, 'ses-Visit1'), ['PD_POM.*' SubInfo.Sub{n} '.*' ConList{3} '.*.nii']);
        SubInfo.con_0004{n} = spm_select('FPList', fullfile(ANALYSESDir, GroupFolder, ConList{4}, 'ses-Visit1'), ['PD_POM.*' SubInfo.Sub{n} '.*' ConList{4} '.*.nii']);
    elseif strcmp(SubInfo.Group{n}, 'HC_PIT')
        SubInfo.con_0001{n} = spm_select('FPList', fullfile(ANALYSESDir, GroupFolder, ConList{1}, 'ses-Visit1'), ['HC_PIT.*' SubInfo.Sub{n} '.*' ConList{1} '.*.nii']);
        SubInfo.con_0002{n} = spm_select('FPList', fullfile(ANALYSESDir, GroupFolder, ConList{2}, 'ses-Visit1'), ['HC_PIT.*' SubInfo.Sub{n} '.*' ConList{2} '.*.nii']);
        SubInfo.con_0003{n} = spm_select('FPList', fullfile(ANALYSESDir, GroupFolder, ConList{3}, 'ses-Visit1'), ['HC_PIT.*' SubInfo.Sub{n} '.*' ConList{3} '.*.nii']);
        SubInfo.con_0004{n} = spm_select('FPList', fullfile(ANALYSESDir, GroupFolder, ConList{4}, 'ses-Visit1'), ['HC_PIT.*' SubInfo.Sub{n} '.*' ConList{4} '.*.nii']);
    end
end

Inputs = cell(10,1);
if strcmp(Comparison, 'TremorHc')
    Inputs{1,1} = {fullfile(ANALYSESDir, GroupFolder, 'TremorHc_x_ExtInt2Int3Catch')};
    G1 = 1;
    G2 = 3;
elseif strcmp(Comparison, 'NonTremorHc')
    Inputs{1,1} = {fullfile(ANALYSESDir, GroupFolder, 'NonTremorHc_x_ExtInt2Int3Catch')};
    G1 = 1;
    G2 = 2;
elseif strcmp(Comparison, 'TremorNonTremor')
    Inputs{1,1} = {fullfile(ANALYSESDir, GroupFolder, 'TremorNonTremor_x_ExtInt2Int3Catch')};
    G1 = 2;
    G2 = 3;
end

if exclude_outliers
    Inputs{1,1} = {[char(Inputs{1,1}) '_NoOutliers']};
end

Inputs{2,1} = SubInfo.con_0001(SubInfo.Selection == G1,:);
Inputs{4,1} = SubInfo.con_0002(SubInfo.Selection == G1,:);
Inputs{6,1} = SubInfo.con_0003(SubInfo.Selection == G1,:);
Inputs{8,1} = SubInfo.con_0004(SubInfo.Selection == G1,:);
Inputs{3,1} = SubInfo.con_0001(SubInfo.Selection == G2,:);
Inputs{5,1} = SubInfo.con_0002(SubInfo.Selection == G2,:);
Inputs{7,1} = SubInfo.con_0003(SubInfo.Selection == G2,:);
Inputs{9,1} = SubInfo.con_0004(SubInfo.Selection == G2,:);
G1_FD = SubInfo.FD(SubInfo.Selection == G1,:);
G2_FD = SubInfo.FD(SubInfo.Selection == G2,:);
G1_Age = SubInfo.Age(SubInfo.Selection == G1,:);
G2_Age = SubInfo.Age(SubInfo.Selection == G2,:);
G1_Gender = SubInfo.Gender_num(SubInfo.Selection == G1,:);
G2_Gender = SubInfo.Gender_num(SubInfo.Selection == G2,:);
Inputs{10,1} = [G1_FD; G1_FD; G1_FD; G1_FD; G2_FD; G2_FD; G2_FD; G2_FD];
Inputs{11,1} = [G1_Age; G1_Age; G1_Age; G1_Age; G2_Age; G2_Age; G2_Age; G2_Age];
Inputs{12,1} = [G1_Gender; G1_Gender; G1_Gender; G1_Gender; G2_Gender; G2_Gender; G2_Gender; G2_Gender];

%% Run

JobFile = {spm_file(mfilename('fullpath'), 'suffix','_job', 'ext','.m')};

delete(fullfile(char(Inputs{1}), '*.*'))
spm_jobman('run', JobFile, Inputs{:});

fInputs = char(fullfile(Inputs{1,1}, 'Inputs.mat'));
save(fInputs, 'Inputs')

end

function [SubInfo] = TremorClassificationByRegressors(SubInfo)

TremorClass = load('/project/3024006.02/Analyses/EMG/motor/manually_checked/Martin/Tremor_check-24-Mar-2021.mat');
PeakClass = load('/project/3024006.02/Analyses/EMG/motor/manually_checked/Martin/Peak_check-24-Mar-2021.mat');
TremorRegFolder = fullfile('/project/3024006.02/Analyses/EMG/motor/processing/prepemg/Regressors/ZSCORED');

Sel = true(size(SubInfo.Sub));
for n = 1:numel(SubInfo.Sub)
    if strcmp(SubInfo.Group{n}, 'PD_POM')
        TremorClassID = find(contains(TremorClass.Tremor_check.cName, [SubInfo.Sub{n} '-ses-Visit1']));
        PeakClassID = find(contains(PeakClass.Peak_check.cName, [SubInfo.Sub{n} '-ses-Visit1']));
        if isempty(TremorClassID) || isempty(PeakClassID)
            Sel(n) = false;
        end
    end
end
SubInfo = subset_subinfo(SubInfo,Sel);
SubInfo.Selection = zeros(numel(SubInfo.Sub),1);

for n = 1:numel(SubInfo.Sub)
    if strcmp(SubInfo.Group{n}, 'HC_PIT')
        SubInfo.Selection(n) = 1;
    elseif strcmp(SubInfo.Group{n}, 'PD_POM')
        
        TremorClassID = find(contains(TremorClass.Tremor_check.cName, [SubInfo.Sub{n} '-ses-Visit1']));
        TremorPresence = TremorClass.Tremor_check.cVal(TremorClassID);
        PeakClassID = find(contains(PeakClass.Peak_check.cName, [SubInfo.Sub{n} '-ses-Visit1']));
        PeakClarity = PeakClass.Peak_check.cVal(PeakClassID);
        
        TremorRegFile = spm_select('List', TremorRegFolder, [SubInfo.Sub{n} '-ses-Visit1.*_log.jpg']);
        strtPtn = '_acc_' + wildcardPattern + '_';
        TremorFreq = cell2mat(extractBetween(TremorRegFile, strtPtn, 'Hz'));
        TremorFreq = str2double(TremorFreq);
        if TremorPresence == 0
            SubInfo.Selection(n) = 2;
        elseif TremorPresence == 1 && PeakClarity == 1 && TremorFreq > 2 && TremorFreq < 8
            SubInfo.Selection(n) = 3;
        else
            SubInfo.Selection(n) = 4;
        end
    end
end
fprintf('Outcome of tremor subtyping based on tremor regressors \n')
tabulate(SubInfo.Selection)

end

function [SubInfo] = TremorClassificationByClinVars(SubInfo)

ClinVars = readtable('/project/3022026.01/pep/ClinVars/derivatives/database_clinical_variables_2021-03-04.csv');

SubInfo.Selection = zeros(numel(SubInfo.Sub),1);
Age = zeros(numel(SubInfo.Sub),1);
EstDisDurYears = zeros(numel(SubInfo.Sub),1);
Up3OfTotal = zeros(numel(SubInfo.Sub),1);

for n = 1:numel(SubInfo.Sub)
    if strcmp(SubInfo.Group{n}, 'HC_PIT')
        SubInfo.Selection(n) = 1;
    elseif strcmp(SubInfo.Group{n}, 'PD_POM')
        
        idx_sub = find(contains(ClinVars.pseudonym, SubInfo.Sub{n}));
        c = ClinVars(idx_sub,:);
        idx_time = find(contains(c.Timepoint, 'ses-Visit1'));
        c = c(idx_time,:);
        
        if isempty(c)
            
            SubInfo.Selection(n) = NaN;
            Age(n) = NaN;
            EstDisDurYears(n) = NaN;
            Up3OfTotal(n) = NaN;
            continue
            
        end
        
        idx_tremitems = find(contains(c.Properties.VariableNames,"Up3OnRAmpArmYesDev"));
        TremorSeverity = table2array(c(:, [idx_tremitems]));
        MaxTremorSeverity = max(TremorSeverity);
        
        if MaxTremorSeverity < 1
            SubInfo.Selection(n) = 2;
        elseif MaxTremorSeverity >= 2
            SubInfo.Selection(n) = 3;
        else
            SubInfo.Selection(n) = 4;
        end
        
        idx_age = find(contains(c.Properties.VariableNames,"Age"));
        Age(n) = table2array(c(:, [idx_age]));
        idx_EstDisDurYears = find(contains(c.Properties.VariableNames,"EstDisDurYears"));
        EstDisDurYears(n) = table2array(c(:, [idx_EstDisDurYears]));
        idx_Up3OfTotal = find(contains(c.Properties.VariableNames,"Up3OfTotal"));
        Up3OfTotal(n) = table2array(c(:, [idx_Up3OfTotal(1)]));
        
    end
end
fprintf('Outcome of tremor subtyping based on clinical assessment \n')
tabulate(SubInfo.Selection)

% MeanAge.NonTremor = mean(Age(SubInfo.Selection == 2));
% MeanAge.Tremor = mean(Age(SubInfo.Selection == 3));
% [h,p,ci,stats] = ttest2(Age(SubInfo.Selection == 2), Age(SubInfo.Selection == 3));
% fprintf('Does age differ between tremor subgroups? H%i accepted, p = %f \n', h,p)
% 
% MeanDisDur.NonTremor = mean(EstDisDurYears(SubInfo.Selection == 2));
% MeanDisDur.Tremor = mean(EstDisDurYears(SubInfo.Selection == 3));
% [h,p,ci,stats] = ttest2(EstDisDurYears(SubInfo.Selection == 2), EstDisDurYears(SubInfo.Selection == 3));
% fprintf('Does disease duration differ between tremor subgroups? H%i accepted, p = %f \n', h,p)
% 
% MeanUp3OfTotal.NonTremor = mean(Up3OfTotal(SubInfo.Selection == 2), 'omitnan');
% MeanUp3OfTotal.Tremor = mean(Up3OfTotal(SubInfo.Selection == 3), 'omitnan');
% [h,p,ci,stats] = ttest2(Up3OfTotal(SubInfo.Selection == 2), Up3OfTotal(SubInfo.Selection == 3));
% fprintf('Does total UPDRS III score differ between tremor subgroups? H%i accepted, p = %f \n', h,p)

end
