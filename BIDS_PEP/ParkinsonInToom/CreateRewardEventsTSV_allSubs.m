%Output path, will create a folder with subjectnumber in this folder

%Do PIT
% newFilePath = fullfile("/project", "3024006.01", "bids");
% pitSubsDir = dir(fullfile("/project", "3024006.01", "bids", "sub-PIT1*"));
% pitSubs = table(string({pitSubsDir.name})', 'VariableNames', "SubjectNumber");
% rowfun(@(cSub) CreateEventsTSV("PIT", cSub, newFilePath), pitSubs, 'NumOutputs', 0);
% 
% %Do POM
newFilePath = fullfile("/project", "3022026.01", "bids2");
pomSubsDir = dir(fullfile("/project", "3022026.01", "bids2", "sub-POM*"));
pomSubs = table(string({pomSubsDir.name})', 'VariableNames', "SubjectNumber");
badPomSubs = ["sub-POM1FM1144991", "sub-POM1FM5574205", "sub-POM1FM1322695", "sub-POM1FM2212282", "sub-POM1VS3896152", "sub-POM3FM3267632", "sub-POM3FM3916756", "sub-POM3FM3951676", ...
    "sub-POM3FM4011234", "sub-POM3FM4183797", "sub-POM3FM4879287", "sub-POM3FM6305963", "sub-POM3FM6992432", "sub-POM3FM7047140", "sub-POM3FM7413218" ,...
    "sub-POM3FM7726819", "sub-POM3FM8578770", "sub-POM3FM8901683"];
pomSubs = pomSubs(~contains(pomSubs{:,:}, badPomSubs),:);
rewardPomSubs = [pomSubs, rowfun(@checkPomTask, pomSubs, 'NumOutputs', 2)];
rewardPomSubs = rewardPomSubs(rewardPomSubs.Var2, "SubjectNumber");
rowfun(@(cSub) CreateEventsTSV("POM", cSub, newFilePath), rewardPomSubs, 'NumOutputs', 0);

%SPECIAL SUBS POM
% sub-POM1FM1144991 -- Missng task scans altogether in raw -- will be done later if patient is able 
% sub-POM1FM5574205 -- Only practise, due to problem with glasses in the scanner
% sub-POM1FM1322695 -- NAMED TASK 3, MANUALLY ADDAPT THE CODE to cTaskFileEnding = "_task3_logfile.txt";
% sub-POM1FM2212282 -- NAMED TASK 2, MANUALLY ADDAPT THE CODE to cTaskFileEnding = "_task2_logfile.txt";
% sub-POM1VS3896152 -- MOTOR SUBJECTS which naming makes my scripts crash 
% sub-POM3FM3267632 -- Empty behavioural folder
% sub-POM3FM3916756 -- NO beh folder
% sub-POM3FM3951676 -- Motor sub with only practise
% sub-POM3FM4011234 -- Motor sub with only practise and some weird files
% sub-POM3FM4183797 -- Motor sub which crashed for no apparent reason 
% sub-POM3FM4879287 -- Motor sub with no beh folder
% sub-POM3FM6305963 -- REWAR SUB!!!! WITHOUT BEH FOLDER 
% sub-POM3FM6992432 -- Missing lots of files only practise
% sub-POM3FM7047140 -- No task files/scans at all 
% sub-POM3FM7413218 -- REWARD SUB!!!! WITHOUT BEH FOLDER
% sub-POM3FM7726819 -- REWARD SUB!!!! SESSION LABEL NOT ADJUSTED 
% sub-POM3FM8578770 -- Motor sub without beh folder 
% sub-POM3FM8901683 -- Not task files/scans at all 


%Single sub
% cohort = "PIT";
% cSub = "sub-PIT1MR5865428";
% CreateEventsTSV(cohort, cSub, newFilePath)
% ----
% testSub = "sub-POM1FM0416036";
% cohort = "POM";
% retrieveFiles(cohort, testSub)

% FUNCTION TO CHECK POM TASK FROM RAW
function [cFileName, isReward] = checkPomTask(cSub)
if ~(strcmp(cSub, "sub-POM1FM5013448") || strcmp(cSub, "sub-POM1VS3896152")) %motor subjects without task, should be marked as motor 
    cFileDir = dir(fullfile("/project", "3022026.01", "raw", cSub, "ses-POMVisit*", "beh", "*.log"));
%     if strcmp("sub-POM3FM3267632", cSub); keyboard(); end
    cFileName = string(extractBetween(cFileDir(end).name, "task", "_"));
    if contains(cFileName, "Reward")
        isReward = true;
    else
        isReward = false;
    end
else
    isReward = false;
    cFileName = "Motor";
end
end

% FUNCTION TO RETRIEVE RAW TABLES
function [pracTable, taskTable, mriTable, cMeta] = retrieveFiles(cohort, cSub)
%Check cohort
if strcmp(cohort, "POM")
    cPfolder = "3022026.01";
    cPracFileEnding = "_prac1_logfile.txt";
    cTaskFileEnding = "_task1_logfile.txt";
    cVisitNumber = extractBetween(cSub, "sub-POM", "FM");
elseif strcmp(cohort, "PIT")
    cPfolder = "3024006.01";
    cPracFileEnding = "_prac2_logfile.txt";
    cTaskFileEnding = "_task2_logfile.txt";
    cVisitNumber = extractBetween(cSub, "sub-PIT", "MR");

else
    error(strcat("Current cohort not recognized: ", cohort));
end


%Construct file names
cPitFolder = fullfile("/project", cPfolder, "bids", cSub, strcat("ses-", cohort, "Visit", cVisitNumber), "dwi");
cPracFile = fullfile("/project", cPfolder, "raw", cSub, strcat("ses-", cohort, "Visit", cVisitNumber), "beh", strcat(extractAfter(cSub, "sub-"), cPracFileEnding));
cTaskFile = fullfile("/project", cPfolder, "raw", cSub, strcat("ses-", cohort, "Visit", cVisitNumber), "beh", strcat(extractAfter(cSub, "sub-"), cTaskFileEnding));
mriFileDir = dir(fullfile("/project", cPfolder, "raw", cSub, strcat("ses-", cohort, "Visit", cVisitNumber), "beh", strcat(extractAfter(cSub, "sub-"), "_task*RewardTask_fmri*.log")));
cMriFile = string(fullfile(mriFileDir.folder, mriFileDir.name));

%Check if files exist
if exist(cPracFile, 'file') && exist(cTaskFile, 'file') && exist(cMriFile, 'file')
    %Definitive file names
    pracFile = cPracFile;
    taskFile= cTaskFile;
    mriFile = cMriFile;
    
    %Read tables
    pracTable = readtable(pracFile, 'TextType','string');
    taskTable = readtable(taskFile, 'TextType','string');
    mriTable = readtable(mriFile, 'Delimiter',{'\t'}, 'FileType', 'text', 'TextType','string', 'HeaderLines', 3, 'ReadVariableNames', true); %'Delimiter',{'\t'},'HeaderLines',3,'FileType','text','TextType','string');
    
elseif strcmp(cSub, "sub-POM1FM4322614") || strcmp(cSub, "sub-PIT2MR1317093") || strcmp(cSub, "sub-PIT2MR0616365") %Subjects without training
    taskFile = cTaskFile;
    mriFile = cMriFile;
    
    taskTable = readtable(taskFile, 'TextType','string');
    mriTable = readtable(mriFile, 'Delimiter',{'\t'}, 'FileType', 'text', 'TextType','string', 'HeaderLines', 3, 'ReadVariableNames', true); %'Delimiter',{'\t'},'HeaderLines',3,'FileType','text','TextType','string');
    pracTable = table();
else %Return empty tables if files are missing
    warning(strcat("!!! No raw beh file for : ", cSub));
    pracTable = table();
    taskTable= table();
    mriTable = table();
    cMeta = table();
    return
end

%Read Meta
cMeta.Hand = extractBetween(mriFile,"_fmri",".log");
StartPulseLine = textscan(fopen(taskFile), '%s','delimiter', '\n'); fclose('all');
cMeta.StartPulse = str2double(strtrim(extractBetween(string(StartPulseLine{1,1}(2)),"Pulse:","Starting")));
if strcmp(cohort, "POM")
    cMeta.group = "PD_POM";
elseif exist(cPitFolder, 'dir')
    cMeta.group = "HC_PIT";
else
    cMeta.group = "PD_PIT";
end
end

% FUNCTION TO CONVERT RAW TABLES INTO EVENTS.TSV
function CreateEventsTSV(cohort, cSub, newFilePath)
if strcmp(cohort, "POM")
    cVisitNumber = extractBetween(cSub, "sub-POM", "FM");
elseif strcmp(cohort, "PIT")
    cVisitNumber = extractBetween(cSub, "sub-PIT", "MR");
else
    error(strcat("Current cohort not recognized: ", cohort));
end

fprintf('Processing: %s\n', cSub)

newSubDir = fullfile(newFilePath,  cSub, strcat("ses-", cohort, "Visit", cVisitNumber), "beh");
if ~exist(newSubDir, 'dir'); mkdir(newSubDir); end
newFileName = fullfile(newSubDir, strcat(cSub, "_ses-", cohort, "Visit", cVisitNumber, "_task-reward_acq-ME5_run-1_events.tsv"));
newJsonFileName = strrep(newFileName, ".tsv", ".json");
trainingFileName = fullfile(newSubDir, strcat(cSub, "_ses-", cohort, "Visit", cVisitNumber, "_task-reward_acq-practice_run-1_events.tsv"));

if ~exist(newFileName, 'file')
    %Load files
    [trainingFile, customFile, standardFile, cMeta] = retrieveFiles(cohort, cSub);
    if isempty(cMeta); return; end
    
    %New Events.tsv
    numEvents = size(customFile,1)*4;
    eventsTable =  table('Size', [numEvents 12], ...
        'VariableTypes', {'double', 'double', 'string', 'string', 'string', 'string', 'string', 'string', 'string', 'string', 'string', 'string'}, ...
        'VariableNames', {'onset', 'duration', 'trial_number', 'event_type', 'trial_type', 'response_time', 'button_pressed', 'button_expected', 'correct_response', 'block', 'mis', 'outcome'});
    eventsTable.onset = NaN(numEvents, 1);
    eventsTable.duration = NaN(numEvents, 1);
    eventsTable.response_time = repmat("n/a", numEvents, 1);
    eventsTable.mis = repmat("n/a", numEvents, 1);
    eventsTable.trial_number = repmat("n/a", numEvents, 1);
    eventsTable.trial_type = repmat("n/a", numEvents, 1);
    eventsTable.block = repmat("n/a", numEvents, 1);
    eventsTable.outcome = repmat("n/a", numEvents, 1);
    eventsTable.button_pressed = repmat("n/a", numEvents, 1);
    eventsTable.button_expected = repmat("n/a", numEvents, 1);
    eventsTable.correct_response = repmat("n/a", numEvents, 1);
    
    %Loop through all trials
    cEvent = 0;
    for cTrial = 1:size(customFile,1)
        %Check if miss trial
        if customFile.Button_Time(cTrial) == 0
            cMiss = true;
        else
            cMiss = false;
        end
        
        %Loop through all events per trial
        for eventType = ["fixation", "cue", "response", "outcome"]
            switch eventType
                case "fixation"
                    cEvent=cEvent+1;
                    eventsTable{cEvent,'event_type'} = eventType;
                    eventsTable{cEvent,'onset'} = customFile.Fixation_Time(cTrial);
                    eventsTable{cEvent,'duration'} = customFile.Picture_Time(cTrial) - customFile.Fixation_Time(cTrial);
                    eventsTable{cEvent,'trial_type'} = customFile.Condition(cTrial);
                    eventsTable{cEvent,'trial_number'} = customFile.Trial_no_(cTrial);
                    eventsTable{cEvent,'block'} = customFile.Run(cTrial);
                    eventsTable{cEvent,'correct_response'} = customFile.Correct_Response(cTrial);
                    
                    %Mis dependend info
                    if cMiss
                        eventsTable{cEvent,'mis'}=1;
                    else
                        eventsTable{cEvent,'mis'}=0;
                    end
                    
                case "cue"
                    cEvent=cEvent+1;
                    eventsTable{cEvent,'event_type'} = eventType;
                    eventsTable{cEvent,'onset'} = customFile.Picture_Time(cTrial);
                    eventsTable{cEvent,'duration'} = 2916;
                    eventsTable{cEvent,'trial_type'} = customFile.Condition(cTrial);
                    eventsTable{cEvent,'block'} = customFile.Run(cTrial);
                    eventsTable{cEvent,'trial_number'} = customFile.Trial_no_(cTrial);
                    eventsTable{cEvent,'correct_response'} = customFile.Correct_Response(cTrial);
                    
                    %Mis dependend info
                    if cMiss
                        eventsTable{cEvent,'mis'}=1;
                    else
                        eventsTable{cEvent,'mis'}=0;
                    end
                    
                case "response"
                    cEvent=cEvent+1;
                    eventsTable{cEvent,'event_type'} = eventType;
                    eventsTable{cEvent,'trial_number'} = customFile.Trial_no_(cTrial);
                    eventsTable{cEvent,'trial_type'} = customFile.Condition(cTrial);
                    eventsTable{cEvent,'block'} = customFile.Run(cTrial);
                    eventsTable{cEvent,'correct_response'} = customFile.Correct_Response(cTrial);
                    
                    %Mis dependend info
                    if cMiss
                        eventsTable{cEvent,'mis'}=1;
                    else
                        eventsTable{cEvent,'onset'} = customFile.Button_Time(cTrial);
                        eventsTable{cEvent,'duration'} = customFile.Feedback_Time(cTrial) - customFile.Button_Time(cTrial);
                        eventsTable{cEvent,'response_time'} = customFile.Reaction_Time(cTrial)/1000;
                        eventsTable{cEvent,'mis'}=0;
                        eventsTable{cEvent,'button_pressed'} = customFile.Button_Pressed(cTrial);
                        eventsTable{cEvent,'button_expected'} = customFile.Button_Expected(cTrial);
                    end
                    
                case "outcome"
                    cEvent=cEvent+1;
                    eventsTable{cEvent,'trial_type'} = customFile.Condition(cTrial);
                    eventsTable{cEvent,'trial_number'} = customFile.Trial_no_(cTrial);
                    eventsTable{cEvent,'block'} = customFile.Run(cTrial);
                    eventsTable{cEvent,'correct_response'} = customFile.Correct_Response(cTrial);
                    
                    %Mis dependend info
                    if cMiss
                        eventsTable{cEvent,'mis'}=1;
                        eventsTable{cEvent,'onset'} = customFile.Picture_Time(cTrial) + 2.5;
                        if cTrial == 56 || cTrial == 112
                            eventsTable{cEvent,'duration'} = 1;
                        else
                            eventsTable{cEvent,'duration'} = customFile.Fixation_Time(cTrial+1) - eventsTable{cEvent,'onset'};
                        end
                        eventsTable{cEvent,'event_type'} = "missed";
                    else
                        eventsTable{cEvent,'onset'} = customFile.Feedback_Time(cTrial);
                        eventsTable{cEvent,'duration'} = 1000;
                        eventsTable{cEvent,'outcome'} = customFile.Magnitude(cTrial);
                        eventsTable{cEvent,'mis'}=0;
                        eventsTable{cEvent,'event_type'} = eventType;
                    end
            end
        end
    end
    
    %Standardize time (2 decimal places)
    eventsTable.onset = round(eventsTable.onset/1000,2);
    eventsTable.duration = round(eventsTable.duration/1000,2);
    eventsTable(isnan(eventsTable.onset), :) = [];
    
    %% Training file
    if ~strcmp(cSub, "sub-POM1FM4322614")
        %New Events.tsv
        numEvents = size(trainingFile,1)*4;
        trainingEventsTable =  table('Size', [numEvents 12], ...
            'VariableTypes', {'double', 'double', 'string', 'string', 'string', 'string', 'string', 'string', 'string', 'string', 'string', 'string'}, ...
            'VariableNames', {'onset', 'duration', 'trial_number', 'event_type', 'trial_type', 'response_time', 'button_pressed', 'button_expected', 'correct_response', 'block', 'mis', 'outcome'});
        trainingEventsTable.onset = NaN(numEvents, 1);
        trainingEventsTable.duration = NaN(numEvents, 1);
        trainingEventsTable.response_time = repmat("n/a", numEvents, 1);
        trainingEventsTable.mis = repmat("n/a", numEvents, 1);
        trainingEventsTable.trial_number = repmat("n/a", numEvents, 1);
        trainingEventsTable.trial_type = repmat("n/a", numEvents, 1);
        trainingEventsTable.block = repmat("n/a", numEvents, 1);
        trainingEventsTable.outcome = repmat("n/a", numEvents, 1);
        trainingEventsTable.button_pressed = repmat("n/a", numEvents, 1);
        trainingEventsTable.button_expected = repmat("n/a", numEvents, 1);
        trainingEventsTable.correct_response = repmat("n/a", numEvents, 1);
        
        %Loop through all trials
        cEvent = 0;
        for cTrial = 1:size(trainingFile,1)
            %Check if miss trial
            if trainingFile.Button_Time(cTrial) == 0
                cMiss = true;
            else
                cMiss = false;
            end
            
            %Loop through all events per trial
            for eventType = ["fixation", "cue", "response", "outcome"]
                switch eventType
                    case "fixation"
                        cEvent=cEvent+1;
                        trainingEventsTable{cEvent,'event_type'} = eventType;
                        trainingEventsTable{cEvent,'onset'} = trainingFile.Fixation_Time(cTrial);
                        trainingEventsTable{cEvent,'duration'} = trainingFile.Picture_Time(cTrial) - trainingFile.Fixation_Time(cTrial);
                        trainingEventsTable{cEvent,'trial_type'} = trainingFile.Condition(cTrial);
                        trainingEventsTable{cEvent,'trial_number'} = trainingFile.Trial_no_(cTrial);
                        trainingEventsTable{cEvent,'block'} = trainingFile.Run(cTrial);
                        trainingEventsTable{cEvent,'correct_response'} = trainingFile.Correct_Response(cTrial);
                        
                        %Mis dependend info
                        if cMiss
                            trainingEventsTable{cEvent,'mis'}=1;
                        else
                            trainingEventsTable{cEvent,'mis'}=0;
                        end
                        
                    case "cue"
                        cEvent=cEvent+1;
                        trainingEventsTable{cEvent,'event_type'} = eventType;
                        trainingEventsTable{cEvent,'onset'} = trainingFile.Picture_Time(cTrial);
                        trainingEventsTable{cEvent,'duration'} = 2916;
                        trainingEventsTable{cEvent,'trial_type'} = trainingFile.Condition(cTrial);
                        trainingEventsTable{cEvent,'block'} = trainingFile.Run(cTrial);
                        trainingEventsTable{cEvent,'trial_number'} = trainingFile.Trial_no_(cTrial);
                        trainingEventsTable{cEvent,'correct_response'} = trainingFile.Correct_Response(cTrial);
                        
                        %Mis dependend info
                        if cMiss
                            trainingEventsTable{cEvent,'mis'}=1;
                        else
                            trainingEventsTable{cEvent,'mis'}=0;
                        end
                        
                    case "response"
                        cEvent=cEvent+1;
                        trainingEventsTable{cEvent,'event_type'} = eventType;
                        trainingEventsTable{cEvent,'trial_number'} = trainingFile.Trial_no_(cTrial);
                        trainingEventsTable{cEvent,'trial_type'} = trainingFile.Condition(cTrial);
                        trainingEventsTable{cEvent,'block'} = trainingFile.Run(cTrial);
                        trainingEventsTable{cEvent,'correct_response'} = trainingFile.Correct_Response(cTrial);
                        
                        %Mis dependend info
                        if cMiss
                            trainingEventsTable{cEvent,'mis'}=1;
                        else
                            trainingEventsTable{cEvent,'onset'} = trainingFile.Button_Time(cTrial);
                            trainingEventsTable{cEvent,'duration'} = trainingFile.Feedback_Time(cTrial) - trainingFile.Button_Time(cTrial);
                            trainingEventsTable{cEvent,'response_time'} = trainingFile.Reaction_Time(cTrial)/1000;
                            trainingEventsTable{cEvent,'mis'}=0;
                            trainingEventsTable{cEvent,'button_pressed'} = trainingFile.Button_Pressed(cTrial);
                            trainingEventsTable{cEvent,'button_expected'} = trainingFile.Button_Expected(cTrial);
                        end
                        
                    case "outcome"
                        cEvent=cEvent+1;
                        trainingEventsTable{cEvent,'trial_type'} = trainingFile.Condition(cTrial);
                        trainingEventsTable{cEvent,'trial_number'} = trainingFile.Trial_no_(cTrial);
                        trainingEventsTable{cEvent,'block'} = trainingFile.Run(cTrial);
                        trainingEventsTable{cEvent,'correct_response'} = trainingFile.Correct_Response(cTrial);
                        
                        %Mis dependend info
                        if cMiss
                            trainingEventsTable{cEvent,'mis'}=1;
                            trainingEventsTable{cEvent,'onset'} = trainingFile.Picture_Time(cTrial) + 2.5;
                            
                            if cTrial == 56 || cTrial == 112
                                trainingEventsTable{cEvent,'duration'} = 1;
                            elseif cTrial == size(trainingFile,1)
                                trainingEventsTable{cEvent,'duration'} = 1;
                            else
                                trainingEventsTable{cEvent,'duration'} = trainingFile.Fixation_Time(cTrial+1) - trainingEventsTable{cEvent,'onset'};
                            end
                            trainingEventsTable{cEvent,'event_type'} = "missed";
                        else
                            trainingEventsTable{cEvent,'onset'} = trainingFile.Feedback_Time(cTrial);
                            trainingEventsTable{cEvent,'duration'} = 1000;
                            trainingEventsTable{cEvent,'outcome'} = trainingFile.Magnitude(cTrial);
                            trainingEventsTable{cEvent,'mis'}=0;
                            trainingEventsTable{cEvent,'event_type'} = eventType;
                        end
                end
            end
        end
        
        %Standardize time (2 decimal places)
        trainingEventsTable.onset = round(trainingEventsTable.onset/1000,2);
        trainingEventsTable.duration = round(trainingEventsTable.duration/1000,2);
        trainingEventsTable(isnan(trainingEventsTable.onset), :) = [];
        
        %Write table
        writetable(trainingEventsTable, trainingFileName,'Delimiter','\t', 'FileType', 'text')
    end
    
    
    %% Standard file
    standardFileTable = table('Size', [0 12], ...
        'VariableTypes', {'double', 'double', 'string', 'string', 'string', 'string', 'string', 'string', 'string', 'string', 'string', 'string'}, ...
        'VariableNames', {'onset', 'duration', 'trial_number', 'trial_type', 'event_type', 'mis', 'response_time', 'block', 'outcome', 'button_pressed', 'button_expected', 'correct_response'});
    cEvent = 0;
    for rowStandard = 1:size(standardFile,1) %MAKE ROWFUN
        switch strcat(standardFile.EventType(rowStandard), string(standardFile.Code(rowStandard)))
            case "Picture4"
                cEvent=cEvent+1;
                standardFileTable.onset(cEvent) = standardFile.Time(rowStandard);
                standardFileTable.duration(cEvent) = standardFile.Duration(rowStandard);
                standardFileTable.response_time(cEvent) = 'n/a';
                standardFileTable.trial_number(cEvent) = 'n/a';
                standardFileTable.trial_type(cEvent) = 'n/a';
                standardFileTable.mis(cEvent) = 'n/a';
                standardFileTable.block(cEvent) = 'n/a';
                standardFileTable.outcome(cEvent) = 'n/a';
                standardFileTable.button_pressed(cEvent) = 'n/a';
                standardFileTable.button_expected(cEvent) = 'n/a';
                standardFileTable.correct_response(cEvent) = 'n/a';
                standardFileTable.event_type(cEvent) = "Instructions";
                
            case "Picture5"
                cEvent=cEvent+1;
                standardFileTable.onset(cEvent) = standardFile.Time(rowStandard);
                standardFileTable.duration(cEvent) = standardFile.Duration(rowStandard);
                standardFileTable.response_time(cEvent) = 'n/a';
                standardFileTable.trial_number(cEvent) = 'n/a';
                standardFileTable.trial_type(cEvent) = 'n/a';
                standardFileTable.mis(cEvent) = 'n/a';
                standardFileTable.block(cEvent) = 'n/a';
                standardFileTable.outcome(cEvent) = 'n/a';
                standardFileTable.button_pressed(cEvent) = 'n/a';
                standardFileTable.button_expected(cEvent) = 'n/a';
                standardFileTable.correct_response(cEvent) = 'n/a';
                standardFileTable.event_type(cEvent) = "TaskStart";
                
                %             case "Picture7"
                %                 cEvent=cEvent+1;
                %                 standardFileTable.onset(cEvent) = standardFile.Time(rowStandard);
                %                 standardFileTable.duration(cEvent) = standardFile.Duration(rowStandard);
                %                 standardFileTable.event_type(cEvent) = "fixation";
                %                 standardFileTable.response_time(cEvent) = 'n/a';
                %                 standardFileTable.trial_number(cEvent) = 'n/a';
                %                 standardFileTable.trial_type(cEvent) = 'n/a';
                %                 standardFileTable.mis(cEvent) = 'n/a';
                %                 standardFileTable.block(cEvent) = 'n/a';
                %                 standardFileTable.outcome(cEvent) = 'n/a';
                %                 standardFileTable.button_pressed(cEvent) = 'n/a';
                %                 standardFileTable.button_expected(cEvent) = 'n/a';
                %                 standardFileTable.correct_response(cEvent) = 'n/a';
                %
                %             case "Picture8"
                %                 cEvent=cEvent+1;
                %                 standardFileTable.onset(cEvent) = standardFile.Time(rowStandard);
                %                 standardFileTable.duration(cEvent) = standardFile.Duration(rowStandard);
                %                 standardFileTable.event_type(cEvent) = "cue";
                %                 standardFileTable.response_time(cEvent) = 'n/a';
                %                 standardFileTable.trial_number(cEvent) = 'n/a';
                %                 standardFileTable.trial_type(cEvent) = 'n/a';
                %                 standardFileTable.mis(cEvent) = 'n/a';
                %                 standardFileTable.block(cEvent) = 'n/a';
                %                 standardFileTable.outcome(cEvent) = 'n/a';
                %                 standardFileTable.button_pressed(cEvent) = 'n/a';
                %                 standardFileTable.button_expected(cEvent) = 'n/a';
                %                 standardFileTable.correct_response(cEvent) = 'n/a';
                %
                %             case "Picture9"
                %                 cEvent=cEvent+1;
                %                 standardFileTable.onset(cEvent) = standardFile.Time(rowStandard);
                %                 standardFileTable.duration(cEvent) = standardFile.Duration(rowStandard);
                %                 standardFileTable.event_type(cEvent) = "outcome";
                %                 standardFileTable.response_time(cEvent) = 'n/a';
                %                 standardFileTable.trial_number(cEvent) = 'n/a';
                %                 standardFileTable.trial_type(cEvent) = 'n/a';
                %                 standardFileTable.mis(cEvent) = 'n/a';
                %                 standardFileTable.block(cEvent) = 'n/a';
                %                 standardFileTable.outcome(cEvent) = 'n/a';
                %                 standardFileTable.button_pressed(cEvent) = 'n/a';
                %                 standardFileTable.button_expected(cEvent) = 'n/a';
                %                 standardFileTable.correct_response(cEvent) = 'n/a';
                %
                %             case "Picture99"
                %                 cEvent=cEvent+1;
                %                 standardFileTable.onset(cEvent) = standardFile.Time(rowStandard);
                %                 standardFileTable.duration(cEvent) = standardFile.Duration(rowStandard);
                %                 standardFileTable.response_time(cEvent) = 'n/a';
                %                 standardFileTable.trial_number(cEvent) = 'n/a';
                %                 standardFileTable.trial_type(cEvent) = 'n/a';
                %                 standardFileTable.mis(cEvent) = 'n/a';
                %                 standardFileTable.block(cEvent) = 'n/a';
                %                 standardFileTable.outcome(cEvent) = 'n/a';
                %                 standardFileTable.button_pressed(cEvent) = 'n/a';
                %                 standardFileTable.button_expected(cEvent) = 'n/a';
                %                 standardFileTable.correct_response(cEvent) = 'n/a';
                %                 standardFileTable.event_type(cEvent) = "start-second-run";
                %
                %             case "Response1"
                %                 cEvent=cEvent+1;
                %                 standardFileTable.onset(cEvent) = standardFile.Time(rowStandard);
                %                 standardFileTable.duration(cEvent) = standardFile.Duration(rowStandard);
                %                 standardFileTable.event_type(cEvent) = "Press-Button-1";
                %                 standardFileTable.response_time(cEvent) = 'n/a';
                %                 standardFileTable.trial_number(cEvent) = 'n/a';
                %                 standardFileTable.trial_type(cEvent) = 'n/a';
                %                 standardFileTable.mis(cEvent) = 'n/a';
                %                 standardFileTable.block(cEvent) = 'n/a';
                %                 standardFileTable.outcome(cEvent) = 'n/a';
                %                 standardFileTable.button_pressed(cEvent) = 'n/a';
                %                 standardFileTable.button_expected(cEvent) = 'n/a';
                %                 standardFileTable.correct_response(cEvent) = 'n/a';
                %
                %             case "Response2"
                %                 cEvent=cEvent+1;
                %                 standardFileTable.onset(cEvent) = standardFile.Time(rowStandard);
                %                 standardFileTable.duration(cEvent) = standardFile.Duration(rowStandard);
                %                 standardFileTable.event_type(cEvent) = "Press-Button-2";
                %                 standardFileTable.response_time(cEvent) = 'n/a';
                %                 standardFileTable.trial_number(cEvent) = 'n/a';
                %                 standardFileTable.trial_type(cEvent) = 'n/a';
                %                 standardFileTable.mis(cEvent) = 'n/a';
                %                 standardFileTable.block(cEvent) = 'n/a';
                %                 standardFileTable.outcome(cEvent) = 'n/a';
                %                 standardFileTable.button_pressed(cEvent) = 'n/a';
                %                 standardFileTable.button_expected(cEvent) = 'n/a';
                %                 standardFileTable.correct_response(cEvent) = 'n/a';
                %
                %             case "Pulse10"
                %                 cEvent=cEvent+1;
                %                 standardFileTable.onset(cEvent) = standardFile.Time(rowStandard);
                %                 standardFileTable.duration(cEvent) = 22400;
                %                 standardFileTable.response_time(cEvent) = 'n/a';
                %                 standardFileTable.trial_number(cEvent) = 'n/a';
                %                 standardFileTable.trial_type(cEvent) = 'n/a';
                %                 standardFileTable.mis(cEvent) = 'n/a';
                %                 standardFileTable.block(cEvent) = 'n/a';
                %                 standardFileTable.outcome(cEvent) = 'n/a';
                %                 standardFileTable.button_pressed(cEvent) = 'n/a';
                %                 standardFileTable.button_expected(cEvent) = 'n/a';
                %                 standardFileTable.correct_response(cEvent) = 'n/a';
                %                 standardFileTable.event_type(cEvent) = "fmri-pulse";
                %
                %             case "Pulse99"
                %                 cEvent=cEvent+1;
                %                 standardFileTable.onset(cEvent) = standardFile.Time(rowStandard);
                %                 standardFileTable.duration(cEvent) = 22400;
                %                 standardFileTable.response_time(cEvent) = 'n/a';
                %                 standardFileTable.trial_number(cEvent) = 'n/a';
                %                 standardFileTable.trial_type(cEvent) = 'n/a';
                %                 standardFileTable.mis(cEvent) = 'n/a';
                %                 standardFileTable.block(cEvent) = 'n/a';
                %                 standardFileTable.outcome(cEvent) = 'n/a';
                %                 standardFileTable.button_pressed(cEvent) = 'n/a';
                %                 standardFileTable.button_expected(cEvent) = 'n/a';
                %                 standardFileTable.correct_response(cEvent) = 'n/a';
                %                 standardFileTable.event_type(cEvent) = "fmri-pulse";
        end
    end
    
    %Standardize time
    standardFileTable.onset = round(floor(standardFileTable.onset/10)/1000,2);
    standardFileTable.duration = round(floor(standardFileTable.duration/10)/1000,2);
    
    
    %% Add standardFileTable to customFileTable
    for cRow = 1:size(standardFileTable,1)
        cOnset = standardFileTable.onset(cRow);
        newRow = find(eventsTable.onset>=cOnset,1);
        if newRow == 1
            eventsTable = [standardFileTable(cRow,:); eventsTable];
        elseif isempty(newRow)
            eventsTable = [eventsTable; standardFileTable(cRow,:)];
        else
            eventsTable = [eventsTable(1:(newRow-1),:); standardFileTable(cRow,:); eventsTable(newRow:end,:)];
        end
    end
    
    %allign onsets to first pulse
    subtractOnset = round(floor(standardFile{find(standardFile.EventType=="Pulse",1),"Time"}/10)/1000,2);
    eventsTable.onset = eventsTable.onset-subtractOnset;
    
    %Also transfer onset and duration NaN
    %     eventsTable.onset    = string(eventsTable.onset);
    %     eventsTable.duration = string(eventsTable.duration);
    %     eventsTable.onset(ismissing(eventsTable.onset))       = 'n/a';
    %     eventsTable.duration(ismissing(eventsTable.duration)) = 'n/a';
    
    %writeTable
    writetable(eventsTable, newFileName,'Delimiter','\t', 'FileType', 'text')
    
    %%%%%%%%%%%%%%%%%%%%%%% PART 2: JSON %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Task description
    JSON.Task_description.Value = "These are the behavioural results from the probabilistic instrumental reinforcement learning task. The task is based on Pessiglione et al. 2006 (10.1038/nature05051). Participants do three blocks of the task. One training block outside the MRI scanner and two blocks inside the MRI scanner. Each block consists of 56 trials, of which 28 and GAIN trials (in which a monetary reward can be earned) and 28 LOSS trials (in which a monetary  punishment needs to be avoided). Each trial consists of 2 cue?s, a correct and incorrect visual stimuli. The stimuli are different for GAIN and LOSS, but consistent throughout a block. By trial and error participants learn which cue is correct and maximizes monetary payoff. In GAIN trials, the correct symbol reinforces ?10 in 75% of the trials and does not reinforce (?0) in 25% of the trials. In LOSS trials, the correct symbol does not reinforce (?0) in 75% of the trials and punishes -?10 in 25% trials. The probabilities are reversed if one chooses the incorrect symbol.";
    JSON.Task_description.LongName = "Task Description";
    JSON.Task_description.Description = "A general description of how the task works";
    
    %Group
    JSON.Group.Value = cMeta.group;
    JSON.Group.LongName = "Group";
    JSON.Group.Description = "Denotes the grouping of a participant";
    JSON.Group.Levels.PD_POM = "Patients from the Parkinson Op Maat study";
    JSON.Group.Levels.PD_PIT = "Patients from the Parkinson In Toom study";
    JSON.Group.Levels.HC_PIT = "Healthy Controls from the Parkinson In Toom study";
    
    %Hand used in trial
    JSON.RespondingHand.Value = cMeta.Hand;
    JSON.RespondingHand.LongName = "Responding hand";
    JSON.RespondingHand.Description = "Hand used for pressing response button. For patients, this also denotes the most affected side.";
    JSON.RespondingHand.Levels.Left = "Left hand";
    JSON.RespondingHand.Levels.Right = "Right hand";
    
    %Starting pulse
    JSON.StartPulse.Value = cMeta.StartPulse;
    JSON.StartPulse.LongName = "Starting pulse";
    JSON.StartPulse.Description = "From this pulse onwards, the task starts.";
    
    %Number of pulses
    JSON.NPulses.Value = sum(strcmp(standardFile.EventType, "Pulse"));
    JSON.NPulses.LongName = "Number of pulses";
    JSON.NPulses.Description = "Pulses recorded while Presentation is running the task. Scanning is manually stopped once the task is finished. As a result, images will usually contain more volumes than the number of pulses that are recorded by Presentation.";
    
    %IMAGE USED
    JSON.ImageBlock1.Value = customFile.StimPair(1);
    JSON.ImageBlock1.LongName = "Images used in block 1";
    JSON.ImageBlock1.Description = "Set of images depicting the cues for block 1. The number corresponds to the set of Stim*.bmp images in the PictureStimuli folder within the Presentation task folder. The Presentation scripts can be shared seperatly.";
    JSON.ImageBlock2.Value = customFile.StimPair(end);
    JSON.ImageBlock2.LongName = "Images used in block 2";
    JSON.ImageBlock2.Description = "Set of images depicting the cues for block 2. The number corresponds to the set of Stim*.bmp images in the PictureStimuli folder within the Presentation task folder. The Presentation scripts can be shared seperatly.";
    
    %Explaining the columns
    JSON.onset = struct('LongName', 'Event onset', 'Description', 'Denotes onset of a specific event relative to acquisition of first scanner pulse (T0)', 'Units', 'seconds');
    JSON.duration = struct('LongName', 'Event duration', 'Description', 'Denotes duration of a specific event', 'Units', 'seconds');
    JSON.trial_number = struct('LongName', 'Trial number', 'Description', 'Denotes trial number (1 through 112) of a specific event');
    JSON.event_type = struct('LongName', 'Event type', 'Description', 'Denotes the type of a specific event', 'Levels', struct('Instructions', 'Instructions presented at the start of the task', 'TaskStart', 'Screen which tells the participant the task is about to begin', 'fixation', 'Presentation of a fixation cross, inter-trial interval duration ranged between 0.56s and 3.92s with a mean of 1.04s', 'cue', 'Denotes presentation of cues', 'response', 'Denotes detection of a response (note: duration of response is the time the participent saw which cue was chosen)', 'outcome', 'Denotes outcome of the current trial', 'missed', 'Denotes 5 number signs (#####) to indicate that no response was given in time'));
    JSON.trial_type = struct('LongName', 'Trial type', 'Description', 'Trial types denote valence in task', 'Levels', struct('Gain', strcat('Optimal choice rewards 10 euros, non-optimal choice rewards 0 euro'), 'Loss', strcat('Optimal choice punishes 0 euro, non-optimal choice punishes -10 euros')));
    JSON.response_time = struct('LongName', 'Reaction time', 'Description', 'Denotes reaction time (i.e. Response onset - Cue onset) for a specific trial', 'Units', 'seconds');
    JSON.button_pressed = struct('LongName', 'Button pressed', 'Description', 'Button pressed in response to a specific cue', 'Levels', struct('One', 'Index finger', 'Two', 'Middle finger'));
    JSON.button_expected = struct('LongName', 'Button expected', 'Description', 'Correct button press for a specific cue', 'Levels', struct('One', 'Index finger', 'Two', 'Middle finger'));
    JSON.correct_response = struct('LongName', 'Accuracy of the response', 'Description', 'Denotes whether a response was correct or not', 'Levels', struct('Correct', 'Correct response (button_pressed matches button_expected)', 'Incorrect', 'Incorrect response (button_pressed does not match button_expected)'));
    JSON.block = struct('LongName', 'Block', 'Description', 'Denotes block of a specific event', 'Level', struct('One', 'Block number 1', 'Two', 'Block number 2'));
    JSON.mis = struct('LongName', 'Missed trial', 'Description', 'Denotes whether the participant failed to responded within 2.5s', 'Levels', struct('One','The participant was too late in answering the current trial','Zero','The participant answered the current trial on time'));
    JSON.outcome = struct('LongName', 'Outcome', 'Description', 'Denotes the reward of the trial', 'Level', struct('Ten', strcat('10 euro was rewarded'), 'Zero', 'No reward or punishment was given', 'minus_ten', strcat('-10 euro was taken as punishment')));
    
    saveJSONfile(JSON, newJsonFileName);
else
    warning(strcat(newFileName, " already exists"));
end
end