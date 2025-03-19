%QSUB
% motor_longitudinal_2ndlevel_TwoSampleTtests('con_0010',true);motor_longitudinal_2ndlevel_TwoSampleTtests('con_0010',false);
% motor_longitudinal_2ndlevel_TwoSampleTtests('con_0011',true);motor_longitudinal_2ndlevel_TwoSampleTtests('con_0011',false);
% motor_longitudinal_2ndlevel_TwoSampleTtests('con_0012',true);motor_longitudinal_2ndlevel_TwoSampleTtests('con_0012',false);
% motor_longitudinal_2ndlevel_TwoSampleTtests('con_0007',true);motor_longitudinal_2ndlevel_TwoSampleTtests('con_0007',false)

function motor_longitudinal_2ndlevel_TwoSampleTtests(Contrast, roi)

if nargin < 1
    Contrast = 'con_0010';
    roi = false;
end

%% Paths

addpath('/home/common/matlab/fieldtrip/qsub');
addpath('/home/common/matlab/spm12');
spm('defaults', 'FMRI');
global defaults
defaults.mask.thresh = -Inf;
defaults.stats.topoFDR = 0; %Cluster-level rather than default 'peak'
defaults.stats.maxmem = 2^33; %2^33=8.5899e+09=8.59bg

dCon = fullfile('/project/3024006.02/Analyses/motor_task/Group/', Contrast, 'ses-Diff');
dOutput = fullfile('/project/3024006.02/Analyses/motor_task/Group/Longitudinal/SPM/',Contrast);
ClinicalConfs = readtable('/project/3024006.02/Data/matlab/fmri-confs-taskclin_ses-all_groups-all_2023-10-17.csv');
% baseid = strcmp(ClinicalConfs.TimepointNr,'T0');
% ClinicalConfs = ClinicalConfs(baseid,:);
% baseid = or(contains(ClinicalConfs.ParticipantType,'HC_PIT'),contains(ClinicalConfs.ParticipantType,'PD_POM'));
% ClinicalConfs = ClinicalConfs(baseid,:);

Sub = cellstr(spm_select('List', dCon, '.*sub-POM.*'));
Sub = extractBetween(Sub, 1, 31);
fprintf('Number of subjects processed: %i\n', numel(Sub))

SubInfo.Sub = extractBetween(Sub, 8, 31);
SubInfo.Group = extractBetween(Sub, 1, 6);

% %% Collect events.json and confound files
% 
% SubInfo.ConfFiles = cell(size(SubInfo.Sub));
% for n = 1:numel(SubInfo.Sub)
%     if contains(SubInfo.Group{n}, '_PIT')
%         Session = 'ses-PITVisit1';
%     else
%         Session = 'ses-POMVisit1';
%     end
% %     SubInfo.ConfFiles{n} = spm_select('FPList', fullfile(ANALYSESDir, SubInfo.Sub{n}, Session), '^.*task-motor_acq-MB6_run-.*_desc-confounds_timeseries3.mat$');
% %     if isempty(SubInfo.ConfFiles{n})
% %         SubInfo.ConfFiles{n} = spm_select('FPList', fullfile(ANALYSESDir, SubInfo.Sub{n}, Session), '^.*task-motor_acq-MB6_run-.*_desc-confounds_timeseries2.mat$');
% %     end
%     confs = spm_select('FPList', fullfile(ANALYSESDir, SubInfo.Sub{n}, Session), '^.*task-motor_acq-MB6_run-.*_desc-confounds_timeseries.*.mat$');
%     dims = size(confs);
%     SubInfo.ConfFiles{n} = confs(dims(1),:);
% end
% 
% %% Framewise displacement
% 
% SubInfo.FD = zeros(size(SubInfo.Sub));
% for n = 1:numel(SubInfo.Sub)
%     Confounds = spm_load(SubInfo.ConfFiles{n});
%     FrameDisp = Confounds.R(:,strcmp(Confounds.names, 'framewise_displacement'));
%     FrameDisp(isnan(FrameDisp)) = 0;
%     SubInfo.FD(n) = mean(FrameDisp);
% end

%% Age and Gender

% Exclude subjects with missing Age and Gender
Sel = true(size(SubInfo.Sub));
SubInfo.Age = zeros(size(SubInfo.Sub));
SubInfo.Gender = zeros(size(SubInfo.Sub));
SubInfo.RespHandIsDominant = zeros(size(SubInfo.Sub));
SubInfo.NpsEducYears = zeros(size(SubInfo.Sub));
for n = 1:numel(SubInfo.Sub)
    
    subid = find(contains(ClinicalConfs.pseudonym, SubInfo.Sub{n}));
    if length(subid)>1
        subid=subid(1);
    end
    
    if isempty(subid) || isnan(ClinicalConfs.Age(subid)) || isnan(ClinicalConfs.Gender(subid)) || isnan(ClinicalConfs.RespHandIsDominant_T0(subid)) || isnan(ClinicalConfs.NpsEducYears(subid)) 
        fprintf('Missing values, excluding %s...\n', SubInfo.Sub{n})
        Sel(n) = false;
    else
        SubInfo.Age(n) = ClinicalConfs.Age(subid);
        SubInfo.Gender(n) = ClinicalConfs.Gender(subid);
        SubInfo.RespHandIsDominant(n) = ClinicalConfs.RespHandIsDominant_T0(subid);
        SubInfo.NpsEducYears(n) = ClinicalConfs.NpsEducYears(subid);
    end
    
end
fprintf('%i subjects have missing Age/Gender/Hand, excluding...\n', length(Sel) - sum(Sel))
SubInfo = subset_subinfo(SubInfo, Sel);

%% Demean covars
SubInfo.Age = SubInfo.Age - mean(SubInfo.Age);
SubInfo.Gender = SubInfo.Gender - mean(SubInfo.Gender);
SubInfo.RespHandIsDominant = SubInfo.RespHandIsDominant - mean(SubInfo.RespHandIsDominant);
SubInfo.NpsEducYears = SubInfo.NpsEducYears - mean(SubInfo.NpsEducYears);
% SubInfo.FD = SubInfo.FD - mean(SubInfo.FD);

%% Assemble inputs
Inputs = cell(7,1);

if (roi)
    Inputs{1,1} = {fullfile(dOutput,'TwoSampleTTest-roi')};
else
    Inputs{1,1} = {fullfile(dOutput,'TwoSampleTTest-whole')};
end
if ~exist(char(Inputs{1,1}),'dir')
    mkdir(char(Inputs{1,1}))
end

HC = dir(fullfile(dCon, 'HC_PIT*'));
HC_files = {HC.name}';
HC_files = HC_files(contains({HC.name}, SubInfo.Sub));
Inputs{2,1} = fullfile(dCon, HC_files);

PD = dir(fullfile(dCon, 'PD_POM*'));
PD_files = {PD.name}';
PD_files = PD_files(contains({PD.name}, SubInfo.Sub));
Inputs{3,1} = fullfile(dCon, PD_files);

% FD_hc = SubInfo.FD(strcmp(SubInfo.Group, 'HC_PIT'));
% FD_pd = SubInfo.FD(strcmp(SubInfo.Group, 'PD_POM'));
Age_hc = SubInfo.Age(strcmp(SubInfo.Group, 'HC_PIT'));
Age_pd = SubInfo.Age(strcmp(SubInfo.Group, 'PD_POM'));
Gender_hc = SubInfo.Gender(strcmp(SubInfo.Group, 'HC_PIT'));
Gender_pd = SubInfo.Gender(strcmp(SubInfo.Group, 'PD_POM'));   
RespHand_hc = SubInfo.RespHandIsDominant(strcmp(SubInfo.Group, 'HC_PIT'));
RespHand_pd = SubInfo.RespHandIsDominant(strcmp(SubInfo.Group, 'PD_POM')); 
NpsEducYears_hc = SubInfo.NpsEducYears(strcmp(SubInfo.Group, 'HC_PIT'));
NpsEducYears_pd = SubInfo.NpsEducYears(strcmp(SubInfo.Group, 'PD_POM')); 
% Inputs{10,1} = [FD_hc; FD_hc; FD_hc; FD_hc; FD_pd; FD_pd; FD_pd; FD_pd];
Inputs{4,1} = [Age_hc; Age_pd];
Inputs{5,1} = [Gender_hc; Gender_pd];
Inputs{6,1} = [RespHand_hc; RespHand_pd];
Inputs{7,1} = [NpsEducYears_hc; NpsEducYears_pd];

if (roi)
    Inputs{8,1} = {'/project/3024006.02/Analyses/motor_task/Group/Longitudinal/Masks/bi_partial_clincorr_bg_mask_2mm_cropped.nii'};
else
    Inputs{8,1} = {'/project/3024006.02/templates/templateflow/tpl-MNI152NLin6Asym_res-02_desc-brain_mask.nii'};
end

%% Run

JobFile = {spm_file(mfilename('fullpath'), 'suffix','_job', 'ext','.m')};

delete(fullfile(char(Inputs{1}), '*.*'))
% spm_jobman('run', JobFile, Inputs{:});
qsubfeval('spm_jobman','run', JobFile, Inputs{:},'memreq',9*1024^3,'timreq',10*60*60);

filename = char(fullfile(Inputs{1,1}, 'Inputs.mat'));
save(filename, 'Inputs')

end