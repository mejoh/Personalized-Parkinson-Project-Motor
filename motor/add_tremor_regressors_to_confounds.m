% Run after AROMA confounds have been added (otherwise there wont be a regressors2.tsv file
% Adds tremor regressors to fmriprep confounds file
function add_tremor_regressors_to_confounds()

session = 'ses-POMVisit1';
BIDSDir  = '/project/3022026.01/pep/bids';
FMRIPrep = fullfile(BIDSDir, 'derivatives/fmriprep');
% ClinVars = fullfile(Root, 'ClinVars');
EMGDir = '/project/3024006.02/Analyses/EMG/motor';
Prepemg = fullfile(EMGDir, 'processing/prepemg/Regressors/ZSCORED');
Automaticdir = fullfile(EMGDir, 'automaticdir');
Peak_Check = fullfile(EMGDir, 'manually_checked/Martin/Peak_check-24-Mar-2021.mat');
load(Peak_Check, 'Peak_check');
Tremor_Check = fullfile(EMGDir, 'manually_checked/Martin/Tremor_check-24-Mar-2021.mat');
load(Tremor_Check, 'Tremor_check');
Sub = cellstr(spm_select('List', fullfile(BIDSDir), 'dir', '^sub-POM.*'));

% Exclude subjects
Sel = true(size(Sub,1),1);
for n = 1:numel(Sub)
    Visit = cellstr(spm_select('List', fullfile(BIDSDir, Sub{n}), 'dir', session));
    for v = 1:numel(Visit)
        
        t = eraseBetween(Visit{v}, 'ses-','Visit');
        % Confounds file
        dFunc = fullfile(FMRIPrep, Sub{n}, Visit{v}, 'func');
        ConfoundsFile = cellstr(spm_select('FPList', dFunc, [Sub{n}, '.*task-motor_acq-MB6_run-', '.*_desc-confounds_timeseries2.tsv']));
        ConfoundsFile = cellstr(ConfoundsFile{size(ConfoundsFile,1)});
        % Automaticdir
        AutoClassed = spm_select('FPList', Automaticdir, [Sub{n}, '-', t, '-motor-selected-acc.*.jpg']);
        % Prepemg output
        TAmp = spm_select('FPList', Prepemg, [Sub{n}, '-', t, '.*acc.*amplitude.mat']);
        TLog = spm_select('FPList', Prepemg, [Sub{n}, '-', t, '.*acc.*log.mat']);
        TPow = spm_select('FPList', Prepemg, [Sub{n}, '-', t, '.*acc.*power.mat']);
        
        % Exclude participants
        if isempty(ConfoundsFile{1})
%             fprintf('Excluding %s:  %s lacks edited fmriprep confound regressors \n', Sub{n}, Visit{v})
            Sel(n) = false;
        end
        if isempty(AutoClassed)
%              fprintf('Excluding %s: %s lacks automatic classification of tremor \n', Sub{n}, Visit{v})
             Sel(n) = false;    
        end
        if isempty(TAmp) || isempty(TLog) || isempty(TPow)
%             fprintf('Excluding %s: %s lacks accelerometer tremor regressor \n', Sub{n}, Visit{v})
            Sel(n) = false;
        end
        
        % Determine tremor presence from manual checks of prepemg output
        fid1 = find(contains(Tremor_check.cName,[Sub{n}, '-',t]));    % Find subject's visit
        fid2 = find(contains(Peak_check.cName,[Sub{n}, '-',t]));
        if ~isempty(fid1) && ~isempty(fid2) && (Tremor_check.cVal(fid1) == 1) && (Peak_check.cVal(fid2) == 1)          % Define tremor presence
            Sel(n) = true;
            fprintf('Including %s %s : labelled as tremor \n', Sub{n}, Visit{v})
        else
            Sel(n) = false;
        end
        
    end
end
Sub = Sub(Sel);
NrSub = numel(Sub);
fprintf('%i participants included for further processing \n', NrSub)

% Add tremor regressor to confounds
for n = 1:NrSub
    Visit = cellstr(spm_select('List', fullfile(BIDSDir, Sub{n}), 'dir', session));
    for v = 1:numel(Visit)
        
        t = eraseBetween(Visit{v}, 'ses-','Visit');
        % Confounds file
        dFunc = fullfile(FMRIPrep, Sub{n}, Visit{v}, 'func');
        ConfoundsFile = cellstr(spm_select('FPList', dFunc, [Sub{n}, '.*task-motor_acq-MB6_run-', '.*_desc-confounds_timeseries2.tsv']));
        ConfoundsFile = cellstr(ConfoundsFile{size(ConfoundsFile,1)});
        if isempty(ConfoundsFile{1})
            break
        end
        NewConfoundsFile = {strrep(ConfoundsFile{1}, 'timeseries2.tsv', 'timeseries3.tsv')};
        % Load confounds
        confounds      = spm_load(ConfoundsFile{1});    % Load confound file
        
        % Tremor files
        TAmp = spm_select('FPList', Prepemg, [Sub{n}, '-', t '.*acc.*amplitude.mat']);
        TLog = spm_select('FPList', Prepemg, [Sub{n}, '-', t '.*acc.*log.mat']);
        TPow = spm_select('FPList', Prepemg, [Sub{n}, '-', t '.*acc.*power.mat']);
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