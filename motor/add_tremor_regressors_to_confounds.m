% Run after AROMA confounds have been added (otherwise there wont be a regressors2.tsv file
% Adds tremor regressors to fmriprep confounds file
function add_tremor_regressors_to_confounds()

session = 'ses-POMVisit1';
BIDSDir  = '/project/3022026.01/pep/bids';
FMRIPrep = fullfile(BIDSDir, 'derivatives/fmriprep');
EMGDir = '/project/3024006.02/Analyses/EMG/motor';
% EMGDir = '/project/3024006.02/Analyses/EMG/motor_PIT';
Prepemg = fullfile(EMGDir, 'processing/prepemg/Regressors/ZSCORED');
Automaticdir = fullfile(EMGDir, 'automaticdir');

% Peak_Check = fullfile(EMGDir, 'manually_checked/Martin/Peak_check-24-Mar-2021.mat');        %POM
% Peak_Check = fullfile(EMGDir, 'manually_checked/Martin/Peak_check-14-Apr-2021.mat');       %PIT
% load(Peak_Check, 'Peak_check');
% Tremor_Check = fullfile(EMGDir, 'manually_checked/Martin/Tremor_check-24-Mar-2021.mat');    %POM
% Tremor_Check = fullfile(EMGDir, 'manually_checked/Martin/Tremor_check-14-Apr-2021.mat');  %PIT
% load(Tremor_Check, 'Tremor_check');

Peak_Check = fullfile(EMGDir, 'manually_checked/Martin/Peak_check-24-Mar-2021_and_13-Jun-2022.csv'); 
Peak_check = readtable(Peak_Check, 'Format','auto','Delimiter',',');
Tremor_Check = fullfile(EMGDir, 'manually_checked/Martin/Tremor_check-24-Mar-2021_and_13-Jun-2022.csv');  
Tremor_check = readtable(Tremor_Check, 'Format','auto','Delimiter',',');

Sub = cellstr(spm_select('List', fullfile(BIDSDir), 'dir', '^sub-POM.*'));

% Select subject by session
Sel = true(size(Sub,1),1);
for n = 1:numel(Sub)
    checkfile = spm_select('FPList', fullfile(FMRIPrep, Sub{n}), 'dir', session);
    if isempty(checkfile)
        Sel(n) = false;
    end
end
Sub = Sub(Sel);

% Exclude subjects
Sel = true(size(Sub,1),1);
for n = 1:numel(Sub)
    Visit = cellstr(spm_select('List', fullfile(BIDSDir, Sub{n}), 'dir', session));
    for v = 1:numel(Visit)
        
        s = Sub{n};
        % Confounds file
        t = char(Visit);
        dFunc = fullfile(FMRIPrep, s, t, 'func');
        ConfoundsFile = cellstr(spm_select('FPList', dFunc, [s, '.*task-motor_acq-MB6_run-', '.*_desc-confounds_timeseries2.tsv']));
        ConfoundsFile = cellstr(ConfoundsFile{size(ConfoundsFile,1)});
     
%         if(~contains(t, 'PIT'))
%             t = eraseBetween(Visit{v}, 'ses-','Visit');
%         end
        % FIX: Visit1 and Visit3 were done at different times with different
        % structures
        if contains(t, 'POMVisit1')
            t = strrep(t,'POM','');
        end
        % Automaticdir
        AutoClassed = spm_select('FPList', Automaticdir, [s, '-', t, '-motor-selected-acc.*.jpg']);
        % Prepemg output
        TAmp = spm_select('FPList', Prepemg, [s, '-', t, '.*acc.*amplitude.mat']);
        TLog = spm_select('FPList', Prepemg, [s, '-', t, '.*acc.*log.mat']);
        TPow = spm_select('FPList', Prepemg, [s, '-', t, '.*acc.*power.mat']);
        
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
        fid1 = find(contains(Tremor_check.cName,[s '-' t]));    % Find subject's visit
        fid2 = find(contains(Peak_check.cName,[s '-' t]));
        if ~isempty(fid1) && ~isempty(fid2) && (Tremor_check.cVal(fid1) == 1) && (Peak_check.cVal(fid2) == 1)          % Define tremor presence
            Sel(n) = true;
            fprintf('Including %s %s : labelled as tremor \n', s, t)
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
        
        s = Sub{n};
        % Confounds file
        t = char(Visit);
        dFunc = fullfile(FMRIPrep, s, t, 'func');
        ConfoundsFile = cellstr(spm_select('FPList', dFunc, [s, '.*task-motor_acq-MB6_run-', '.*_desc-confounds_timeseries2.tsv']));
        ConfoundsFile = cellstr(ConfoundsFile{size(ConfoundsFile,1)});
        if isempty(ConfoundsFile{1})
            break
        end
        NewConfoundsFile = {strrep(ConfoundsFile{1}, 'timeseries2.tsv', 'timeseries3.tsv')};
        % Load confounds
        confounds      = spm_load(ConfoundsFile{1});    % Load confound file
        
        % Tremor files
%         if(~contains(t, 'PIT'))
%             t = eraseBetween(Visit{v}, 'ses-','Visit');
%         end
        TAmp = spm_select('FPList', Prepemg, [s, '-', t '.*acc.*amplitude.mat']);
        TLog = spm_select('FPList', Prepemg, [s, '-', t '.*acc.*log.mat']);
        TPow = spm_select('FPList', Prepemg, [s, '-', t '.*acc.*power.mat']);
        % Load tremor files
        TAmp = load(TAmp);
        TLog = load(TLog);
        TPow = load(TPow);
        % EMG data typically have a different length than the confound ts
        % because 'prepemg' removes a certain number of 'dummy'-timepoints
        % from the data. I have set this number to 5. This means that EMG
        % data usually have fewer timepoints than the confound ts. If the
        % number of timepoints in the EMG data exceed the number found in
        % the confound ts, then something has gone wrong.
        if length(confounds.dvars) ~= length(TAmp.R(:,2))
            ZerosToAdd = length(confounds.dvars) - length(TAmp.R(:,2));
            if ZerosToAdd < 0
                fprintf('Skipping %s: EMG data is longer than confound timeseries by %i timepoints \n', s, ZerosToAdd)
                break
            end
        end
        % Insert convolved tremor regressors (lin and deriv1)
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