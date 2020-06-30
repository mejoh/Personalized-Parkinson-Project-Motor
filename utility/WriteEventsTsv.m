function WriteEventsTsv(project)
%% Write bids-compatible events.tsv file from motor task log files
%%% Reference for OutputFile

% Events
%instruction          
%break            
%fixation    
%cue         
%response    

% Columns
% onset   duration    trial_no    trial_type    reaction_time
% button_pressed  button_expected     correct_response   block

%%% Reference for Trials{} variable
% 1. Trial_no.  2. Task  3. Fixation_Time  4. Cue_Time  5. Response_Time 6. Reaction_Time  7. Button_Pressed  8. Button_Expected  9. Correct_Response 10. Block
%%%

%% Collect existing log files and define output .tsv file
Root = strcat('/project/', project);
RAWDir   = fullfile(Root, 'raw');
BIDSDir  = fullfile(Root, 'bids');
BIDS     = spm_BIDS(BIDSDir);

Run = {'1', '2'};       % 2 runs is the maximum at the time this is written. Check regularly whether this holds.
for r = 1:length(Run)
  Sub      = spm_BIDS(BIDS, 'subjects', 'task','motor', 'run', Run{r});
  NSub     = numel(Sub);
  fprintf('Project = %s\n', project)
  fprintf('%i subjects have run %s data. Checking for missing files...\n', NSub, Run{r})

  % Exclude participants with missing log files
  Sel = true(size(Sub));
  for n = 1:numel(Sub)
    
    if strcmp(project, '3024006.01')
        SearchPath = fullfile(RAWDir, ['sub-' Sub{n}], 'ses-mri01',  '*motor_behav');
        MotorBehavDir = dir(SearchPath);
        MotorBehavDir = fullfile(MotorBehavDir.folder, MotorBehavDir.name);
    elseif strcmp(project, '3022026.01')
        MotorBehavDir = fullfile(Root, 'DataTask');
    end
    
    CustomLog    = spm_select('FPList', MotorBehavDir, [Sub{n} '_(t|T)ask' Run{r} '_logfile\.txt$']);
	DefaultLog    = spm_select('FPList', MotorBehavDir, [Sub{n} '_(t|T)ask' Run{r} '-MotorTaskEv_.*\.log$']);
    if size(CustomLog,1) ~= 1 || size(DefaultLog,1) ~= 1
		fprintf('Skipping sub-%s with %i custom log and %i default log\n', Sub{n}, size(CustomLog,1), size(DefaultLog,1))
		Sel(n) = false;
    end
    
  end
Sub = Sub(Sel);
NSub = numel(Sub);
fprintf('%i subjects excluded\n', length(Sel) - NSub)
fprintf('%i remaining subjects have custom and default log files for run %s data\n', NSub, Run{r})

% Preallocate
CustomLogs = cell(NSub,1);
DefaultLogs = cell(NSub,1);
OutputFiles = cell(NSub,1);
JsonOutputFiles = cell(NSub,1);
Group = cell(NSub,1);
RespondingHand = cell(NSub,1);
NPulses = cell(NSub,1);
ExtCorrResp = cell(NSub,1);

% Collect log files, also determine handedness and group.
  for n = 1:NSub
    
    if strcmp(project, '3024006.01')
        SearchPath = fullfile(RAWDir, ['sub-' Sub{n}], 'ses-mri01',  '*motor_behav');
        MotorBehavDir = dir(SearchPath);
        MotorBehavDir = fullfile(MotorBehavDir.folder, MotorBehavDir.name);
    elseif strcmp(project, '3022026.01')
        MotorBehavDir = fullfile(Root, 'DataTask');
    end
    
    CustomLogs{n}    = spm_select('FPList', MotorBehavDir, [Sub{n} '_(t|T)ask' Run{r} '_logfile\.txt$']);
	DefaultLogs{n}    = spm_select('FPList', MotorBehavDir, [Sub{n} '_(t|T)ask' Run{r} '-MotorTaskEv_.*\.log$']);
    OutputFiles{n} = fullfile(BIDSDir, ['sub-' Sub{n}], 'func', ['sub-' Sub{n} '_task-motor_acq-MB6_run-' Run{r} '_events.tsv']);
    JsonOutputFiles{n} = strrep(OutputFiles{n}, '.tsv', '.json');
    
    if contains(DefaultLogs{n}, 'left')
        RespondingHand{n} = 'Left';
    else
        RespondingHand{n} = 'Right';
    end
        
    if strcmp(project, '3024006.01')  && ~exist(fullfile(BIDSDir, ['sub-' Sub{n}], 'dwi'), 'dir')
        Group{n} = 'PDoff';
    elseif strcmp(project, '3024006.01')  && exist(fullfile(BIDSDir, ['sub-' Sub{n}], 'dwi'), 'dir')
        Group{n} = 'Healthy';
    else
        Group{n} = 'PDon';
    end
    
  end

% Delete pre-existing files
  for n = 1:NSub
    if exist(OutputFiles{n}, 'file')
        delete(OutputFiles{n})
        delete(JsonOutputFiles{n})
    end
  end

% Set time scale and formatting for events.tsv
TimeScaleCust = 1e-3;							% Time unit in custom log is 1/1000 sec
TimeScaleDef = 1e-4;                            % Time unit in default log is 1/10000 sec
TR = 1;                                     % Repetition time
formatSpec = '%0.3f';                       % Number of decimals
Events = {'fixation' 'cue' 'response'};     % Stimulus events
NEvents = numel(Events);

%% Extract acquisition time of first image
  for a = 1:NSub
    
    %% Read custom log file and extract trial data
    fileID = fopen(CustomLogs{a}, 'r');
    Header = textscan(fileID, '%*s%*s%*s%f%*s%f%*s%*s%*s', 1, 'Delimiter','\t', 'ReturnOnError',false);
    NScans = Header{1};											% The experiment starts after N scans
    TScan1 = Header{2} * TimeScaleCust;								% The time of the Nth scan
    T0	   = TScan1 - (NScans - 1) * TR;                        % The time of the 1st scan
    Trials = textscan(fileID, '%f%s%f%f%f%f%f%f%s', 'Delimiter','\t', 'HeaderLines',2, 'ReturnOnError',false);
    fclose(fileID);
    NTrials = numel(Trials{1});                         % Number of trials
    
    % Calculate ratio of correct external responses to total number of trials
    ExtCorrResp{a} = length(Trials{1,1}(logical(strcmp(Trials{1,2}, 'Ext') .* strcmp(Trials{1,9}, 'Hit')))) / 60;
    
    fixation.onsets = Trials{3} * TimeScaleCust - T0;       % Onsets
    cue.onsets = Trials{4} * TimeScaleCust - T0;
    response.onsets = Trials{5} * TimeScaleCust - T0;
    
    fixation.durations = (Trials{4} - Trials{3}) * TimeScaleCust;       % Durations
    cue.durations = (Trials{5} - Trials{4}) * TimeScaleCust;
    response.durations = ([Trials{3}(2:length(fixation.onsets)); 0] - Trials{5}) * TimeScaleCust;

    response.response_time = Trials{6} * TimeScaleCust;     % Reaction_time
    
    %% Read default log file and generate pulse trigger, instruction, and rest events
    Type		= 3;									% Column number containg event type
    Code        = 4;                                    % Column number containing event code
    Time		= 5;									% Column number containg time
    fileID = fopen(DefaultLogs{a}, 'r');
    AdditionalEvents		= textscan(fileID, '%s\t%f\t%s\t%s\t%f\t%*f\t%*f\t%*f\t%*f\t%*f\t%*s\t%s\t%*f', 'HeaderLines',5, 'Delimiter','\t', 'TreatAsEmpty','NA');
    fclose(fileID);
    
    pulses.onsets = AdditionalEvents{Time}(strcmp(AdditionalEvents{Type}, 'Pulse')) * TimeScaleDef - T0;
    NPulses{a} = numel(pulses.onsets);                      % Number of pulses
    
    instructions.onsets = AdditionalEvents{1,Time}(find(ismember(AdditionalEvents{1,Code}, '5'))) * TimeScaleDef - T0;
    inbetweenblocks.onsets = AdditionalEvents{1,Time}(find(ismember(AdditionalEvents{1,Code}, '6'))) * TimeScaleDef - T0;
    rest.onsets = AdditionalEvents{1,Time}(find(ismember(AdditionalEvents{1,Code}, '7'))) * TimeScaleDef - T0;
    
    instructions.durations = inbetweenblocks.onsets(1) - instructions.onsets(1);
    inbetweenblocks.durations = {'4', '4', '4', '4', '4'};
    rest.durations = {'20', '20'};
    
    %% Write json file
    Json = struct('Group', Group{a}, 'RespondingHand', RespondingHand{a}, 'NPulses', NPulses{a}, 'ExtCorrResp', ExtCorrResp{a});
    Json.task_description = struct('LongName', 'Short description of the motor task', 'Description', 'Fixate on the cross presented in the middle of the screen. Four circles will be presented, each corresponding to a specific finger on the responding hand. Filled circles indicate correct responses. If only one circle is filled, press the corresponding response button. If multiple circles are filled, choose one and press the corresponding response button. Respond as quickly and accurately as possible.');
    Json.Group = struct('Value', Group{a}, 'LongName', 'Group', 'Description', 'Denotes the grouping of a participant', 'Levels', struct('PD_PIT', 'Patients from the Parkinson In Toom study', 'PD_POM', 'Patients from the Parkinson Op Maat study', 'HC_PIT', 'Healthy controls from the Parkinson In Toom study'));
    Json.RespondingHand = struct('Value', RespondingHand{a}, 'LongName', 'Responding hand', 'Description', 'Hand used for pressing response button. For patients, this also denotes the most affected side', 'Levels', struct('Left', 'Left hand', 'Right', 'Right hand'));
    Json.NPulses = struct('Value', NPulses{a}, 'LongName', 'Number of pulses', 'Description', 'Pulses recorded while Presentation is running the task. Scanning is manually stopped once the task is finished. As a result, images will usually contain more volumes than the number of pulses that are recorded by Presentation.');
    Json.ExtCorrResp = struct('Value', ExtCorrResp{a}, 'LongName', 'External correct responses', 'Description', 'Ratio of correct responses relative to the total number of trials registered for the external condition. Value < 0.25 Indicates pattern of random responses');
    Json.onset = struct('LongName', 'Event onset', 'Description', 'Denotes onset of a specific event relative to acquisition of first scanner pulse (T0)', 'Units', 'seconds');
    Json.duration = struct('LongName', 'Event duration', 'Description', 'Denotes duration of a specific event', 'Units', 'seconds');
    Json.trial_number = struct('LongName', 'Trial number', 'Description', 'Denotes trial number (1 through 132) of a specific event');
    Json.event_type = struct('LongName', 'Event type', 'Description', 'Denotes the type of a specific event', 'Levels', struct('Instructions', 'Instructions presented at the start of the task', 'ShortRest', '4 second presentation of a fixation cross', 'LongRest', '20 second presentation of a fixation cross', 'fixation', 'Denotes presentation of a fixation crosses between trials', 'cue', 'Denotes presentation of a cue', 'response', 'Denotes detection of a response'));
    Json.trial_type = struct('LongName', 'Trial type', 'Description', 'Trial types denote conditions in task', 'Levels', struct('Ext', 'External, one choice', 'Int2', 'Internal, two choices', 'Int3', 'Internal, three choices'));
    Json.response_time = struct('LongName', 'Response time', 'Description', 'Denotes reaction time (i.e. Response onset - Cue onset) for a specific trial', 'Units', 'seconds');
    Json.button_pressed = struct('LongName', 'Button pressed', 'Description', 'Button pressed in response to a specific cue', 'Levels', struct('Zero', 'No response detected (Miss)', 'One', 'Index finger', 'Two', 'Middle finger', 'Three', 'Ring finger', 'Four', 'Pinky finger'));
    Json.button_expected = struct('LongName', 'Button expected', 'Description', 'Correct button press(es) for a specific cue', 'Levels', struct('Zero', 'No response (only applicable for catch-trials)', 'One', 'Index finger', 'Two', 'Middle finger', 'Three', 'Ring finger', 'Four', 'Pinky finger'));
    Json.correct_response = struct('LongName', 'Accuracy of response', 'Description', 'Denotes whether a response was correct or not', 'Levels', struct('Hit', 'Correct response (button_pressed matches button_expected)', 'Incorrect', 'Incorrect response (button_pressed does not match button_expected)', 'Miss', 'No response detected when a response was required', 'FalseAlarm', 'Response detected when the correct response was to withhold a response'));
    Json.block = struct('LongName', 'Block', 'Description', 'Denotes block of a specific event', 'Level', struct('One', 'Block no. 1', 'Two', 'Block no. 2', 'Three', 'Block no. 3'));
    saveJSONfile(Json, JsonOutputFiles{a});
    
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
    block = cell(NTrials*NEvents,1);
    hand = cell(NTrials*NEvents,1);
    group = cell(NTrials*NEvents,1);

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
        
        if trial_number{Count} <= 44
            block{Count} = 1;
            block{Count+1} = 1;
            block{Count+2} = 1;
        elseif trial_number{Count} > 44 && trial_number{Count} <= 88
            block{Count} = 2;
            block{Count+1} = 2;
            block{Count+2} = 2;
        else
            block{Count} = 3;
            block{Count+1} = 3;
            block{Count+2} = 3;
        end
    
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
    
    %% Insert additional events (instructions, breaks)
    %Instructions
    for n = 1:numel(instructions.onsets)
        onset = [onset; sprintf(formatSpec, instructions.onsets(n))];
        duration = [duration; sprintf(formatSpec, instructions.durations(n))];
        trial_number = [trial_number; 'n/a'];
        event_type = [event_type; 'Instructions'];
        trial_type = [trial_type; 'n/a'];
        response_time = [response_time; 'n/a'];
        button_pressed = [button_pressed; 'n/a'];
        button_expected = [button_expected; 'n/a'];
        correct_response = [correct_response; 'n/a'];
        block = [block; 'n/a'];
        hand = [hand; 'n/a'];
        group = [group; 'n/a'];
    end
    
    %In-between-blocks cues
    for n = 1:numel(inbetweenblocks.onsets)
        onset = [onset; sprintf(formatSpec, inbetweenblocks.onsets(n))];
        duration = [duration; inbetweenblocks.durations{n}];
        trial_number = [trial_number; 'n/a'];
        event_type = [event_type; 'ShortRest'];
        trial_type = [trial_type; 'n/a'];
        response_time = [response_time; 'n/a'];
        button_pressed = [button_pressed; 'n/a'];
        button_expected = [button_expected; 'n/a'];
        correct_response = [correct_response; 'n/a'];
        block = [block; 'n/a'];
        hand = [hand; 'n/a'];
        group = [group; 'n/a'];
    end
    
    %Rest fixation
    for n = 1:numel(rest.onsets)
        onset = [onset; sprintf(formatSpec, rest.onsets(n))];
        duration = [duration; rest.durations{n}];
        trial_number = [trial_number; 'n/a'];
        event_type = [event_type; 'LongRest'];
        trial_type = [trial_type; 'n/a'];
        response_time = [response_time; 'n/a'];
        button_pressed = [button_pressed; 'n/a'];
        button_expected = [button_expected; 'n/a'];
        correct_response = [correct_response; 'n/a'];
        block = [block; 'n/a'];
        hand = [hand; 'n/a'];
        group = [group; 'n/a'];
    end
    
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
    block = block(idx);

    %% Write table
    T = table(onset, duration, trial_number, event_type, trial_type, response_time, button_pressed, button_expected, correct_response, block);
    
    
    writetable(T, OutputFiles{a}, 'Delimiter', '\t', 'FileType', 'text')
    
  end

end

end

