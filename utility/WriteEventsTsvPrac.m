%% Write bids-compatible events.tsv file from motor task log files

%% Collect existing log files and define output .tsv file
project = '3024006.01';
visit = 'ses-PITVisit2';
% project = '3022026.01';
% visit = 'ses-POMVisit3';
Root = strcat('/project/', project);
RAWDir   = fullfile(Root, 'raw');
BIDSDir  = fullfile(Root, 'bids');
Sub = cellstr(spm_select('List', fullfile(BIDSDir), 'dir', '^sub-PIT2MR.*'));
% BIDS     = spm_BIDS(BIDSDir);

  % Exclude participants with missing log files
Sel = true(size(Sub));
for n = 1:numel(Sub)
    
    s = char(extractAfter(Sub{n}, 'sub-'));
%     MotorBehavDir = dir(fullfile(RAWDir, ['sub-' s], visit,  '*motor_behav'));
    MotorBehavDir = dir(fullfile(RAWDir, ['sub-' s], visit,  '*beh*'));
    if length(MotorBehavDir) > 1
        fprintf('%s Located multiple motor behavior dirs, selecting last one...\n', Sub{n})
        MotorBehavDir = MotorBehavDir(length(MotorBehavDir));
    elseif length(MotorBehavDir) < 1
        Sel(n) = false;
        continue
    end
    
    PracLog    = spm_select('FPList', fullfile(MotorBehavDir.folder, MotorBehavDir.name), [s '_(p|P)rac1_logfile\.txt$']);
    if size(PracLog,1) ~= 1
		Sel(n) = false;
    end
    
end

Sub = Sub(Sel);
NSub = numel(Sub);
fprintf('%i subjects excluded\n', length(Sel) - NSub)

% Preallocate
PracLog = cell(NSub,1);
OutputFiles = cell(NSub,1);

% Collect log files, also determine handedness and group.
for n = 1:NSub
    
    s = char(extractAfter(Sub{n}, 'sub-'));
%     MotorBehavDir = dir(fullfile(RAWDir, ['sub-' s], visit,  '*motor_behav'));
    MotorBehavDir = dir(fullfile(RAWDir, ['sub-' s], visit,  '*beh*'));
    if length(MotorBehavDir) > 1
        fprintf('%s Located multiple motor behavior dirs, selecting last one...\n', Sub{n})
        MotorBehavDir = MotorBehavDir(length(MotorBehavDir));
    end
    
    PracLog{n}    = spm_select('FPList', fullfile(MotorBehavDir.folder, MotorBehavDir.name), [s '_(p|P)rac1_logfile\.txt$']);
    OutputFiles{n} = fullfile(BIDSDir, ['sub-' s], visit, 'beh', ['sub-' s '_' visit '_task-motor_acq-practice_run-1_events.tsv']);
  
end

% Delete pre-existing files
for n = 1:NSub
    if ~exist(fileparts(OutputFiles{n}), 'dir')
        mkdir(fileparts(OutputFiles{n}))
    end
    
    if exist(OutputFiles{n}, 'file')
        delete(OutputFiles{n})
    end
end

% Set time scale and formatting for events.tsv
TimeScaleCust = 1e-3;							% Time unit in custom log is 1/1000 sec
TR = 1;                                     % Repetition time
formatSpec = '%0.3f';                       % Number of decimals
Events = {'fixation' 'cue' 'response'};     % Stimulus events
NEvents = numel(Events);

%% Extract acquisition time of first image
for a = 1:NSub

    %% Read custom log file and extract trial data
    fileID = fopen(PracLog{a}, 'r');
    Trials = textscan(fileID, '%f%s%f%f%f%f%f%f%s', 'Delimiter','\t', 'HeaderLines',2, 'ReturnOnError',false);
    fclose(fileID);
    NTrials = numel(Trials{1});                         % Number of trials
    
    fixation.onsets = Trials{3} * TimeScaleCust;       % Onsets
    if isempty(fixation.onsets)             % Pass logfiles that are empty
        continue
    end
    fixation.onsets = fixation.onsets;
    cue.onsets = Trials{4} * TimeScaleCust;
    response.onsets = Trials{5} * TimeScaleCust;
    
    fixation.durations = (Trials{4} - Trials{3}) * TimeScaleCust;       % Durations
    cue.durations = (Trials{5} - Trials{4}) * TimeScaleCust;
    response.durations = ([Trials{3}(2:length(fixation.onsets)); 0] - Trials{5}) * TimeScaleCust;

    response.response_time = Trials{6} * TimeScaleCust;     % Reaction_time
    
 %% Separate trials into separate 'Fixation', 'Cue', and 'Response' events, follows reference above
    onset = cell(NTrials*NEvents,1);                   % Preallocate
    duration = cell(NTrials*NEvents,1);
    trial_number = cell(NTrials*NEvents,1);
    event_type = cell(NTrials*NEvents,1);
    trial_type = cell(NTrials*NEvents,1);
    response_time = cell(NTrials*NEvents,1); 
    button_pressed = cell(NTrials*NEvents,1);
    button_expected = cell(NTrials*NEvents,1);
    correct_response = cell(NTrials*NEvents,1);

    Count = 1;
    for i = 1:NTrials
        onset{Count} = sprintf(formatSpec, fixation.onsets(i));
        onset{Count+1} = sprintf(formatSpec, cue.onsets(i));
        onset{Count+2} = sprintf(formatSpec, response.onsets(i));
    
        duration{Count,:} = sprintf(formatSpec, fixation.durations(i));
        duration{Count+1} = sprintf(formatSpec, cue.durations(i));
        duration{Count+2} = sprintf(formatSpec, response.durations(i));
    
        trial_number{Count} = Trials{1}(i);
        trial_number{Count+1} = Trials{1}(i);
        trial_number{Count+2} = Trials{1}(i);
    
        event_type{Count} = Events{1};
        event_type{Count+1} = Events{2};
        event_type{Count+2} = Events{3};
    
        trial_type{Count} = Trials{2}{i};
        trial_type{Count+1} = Trials{2}{i};
        trial_type{Count+2} = Trials{2}{i};
    
        response_time{Count} = 'n/a';
        response_time{Count+1} = 'n/a';
        response_time{Count+2} = sprintf(formatSpec, response.response_time(i));
    
        button_pressed{Count} = 'n/a';
        button_pressed{Count+1} = 'n/a';
        button_pressed{Count+2} = Trials{7}(i);
    
        button_expected{Count} = 'n/a';
        button_expected{Count+1} = 'n/a';
        button_expected{Count+2} = Trials{8}(i);
    
        correct_response{Count} = Trials{9}{i};
        correct_response{Count+1} = Trials{9}{i};
        correct_response{Count+2} = Trials{9}{i};
        
        Count = Count+3;
    end
    
    %% Certain timings need to be adjusted
    for n = 1:NTrials*NEvents       % Catch trials where correct_response = 'Hit'
        if strcmp(event_type{n}, 'cue') && strcmp(trial_type{n}, 'Catch') && strcmp(correct_response{n+1}, 'Hit')
            duration{n} = 2.000;       % Cue duration to max
        end
        if strcmp(event_type{n}, 'response') && strcmp(trial_type{n}, 'Catch') && strcmp(correct_response{n}, 'Hit')
            onset{n} = sprintf(formatSpec, str2double(onset{n - 1}) + 1); % NOTE! Temporary assignment of onset to enable sorting. Should actually be n/a.
            duration{n} = 'n/a';
            response_time{n} = 'n/a';
        end
    end
    for n = 1:NTrials*NEvents       % Ext trials where button_pressed == 0 (Misses incorrectly labeled as Incorrect)
        if strcmp(event_type{n}, 'response') && strcmp(trial_type{n}, 'Ext') && (button_pressed{n} == 0)
            correct_response{n-2} = 'Miss';     % Correct response is changed to miss for fixation, cue, and response
            correct_response{n-1} = 'Miss';
            correct_response{n} = 'Miss';
            duration{n-1} = '2';     % Cue duration to max
            onset{n} = sprintf(formatSpec, str2double(onset{n - 1}) + 1); % NOTE! Temporary assignment of onset to enable sorting. Should actually be n/a.
            duration{n} = 'n/a';
        elseif strcmp(event_type{n}, 'response') && strcmp(trial_type{n}, 'Ext') && strcmp(correct_response{n}, 'Miss') % Just in case...
            duration{n-1} = '2';     % Cue duration to max
            onset{n} = sprintf(formatSpec, str2double(onset{n - 1}) + 1); % NOTE! Temporary assignment of onset to enable sorting. Should actually be n/a.
            duration{n} = 'n/a';
        end
    end
    for n = 1:NTrials*NEvents       % Int2/3 trials where correct_response == 'Miss'
        if strcmp(event_type{n}, 'response') && (strcmp(trial_type{n}, 'Int2') || strcmp(trial_type{n}, 'Int3')) && strcmp(correct_response{n}, 'Miss')
            duration{n-1} = '2';     % Cue duration to max
            onset{n} = sprintf(formatSpec, str2double(onset{n - 1}) + 1); % NOTE! Temporary assignment of onset to enable sorting. Should actually be n/a.
            duration{n} = 'n/a';
        end
    end
    duration{NTrials*NEvents} = 0;     % Fix last response duration (task ends after last response)
    
    %% Sort
    [E, idx] = sortrows(cellfun(@str2double,onset), 'ascend');  % Generate sorting index 'idx'
    
    for n = 1:NTrials*NEvents       % Remove temporary onset-values after sorting is done
        if strcmp(event_type{n}, 'response') && strcmp(trial_type{n}, 'Catch') && strcmp(correct_response{n}, 'Hit')
            onset{n} = 'n/a';
        end
        if strcmp(event_type{n}, 'response') && (strcmp(trial_type{n}, 'Ext') || strcmp(trial_type{n}, 'Int2') || strcmp(trial_type{n}, 'Int3')) && strcmp(correct_response{n}, 'Miss')
            onset{n} = 'n/a';
        end
    end
    
    onset = onset(idx);         % Apply sorting index to all variables
    duration = duration(idx);
    trial_number = trial_number(idx);
    event_type = event_type(idx);
    trial_type = trial_type(idx);
    response_time = response_time(idx);
    button_pressed = button_pressed(idx);
    button_expected = button_expected(idx);
    correct_response = correct_response(idx);
    
    % Remove Catch Hit Resposnes with n/a onset. Probably not compatible
    % with BIDS
    EventsToKeep = ~strcmp(onset, 'n/a');
    
    onset = onset(EventsToKeep);         % Filter out n/a onset events
    duration = duration(EventsToKeep);
    trial_number = trial_number(EventsToKeep);
    event_type = event_type(EventsToKeep);
    trial_type = trial_type(EventsToKeep);
    response_time = response_time(EventsToKeep);
    button_pressed = button_pressed(EventsToKeep);
    button_expected = button_expected(EventsToKeep);
    correct_response = correct_response(EventsToKeep);

    %% Write table
    T = table(onset, duration, trial_number, event_type, trial_type, response_time, button_pressed, button_expected, correct_response);
    
    
    writetable(T, OutputFiles{a}, 'Delimiter', '\t', 'FileType', 'text')
    
end