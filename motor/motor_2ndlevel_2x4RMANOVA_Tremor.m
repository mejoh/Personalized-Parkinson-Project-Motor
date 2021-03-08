% Contrast one group against another
% Comparison takes one of the following three strings:
% 1. 'TremorHc'
% 2. 'NonTremorHc'
% 3. 'TremorNonTremor'
% TremorClassification takes one of the two following string:
% 1. 'TremorRegressors'
% 2. 'ClinVars'

function motor_2ndlevel_2x4RMANOVA_Tremor(Comparison, TremorClassification, exclude_outliers)

if nargin<1
    Comparison = 'TremorNonTremor';
    TremorClassification = 'ClinVars';
    exclude_outliers = false;
end

%% Group to comapre against controls

%% Paths

addpath('/home/common/matlab/spm12');
spm('defaults', 'FMRI');

%% Directories

ses = 'ses-Visit1';
ANALYSESDir = '/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_NoTrem';
Sub = cellstr(spm_select('List', fullfile(ANALYSESDir, 'Group', 'con_0001', ses), '.*sub-POM.*'));
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

SubInfo.Sub = extractBetween(Sub, 8, 31);
SubInfo.Group = extractBetween(Sub, 1, 6);

if strcmp(TremorClassification, 'TremorRegressors')
    SubInfo = TremorClassificationByRegressors(SubInfo);
elseif strcmp(TremorClassification, 'ClinVars')
    SubInfo = TremorClassificationByClinVars(SubInfo);
else
    msg = 'TremorClassification was not defined properly';
    error(msg)
end
    

Sel = false(size(SubInfo.Sub));
for n = 1:numel(Sub)
    if strcmp(Comparison, 'TremorHc')
        if SubInfo.Selection(n) == 1 || SubInfo.Selection(n) == 3
            Sel(n) = true;
        end
    elseif strcmp(Comparison, 'NonTremorHc')
        if SubInfo.Selection(n) == 1 || SubInfo.Selection(n) == 2
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
if istrue(exclude_outliers)
    outliers = ["sub-POMU06C08BB18FE38A3B" "sub-POMU10D1CBD2A4EB7831" "sub-POMU1EC01A53575D7104" "sub-POMU242851EF4B22A600" "sub-POMU7AABE759AC531D35" "sub-POMU80C7D6A96AA13388" "sub-POMUA6BD4DCB8040A67B" "sub-POMUB0A6FB4D3AF0D3B5" "sub-POMUB24789880E112F8F" "sub-POMUD2870200E030B451" "sub-POMUE49FF489B8076A3E" "sub-POMU06664E2F91AA04E0" "sub-POMU10D1CBD2A4EB7831" "sub-POMUA6BD4DCB8040A67B" "sub-POMUB0B32692E1393605" "sub-POMUC80F15E9B41B3EE4" "sub-POMU10D1CBD2A4EB7831" "sub-POMU7AABE759AC531D35" "sub-POMU907470A979431AAF" "sub-POMUA6BD4DCB8040A67B" "sub-POMUB0B32692E1393605" "sub-POMUC80F15E9B41B3EE4" "sub-POMU020A9277DF9F5A83" "sub-POMU02C38D3DE0820685" "sub-POMU0E19B895DF700AB0" "sub-POMU12FA62414399DD8F" "sub-POMU1C7AEA3B0ADEB876" "sub-POMU1E7EF007D32758D4" "sub-POMU1E7EF007D32758D4" "sub-POMU1EDD7C2E9E8DF70C" "sub-POMU3227DABC7764ADB0" "sub-POMU4A7412A72D2973F1" "sub-POMU54503B880C9EB267" "sub-POMU566ED54BF23566B6" "sub-POMU58B6CDD53AD4049C" "sub-POMU7E16E08D6D3BD46C" "sub-POMU82E58ECC13773EA2" "sub-POMU86B947749A70E997" "sub-POMUA6F5671F320EA927" "sub-POMUAC2513F0E5E32349" "sub-POMUBA95A9F6A41E872C" "sub-POMUDEC90EA2FF4B337C" "sub-POMUE0EFDE0DD571E3A5" "sub-POMUEE16EA86913A5BEC"];
    Sel = true(size(SubInfo.Sub));
    for n = 1:numel(SubInfo.Sub)
        if contains(SubInfo.Sub{n}, unique(outliers))
           Sel(n) = false;
        fprintf('Excluding outlier: %s %s \n', SubInfo.Sub{n}, SubInfo.Group{n})
        end
    end
    SubInfo.Sub = SubInfo.Sub(Sel);
    SubInfo.Group = SubInfo.Group(Sel);
end

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
        SubInfo.con_0001{n} = spm_select('FPList', fullfile(ANALYSESDir, 'Group', ConList{1}, 'ses-Visit1'), ['PD_POM.*' SubInfo.Sub{n} '.*' ConList{1} '.*.nii']);
        SubInfo.con_0002{n} = spm_select('FPList', fullfile(ANALYSESDir, 'Group', ConList{2}, 'ses-Visit1'), ['PD_POM.*' SubInfo.Sub{n} '.*' ConList{2} '.*.nii']);
        SubInfo.con_0003{n} = spm_select('FPList', fullfile(ANALYSESDir, 'Group', ConList{3}, 'ses-Visit1'), ['PD_POM.*' SubInfo.Sub{n} '.*' ConList{3} '.*.nii']);
        SubInfo.con_0004{n} = spm_select('FPList', fullfile(ANALYSESDir, 'Group', ConList{4}, 'ses-Visit1'), ['PD_POM.*' SubInfo.Sub{n} '.*' ConList{4} '.*.nii']);
    elseif strcmp(SubInfo.Group{n}, 'HC_PIT')
        SubInfo.con_0001{n} = spm_select('FPList', fullfile(ANALYSESDir, 'Group', ConList{1}, 'ses-Visit1'), ['HC_PIT.*' SubInfo.Sub{n} '.*' ConList{1} '.*.nii']);
        SubInfo.con_0002{n} = spm_select('FPList', fullfile(ANALYSESDir, 'Group', ConList{2}, 'ses-Visit1'), ['HC_PIT.*' SubInfo.Sub{n} '.*' ConList{2} '.*.nii']);
        SubInfo.con_0003{n} = spm_select('FPList', fullfile(ANALYSESDir, 'Group', ConList{3}, 'ses-Visit1'), ['HC_PIT.*' SubInfo.Sub{n} '.*' ConList{3} '.*.nii']);
        SubInfo.con_0004{n} = spm_select('FPList', fullfile(ANALYSESDir, 'Group', ConList{4}, 'ses-Visit1'), ['HC_PIT.*' SubInfo.Sub{n} '.*' ConList{4} '.*.nii']);
    end
end

Inputs = cell(10,1);
if strcmp(Comparison, 'TremorHc')
    Inputs{1,1} = {fullfile(ANALYSESDir, 'Group', 'HcTremor x ExtInt2Int3Catch')};
    G1 = 1;
    G2 = 3;
elseif strcmp(Comparison, 'NonTremorHc')
    Inputs{1,1} = {fullfile(ANALYSESDir, 'Group', 'HcNonTremor x ExtInt2Int3Catch')};
    G1 = 1;
    G2 = 2;
elseif strcmp(Comparison, 'TremorNonTremor')
    Inputs{1,1} = {fullfile(ANALYSESDir, 'Group', 'TremorNonTremor x ExtInt2Int3Catch')};
    G1 = 2;
    G2 = 3;
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
Inputs{10,1} = [G1_FD; G1_FD; G1_FD; G1_FD; G2_FD; G2_FD; G2_FD; G2_FD];

%% Run

JobFile = {spm_file(mfilename('fullpath'), 'suffix','_job', 'ext','.m')};

delete(fullfile(char(Inputs{1}), '*.*'))
spm_jobman('run', JobFile, Inputs{:});

filename = char(fullfile(Inputs{1,1}, 'Inputs.mat'));
save(filename, 'Inputs')

end

function [SubInfo] = TremorClassificationByRegressors(SubInfo)

TremorClass = load('/project/3024006.02/Analyses/EMG/motor/manually_checked/Martin/Tremor_check-09-Nov-2020.mat');
PeakClass = load('/project/3024006.02/Analyses/EMG/motor/manually_checked/Martin/Peak_check-09-Nov-2020.mat');
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
SubInfo.Sub = SubInfo.Sub(Sel);
SubInfo.Group = SubInfo.Group(Sel);
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
        
        idx_tremitems = find(contains(c.Properties.VariableNames,["Up3OfRAmpArmNonDev","Up3OfRAmpArmYesDev","Up3OfRAmpLegNonDev","Up3OfRAmpLegYesDev","Up3OfRAmpJaw"]));
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

MeanAge.NonTremor = mean(Age(SubInfo.Selection == 2));
MeanAge.Tremor = mean(Age(SubInfo.Selection == 3));
[h,p,ci,stats] = ttest2(Age(SubInfo.Selection == 2), Age(SubInfo.Selection == 3));
fprintf('Does age differ between tremor subgroups? H%i accepted, p = %f \n', h,p)

MeanDisDur.NonTremor = mean(EstDisDurYears(SubInfo.Selection == 2));
MeanDisDur.Tremor = mean(EstDisDurYears(SubInfo.Selection == 3));
[h,p,ci,stats] = ttest2(EstDisDurYears(SubInfo.Selection == 2), EstDisDurYears(SubInfo.Selection == 3));
fprintf('Does disease duration differ between tremor subgroups? H%i accepted, p = %f \n', h,p)

MeanUp3OfTotal.NonTremor = mean(Up3OfTotal(SubInfo.Selection == 2), 'omitnan');
MeanUp3OfTotal.Tremor = mean(Up3OfTotal(SubInfo.Selection == 3), 'omitnan');
[h,p,ci,stats] = ttest2(Up3OfTotal(SubInfo.Selection == 2), Up3OfTotal(SubInfo.Selection == 3));
fprintf('Does total UPDRS III score differ between tremor subgroups? H%i accepted, p = %f \n', h,p)

end
