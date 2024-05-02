%QSUB
% motor_longitudinal_2ndlevel_OneSampleTtests('con_0010',true);motor_longitudinal_2ndlevel_OneSampleTtests('con_0010',false);
% motor_longitudinal_2ndlevel_OneSampleTtests('con_0011',true);motor_longitudinal_2ndlevel_OneSampleTtests('con_0011',false);
% motor_longitudinal_2ndlevel_OneSampleTtests('con_0012',true);motor_longitudinal_2ndlevel_OneSampleTtests('con_0012',false);
% motor_longitudinal_2ndlevel_OneSampleTtests('con_0007',true);motor_longitudinal_2ndlevel_OneSampleTtests('con_0007',false)

function motor_longitudinal_2ndlevel_OneSampleTtests(Contrast, roi)

if nargin < 1
    Contrast = 'con_0010';
    roi=false;
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
ClinicalConfs.ClinScore_RawChange = ClinicalConfs.Up3OnBradySum_RawChange;
ClinicalConfs.ClinScore_BA = ClinicalConfs.Up3OnBradySum_T0;
ClinicalConfs.ClinScore_dXba = ClinicalConfs.Up3OnBradySum_dXba;

Sub = cellstr(spm_select('List', dCon, 'PD_POM_sub-POM.*'));
Sub = extractBetween(Sub, 1, 31);
fprintf('Number of subjects processed: %i\n', numel(Sub))

SubInfo.Sub = extractBetween(Sub, 8, 31);

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
SubInfo.DisDur = zeros(size(SubInfo.Sub));
SubInfo.ClinScore_RawChange = zeros(size(SubInfo.Sub));
SubInfo.ClinScore_BA = zeros(size(SubInfo.Sub));
SubInfo.ClinScore_dXba = zeros(size(SubInfo.Sub));
for n = 1:numel(SubInfo.Sub)
    
    subid = find(contains(ClinicalConfs.pseudonym, SubInfo.Sub{n}));
    if length(subid)>1
        subid=subid(1);
    end
    
    if isempty(subid) || isnan(ClinicalConfs.Age(subid)) || isnan(ClinicalConfs.Gender(subid)) || isnan(ClinicalConfs.RespHandIsDominant_T0(subid))|| isnan(ClinicalConfs.NpsEducYears(subid)) || isnan(ClinicalConfs.DisDur(subid)) || isnan(ClinicalConfs.ClinScore_RawChange(subid)) || isnan(ClinicalConfs.ClinScore_BA(subid))
        fprintf('Missing values, excluding %s...\n', SubInfo.Sub{n})
        Sel(n) = false;
    else
        SubInfo.Age(n) = ClinicalConfs.Age(subid);
        SubInfo.Gender(n) = ClinicalConfs.Gender(subid);
        SubInfo.RespHandIsDominant(n) = ClinicalConfs.RespHandIsDominant_T0(subid);
        SubInfo.NpsEducYears(n) = ClinicalConfs.NpsEducYears(subid);
        SubInfo.DisDur(n) = ClinicalConfs.DisDur(subid);
        SubInfo.ClinScore_RawChange(n) = ClinicalConfs.ClinScore_RawChange(subid);
        SubInfo.ClinScore_BA(n) = ClinicalConfs.ClinScore_BA(subid);
        SubInfo.ClinScore_dXba(n) = ClinicalConfs.ClinScore_dXba(subid);
    end
    
end
fprintf('%i subjects have missing Age/Gender/Hand/Clinical score, excluding...\n', length(Sel) - sum(Sel))
SubInfo = subset_subinfo(SubInfo, Sel);

%% Demean covars
SubInfo.Age = SubInfo.Age - mean(SubInfo.Age);
SubInfo.Gender = SubInfo.Gender - mean(SubInfo.Gender);
SubInfo.RespHandIsDominant = SubInfo.RespHandIsDominant - mean(SubInfo.RespHandIsDominant);
SubInfo.NpsEducYears = SubInfo.NpsEducYears - mean(SubInfo.NpsEducYears);
SubInfo.DisDur = SubInfo.DisDur - mean(SubInfo.DisDur);
SubInfo.ClinScore_RawChange = SubInfo.ClinScore_RawChange - mean(SubInfo.ClinScore_RawChange);
SubInfo.ClinScore_BA = SubInfo.ClinScore_BA - mean(SubInfo.ClinScore_BA);
SubInfo.ClinScore_dXba = SubInfo.ClinScore_dXba - mean(SubInfo.ClinScore_dXba);

%% Assemble inputs
Inputs = cell(10,1);

if (roi)
    Inputs{1,1} = {fullfile(dOutput,'OneSampleTTest-roi')};
else
    Inputs{1,1} = {fullfile(dOutput,'OneSampleTTest-whole')};
end
if ~exist(char(Inputs{1,1}),'dir')
    mkdir(char(Inputs{1,1}))
end

PD = dir(fullfile(dCon, 'PD_POM*'));
PD_files = {PD.name}';
PD_files = PD_files(contains({PD.name}, SubInfo.Sub));
Inputs{2,1} = fullfile(dCon, PD_files);

Inputs{3,1} = [SubInfo.ClinScore_BA];
Inputs{4,1} = [SubInfo.ClinScore_RawChange];
% Inputs{5,1} = [SubInfo.ClinScore_dXba];
Inputs{5,1} = [SubInfo.Age];
Inputs{6,1} = [SubInfo.Gender];
Inputs{7,1} = [SubInfo.RespHandIsDominant];
Inputs{8,1} = [SubInfo.NpsEducYears];
Inputs{9,1} = [SubInfo.DisDur];

if (roi)
    Inputs{10,1} = {'/project/3024006.02/Analyses/motor_task/Group/Longitudinal/Masks/bi_partial_clincorr_bg_mask_2mm_cropped.nii'};
else
    Inputs{10,1} = {'/project/3024006.02/templates/templateflow/tpl-MNI152NLin6Asym_res-02_desc-brain_mask.nii'};
end

%% Run

JobFile = {spm_file(mfilename('fullpath'), 'suffix','_job', 'ext','.m')};

delete(fullfile(char(Inputs{1}), '*.*'))
% spm_jobman('run', JobFile, Inputs{:});
qsubfeval('spm_jobman','run', JobFile, Inputs{:},'memreq',9*1024^3,'timreq',10*60*60);

filename = char(fullfile(Inputs{1,1}, 'Inputs.mat'));
save(filename, 'Inputs')

end