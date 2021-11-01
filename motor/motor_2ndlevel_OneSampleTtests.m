% NOTE: Doesnt work with offstate at the moment since no castor data is available

function motor_2ndlevel_OneSampleTtests(BaselineOnly, Subscore, exclude_outliers, Subtype)
% Subscores
% Total AppendicularSum CompositeTremorSum
% PIGDSum ActionTremorSum TotalOnOffDelta BradySumOnOffDelta RestTremAmpSumOnOffDelta RestTremAmpSum BradySum RigiditySum 

if nargin < 1 || isempty(BaselineOnly)
    BaselineOnly = false;
end
if nargin < 1 || isempty(Subscore)
    Subscore = 'Total';
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

ses = 'ses-POMVisit1';
GroupFolder = 'Group';
ANALYSESDir = '/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem';
ClinicalDataFile = '/project/3022026.01/pep/ClinVars/derivatives/database_clinical_variables_2021-08-30.csv';
SubtypeDataFile = '/project/3022026.01/pep/deprecated_ClinVars/derivatives/Subtypes_2021-04-12.csv';
Sub = cellstr(spm_select('List', fullfile(ANALYSESDir, GroupFolder, 'con_0001', 'ses-Visit1'), '.*sub-POM.*'));
Sub = extractBetween(Sub, 1, 31);
fprintf('Number of subjects found: %i\n', numel(Sub))

%% Import clinical data

ClinVars = readtable(ClinicalDataFile);
ClinVars = ClinVars(contains(ClinVars.Timepoint, extractAfter(ses, 'POM')),:);

% Subtype = 'Mild-Motor';
if ~isempty(Subtype)
    Classification = readtable(SubtypeDataFile);
    Classification = Classification(strcmp(Classification.Subtype, Subtype),:);
    Sub = Sub(contains(Sub,Classification.pseudonym));
    ClinVars = ClinVars(contains(ClinVars.pseudonym, Classification.pseudonym),:);
    fprintf('Analyzing subtype: %s, n = %i \n', Subtype, numel(Sub))
end

% Subset data frame
rID_task = strcmp(ClinVars.MriNeuroPsychTask, 'Motor');
rID_time = strcmp(ClinVars.Timepoint, ses);
if ~istrue(BaselineOnly)
    rID_multses = strcmp(ClinVars.MultipleSessions, 'Yes');
    rID = logical(rID_task .* rID_time .* rID_multses);
    Colnames = {'pseudonym' ['Up3Of' Subscore] ['Up3On' Subscore] ['Up3Of' Subscore '_1YearDelta'] ['Up3On' Subscore '_1YearDelta'] 'Age' 'Gender' 'EstDisDurYears'};
    cID = ismember(ClinVars.Properties.VariableNames, Colnames);
else
    rID = logical(rID_task .* rID_time);
    Colnames = {'pseudonym' ['Up3Of' Subscore] ['Up3On' Subscore] 'Age' 'Gender' 'EstDisDurYears'};
    cID = ismember(ClinVars.Properties.VariableNames, Colnames);
end
ClinVars_subset = rmmissing(ClinVars(rID,cID));
fprintf('Number of Motor subjects with multiple sessions found in clinical data: %i\n', sum(rID))

%% Framewise displacement
SubInfo.Sub = Sub(contains(Sub,'PD_POM'));
SubInfo.ConfFiles = cell(size(SubInfo.Sub));
for n = 1:numel(SubInfo.Sub)
    s = extractAfter(SubInfo.Sub{n}, 7);
    SubInfo.ConfFiles{n} = spm_select('FPList', fullfile(ANALYSESDir, s, 'ses-POMVisit1'), '^.*task-motor_acq-MB6_run-.*_desc-confounds_timeseries3.mat$');
    if isempty(SubInfo.ConfFiles{n})
        SubInfo.ConfFiles{n} = spm_select('FPList', fullfile(ANALYSESDir, s, 'ses-POMVisit1'), '^.*task-motor_acq-MB6_run-.*_desc-confounds_timeseries2.mat$');
    end
end

SubInfo.FD = zeros(size(SubInfo.Sub));
for n = 1:numel(SubInfo.Sub)
    if ~isempty(SubInfo.ConfFiles{n})
        Confounds = spm_load(SubInfo.ConfFiles{n});
        FrameDisp = Confounds.R(:,strcmp(Confounds.names, 'framewise_displacement'));
%     FrameDisp(isnan(FrameDisp)) = 0;
        SubInfo.FD(n) = mean(FrameDisp, 'omitna');
    else
        SubInfo.FD(n) = NaN;
    end
end

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
        fprintf('Excluding outlier: %s \n', SubInfo.Sub{n})
        end
    end
    SubInfo = subset_subinfo(SubInfo,Sel);
    rID = contains(ClinVars_subset.pseudonym, outliers);
    ClinVars_subset = ClinVars_subset(~rID,:);
end

%% Assemble inputs
%ConList = {'con_0001' 'con_0002' 'con_0003' 'con_0004' 'con_0005' 'con_0006' 'con_0007' 'con_0008' 'con_0009' 'con_0010'};
%ConNames   = {'Ext' 'Int2' 'Int3' 'Catch' 'Int' 'Ext>Int' 'Int>Ext' 'Int3>Int2' 'Int2>Int3' 'Mean_ExtInt'};
% ConList = {'con_0001' 'con_0005' 'con_0006' 'con_0007' 'con_0010'};
% ConNames= {'Ext'      'Int'      'Ext>Int'  'Int>Ext'  'Mean_ExtInt'};
ConList = {'con_0007' 'con_0010'};
ConNames= {'Int>Ext'  'Mean_ExtInt'};

if ~istrue(BaselineOnly)
    inputs = cell(8, 1);
    JobFile = '/home/sysneu/marjoh/scripts/Personalized-Parkinson-Project-Motor/motor/motor_2ndlevel_OneSampleTtests_prog_job.m';
else
    inputs = cell(7, 1);
    JobFile = '/home/sysneu/marjoh/scripts/Personalized-Parkinson-Project-Motor/motor/motor_2ndlevel_OneSampleTtests_ba_job.m';
end

for c = 1:numel(ConList)
    
    if strcmp(ConNames{c}, 'Int>Ext')
        Mask = {'/project/3024006.02/Analyses/Masks/WholeBrain.nii'};
    elseif strcmp(ConNames{c}, 'Ext>Int')
        Mask = {'/project/3024006.02/Analyses/Masks/WholeBrain.nii'};
    elseif strcmp(ConNames{c}, 'Mean_ExtInt')
        Mask = {'/project/3024006.02/Analyses/Masks/WholeBrain.nii'};
    end
    
    % Disease progression regressed against brain activity (BA severity treated as a covariate of non-interest)
    % Find images based on pseudos in clinical vars
    ConDir = fullfile(ANALYSESDir, GroupFolder, ConList{c}, 'ses-Visit1');
    PdIms = struct2table(dir(fullfile(ConDir, 'PD_POM*')));
    rID = contains(PdIms.name, ClinVars_subset.pseudonym);
    PdIms_subset = PdIms(rID,1);
    PdIms_subset.pseudonym = extractBetween(PdIms_subset.name, 'PD_POM_', '_ses');
    inputs{2,1} = fullfile(ConDir,PdIms_subset.name);
    % Find pseudos in clinical vars that match with found images
    rID = contains(ClinVars_subset.pseudonym, PdIms_subset.pseudonym);
    fprintf('Number of pseudonyms that have both clinical and fmri data: %i\n', sum(rID))
    ClinVars_subset = ClinVars_subset(rID,:);
    rID = contains(SubInfo.Sub, ClinVars_subset.pseudonym);
    ClinVars_subset.FD = SubInfo.FD(rID);
    inputs{3,1} = table2array(ClinVars_subset(:,5));
    if ~istrue(BaselineOnly)
        inputs{1,1} = {fullfile(ANALYSESDir, GroupFolder, ['OneSampleTtest_ClinCorr-Off-Prog-' Subscore], ConNames{c})};
        inputs{4,1} = table2array(ClinVars_subset(:,6));
        inputs{5,1} = ClinVars_subset.Age;
        inputs{6,1} = grp2idx(ClinVars_subset.Gender)-1;
        inputs{7,1} = ClinVars_subset.FD;
        inputs{8,1} = Mask;
    else
        inputs{1,1} = {fullfile(ANALYSESDir, GroupFolder, ['OneSampleTtest_ClinCorr-Off-BA' Subscore], ConNames{c})};
        inputs{4,1} = ClinVars_subset.Age;
        inputs{5,1} = grp2idx(ClinVars_subset.Gender)-1;
        inputs{6,1} = ClinVars_subset.FD;
        inputs{7,1} = Mask;
    end
    if exclude_outliers
        inputs{1,1} = insertAfter(inputs{1,1}, Subscore, '_NoOutliers');
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