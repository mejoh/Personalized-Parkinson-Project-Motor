% NOTE: Doesnt work with offstate at the moment since no castor data is available

function motor_2ndlevel_OneSampleTtests(BaselineOnly, Subscore)
% Subscores
% Total BradySum RigiditySum RestTremAmpSum 
% PIGDSum ActionTremorSum CompositeTremorSum TotalOnOffDelta BradySumOnOffDelta RestTremAmpSumOnOffDelta

if nargin < 1 || isempty(BaselineOnly)
    BaselineOnly = false;
end
if nargin < 1 || isempty(Subscore)
    Subscore = 'Total';
end

%% Paths

addpath('/home/common/matlab/fieldtrip/qsub');
addpath('/home/common/matlab/spm12');
spm('defaults', 'FMRI');

%% Directories

ses = 'ses-Visit1';
ANALYSESDir = '/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer/';
% ANALYSESDir = '/project/3022026.01/analyses/motor/fMRI_EventRelated_BRCtrl';
ClinicalDataFile = '/project/3022026.01/pep/ClinVars/derivatives/database_clinical_variables.csv';
Sub = cellstr(spm_select('List', fullfile(ANALYSESDir, 'Group', 'con_0001', 'ses-Visit1'), '.*sub-POM.*'));
Sub = extractBetween(Sub, 1, 31);
fprintf('Number of subjects found: %i\n', numel(Sub))

%% Import clinical data

ClinVars = readtable(ClinicalDataFile);

% Subset data frame
rID_task = strcmp(ClinVars.MriNeuroPsychTask, 'Motor');
rID_time = strcmp(ClinVars.Timepoint, 'ses-Visit1');
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

%% Assemble inputs
%ConList = {'con_0001' 'con_0002' 'con_0003' 'con_0004' 'con_0005' 'con_0006' 'con_0007' 'con_0008' 'con_0009' 'con_0010'};
%ConNames   = {'Ext' 'Int2' 'Int3' 'Catch' 'Int' 'Ext>Int' 'Int>Ext' 'Int3>Int2' 'Int2>Int3' 'Mean_ExtInt'};
ConList = {'con_0001' 'con_0005' 'con_0006' 'con_0007' 'con_0010'};
ConNames   = {'Ext' 'Int' 'Ext>Int' 'Int>Ext' 'Mean_ExtInt'};

if ~istrue(BaselineOnly)
    inputs = cell(6, 1);
    JobFile = '/home/sysneu/marjoh/scripts/Personalized-Parkinson-Project-Motor/motor/motor_2ndlevel_OneSampleTtests_prog_job.m';
else
    inputs = cell(5, 1);
    JobFile = '/home/sysneu/marjoh/scripts/Personalized-Parkinson-Project-Motor/motor/motor_2ndlevel_OneSampleTtests_ba_job.m';
end

for c = 1:numel(ConList)
    
    % Disease progression regressed against brain activity (BA severity treated as a covariate of non-interest)
    % Find images based on pseudos in clinical vars
    ConDir = fullfile(ANALYSESDir, 'Group', ConList{c}, ses);
    PdIms = struct2table(dir(fullfile(ConDir, 'PD_POM*')));
    rID = contains(PdIms.name, ClinVars_subset.pseudonym);
    PdIms_subset = PdIms(rID,1);
    PdIms_subset.pseudonym = extractBetween(PdIms_subset.name, 'PD_POM_', '_ses');
    inputs{2,1} = fullfile(ConDir,PdIms_subset.name);
    % Find pseudos in clinical vars that match with found images
    rID = contains(ClinVars_subset.pseudonym, PdIms_subset.pseudonym);
    fprintf('Number of pseudonyms that have both clinical and fmri data: %i\n', sum(rID))
    ClinVars_subset = ClinVars_subset(rID,:);
    inputs{3,1} = table2array(ClinVars_subset(:,5));
    if ~istrue(BaselineOnly)
        inputs{1,1} = {fullfile(ANALYSESDir, 'Group', ['OneSampleTtest_ClinCorr-Off-' Subscore '-Prog_POM'], ConNames{c})};
        inputs{4,1} = table2array(ClinVars_subset(:,7));
        inputs{5,1} = ClinVars_subset.Age;
        inputs{6,1} = grp2idx(ClinVars_subset.Gender)-1;
    else
        inputs{1,1} = {fullfile(ANALYSESDir, 'Group', ['OneSampleTtest_ClinCorr-Off-' Subscore '-BA_POM'], ConNames{c})};
        inputs{4,1} = ClinVars_subset.Age;
        inputs{5,1} = grp2idx(ClinVars_subset.Gender)-1;
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