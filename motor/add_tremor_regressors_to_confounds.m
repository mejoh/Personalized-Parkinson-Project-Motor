% Run after AROMA confounds have been added (otherwise there wont be a regressors2.tsv file
% Adds tremor regressors to fmriprep confounds file
function add_tremor_regressors_to_confounds()

Project = '3022026.01';
fprintf('Processing data in project: %s\n', Project)
Root = strcat('/project/', Project, '/pep');
BIDSDir  = fullfile(Root, 'bids');
FMRIPrep = fullfile(BIDSDir, 'derivatives/fmriprep');
% ClinVars = fullfile(Root, 'ClinVars');
EMGDir = '/project/3022026.01/analyses/EMG/motor';
Prepemg = fullfile(EMGDir, 'processing/prepemg/Regressors/ZSCORED');
Automaticdir = fullfile(EMGDir, 'automaticdir');
Tremor_Check = fullfile(EMGDir, 'manually_checked/Martin/Tremor_check-09-Nov-2020.mat');

Sub = cellstr(spm_select('List', fullfile(BIDSDir), 'dir', '^sub-POM.*'));

% Exclude subjects
Sel = true(size(Sub,1),1);
for n = 1:numel(Sub)
    Visit = cellstr(spm_select('List', fullfile(BIDSDir, Sub{n}), 'dir', 'ses-Visit[0-9]'));
    for v = 1:numel(Visit)
        
        % Confounds file
        dFunc = fullfile(FMRIPrep, Sub{n}, Visit{v}, 'func');
        ConfoundsFile = cellstr(spm_select('FPList', dFunc, [Sub{n}, '.*task-motor_acq-MB6_run-', '.*_desc-confounds_regressors2.tsv']));
        ConfoundsFile = cellstr(ConfoundsFile{size(ConfoundsFile,1)});
%         % UPDRS-III tremor assessment
%         dClin = fullfile(ClinVars, Sub{n}, Visit{v});
%         TremorFile = cellstr(spm_select('FPList', dClin, '.*Motorische_taken_OFF.Updrs_3_deel_3.json'));
        % Automaticdir
        AutoClassed = spm_select('FPList', Automaticdir, [Sub{n}, '-', Visit{v}, '-motor-selected-acc.*.jpg']);
        % Prepemg output
        TAmp = spm_select('FPList', Prepemg, [Sub{n}, '-', Visit{v}, '.*acc.*amplitude.mat']);
        TLog = spm_select('FPList', Prepemg, [Sub{n}, '-', Visit{v}, '.*acc.*log.mat']);
        TPow = spm_select('FPList', Prepemg, [Sub{n}, '-', Visit{v}, '.*acc.*power.mat']);
        
        % Exclude participants
        if isempty(ConfoundsFile{1})
            fprintf('Excluding %s:  %s lacks edited fmriprep confound regressors \n', Sub{n}, Visit{v})
            Sel(n) = false;
        end
%         if isempty(TremorFile{1})
%             fprintf('Excluding %s: %s lacks clinical tremor measurement \n', Sub{n}, Visit{v})
%             Sel(n) = false;
%         end
        if isempty(AutoClassed)
             fprintf('Excluding %s: %s lacks automatic classification of tremor \n', Sub{n}, Visit{v})
             Sel(n) = false;    
        end
        if isempty(TAmp) || isempty(TLog) || isempty(TPow)
            fprintf('Excluding %s: %s lacks accelerometer tremor regressor \n', Sub{n}, Visit{v})
            Sel(n) = false;
        end
        
    end
end
Sub = Sub(Sel);
NrSub = numel(Sub);
fprintf('%i participants included for further processing \n', NrSub)

% Load manual tremor check
load(Tremor_Check, 'Tremor_check');

% Add tremor regressor to confounds
for n = 1:NrSub
    Visit = cellstr(spm_select('List', fullfile(BIDSDir, Sub{n}), 'dir', 'ses-Visit[0-9]'));
    for v = 1:numel(Visit)
        
        % Confounds file
        dFunc = fullfile(FMRIPrep, Sub{n}, Visit{v}, 'func');
        ConfoundsFile = cellstr(spm_select('FPList', dFunc, [Sub{n}, '.*task-motor_acq-MB6_run-', '.*_desc-confounds_regressors2.tsv']));
        ConfoundsFile = cellstr(ConfoundsFile{size(ConfoundsFile,1)});
        NewConfoundsFile = {strrep(ConfoundsFile{1}, 'regressors2.tsv', 'regressors3.tsv')};
        % Load confounds
        confounds      = spm_load(ConfoundsFile{1});    % Load confound file

% Determine tremor from MDS-UPDRS III
%         % UPDRS-III file
%         dClin = fullfile(ClinVars, Sub{n}, Visit{v});
%         TremorFile = cellstr(spm_select('FPList', dClin, '.*Motorische_taken_OFF.Updrs_3_deel_3.json'));
%         % Load UPDRS-III file
%         Json = fileread(TremorFile{1});
%         DecodedJson = jsondecode(Json);
%         % Determine tremor presence
%         UD = str2double(DecodedJson.crf.Up3OfRAmpArmYesDev);
%         UnD = str2double(DecodedJson.crf.Up3OfRAmpArmNonDev);
%         LD = str2double(DecodedJson.crf.Up3OfRAmpLegYesDev);
%         LnD = str2double(DecodedJson.crf.Up3OfRAmpLegNonDev);
%         J = str2double(DecodedJson.crf.Up3OfRAmpJaw);
%         TremorScores = [UD, UnD, LD, LnD, J];
%         if max(TremorScores) > 0
%             fprintf('Tremor detected for %s %s, adding to confounds file... \n', Sub{n}, Visit{v})
%             TremorPresence = true;
%         else
%             TremorPresence = false;
%         end
        
% Determine tremor presence from manual checks of prepemg output
        fid = find(contains(Tremor_check.cName,[Sub{n}, '-',Visit{v}]));    % Find subject's visit
        if(Tremor_check.cVal(fid) == 1)           % Define tremor presence
            TremorPresence = true;
            fprintf('Including %s %s : labelled as tremor \n', Sub{n}, Visit{v})
        elseif(Tremor_check.cVal(fid) == 2)
            fprintf('Skipping %s %s : labelled as uncertain \n', Sub{n}, Visit{v})
        else
            fprintf('Skipping %s %s : labelled as non-tremor \n', Sub{n}, Visit{v})
        end
        
        if istrue(TremorPresence)
            % Tremor files
            TAmp = spm_select('FPList', Prepemg, [Sub{n}, '-', Visit{v} '.*acc.*amplitude.mat']);
            TLog = spm_select('FPList', Prepemg, [Sub{n}, '-', Visit{v} '.*acc.*log.mat']);
            TPow = spm_select('FPList', Prepemg, [Sub{n}, '-', Visit{v} '.*acc.*power.mat']);
            % Load tremor files
            TAmp = load(TAmp);
            TLog = load(TLog);
            TPow = load(TPow);
            % Insert convolved tremor regressors (lin and deriv1)
            if length(confounds.dvars) ~= length(TAmp.R(:,2))
                ZerosToAdd = length(confounds.dvars) - length(TAmp.R(:,2));
            end
            confounds2 = confounds;
            confounds2.TremorAmplitude_lin = [zeros(ZerosToAdd,1); TAmp.R(:,2)];
            confounds2.TremorAmplitude_deriv1 = [zeros(ZerosToAdd,1); TAmp.R(:,4)];
            confounds2.TremorLog_lin = [zeros(ZerosToAdd,1); TLog.R(:,2)];
            confounds2.TremorLog_deriv1 = [zeros(ZerosToAdd,1); TLog.R(:,4)];
            confounds2.TremorPower_lin = [zeros(ZerosToAdd,1); TPow.R(:,2)];
            confounds2.TremorPower_deriv1 = [zeros(ZerosToAdd,1); TPow.R(:,4)];
            % Write to confounds file
            confounds2tab = struct2table(confounds2);       % Convert to table
            confounds2tab = fillmissing(confounds2tab, 'constant', 0);      % Turn NaN to 0. If you dont, writetable will save columns with NaNs as cells, and all others as doubles
            writetable(confounds2tab, NewConfoundsFile{1}, 'Delimiter', '\t', 'FileType', 'text')
        end
    end
end
end