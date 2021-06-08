function motor_2ndlevel_OffOn(exclude_outliers)

if nargin < 1
    exclude_outliers = false;
end

%% Paths

addpath('/home/common/matlab/spm12');
spm('defaults', 'FMRI');

ses = 'ses-Visit1';
ConList = {'con_0001' 'con_0002' 'con_0003' 'con_0004'};% 'con_0005'};
ANALYSESDir = '/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem';
ClinicalConfs = readtable('/project/3022026.01/pep/ClinVars/derivatives/database_clinical_confounds_fmri.csv');
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

% Find patients that are included in both PIT and POM
[~, ind] = unique(SubInfo.Sub);   % indices to unique subs
duplicate_ind = setdiff(1:size(SubInfo.Sub, 1), ind);   % duplicate indices
duplicate_subs = SubInfo.Sub(duplicate_ind);   % duplicate values

Sel = true(size(SubInfo.Sub));
for n = 1:numel(SubInfo.Sub)
    if contains(SubInfo.Sub{n}, duplicate_subs)
        Sel(n) = true;
    else
        Sel(n) = false;
    end
end
SubInfo.Sub = SubInfo.Sub(Sel);
SubInfo.Group = SubInfo.Group(Sel);

Sel = false(size(SubInfo.Sub));
for n = 1:height(ClinicalConfs)
    if sum(contains(SubInfo.Sub, ClinicalConfs.pseudonym(n))) == 2
        Sel(n) = true;
    end
end
ClinicalConfs = ClinicalConfs(Sel,:);

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
    % Redo duplicates
    [~, ind] = unique(SubInfo.Sub);   % indices to unique subs
    duplicate_ind = setdiff(1:size(SubInfo.Sub, 1), ind);   % duplicate indices
    duplicate_subs = SubInfo.Sub(duplicate_ind);   % duplicate values
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

%% Age and Gender and Baseline symptom severity

SubInfo.Age = zeros(size(SubInfo.Sub));
SubInfo.Gender = cell(size(SubInfo.Sub));
SubInfo.UPDRSTotalBA = zeros(size(SubInfo.Sub));
for n = 1:numel(SubInfo.Sub)
    
    subid = find(contains(ClinicalConfs.pseudonym, SubInfo.Sub{n}));
    
    if contains(SubInfo.Group{n}, 'PIT')
        subid = subid(1);
    else
        subid = subid(2);
    end
    
    if isempty(subid) || isnan(ClinicalConfs.Up3OfTotal(subid))
        SubInfo.UPDRSTotalBA(n) = mean(ClinicalConfs.Up3OfTotal, 'omitnan');
    else
        SubInfo.UPDRSTotalBA(n) = ClinicalConfs.Up3OfTotal(subid);
    end
    
    if isempty(subid) || isnan(ClinicalConfs.Age(subid)) || strcmp(ClinicalConfs.Gender(subid), 'NA')
        fprintf('Missing values, interpolating...\n')
        SubInfo.Age(n) = mean(ClinicalConfs.Age, 'omitnan');
        SubInfo.Gender{n} = cellstr('Male');
    else
        SubInfo.Age(n) = ClinicalConfs.Age(subid);
        SubInfo.Gender{n} = ClinicalConfs.Gender(subid);
    end
    
end

SubInfo.Gender_num = zeros(size(SubInfo.Gender));
for n = 1:numel(SubInfo.Gender)
    if strcmp(SubInfo.Gender{n}, 'Male')
        SubInfo.Gender_num(n) = 0;
    else
        SubInfo.Gender_num(n) = 1;
    end
end

%% Assemble inputs

Inputs = cell(10, 1);
if ~istrue(exclude_outliers)
    Inputs{1,1} = {fullfile(ANALYSESDir, 'Group', 'OffOn x ExtInt2Int3Catch')};
else
    Inputs{1,1} = {fullfile(ANALYSESDir, 'Group', 'OffOn x ExtInt2Int3Catch_NoOutliers')};
end

ExtPd = dir(fullfile(ANALYSESDir, 'Group', ConList{1}, ses, 'PD_PIT*'));
ExtPd_files = {ExtPd.name}';
ExtPd_files = ExtPd_files(contains({ExtPd.name}, duplicate_subs));
Inputs{2,1} = fullfile(ANALYSESDir, 'Group', ConList{1}, ses, ExtPd_files);
Int2Pd = dir(fullfile(ANALYSESDir, 'Group', ConList{2}, ses, 'PD_PIT*'));
Int2Pd_files = {Int2Pd.name}';
Int2Pd_files = Int2Pd_files(contains({Int2Pd.name}, duplicate_subs));
Inputs{3,1} = fullfile(ANALYSESDir, 'Group', ConList{2}, ses, Int2Pd_files);
Int3Pd = dir(fullfile(ANALYSESDir, 'Group', ConList{3}, ses, 'PD_PIT*'));
Int3Pd_files = {Int3Pd.name}';
Int3Pd_files = Int3Pd_files(contains({Int3Pd.name}, duplicate_subs));
Inputs{4,1} = fullfile(ANALYSESDir, 'Group', ConList{3}, ses, Int3Pd_files);
CatchPd = dir(fullfile(ANALYSESDir, 'Group', ConList{4}, ses, 'PD_PIT*'));
CatchPd_files = {CatchPd.name}';
CatchPd_files = CatchPd_files(contains({CatchPd.name}, duplicate_subs));
Inputs{5,1} = fullfile(ANALYSESDir, 'Group', ConList{4}, ses, CatchPd_files);

ExtPd = dir(fullfile(ANALYSESDir, 'Group', ConList{1}, ses, 'PD_POM*'));
ExtPd_files = {ExtPd.name}';
ExtPd_files = ExtPd_files(contains({ExtPd.name}, duplicate_subs));
Inputs{6,1} = fullfile(ANALYSESDir, 'Group', ConList{1}, ses, ExtPd_files);
Int2Pd = dir(fullfile(ANALYSESDir, 'Group', ConList{2}, ses, 'PD_POM*'));
Int2Pd_files = {Int2Pd.name}';
Int2Pd_files = Int2Pd_files(contains({Int2Pd.name}, duplicate_subs));
Inputs{7,1} = fullfile(ANALYSESDir, 'Group', ConList{2}, ses, Int2Pd_files);
Int3Pd = dir(fullfile(ANALYSESDir, 'Group', ConList{3}, ses, 'PD_POM*'));
Int3Pd_files = {Int3Pd.name}';
Int3Pd_files = Int3Pd_files(contains({Int3Pd.name}, duplicate_subs));
Inputs{8,1} = fullfile(ANALYSESDir, 'Group', ConList{3}, ses, Int3Pd_files);
CatchPd = dir(fullfile(ANALYSESDir, 'Group', ConList{4}, ses, 'PD_POM*'));
CatchPd_files = {CatchPd.name}';
CatchPd_files = CatchPd_files(contains({CatchPd.name}, duplicate_subs));
Inputs{9,1} = fullfile(ANALYSESDir, 'Group', ConList{4}, ses, CatchPd_files);

FD_PD_PIT = SubInfo.FD(strcmp(SubInfo.Group, 'PD_PIT'))';
FD_PD_POM = SubInfo.FD(strcmp(SubInfo.Group, 'PD_POM'))';
Age_PD_PIT = SubInfo.Age(strcmp(SubInfo.Group, 'PD_PIT'))';
Age_PD_POM = SubInfo.Age(strcmp(SubInfo.Group, 'PD_POM'))';
Gender_PD_PIT = SubInfo.Gender_num(strcmp(SubInfo.Group, 'PD_PIT'))';
Gender_PD_POM = SubInfo.Gender_num(strcmp(SubInfo.Group, 'PD_POM'))';
MotorSymSev_PIT = SubInfo.UPDRSTotalBA(strcmp(SubInfo.Group, 'PD_PIT'))';
MotorSymSev_POM = SubInfo.UPDRSTotalBA(strcmp(SubInfo.Group, 'PD_POM'))';

Inputs{10,1} = [FD_PD_PIT FD_PD_POM FD_PD_PIT FD_PD_POM FD_PD_PIT FD_PD_POM FD_PD_PIT FD_PD_POM]';
Inputs{11,1} = [Age_PD_PIT Age_PD_POM Age_PD_PIT Age_PD_POM Age_PD_PIT Age_PD_POM Age_PD_PIT Age_PD_POM]';
Inputs{12,1} = [Gender_PD_PIT Gender_PD_POM Gender_PD_PIT Gender_PD_POM Gender_PD_PIT Gender_PD_POM Gender_PD_PIT Gender_PD_POM]';
Inputs{13,1} = [MotorSymSev_PIT MotorSymSev_POM MotorSymSev_PIT MotorSymSev_POM MotorSymSev_PIT MotorSymSev_POM MotorSymSev_PIT MotorSymSev_POM]';

%% Run
tabulate(SubInfo.Group)
if length(SubInfo.Group(strcmp(SubInfo.Group,'PD_PIT'))) ~= length(SubInfo.Group(strcmp(SubInfo.Group, 'PD_POM')))
    msg = 'Length of groups are not equal, exiting...';
    error(msg)
end

JobFile = {spm_file(mfilename('fullpath'), 'suffix','_job', 'ext','.m')};

delete(fullfile(char(Inputs{1}), '*.*'))
spm_jobman('run', JobFile, Inputs{:});

filename = char(fullfile(Inputs{1,1}, 'Inputs.mat'));
save(filename, 'Inputs')

end