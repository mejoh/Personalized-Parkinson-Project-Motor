% NOTE: Doesnt work with offstate at the moment since no castor data is available

function motor_2ndlevel_OneSampleTtests(BaselineOnly, Subscore, exclude_outliers, Subtype)
% Subscores
% Total AppendicularSum CompositeTremorSum
% PIGDSum ActionTremorSum TotalOnOffDelta BradySumOnOffDelta RestTremAmpSumOnOffDelta RestTremAmpSum BradySum RigiditySum 

if nargin < 1 || isempty(BaselineOnly)
    BaselineOnly = true;
end
if nargin < 1 || isempty(Subscore)
    Subscore = 'AppendicularSum';
end
if nargin < 1 || isempty(exclude_outliers)
    exclude_outliers = true;
end
if nargin < 1 || isempty(Subtype)
    Subtype = [];
end

%% Paths

addpath('/home/common/matlab/fieldtrip/qsub');
addpath('/home/common/matlab/spm12');
spm('defaults', 'FMRI');

%% Directories

ses = 'ses-Visit1';
GroupFolder = 'Group';
ANALYSESDir = '/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem';
ClinicalConfs = readtable('/project/3024006.02/Data/matlab/ClinVars_select_mri5.csv');
baseid = ClinicalConfs.TimepointNr == 0;
ClinicalConfs = ClinicalConfs(baseid,:);
% motortask = strcmp(ClinicalConfs.MriNeuroPsychTask, 'Motor');
% ClinicalConfs = ClinicalConfs(motortask,:);
g1 = string(ClinicalConfs.ParticipantType) == "PD_POM";
ClinicalConfs = ClinicalConfs(logical(g1),:);
Sub = cellstr(spm_select('List', fullfile(ANALYSESDir, GroupFolder, 'con_0001', 'ses-Visit1'), 'PD_POM.*sub-POM.*'));
Sub = extractBetween(Sub, 8, 31);
fprintf('Number of subjects found: %i\n', numel(Sub))

%% Subset data

% Select variables and remove missing values
Colnames = {'pseudonym' 'Subtype_DiagEx1_DisDurSplit' ['Up3Of' Subscore] 'Age' 'Gender' 'non_pd_diagnosis_at_ba'};
cID = ismember(ClinicalConfs.Properties.VariableNames, Colnames);
ClinicalConfs = rmmissing(ClinicalConfs(:,cID));

% Subtype = 'Mild-Motor';
if ~isempty(Subtype)
    % Select patients from the clinical data file that have the selected
    % subtype
    sid = contains(ClinicalConfs.Subtype_DiagEx1_DisDurSplit, Subtype);
    ClinicalConfs = ClinicalConfs(sid,:);
    fprintf('Analyzing subtype: %s, n = %i \n', Subtype, height(ClinicalConfs))
end

% Select patients with contrast images that are listed in the clinical data file
sid = contains(Sub, ClinicalConfs.pseudonym);
SubInfo.Sub = Sub(sid);
SubInfo.Age = zeros(size(SubInfo.Sub));
SubInfo.Gender = cell(size(SubInfo.Sub));
% SubInfo.MonthSinceDiag = zeros(size(SubInfo.Sub));
SubInfo.Type = cell(size(SubInfo.Sub));
SubInfo.Score = zeros(size(SubInfo.Sub));
for n = 1:numel(SubInfo.Sub)
    sid = find(strcmp(ClinicalConfs.pseudonym, SubInfo.Sub{n}));
    SubInfo.Age(n) = ClinicalConfs.Age(sid);
    SubInfo.Gender{n} = ClinicalConfs.Gender{sid};
%     SubInfo.MonthSinceDiag(n) = ClinicalConfs.MonthSinceDiag(sid);
    SubInfo.Type{n} = ClinicalConfs.Subtype_DiagEx1_DisDurSplit{sid};
    cID = ismember(ClinicalConfs.Properties.VariableNames, ['Up3Of' Subscore]);
    SubInfo.Score(n) = table2array(ClinicalConfs(sid,cID));
end

SubInfo.Gender_num = zeros(size(SubInfo.Gender));
for n = 1:numel(SubInfo.Gender)
    if strcmp(SubInfo.Gender{n}, 'Male')
        SubInfo.Gender_num(n) = 0;
    else
        SubInfo.Gender_num(n) = 1;
    end
end


%% Framewise displacement
SubInfo.ConfFiles = cell(size(SubInfo.Sub));
for n = 1:numel(SubInfo.Sub)
    SubInfo.ConfFiles{n} = spm_select('FPList', fullfile(ANALYSESDir, SubInfo.Sub{n}, 'ses-POMVisit1'), '^.*task-motor_acq-MB6_run-.*_desc-confounds_timeseries3.mat$');
    if isempty(SubInfo.ConfFiles{n})
        SubInfo.ConfFiles{n} = spm_select('FPList', fullfile(ANALYSESDir, SubInfo.Sub{n}, 'ses-POMVisit1'), '^.*task-motor_acq-MB6_run-.*_desc-confounds_timeseries2.mat$');
    end
end

SubInfo.FD = zeros(size(SubInfo.Sub));
for n = 1:numel(SubInfo.Sub)
    Confounds = spm_load(SubInfo.ConfFiles{n});
    FrameDisp = Confounds.R(:,strcmp(Confounds.names, 'framewise_displacement'));
    FrameDisp(isnan(FrameDisp)) = 0;
    SubInfo.FD(n) = mean(FrameDisp);
end

% Exclude outliers
mriqc_outliers = readtable('/project/3024006.02/Analyses/mriqc_outliers.txt');
Con1 = '/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/QC/con_0001/Group.txt';
Con2 = '/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/QC/con_0002/Group.txt';
Con3 = '/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/QC/con_0003/Group.txt';
Con12 = '/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/QC/con_0012/Group.txt';
Con13 = '/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/QC/con_0013/Group.txt';
ResMS = '/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/QC/ResMS/Group.txt';
Con1_f = readtable(Con1);
Con1_f_s = Con1_f(Con1_f.Outlier==1,:);
Con2_f = readtable(Con2);
Con2_f_s = Con2_f(Con2_f.Outlier==1,:);
Con3_f = readtable(Con3);
Con3_f_s = Con3_f(Con3_f.Outlier==1,:);
Con12_f = readtable(Con12);
Con12_f_s = Con12_f(Con12_f.Outlier==1,:);
Con13_f = readtable(Con13);
Con13_f_s = Con13_f(Con13_f.Outlier==1,:);
ResMS_f = readtable(ResMS);
ResMS_f_s = ResMS_f(ResMS_f.Outlier==1,:);
% AllOutliers = sortrows([Con1_f_s; Con2_f_s; Con3_f_s; Con12_f_s; Con13_f_s; ResMS_f_s]);
outliers = unique([Con1_f_s.Sub; Con2_f_s.Sub; Con3_f_s.Sub; Con12_f_s.Sub; Con13_f_s.Sub; ResMS_f_s.Sub; mriqc_outliers]);
% outliers = unique([Con12_f_s.Sub; Con13_f_s.Sub; ResMS_f_s.Sub; mriqc_outliers]);
outliers = [];
outliers = cell2table({'POMU3213FF895A391B8E'; 'POMU566ED54BF23566B6'; 'POMU7A45AB468540FBD2'; 'POMU7AABE759AC531D35'; 'POMUCA6A9EC3637FBF91';...
    'sub-POMUD03A248AEB7001CF'}, 'VariableNames',{'pseudonym'});
if istrue(exclude_outliers)
    Sel = true(size(SubInfo.Sub));
    for n = 1:numel(SubInfo.Sub)
        if contains(SubInfo.Sub{n}, string(table2array(outliers)))
           Sel(n) = false;
        fprintf('Excluding outlier: %s %s \n', SubInfo.Sub{n}, SubInfo.Type{n})
        end
    end
    SubInfo = subset_subinfo(SubInfo, Sel);
end

Sel = true(size(SubInfo.Sub));
for n = 1:numel(SubInfo.Sub)
    
    subid = find(contains(ClinicalConfs.pseudonym, SubInfo.Sub{n}));
    
    if ClinicalConfs.non_pd_diagnosis_at_ba(subid)
        fprintf('Misdiagnosis as non-PD, excluding %s...\n', SubInfo.Sub{n})
        Sel(n) = false;
    end
    
end
fprintf('%i subjects have a non-PD diagnosis, excluding these now...\n', length(Sel) - sum(Sel))
SubInfo = subset_subinfo(SubInfo, Sel);

%% Assemble inputs
ConList = {'con_0012' 'con_0013' 'con_0008' 'con_0010'};
ConNames= {'Int2gtExt' 'Int3gtExt' 'Int3gtInt2'  'Mean_ExtInt'};

if ~istrue(BaselineOnly)
    inputs = cell(8, 1);
    JobFile = '/home/sysneu/marjoh/scripts/Personalized-Parkinson-Project-Motor/motor/motor_2ndlevel_OneSampleTtests_prog_job.m';
else
    inputs = cell(7, 1);
    JobFile = '/home/sysneu/marjoh/scripts/Personalized-Parkinson-Project-Motor/motor/motor_2ndlevel_OneSampleTtests_ba_job.m';
end

for c = 1:numel(ConList)
    
%     if strcmp(ConNames{c}, 'Int>Ext')
%         Mask = {'/project/3024006.02/Analyses/Masks/WholeBrain.nii'};
%     elseif strcmp(ConNames{c}, 'Ext>Int')
%         Mask = {'/project/3024006.02/Analyses/Masks/WholeBrain.nii'};
%     elseif strcmp(ConNames{c}, 'Mean_ExtInt')
%         Mask = {'/project/3024006.02/Analyses/Masks/WholeBrain.nii'};
%     end
%     Mask = {'/project/3024006.02/Analyses/Masks/JuBrain_ROIs/Frontoparietal_BasalGanglia_Cerebellum_mask.nii'};
    Mask = {''};
    
    if ~istrue(BaselineOnly)
        inputs{1,1} = {fullfile(ANALYSESDir, GroupFolder, ['OneSampleTtest_ClinCorr-Off-Prog-' Subscore], ConNames{c})};
    else
        inputs{1,1} = {fullfile(ANALYSESDir, GroupFolder, ['OneSampleTtest_ClinCorr-Off-BA' Subscore], ConNames{c})};
    end
    searchnames = insertBefore(SubInfo.Sub, 1, 'PD_POM_');
    inputs{2,1} = find_contrast_files(searchnames, fullfile(ANALYSESDir, GroupFolder, ConList{c}, ses));
    inputs{3,1} = SubInfo.Score;
    inputs{4,1} = SubInfo.Age;
    inputs{5,1} = SubInfo.Gender_num;
    inputs{6,1} = SubInfo.FD;
    inputs{7,1} = Mask;
    
%     % Disease progression regressed against brain activity (BA severity treated as a covariate of non-interest)
%     % Find images based on pseudos in clinical vars
%     ConDir = fullfile(ANALYSESDir, GroupFolder, ConList{c}, 'ses-Visit1');
%     PdIms = struct2table(dir(fullfile(ConDir, 'PD_POM*')));
%     rID = contains(PdIms.name, ClinVars_subset.pseudonym);
%     PdIms_subset = PdIms(rID,1);
%     PdIms_subset.pseudonym = extractBetween(PdIms_subset.name, 'PD_POM_', '_ses');
%     inputs{2,1} = fullfile(ConDir,PdIms_subset.name);
%     % Find pseudos in clinical vars that match with found images
%     rID = contains(ClinVars_subset.pseudonym, PdIms_subset.pseudonym);
%     fprintf('Number of pseudonyms that have both clinical and fmri data: %i\n', sum(rID))
%     ClinVars_subset = ClinVars_subset(rID,:);
%     rID = contains(SubInfo.Sub, ClinVars_subset.pseudonym);
%     ClinVars_subset.FD = SubInfo.FD(rID);
%     inputs{3,1} = table2array(ClinVars_subset(:,5));
%     if ~istrue(BaselineOnly)
%         inputs{1,1} = {fullfile(ANALYSESDir, GroupFolder, ['OneSampleTtest_ClinCorr-Off-Prog-' Subscore], ConNames{c})};
%         inputs{4,1} = table2array(ClinVars_subset(:,6));
%         inputs{5,1} = ClinVars_subset.Age;
%         inputs{6,1} = grp2idx(ClinVars_subset.Gender)-1;
%         inputs{7,1} = ClinVars_subset.FD;
%         inputs{8,1} = Mask;
%     else
%         inputs{1,1} = {fullfile(ANALYSESDir, GroupFolder, ['OneSampleTtest_ClinCorr-Off-BA' Subscore], ConNames{c})};
%         inputs{4,1} = ClinVars_subset.Age;
%         inputs{5,1} = grp2idx(ClinVars_subset.Gender)-1;
%         inputs{6,1} = ClinVars_subset.FD;
%         inputs{7,1} = Mask;
%     end
    if exclude_outliers
        inputs{1,1} = insertAfter(inputs{1,1}, Subscore, '_NoOutliers3');
    end
    if ~isempty(Subtype)
        inputs{1,1} = insertBefore(inputs{1,1}, 'OneSampleTtest', [Subtype '_']);
    end
    %Start with new directory
    if ~exist(char(inputs{1,1}), 'dir')
        mkdir(char(inputs{1,1}));
    else
        delete(fullfile(char(inputs{1,1}), '*.*'));
    end
    filename = char(fullfile(inputs{1,1}, 'Inputs.mat'));
    save(filename, 'inputs')
    spm_jobman('run', JobFile, inputs{:});
%     jobs{c} =  qsubfeval('spm_jobman','run',JobFile, inputs{:},'memreq',15*1024^3,'timreq',20*60*60);
    
end
end