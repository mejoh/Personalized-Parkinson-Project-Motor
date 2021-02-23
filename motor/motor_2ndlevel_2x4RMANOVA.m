% Contrast one group against another

function motor_2ndlevel_2x4RMANOVA(Offstate, exclude_outliers)

%% Group to comapre against controls

if nargin<1 || isempty(Offstate)
    Offstate = false;
end

%% Paths

addpath('/home/common/matlab/spm12');
spm('defaults', 'FMRI');

%% Directories

ses = 'ses-Visit1';
ANALYSESDir = '/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer';
% ANALYSESDir = '/project/3024006.02/Analyses/DurAvg_ReAROMA_NoPMOD_TimeDer_BPCtrl';
Sub = cellstr(spm_select('List', fullfile(ANALYSESDir, 'Group', 'con_0001', ses), '.*sub-POM.*'));
Sub = extractBetween(Sub, 1, 31);
fprintf('Number of subjects processed: %i\n', numel(Sub))

%% Selection

Sel = false(size(Sub));
for n = 1:numel(Sub)
    if istrue(Offstate) && (contains(Sub{n}, 'HC_PIT') || contains(Sub{n}, 'PD_PIT'))
        Sel(n) = true;
    elseif ~istrue(Offstate) && (contains(Sub{n}, 'HC_PIT') || contains(Sub{n}, 'PD_POM'))
        Sel(n) = true;
    else
        fprintf('Excluding %s due to group\n', Sub{n})
    end
end
Sub = Sub(Sel);

SubInfo.Sub = extractBetween(Sub, 8, 31);
SubInfo.Group = extractBetween(Sub, 1, 6);

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
Inputs = cell(10,1);
if Offstate
    Inputs{1,1} = {fullfile(ANALYSESDir, 'Group', 'HcOff x ExtInt2Int3Catch')};
else
    Inputs{1,1} = {fullfile(ANALYSESDir, 'Group', 'HcOn x ExtInt2Int3Catch')};
end

if ~istrue(exclude_outliers) && istrue(Offstate)
    Inputs{1,1} = {fullfile(ANALYSESDir, 'Group', 'HcOff x ExtInt2Int3Catch')};
elseif ~istrue(exclude_outliers) && ~istrue(Offstate)
    Inputs{1,1} = {fullfile(ANALYSESDir, 'Group', 'HcOn x ExtInt2Int3Catch')};
elseif istrue(exclude_outliers) && istrue(Offstate)
    Inputs{1,1} = {fullfile(ANALYSESDir, 'Group', 'HcOff x ExtInt2Int3Catch_NoOutliers')};
elseif istrue(exclude_outliers) && ~istrue(Offstate)
    Inputs{1,1} = {fullfile(ANALYSESDir, 'Group', 'HcOn x ExtInt2Int3Catch_NoOutliers')};
end

ExtHc = dir(fullfile(ANALYSESDir, 'Group', ConList{1}, ses, 'HC*'));
ExtHc_files = {ExtHc.name}';
ExtHc_files = ExtHc_files(contains({ExtHc.name}, SubInfo.Sub));
Inputs{2,1} = fullfile(ANALYSESDir, 'Group', ConList{1}, ses, ExtHc_files);
Int2Hc = dir(fullfile(ANALYSESDir, 'Group', ConList{2}, ses, 'HC*'));
Int2Hc_files = {Int2Hc.name}';
Int2Hc_files = Int2Hc_files(contains({Int2Hc.name}, SubInfo.Sub));
Inputs{4,1} = fullfile(ANALYSESDir, 'Group', ConList{2}, ses, Int2Hc_files);
Int3Hc = dir(fullfile(ANALYSESDir, 'Group', ConList{3}, ses, 'HC*'));
Int3Hc_files = {Int3Hc.name}';
Int3Hc_files = Int3Hc_files(contains({Int3Hc.name}, SubInfo.Sub));
Inputs{6,1} = fullfile(ANALYSESDir, 'Group', ConList{3}, ses, Int3Hc_files);
CatchHc = dir(fullfile(ANALYSESDir, 'Group', ConList{4}, ses, 'HC*'));
CatchHc_files = {CatchHc.name}';
CatchHc_files = CatchHc_files(contains({CatchHc.name}, SubInfo.Sub));
Inputs{8,1} = fullfile(ANALYSESDir, 'Group', ConList{4}, ses, CatchHc_files);

if Offstate
    Pd = 'PD_PIT*';
else
    Pd = 'PD_POM*';
end
ExtPd = dir(fullfile(ANALYSESDir, 'Group', ConList{1}, ses, Pd));
ExtPd_files = {ExtPd.name}';
ExtPd_files = ExtPd_files(contains({ExtPd.name}, SubInfo.Sub));
Inputs{3,1} = fullfile(ANALYSESDir, 'Group', ConList{1}, ses, ExtPd_files);
Int2Pd = dir(fullfile(ANALYSESDir, 'Group', ConList{2}, ses, Pd));
Int2Pd_files = {Int2Pd.name}';
Int2Pd_files = Int2Pd_files(contains({Int2Pd.name}, SubInfo.Sub));
Inputs{5,1} = fullfile(ANALYSESDir, 'Group', ConList{2}, ses, Int2Pd_files);
Int3Pd = dir(fullfile(ANALYSESDir, 'Group', ConList{3}, ses, Pd));
Int3Pd_files = {Int3Pd.name}';
Int3Pd_files = Int3Pd_files(contains({Int3Pd.name}, SubInfo.Sub));
Inputs{7,1} = fullfile(ANALYSESDir, 'Group', ConList{3}, ses, Int3Pd_files);
CatchPd = dir(fullfile(ANALYSESDir, 'Group', ConList{4}, ses, Pd));
CatchPd_files = {CatchPd.name}';
CatchPd_files = CatchPd_files(contains({CatchPd.name}, SubInfo.Sub));
Inputs{9,1} = fullfile(ANALYSESDir, 'Group', ConList{4}, ses, CatchPd_files);

FD_hc = SubInfo.FD(strcmp(SubInfo.Group, 'HC_PIT'));
if Offstate
    FD_pd = SubInfo.FD(strcmp(SubInfo.Group, 'PD_PIT'));
else
    FD_pd = SubInfo.FD(strcmp(SubInfo.Group, 'PD_POM'));
end
Inputs{10,1} = [FD_hc; FD_hc; FD_hc; FD_hc; FD_pd; FD_pd; FD_pd; FD_pd];

%% Run

JobFile = {spm_file(mfilename('fullpath'), 'suffix','_job', 'ext','.m')};

delete(fullfile(char(Inputs{1}), '*.*'))
spm_jobman('run', JobFile, Inputs{:});

filename = char(fullfile(Inputs{1,1}, 'Inputs.mat'));
save(filename, 'Inputs')

end
