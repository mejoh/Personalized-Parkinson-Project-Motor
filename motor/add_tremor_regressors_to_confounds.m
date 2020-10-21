% Run 
% Adds tremor regressors to fmriprep confounds file
function add_tremor_regressors_to_confounds()

Project = '3022026.01';
fprintf('Processing data in project: %s\n', Project)
Root = strcat('/project/', Project, '/pep');
BIDSDir  = fullfile(Root, 'bids');
FMRIPrep = fullfile(BIDSDir, 'derivatives/fmriprep');
ClinVars = fullfile(Root, 'ClinVars');
Prepemg = '/project/3022026.01/analyses/EMG/motor/processing/prepemg/Regressors/ZSCORED';

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
        % UPDRS-III tremor assessment
        dClin = fullfile(ClinVars, Sub{n}, Visit{v});
        TremorFile = cellstr(spm_select('FPList', dClin, '.*Motorische_taken_OFF.Updrs_3_deel_3.json'));
        % Prepemg output
        TAmp = spm_select('FPList', Prepemg, [Sub{n}, '-', Visit{v} '.*acc.*amplitude.mat']);
        TLog = spm_select('FPList', Prepemg, [Sub{n}, '-', Visit{v} '.*acc.*log.mat']);
        TPow = spm_select('FPList', Prepemg, [Sub{n}, '-', Visit{v} '.*acc.*power.mat']);
        
        % Exclude participants
        if isempty(ConfoundsFile{1})
            fprintf('Excluding %s:  %s lacks edited fmriprep confound regressors \n', Sub{n}, Visit{v})
            Sel(n) = false;
        end
        if isempty(TremorFile{1})
            fprintf('Excluding %s: %s lacks clinical tremor measurement \n', Sub{n}, Visit{v})
            Sel(n) = false;
        end
        if isempty(TAmp) || isempty(TLog) || isempty(TPow)
            fprintf('Excluding %s: %s lacks accelerometer tremor measurement \n', Sub{n}, Visit{v})
            Sel(n) = false;
        end
        
    end
end
Sub = Sub(Sel);
NrSub = numel(Sub);
fprintf('%i participants included for further processing \n', NrSub)

% Re-label AROMA components based on correlation with task regressors
for n = 1:NrSub
    Visit = cellstr(spm_select('List', fullfile(BIDSDir, Sub{n}), 'dir', 'ses-Visit[0-9]'));
    for v = 1:numel(Visit)
        
        % Confounds file
        dFunc = fullfile(FMRIPrep, Sub{n}, Visit{v}, 'func');
        ConfoundsFile = cellstr(spm_select('FPList', dFunc, [Sub{n}, '.*task-motor_acq-MB6_run-', '.*_desc-confounds_regressors2.tsv']));
        ConfoundsFile = cellstr(ConfoundsFile{size(ConfoundsFile,1)});
        % Load confounds
        confounds      = spm_load(ConfoundsFile{1});    % Load confound file
        
        % UPDRS-III file
        dClin = fullfile(ClinVars, Sub{n}, Visit{v});
        TremorFile = cellstr(spm_select('FPList', dClin, '.*Motorische_taken_OFF.Updrs_3_deel_3.json'));
        % Load UPDRS-III file
        Json = fileread(TremorFile{1});
        DecodedJson = jsondecode(Json);
        
        % Determine tremor presence
        UD = str2double(DecodedJson.crf.Up3OfRAmpArmYesDev);
        UnD = str2double(DecodedJson.crf.Up3OfRAmpArmNonDev);
        LD = str2double(DecodedJson.crf.Up3OfRAmpLegYesDev);
        LnD = str2double(DecodedJson.crf.Up3OfRAmpLegNonDev);
        J = str2double(DecodedJson.crf.Up3OfRAmpJaw);
        TremorScores = [UD, UnD, LD, LnD, J];
        if max(TremorScores) > 0
            fprintf('Tremor detected for %s %s, adding to confounds file... \n', Sub{n}, Visit{v})
            TremorPresence = true;
        else
            TremorPresence = false;
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
            writetable(struct2table(confounds2), ConfoundsFile{1}, 'Delimiter', '\t', 'FileType', 'text')
        end
    end
end
end