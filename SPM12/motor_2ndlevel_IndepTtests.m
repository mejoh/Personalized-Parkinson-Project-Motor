% Run independent samples t-tests on selected contrast images
% Follow up with TFCE and permutation testing

% Viable comparisons include:
% HcVsOff HcVsOn HcVsMMP HcVsIT HcVsDM MMPVsIT MMPVsDM
% IMPORTANT: Offstate set to false only enables the HcVsOff comparison to work.
% For all other comparisons set Offstate to true.

function motor_2ndlevel_IndepTtests(Offstate, Comparison, exclude_outliers, roi)

%% Swap

%% Group to comapre against controls

if nargin < 1 || isempty(Offstate)
    Offstate = true;
end
if nargin < 1 || isempty(Comparison)
    Comparison = 'HcVsOff';
end
if nargin < 1 || isempty(exclude_outliers)
    exclude_outliers = true;
end
if nargin < 1 || isempty(roi)
    roi = 'Whole';
end

%% Paths

addpath('/home/common/matlab/fieldtrip/qsub');
addpath('/home/common/matlab/spm12');
spm('defaults', 'FMRI');

%% Directories

ses = 'ses-Visit1';
ANALYSESDir = '/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem';
% ANALYSESDir = '/project/3022026.01/analyses/motor/fMRI_EventRelated_BRCtrl';
ClinicalConfs = readtable('/project/3024006.02/Data/matlab/ClinVars_select_mri.csv');
baseid = ClinicalConfs.TimepointNr == 0;
ClinicalConfs = ClinicalConfs(baseid,:);
if Offstate
    g1 = string(ClinicalConfs.ParticipantType) == "HC_PIT";
    g2 = string(ClinicalConfs.ParticipantType) == "PD_PIT";
else
    g1 = string(ClinicalConfs.ParticipantType) == "HC_PIT";
    g2 = string(ClinicalConfs.ParticipantType) == "PD_POM";
end
ClinicalConfs = ClinicalConfs(logical(g1 + g2),:);

Sub = cellstr(spm_select('List', fullfile(ANALYSESDir, 'Group', 'con_0001', ses), '.*sub-POM.*'));
Sub = extractBetween(Sub, 1, 31);
fprintf('Number of subjects processed: %i\n', numel(Sub))
CurrentDir = pwd;
cd(ANALYSESDir);

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
    fprintf('%i outliers have been excluded \n', length(Sel) - sum(Sel))
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
    confs = spm_select('FPList', fullfile(ANALYSESDir, SubInfo.Sub{n}, Session), '^.*task-motor_acq-MB6_run-.*_desc-confounds_timeseries.*.mat$');
    dims = size(confs);
    SubInfo.ConfFiles{n} = confs(dims(1),:);
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

%% Subtype

idx = string(ClinicalConfs.ParticipantType) == 'PD_POM';
Subtypes = ClinicalConfs(idx,:);
% idx = string(Subtypes.Subtype_DisDurSplit) ~= '4_Undefined';
% Subtypes = Subtypes(idx,:);
idx = contains(Subtypes.pseudonym, SubInfo.Sub);
Subtypes = Subtypes(idx,:);
SubInfo.Subtype = cell(size(SubInfo.Sub));
for i = 1:numel(SubInfo.Sub)
    s = SubInfo.Sub{i};
    idx = contains(Subtypes.pseudonym,s);
    if string(SubInfo.Group{i}) == "PD_POM" && sum(idx)>0
        type = Subtypes.Subtype_Imputed_DisDurSplit{contains(Subtypes.pseudonym,s)};
        SubInfo.Subtype{i} = type;
    else
        SubInfo.Subtype{i} = NaN;
    end
end

%% Assemble inputs

% ConList = {   'con_0001' 'con_0002' 'con_0003' 'con_0004' 'con_0005' 'con_0006' 'con_0007' 'con_0008'  'con_0009'  'con_0010'};
% ConNames   = {'Ext'      'Int2'     'Int3'     'Catch'    'Int'      'Ext>Int'   'Int>Ext' 'Int3>Int2' 'Int2>Int3' 'Mean_ExtInt'};
ConList =    {'con_0010',    'con_0007', 'con_0012',  'con_0013',   'con_0008',   'con_0006', 'con_0014',  'con_0015',  'con_0009'};
ConNames   = {'Mean_ExtInt', 'INTgtEXT', 'INT2gtEXT', 'INT3gtEXT',  'INT3gtINT2', 'EXTgtINT', 'EXTgtINT2', 'EXTgtINT3', 'INT2gtINT3'};

inputs = cell(6, 1);
if strcmp(roi, 'Herz')
    inputs{7,1} = {'/project/3024006.02/Analyses/Masks/Herz2021_Herz2014_combined_symmetrical.nii,1'};
    mask = 'Herz';
elseif strcmp(roi, 'MotorNet')
    inputs{7,1} = {'/project/3024006.02/Analyses/Masks/juelich_cb_striatum/Juelich-Cerebellar-Imanova.nii,1'};
    mask = 'MotorNet';
elseif strcmp(roi, 'WholeBrain')
    inputs{7,1} = {'/project/3024006.02/Analyses/Masks/WholeBrain.nii,1'};
    mask = 'WholeBrain';
end
if exclude_outliers
    OutExc = 'OutliersRemoved';
else
    OutExc = 'OutliersRetained';
end
jobs = cell(numel(ConList),1);
JobFile = {spm_file(mfilename('fullpath'), 'suffix','_job', 'ext','.m')};
% JobFile = {'/home/sysneu/marjoh/scripts/Personalized-Parkinson-Project-Motor/motor/motor_2ndlevel_IndepTtests_job.m'};
dat = struct();
for n = 1:numel(ConList)
    ConDir = fullfile(ANALYSESDir, 'Group', ConList{n}, ses);
    
    % Collect data from all groups
    HCs = SubInfo.Sub(strcmp(SubInfo.Group, 'HC_PIT'));
    dat.fd.hc = SubInfo.FD(contains(SubInfo.Sub, HCs));
    dat.age.hc = SubInfo.Age(contains(SubInfo.Sub, HCs));
    dat.sex.hc = SubInfo.Gender_num(contains(SubInfo.Sub, HCs));
    HCs = insertBefore(HCs, 1, 'HC_PIT_');
    dat.ims.hc = find_contrast_files(HCs, ConDir);
    
    OffPDs = SubInfo.Sub(strcmp(SubInfo.Group, 'PD_PIT'));
    dat.fd.off = SubInfo.FD(contains(SubInfo.Sub, OffPDs));
    dat.age.off = SubInfo.Age(contains(SubInfo.Sub, OffPDs));
    dat.sex.off = SubInfo.Gender_num(contains(SubInfo.Sub, OffPDs));
    OffPDs = insertBefore(OffPDs, 1, 'PD_PIT_');
    dat.ims.off = find_contrast_files(OffPDs, ConDir);
    
    OnPDs = SubInfo.Sub(strcmp(SubInfo.Group, 'PD_POM'));
    dat.fd.on = SubInfo.FD(contains(SubInfo.Sub, OnPDs));
    dat.age.on = SubInfo.Age(contains(SubInfo.Sub, OnPDs));
    dat.sex.on = SubInfo.Gender_num(contains(SubInfo.Sub, OnPDs));
    OnPDs = insertBefore(OnPDs, 1, 'PD_POM_');
    dat.ims.on = find_contrast_files(OnPDs, ConDir);
    
    MMPs = SubInfo.Sub(strcmp(SubInfo.Subtype, '1_Mild-Motor'));
    dat.fd.mmp = SubInfo.FD(contains(SubInfo.Sub, MMPs));
    dat.age.mmp = SubInfo.Age(contains(SubInfo.Sub, MMPs));
    dat.sex.mmp = SubInfo.Gender_num(contains(SubInfo.Sub, MMPs));
    MMPs = insertBefore(MMPs, 1, 'PD_POM_');
    dat.ims.mmp = find_contrast_files(MMPs, ConDir);
    
    ITs = SubInfo.Sub(strcmp(SubInfo.Subtype, '2_Intermediate'));
    dat.fd.it = SubInfo.FD(contains(SubInfo.Sub, ITs));
    dat.age.it = SubInfo.Age(contains(SubInfo.Sub, ITs));
    dat.sex.it = SubInfo.Gender_num(contains(SubInfo.Sub, ITs));
    ITs = insertBefore(ITs, 1, 'PD_POM_');
    dat.ims.it = find_contrast_files(ITs, ConDir);
    
    DMs = SubInfo.Sub(strcmp(SubInfo.Subtype, '3_Diffuse-Malignant'));
    dat.fd.dm = SubInfo.FD(contains(SubInfo.Sub, DMs));
    dat.age.dm = SubInfo.Age(contains(SubInfo.Sub, DMs));
    dat.sex.dm = SubInfo.Gender_num(contains(SubInfo.Sub, DMs));
    DMs = insertBefore(DMs, 1, 'PD_POM_');
    dat.ims.dm = find_contrast_files(DMs, ConDir);
    
    % Define inputs to SPM
    if strcmp(Comparison,'HcVsOff')
        inputs{1,1} = {fullfile(ANALYSESDir, 'Group/TFCE', ['IndependentTtest_TFCE_HcVsOff', '-', mask, '-', OutExc], ConNames{n})};
        inputs{2,1} = dat.ims.hc;
        inputs{3,1} = dat.ims.off;
        inputs{4,1} = [dat.fd.hc', dat.fd.off'];
        inputs{5,1} = [dat.age.hc', dat.age.off'];
        inputs{6,1} = [dat.sex.hc', dat.sex.off'];
    elseif strcmp(Comparison,'HcVsOn')
        inputs{1,1} = {fullfile(ANALYSESDir, 'Group/TFCE', ['IndependentTtest_TFCE_HcVsOn', '-', mask, '-', OutExc], ConNames{n})};
        inputs{2,1} = dat.ims.hc;
        inputs{3,1} = dat.ims.on;
        inputs{4,1} = [dat.fd.hc', dat.fd.on'];
        inputs{5,1} = [dat.age.hc', dat.age.on'];
        inputs{6,1} = [dat.sex.hc', dat.sex.on'];
    elseif strcmp(Comparison,'HcVsMMP')
        inputs{1,1} = {fullfile(ANALYSESDir, 'Group/TFCE', ['IndependentTtest_TFCE_HcVsMMP', '-', mask, '-', OutExc], ConNames{n})};
        inputs{2,1} = dat.ims.hc;
        inputs{3,1} = dat.ims.mmp;
        inputs{4,1} = [dat.fd.hc', dat.fd.mmp'];
        inputs{5,1} = [dat.age.hc', dat.age.mmp'];
        inputs{6,1} = [dat.sex.hc', dat.sex.mmp'];
    elseif strcmp(Comparison,'HcVsIT')
        inputs{1,1} = {fullfile(ANALYSESDir, 'Group/TFCE', ['IndependentTtest_TFCE_HcVsIT', '-', mask, '-', OutExc], ConNames{n})};
        inputs{2,1} = dat.ims.hc;
        inputs{3,1} = dat.ims.it;
        inputs{4,1} = [dat.fd.hc', dat.fd.it'];
        inputs{5,1} = [dat.age.hc', dat.age.it'];
        inputs{6,1} = [dat.sex.hc', dat.sex.it'];
    elseif strcmp(Comparison,'HcVsDM')
        inputs{1,1} = {fullfile(ANALYSESDir, 'Group/TFCE', ['IndependentTtest_TFCE_HcVsDM', '-', mask, '-', OutExc], ConNames{n})};
        inputs{2,1} = dat.ims.hc;
        inputs{3,1} = dat.ims.dm;
        inputs{4,1} = [dat.fd.hc', dat.fd.dm'];
        inputs{5,1} = [dat.age.hc', dat.age.dm'];
        inputs{6,1} = [dat.sex.hc', dat.sex.dm'];
    elseif strcmp(Comparison,'MMPVsIT')
        inputs{1,1} = {fullfile(ANALYSESDir, 'Group/TFCE', ['IndependentTtest_TFCE_MMPVsIT', '-', mask, '-', OutExc], ConNames{n})};
        inputs{2,1} = dat.ims.mmp;
        inputs{3,1} = dat.ims.it;
        inputs{4,1} = [dat.fd.mmp', dat.fd.it'];
        inputs{5,1} = [dat.age.mmp', dat.age.it'];
        inputs{6,1} = [dat.sex.mmp', dat.sex.it'];
    elseif strcmp(Comparison,'MMPVsDM')
        inputs{1,1} = {fullfile(ANALYSESDir, 'Group/TFCE', ['IndependentTtest_TFCE_MMPVsDM', '-', mask, '-', OutExc], ConNames{n})};
        inputs{2,1} = dat.ims.mmp;
        inputs{3,1} = dat.ims.dm;
        inputs{4,1} = [dat.fd.mmp', dat.fd.dm'];
        inputs{5,1} = [dat.age.mmp', dat.age.dm'];
        inputs{6,1} = [dat.sex.mmp', dat.sex.dm'];
    elseif strcmp(Comparison,'ITVsDM')
        inputs{1,1} = {fullfile(ANALYSESDir, 'Group/TFCE', ['IndependentTtest_TFCE_ITVsDM', '-', mask, '-', OutExc], ConNames{n})};
        inputs{2,1} = dat.ims.it;
        inputs{3,1} = dat.ims.dm;
        inputs{4,1} = [dat.fd.it', dat.fd.dm'];
        inputs{5,1} = [dat.age.it', dat.age.dm'];
        inputs{6,1} = [dat.sex.it', dat.sex.dm'];
    end
    
        
%         % Select images and define covars
%     if Offstate
%         inputs{1,1} = {fullfile(ANALYSESDir, 'Group/TFCE', 'IndependentTtest_TFCE_HcVsOff', ConNames{n})};
%         HcIms = dir(fullfile(ConDir, 'HC_PIT*'));
%         inputs{2,1} = fullfile(ConDir, {HcIms.name}');
%         PdIms = dir(fullfile(ConDir, 'PD_PIT*'));
%         inputs{3,1} = fullfile(ConDir, {PdIms.name}');
%         FD2 = [SubInfo.FD(strcmp(SubInfo.Group, 'HC_PIT')); SubInfo.FD(strcmp(SubInfo.Group, 'PD_PIT'))];
%         Age_cov = [SubInfo.Age(strcmp(SubInfo.Group, 'HC_PIT')); SubInfo.Age(strcmp(SubInfo.Group, 'PD_PIT'))];
%         Gender_cov = [SubInfo.Gender_num(strcmp(SubInfo.Group, 'HC_PIT')); SubInfo.Gender_num(strcmp(SubInfo.Group, 'PD_PIT'))];
%     else
%         inputs{1,1} = {fullfile(ANALYSESDir, 'Group/TFCE', 'IndependentTtest_TFCE_HcVsOn', ConNames{n})};
%         HcIms = dir(fullfile(ConDir, 'HC_PIT*'));
%         inputs{2,1} = fullfile(ConDir, {HcIms.name}');
%         PdIms = dir(fullfile(ConDir, 'PD_POM*'));
%         inputs{3,1} = fullfile(ConDir, {PdIms.name}');
%         FD2 = [SubInfo.FD(strcmp(SubInfo.Group, 'HC_PIT')); SubInfo.FD(strcmp(SubInfo.Group, 'PD_POM'))];
%         Age_cov = [SubInfo.Age(strcmp(SubInfo.Group, 'HC_PIT')); SubInfo.Age(strcmp(SubInfo.Group, 'PD_POM'))];
%         Gender_cov = [SubInfo.Gender_num(strcmp(SubInfo.Group, 'HC_PIT')); SubInfo.Gender_num(strcmp(SubInfo.Group, 'PD_POM'))];
%     end
%     inputs{4,1} = FD2';%(FD2 - mean(FD2) / std(FD2))';       %Normalize FD
%     inputs{5,1} = Age_cov';
%     inputs{6,1} = Gender_cov';
        
    %Start with new directory
    if ~exist(char(inputs{1,1}), 'dir')
        mkdir(char(inputs{1,1}));
    else
        delete(fullfile(char(inputs{1,1}), '*.*'));
    end
    
    filename = char(fullfile(inputs{1,1}, 'Inputs.mat'));
    save(filename, 'inputs')
    
        % Run job
%     spm_jobman('run', JobFile, inputs{:});
    jobs{n} =  qsubfeval('spm_jobman','run',JobFile, inputs{:},'memreq',5*1024^3,'timreq',6*60*60);

%     spmmat = spm_select('FPList', char(inputs{1,1}), 'SPM.mat');
%     motor_tfce(spmmat, 2, 5000)

end

%% Write output files

% pause(1*60)

% % File for jobs
% task.jobs = jobs;
% task.submittime = datestr(clock);
% task.mfile = mfilename;
% task.mfiletext = fileread([task.mfile '.m']);
% 
% % File for analyzed subjects
% AnalyzedSubs = extractBetween(inputs{2,1}, 'HC_PIT_', '_ses');      % Check for pseudonyms included in analysis
% if ~istrue(Offstate)
%     AnalyzedSubs = [AnalyzedSubs; extractBetween(inputs{3,1}, 'PD_POM_', '_ses')];
% else
%     AnalyzedSubs = [AnalyzedSubs; extractBetween(inputs{3,1}, 'PD_PIT_', '_ses')];
% end
% SubInfo.Analyzed = contains(SubInfo.Sub, AnalyzedSubs);         % Write to SubInfo
% SubInfo2 = struct2table(SubInfo);                               % Create a second SubInfo to store only analyzed subjects
% SubInfo2 = SubInfo2(SubInfo2.Analyzed,:);
% if ~istrue(Offstate)                                            % Remove duplicates depending on 'Offstate'
%     SubInfo2 = SubInfo2(SubInfo2.Group ~= "PD_PIT",:);
% else
%     SubInfo2 = SubInfo2(SubInfo2.Group ~= "PD_POM",:);
% end
% 
% % Write files
% if ~istrue(Offstate)
%     save([fullfile(ANALYSESDir, 'Group/TFCE', 'IndependentTtest_TFCE_HcVsOn') '/jobs___' task.mfile  '___' datestr(clock) '.mat'],'task');
%     save([fullfile(ANALYSESDir, 'Group/TFCE', 'IndependentTtest_TFCE_HcVsOn') '/AllSubs___' task.mfile  '___' datestr(clock) '.mat'],'SubInfo');
%     save([fullfile(ANALYSESDir, 'Group/TFCE', 'IndependentTtest_TFCE_HcVsOn') '/AnalyzedSubs___' task.mfile  '___' datestr(clock) '.mat'],'SubInfo2');
%     writetable(struct2table(SubInfo), [fullfile(ANALYSESDir, 'Group/TFCE', 'IndependentTtest_TFCE_HcVsOn') '/AllSubs___' task.mfile  '___' datestr(clock) '.csv'])
%     writetable(SubInfo2, [fullfile(ANALYSESDir, 'Group/TFCE', 'IndependentTtest_TFCE_HcVsOn') '/AnalyzedSubs___' task.mfile  '___' datestr(clock) '.csv'])
% else
%     save([fullfile(ANALYSESDir, 'Group/TFCE', 'IndependentTtest_TFCE_HcVsOff') '/jobs___' task.mfile  '___' datestr(clock) '.mat'],'task');
%     save([fullfile(ANALYSESDir, 'Group/TFCE', 'IndependentTtest_TFCE_HcVsOff') '/AllSubs___' task.mfile  '___' datestr(clock) '.mat'],'SubInfo');
%     save([fullfile(ANALYSESDir, 'Group/TFCE', 'IndependentTtest_TFCE_HcVsOff') '/AnalyzedSubs___' task.mfile  '___' datestr(clock) '.mat'],'SubInfo2');
%     writetable(struct2table(SubInfo), [fullfile(ANALYSESDir, 'Group/TFCE', 'IndependentTtest_TFCE_HcVsOff') '/AllSubs___' task.mfile  '___' datestr(clock) '.csv'])
%     writetable(SubInfo2, [fullfile(ANALYSESDir, 'Group/TFCE', 'IndependentTtest_TFCE_HcVsOff') '/AnalyzedSubs___' task.mfile  '___' datestr(clock) '.csv'])
% end

cd(CurrentDir)

end

