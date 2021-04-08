function motor_swe(input)

addpath('/home/common/matlab/spm12');
addpath('/home/common/matlab/spm12_r7487_20181114/toolbox/SwE-toolbox')
spm('defaults', 'FMRI');

% Load input
% input = '/project/3024006.02/Analyses/DurAvg_ReAROMA_NoPMOD_TimeDer_BPCtrl/Group/HcOn x ExtInt2Int3Catch_Bp/Inputs.mat';
% input = '/project/3022026.01/analyses/motor/DurAvg_ReAROMA_PMOD_TimeDer/Group/HcOn x ExtInt2Int3Catch/Inputs.mat';
% input = '/project/3022026.01/analyses/motor/DurAvg_ReAROMA_PMOD_TimeDer/Group/OffOn x ExtInt2Int3Catch/Inputs.mat'; Doesn't work!
dat = load(input);
dat = dat.Inputs;

% Separate by condition
Ext = [dat{2,1};dat{3,1}];
Int2 = [dat{4,1};dat{5,1}];
Int3 = [dat{6,1};dat{7,1}];

% Define full paths to scans
% Order is as follows: Cond1/Group1 > Cond1/Group2 > Cond2/Group1 > Cond2/Group2...
SubInfo.Scans = [Ext;Int2;Int3];

% Define groups (i.e. between-subject factor) according to order of scans
SubInfo.Groups = repmat([repmat(1, length(dat{2,1}),1); repmat(2, length(dat{3,1}),1)],3,1);

% Define visits (i.e. within-subjects factor) according to order of scans
SubInfo.Visits = [ones(length(Ext),1); repmat(2,length(Ext),1); repmat(3,length(Ext),1)];

% Define subject ids
SubInfo.Subjects = extractBetween(SubInfo.Scans,97,120);
SubInfo.ExplicitGroup = extractBetween(SubInfo.Scans,90,95);
[~, ~, SubInfo.SubjectsId] = unique(SubInfo.Subjects);   % indices to unique subs

% Define covars
NScans = length(SubInfo.Scans);
SubInfo.Ext_1 = zeros(NScans,1);
SubInfo.Ext_2 = zeros(NScans,1);
SubInfo.Int2_1 = zeros(NScans,1);
SubInfo.Int2_2 = zeros(NScans,1);
SubInfo.Int3_1 = zeros(NScans,1);
SubInfo.Int3_2 = zeros(NScans,1);
for n = 1:numel(SubInfo.Scans)
    if SubInfo.Groups(n) == 1 && SubInfo.Visits(n) == 1
        SubInfo.Ext_1(n) = 1;
    elseif SubInfo.Groups(n) == 2 && SubInfo.Visits(n) == 1
        SubInfo.Ext_2(n) = 1;
    elseif SubInfo.Groups(n) == 1 && SubInfo.Visits(n) == 2
        SubInfo.Int2_1(n) = 1;
    elseif SubInfo.Groups(n) == 2 && SubInfo.Visits(n) == 2
        SubInfo.Int2_2(n) = 1;
    elseif SubInfo.Groups(n) == 1 && SubInfo.Visits(n) == 3
        SubInfo.Int3_1(n) = 1;
    elseif SubInfo.Groups(n) == 2 && SubInfo.Visits(n) == 3
        SubInfo.Int3_2(n) = 1;
    end
end
SubInfo.FD = dat{10,1}; SubInfo.FD = num2cell(SubInfo.FD(1:length(Ext)*3,1));

%% Assemble inputs

% List of open inputs
% Data & Design: Directory - cfg_files
% Data & Design: Scans - cfg_files
% Data & Design: Groups - cfg_entry
% Data & Design: Visits - cfg_entry
% Data & Design: Subjects - cfg_entry
% Data & Design: Covariates - cfg_repeat

inputs = cell(8,1);

% Output directory
inputs{1,1} = {append(fileparts(input), '_swe')};
if ~exist(char(inputs{1,1}), 'dir')
    mkdir(char(inputs{1,1}));
else
    delete(fullfile(char(inputs{1,1}), '*.*'));
end
% Scans, groups, visits, subjects
inputs{2,1} = SubInfo.Scans;
inputs{3,1} = SubInfo.Groups;
inputs{4,1} = SubInfo.Visits;
inputs{5,1} = SubInfo.SubjectsId;
% Covars
inputs{6,1} = SubInfo.Ext_1;
inputs{7,1} = SubInfo.Ext_2;
inputs{8,1} = SubInfo.Int2_1;
inputs{9,1} = SubInfo.Int2_2;
inputs{10,1} = SubInfo.Int3_1;
inputs{11,1} = SubInfo.Int3_2;
inputs{12,1} = cell2mat(SubInfo.FD);

%% Run job
JobFile = {spm_file(mfilename('fullpath'), 'suffix','_job', 'ext','.m')};
spm_jobman('run', JobFile, inputs{:});

end